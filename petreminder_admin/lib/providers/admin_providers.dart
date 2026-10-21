import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_admin/models/admin_pet.dart';
import 'package:petreminder_admin/models/admin_schedule.dart';
import 'package:petreminder_admin/models/admin_user.dart';
import 'package:petreminder_admin/providers/firebase_providers.dart';
import 'package:petreminder_admin/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(firestoreProvider));
});

final usersProvider = StreamProvider<List<AdminUser>>((ref) {
  return ref.watch(adminRepositoryProvider).watchUsers();
});

final allPetsProvider = StreamProvider<List<AdminPet>>((ref) {
  return ref.watch(adminRepositoryProvider).watchAllPets();
});

final allSchedulesProvider = StreamProvider<List<AdminSchedule>>((ref) {
  return ref.watch(adminRepositoryProvider).watchAllSchedules();
});

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, void>(AccountController.new);

class AccountController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> setStatus(AdminUser user, String status) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(adminRepositoryProvider)
          .setAccountStatus(user.uid, status);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
