import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/core/errors/feeding_history_failure.dart';
import 'package:petreminder_user/models/feeding_record.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/repositories/feeding_history_repository.dart';

final feedingHistoryRepositoryProvider = Provider<FeedingHistoryRepository>(
  (ref) => FeedingHistoryRepository(ref.watch(firestoreProvider)),
);

final feedingHistoryProvider = StreamProvider.autoDispose<List<FeedingRecord>>((
  ref,
) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    return Stream.value(const []);
  }
  return ref.watch(feedingHistoryRepositoryProvider).watchHistory(user.uid);
});

final ensureTodayForPetProvider = FutureProvider.autoDispose.family<void, Pet>((
  ref,
  pet,
) async {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    return;
  }
  await ref
      .watch(feedingHistoryRepositoryProvider)
      .ensureTodayForPet(user.uid, pet);
});

final ensureTodayForAllPetsProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    return;
  }
  await ref
      .watch(feedingHistoryRepositoryProvider)
      .ensureTodayForAllPets(user.uid);
});

final feedingHistoryControllerProvider =
    AsyncNotifierProvider<FeedingHistoryController, void>(
      FeedingHistoryController.new,
    );

class FeedingHistoryController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> markAsFed({
    required Pet pet,
    required String scheduleId,
    required String scheduledTime,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const FeedingHistoryFailure(
          'Debes iniciar sesión para registrar una alimentación.',
        );
      }
      await ref
          .read(feedingHistoryRepositoryProvider)
          .markAsFed(
            userId: user.uid,
            pet: pet,
            scheduleId: scheduleId,
            scheduledTime: scheduledTime,
          );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
