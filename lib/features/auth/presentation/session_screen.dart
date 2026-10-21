import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/profile_providers.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed =
        ref.watch(authStateChangesProvider).hasError ||
        ref.watch(adminAccessProvider).hasError ||
        ref.watch(appUserProvider).hasError;
    return Scaffold(
      body: Center(
        child: failed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo verificar tu sesión.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.invalidate(authStateChangesProvider);
                      ref.invalidate(adminAccessProvider);
                      ref.invalidate(appUserProvider);
                    },
                    child: const Text('Reintentar'),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
