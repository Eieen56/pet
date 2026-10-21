import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

final notificationSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return;
  }
  await ref
      .watch(notificationServiceProvider)
      .syncAllForUser(
        firestore: ref.watch(firestoreProvider),
        userId: user.uid,
      );
});
