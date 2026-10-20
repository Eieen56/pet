import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/core/errors/feeding_schedule_failure.dart';
import 'package:petreminder_user/models/feeding_schedule.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/providers/notification_providers.dart';
import 'package:petreminder_user/repositories/feeding_schedule_repository.dart';

final feedingScheduleRepositoryProvider = Provider<FeedingScheduleRepository>(
  (ref) => FeedingScheduleRepository(ref.watch(firestoreProvider)),
);

final feedingSchedulesProvider = StreamProvider.autoDispose
    .family<List<FeedingSchedule>, String>((ref, petId) {
      final user = ref.watch(firebaseAuthProvider).currentUser;
      if (user == null) {
        return Stream.value(const []);
      }
      return ref
          .watch(feedingScheduleRepositoryProvider)
          .watchSchedules(user.uid, petId);
    });

final feedingScheduleControllerProvider =
    AsyncNotifierProvider<FeedingScheduleController, void>(
      FeedingScheduleController.new,
    );

class FeedingScheduleController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> create({required Pet pet, required String time}) {
    return _run((userId, repository) async {
      final scheduleId = await repository.createSchedule(userId, pet.id, time);
      await ref
          .read(notificationServiceProvider)
          .updateSchedule(
            petId: pet.id,
            petName: pet.name,
            scheduleId: scheduleId,
            time: time,
            active: true,
          );
    });
  }

  Future<bool> updateTime({
    required Pet pet,
    required FeedingSchedule schedule,
    required String time,
  }) {
    return _run((userId, repository) async {
      await repository.updateTime(userId, pet.id, schedule.id, time);
      await ref
          .read(notificationServiceProvider)
          .updateSchedule(
            petId: pet.id,
            petName: pet.name,
            scheduleId: schedule.id,
            time: time,
            active: schedule.active,
          );
    });
  }

  Future<bool> setActive({
    required Pet pet,
    required FeedingSchedule schedule,
    required bool active,
  }) {
    return _run((userId, repository) async {
      await repository.setActive(userId, pet.id, schedule.id, active);
      await ref
          .read(notificationServiceProvider)
          .updateSchedule(
            petId: pet.id,
            petName: pet.name,
            scheduleId: schedule.id,
            time: schedule.time,
            active: active,
          );
    });
  }

  Future<bool> delete({required String petId, required String scheduleId}) {
    return _run((userId, repository) async {
      await repository.deleteSchedule(userId, petId, scheduleId);
      await ref
          .read(notificationServiceProvider)
          .cancelSchedule(petId: petId, scheduleId: scheduleId);
    });
  }

  Future<bool> _run(
    Future<void> Function(String userId, FeedingScheduleRepository repository)
    operation,
  ) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const FeedingScheduleFailure(
          'Debes iniciar sesión para administrar horarios.',
        );
      }
      await operation(user.uid, ref.read(feedingScheduleRepositoryProvider));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
