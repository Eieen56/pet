import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petreminder_user/core/errors/feeding_history_failure.dart';
import 'package:petreminder_user/models/feeding_record.dart';
import 'package:petreminder_user/models/pet.dart';

class FeedingHistoryRepository {
  FeedingHistoryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<FeedingRecord>> watchHistory(String userId) {
    return _history(userId).snapshots().map((snapshot) {
      final records = snapshot.docs.map(FeedingRecord.fromDocument).toList();
      records.sort((a, b) {
        final dateComparison = b.dateKey.compareTo(a.dateKey);
        return dateComparison != 0
            ? dateComparison
            : b.scheduledTime.compareTo(a.scheduledTime);
      });
      return records;
    });
  }

  Future<void> ensureTodayForPet(String userId, Pet pet) async {
    try {
      final schedules = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(pet.id)
          .collection('feedingSchedules')
          .where('active', isEqualTo: true)
          .get();
      if (schedules.docs.isEmpty) {
        return;
      }

      final now = DateTime.now();
      final dateKey = FeedingRecord.dateKeyFor(now);
      final history = _history(userId);
      final existing = await history.where('dateKey', isEqualTo: dateKey).get();
      final existingById = {
        for (final document in existing.docs) document.id: document,
      };
      final batch = _firestore.batch();
      var hasWrites = false;

      for (final schedule in schedules.docs) {
        final data = schedule.data();
        final id = FeedingRecord.documentId(
          petId: pet.id,
          scheduleId: schedule.id,
          date: now,
        );
        final existingRecord = existingById[id];
        if (existingRecord != null) {
          final existingData = existingRecord.data();
          final scheduledTime = data['time'] as String? ?? '00:00';
          if (existingData['status'] == 'pending' &&
              existingData['scheduledTime'] != scheduledTime) {
            batch.update(existingRecord.reference, {
              'scheduledTime': scheduledTime,
            });
            hasWrites = true;
          }
          continue;
        }
        batch.set(history.doc(id), {
          'id': id,
          'userId': userId,
          'petId': pet.id,
          'petName': pet.name,
          'scheduleId': schedule.id,
          'scheduledTime': data['time'] as String? ?? '00:00',
          'dateKey': dateKey,
          'status': 'pending',
          'fedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        hasWrites = true;
      }

      if (hasWrites) {
        await batch.commit();
      }
    } on FirebaseException catch (exception) {
      throw FeedingHistoryFailure.fromFirebase(exception);
    }
  }

  Future<void> ensureTodayForAllPets(String userId) async {
    try {
      final pets = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .get();
      for (final document in pets.docs) {
        await ensureTodayForPet(userId, Pet.fromDocument(document));
      }
    } on FirebaseException catch (exception) {
      throw FeedingHistoryFailure.fromFirebase(exception);
    }
  }

  Future<void> markAsFed({
    required String userId,
    required Pet pet,
    required String scheduleId,
    required String scheduledTime,
  }) async {
    final now = DateTime.now();
    final dateKey = FeedingRecord.dateKeyFor(now);
    final id = FeedingRecord.documentId(
      petId: pet.id,
      scheduleId: scheduleId,
      date: now,
    );
    final reference = _history(userId).doc(id);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        if (snapshot.exists && snapshot.data()?['status'] == 'fed') {
          return;
        }
        if (snapshot.exists) {
          transaction.update(reference, {
            'status': 'fed',
            'fedAt': FieldValue.serverTimestamp(),
          });
          return;
        }
        transaction.set(reference, {
          'id': id,
          'userId': userId,
          'petId': pet.id,
          'petName': pet.name,
          'scheduleId': scheduleId,
          'scheduledTime': scheduledTime,
          'dateKey': dateKey,
          'status': 'fed',
          'fedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (exception) {
      throw FeedingHistoryFailure.fromFirebase(exception);
    }
  }

  CollectionReference<Map<String, dynamic>> _history(String userId) =>
      _firestore.collection('users').doc(userId).collection('feedingHistory');
}
