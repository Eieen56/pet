import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/core/errors/feeding_history_failure.dart';
import 'package:petreminder_user/models/feeding_record.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/pet_providers.dart';
import 'package:petreminder_user/providers/feeding_schedule_providers.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/repositories/feeding_history_repository.dart';

final feedingHistoryRepositoryProvider = Provider<FeedingHistoryRepository>(
  (ref) => FeedingHistoryRepository(ref.watch(firestoreProvider)),
);

final rawFeedingHistoryProvider =
    StreamProvider.autoDispose<List<FeedingRecord>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        return Stream.value(const []);
      }
      return ref.watch(feedingHistoryRepositoryProvider).watchHistory(userId);
    });

// También excluye registros huérfanos generados por versiones anteriores.
final feedingHistoryProvider =
    Provider.autoDispose<AsyncValue<List<FeedingRecord>>>((ref) {
      final pets = ref.watch(petsProvider);
      return pets
          .whenData((items) {
            final schedules = {
              for (final pet in items)
                pet.id: ref.watch(feedingSchedulesProvider(pet.id)),
            };
            return schedules;
          })
          .when(
            loading: () => const AsyncLoading(),
            error: (error, stack) => AsyncError(error, stack),
            data: (schedules) {
              for (final value in schedules.values) {
                if (value.hasError) {
                  return AsyncError(value.error!, value.stackTrace!);
                }
                if (value.isLoading) return const AsyncLoading();
              }
              final ids = {
                for (final entry in schedules.entries)
                  entry.key: entry.value.value!.map((s) => s.id).toSet(),
              };
              return ref
                  .watch(rawFeedingHistoryProvider)
                  .whenData(
                    (records) => records
                        .where(
                          (r) => ids[r.petId]?.contains(r.scheduleId) == true,
                        )
                        .toList(),
                  );
            },
          );
    });

final ensureTodayForPetProvider = FutureProvider.autoDispose.family<void, Pet>((
  ref,
  pet,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return;
  }
  await ref
      .watch(feedingHistoryRepositoryProvider)
      .ensureTodayForPet(userId, pet);
});

final ensureTodayForAllPetsProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return;
  }
  await ref
      .watch(feedingHistoryRepositoryProvider)
      .ensureTodayForAllPets(userId);
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
