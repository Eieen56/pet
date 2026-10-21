import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/core/errors/auth_failure.dart';
import 'package:petreminder_user/models/app_user.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/services/profile_photo_service.dart';

final profilePhotoServiceProvider = Provider<ProfilePhotoService>(
  (ref) => ProfilePhotoService(),
);

final appUserProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).watchUser(userId);
});

final profilePhotoPathProvider = FutureProvider.autoDispose<String?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Future.value(null);
  }
  return ref.watch(profilePhotoServiceProvider).findPhoto(userId);
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> updateName(String name) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthFailure('Debes iniciar sesión para editar el perfil.');
      }
      await ref.read(userRepositoryProvider).updateName(user.uid, name);
      await user.updateDisplayName(name.trim());
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> savePhoto(String sourcePath) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthFailure('Debes iniciar sesión para editar el perfil.');
      }
      await ref
          .read(profilePhotoServiceProvider)
          .savePhoto(userId: user.uid, sourcePath: sourcePath);
      ref.invalidate(profilePhotoPathProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> removePhoto() async {
    state = const AsyncLoading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthFailure('Debes iniciar sesión para editar el perfil.');
      }
      await ref.read(profilePhotoServiceProvider).deletePhoto(user.uid);
      ref.invalidate(profilePhotoPathProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
