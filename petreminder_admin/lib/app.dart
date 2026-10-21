import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_admin/core/theme/app_theme.dart';
import 'package:petreminder_admin/providers/router_provider.dart';

class PetReminderAdminApp extends ConsumerWidget {
  const PetReminderAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PetReminder Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
