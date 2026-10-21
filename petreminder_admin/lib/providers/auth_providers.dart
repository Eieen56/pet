import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_admin/core/admin_credentials.dart';
import 'package:petreminder_admin/models/admin_session.dart';
import 'package:petreminder_admin/providers/firebase_providers.dart';

final adminSessionProvider = StreamProvider<AdminSession?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges().asyncMap((
    user,
  ) async {
    if (user == null) {
      return null;
    }
    final token = await user.getIdTokenResult();
    return AdminSession(user: user, isAdmin: token.claims?['admin'] == true);
  });
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    final auth = ref.read(firebaseAuthProvider);
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: AdminCredentials.normalizeEmail(email),
        password: password,
      );
      final token = await credential.user?.getIdTokenResult(true);
      if (token?.claims?['admin'] != true) {
        await auth.signOut();
        throw const AdminAuthException(
          'Esta cuenta no tiene permisos de administrador.',
        );
      }
      state = const AsyncData(null);
      return true;
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(_messageFor(error), stackTrace);
      return false;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(firebaseAuthProvider).signOut();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  AdminAuthException _messageFor(FirebaseAuthException error) {
    return AdminAuthException(switch (error.code) {
      'invalid-email' => 'El correo no es válido.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Correo o contraseña incorrectos.',
      'user-disabled' => 'Esta cuenta fue deshabilitada en Firebase Auth.',
      'network-request-failed' => 'No fue posible conectarse a Firebase.',
      'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
      _ => 'No fue posible iniciar sesión.',
    });
  }
}

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
