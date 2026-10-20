import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petreminder_user/core/errors/feeding_schedule_failure.dart';
import 'package:petreminder_user/models/feeding_schedule.dart';

class FeedingScheduleRepository {
  FeedingScheduleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<FeedingSchedule>> watchSchedules(String userId, String petId) {
    return _schedules(userId, petId)
        .orderBy('time')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(FeedingSchedule.fromDocument).toList(),
        );
  }

  Future<String> createSchedule(
    String userId,
    String petId,
    String time,
  ) async {
    final reference = _schedules(userId, petId).doc();
    try {
      await reference.set({
        'id': reference.id,
        'time': time,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return reference.id;
    } on FirebaseException catch (exception) {
      throw FeedingScheduleFailure.fromFirebase(exception);
    }
  }

  Future<void> updateTime(
    String userId,
    String petId,
    String scheduleId,
    String time,
  ) async {
    try {
      await _schedules(userId, petId).doc(scheduleId).update({'time': time});
    } on FirebaseException catch (exception) {
      throw FeedingScheduleFailure.fromFirebase(exception);
    }
  }

  Future<void> setActive(
    String userId,
    String petId,
    String scheduleId,
    bool active,
  ) async {
    try {
      await _schedules(
        userId,
        petId,
      ).doc(scheduleId).update({'active': active});
    } on FirebaseException catch (exception) {
      throw FeedingScheduleFailure.fromFirebase(exception);
    }
  }

  Future<void> deleteSchedule(
    String userId,
    String petId,
    String scheduleId,
  ) async {
    try {
      await _schedules(userId, petId).doc(scheduleId).delete();
    } on FirebaseException catch (exception) {
      throw FeedingScheduleFailure.fromFirebase(exception);
    }
  }

  CollectionReference<Map<String, dynamic>> _schedules(
    String userId,
    String petId,
  ) => _firestore
      .collection('users')
      .doc(userId)
      .collection('pets')
      .doc(petId)
      .collection('feedingSchedules');
}
