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
      for (final schedule in schedules.docs) {
        final id = FeedingRecord.documentId(
          petId: pet.id,
          scheduleId: schedule.id,
          date: now,
        );
        final reference = _history(userId).doc(id);
        await _firestore.runTransaction((transaction) async {
          final currentPet = await transaction.get(
            schedule.reference.parent.parent!,
          );
          final currentSchedule = await transaction.get(schedule.reference);
          final existing = await transaction.get(reference);
          if (!currentPet.exists ||
              !currentSchedule.exists ||
              currentSchedule.data()?['active'] != true) {
            return;
          }
          final scheduledTime = currentSchedule.data()!['time'] as String;
          if (existing.exists) {
            if (existing.data()?['status'] == 'pending' &&
                existing.data()?['scheduledTime'] != scheduledTime) {
              transaction.update(reference, {'scheduledTime': scheduledTime});
            }
            return;
          }
          transaction.set(reference, {
            'id': id,
            'userId': userId,
            'petId': pet.id,
            'petName': currentPet.data()!['name'],
            'scheduleId': schedule.id,
            'scheduledTime': scheduledTime,
            'dateKey': dateKey,
            'status': 'pending',
            'fedAt': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
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
        final petReference = _firestore
            .collection('users')
            .doc(userId)
            .collection('pets')
            .doc(pet.id);
        final currentPet = await transaction.get(petReference);
        final schedule = await transaction.get(
          petReference.collection('feedingSchedules').doc(scheduleId),
        );
        final snapshot = await transaction.get(reference);
        if (!currentPet.exists ||
            !schedule.exists ||
            schedule.data()?['active'] != true) {
          throw const FeedingHistoryFailure(
            'La mascota o el horario ya no están disponibles.',
          );
        }
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
          'petName': currentPet.data()!['name'],
          'scheduleId': scheduleId,
          'scheduledTime': schedule.data()!['time'],
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
