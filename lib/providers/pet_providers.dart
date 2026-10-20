import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/core/errors/pet_failure.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/providers/notification_providers.dart';
import 'package:petreminder_user/repositories/pet_repository.dart';
import 'package:petreminder_user/services/pet_photo_service.dart';

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepository(ref.watch(firestoreProvider)),
);

final petPhotoServiceProvider = Provider<PetPhotoService>(
  (ref) => PetPhotoService(),
);

final petsProvider = StreamProvider.autoDispose<List<Pet>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    return Stream.value(const []);
  }
  return ref.watch(petRepositoryProvider).watchPets(user.uid);
});

final petPhotoPathProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, petId) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null) {
      return Future.value(null);
    }
    return ref
        .watch(petPhotoServiceProvider)
        .findPhoto(userId: user.uid, petId: petId);
  },
);

final petControllerProvider = AsyncNotifierProvider<PetController, void>(
  PetController.new,
);

class PetController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> createPet({
    required PetInput input,
    String? photoPath,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const PetFailure('Debes iniciar sesión para agregar mascotas.');
      }

      final petId = await ref
          .read(petRepositoryProvider)
          .createPet(user.uid, input);
      if (photoPath != null) {
        await ref
            .read(petPhotoServiceProvider)
            .savePhoto(userId: user.uid, petId: petId, sourcePath: photoPath);
        ref.invalidate(petPhotoPathProvider(petId));
      }
      state = const AsyncData(null);
      return petId;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<bool> updatePet({
    required String petId,
    required PetInput input,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const PetFailure('Debes iniciar sesión para editar mascotas.');
      }

      await ref.read(petRepositoryProvider).updatePet(user.uid, petId, input);
      final photoService = ref.read(petPhotoServiceProvider);
      if (removePhoto) {
        await photoService.deletePhoto(userId: user.uid, petId: petId);
      } else if (photoPath != null) {
        await photoService.savePhoto(
          userId: user.uid,
          petId: petId,
          sourcePath: photoPath,
        );
      }
      ref.invalidate(petPhotoPathProvider(petId));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> deletePet(String petId) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const PetFailure('Debes iniciar sesión para eliminar mascotas.');
      }

      final schedules = await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petId)
          .collection('feedingSchedules')
          .get();
      await ref.read(petRepositoryProvider).deletePet(user.uid, petId);
      final notifications = ref.read(notificationServiceProvider);
      for (final schedule in schedules.docs) {
        await notifications.cancelSchedule(
          petId: petId,
          scheduleId: schedule.id,
        );
      }
      await ref
          .read(petPhotoServiceProvider)
          .deletePhoto(userId: user.uid, petId: petId);
      ref.invalidate(petPhotoPathProvider(petId));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
