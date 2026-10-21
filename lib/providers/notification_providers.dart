import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/firebase_providers.dart';
import 'package:petreminder_user/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

final notificationSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return;
  }
  await ref
      .watch(notificationServiceProvider)
      .syncAllForUser(firestore: ref.watch(firestoreProvider), userId: userId);
});
