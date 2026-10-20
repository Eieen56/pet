import 'package:firebase_auth/firebase_auth.dart';
import 'package:petreminder_user/core/auth/admin_credentials.dart';
import 'package:petreminder_user/core/errors/auth_failure.dart';
import 'package:petreminder_user/repositories/user_repository.dart';
import 'package:petreminder_user/services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._authService, this._userRepository);

  final AuthService _authService;
  final UserRepository _userRepository;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;

    try {
      credential = await _authService.registerWithEmail(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('No se pudo crear la cuenta.');
      }

      await user.updateDisplayName(name.trim());
      await _userRepository.createUserDocument(user: user, name: name);
    } on FirebaseAuthException catch (exception) {
      throw AuthFailure.fromFirebaseAuth(exception);
    } on AuthFailure {
      if (credential?.user != null) {
        await credential!.user!.delete().catchError((_) {});
      }
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmail(
        email: AdminCredentials.normalizeEmail(email),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final token = await user.getIdTokenResult(true);
        if (token.claims?['admin'] == true) {
          return;
        }
        await _userRepository.ensureAccountIsActive(user);
        await _userRepository.updateLastActivity(user);
      }
    } on FirebaseAuthException catch (exception) {
      throw AuthFailure.fromFirebaseAuth(exception);
    } on AuthFailure {
      await _authService.signOut();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión con Google.');
      }
      await _userRepository.ensureGoogleUserDocument(user);
      await _userRepository.ensureAccountIsActive(user);
    } on FirebaseAuthException catch (exception) {
      throw AuthFailure.fromFirebaseAuth(exception);
    } on AuthFailure catch (failure) {
      if (failure.code != 'canceled') {
        await _authService.signOut();
      }
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email.trim());
    } on FirebaseAuthException catch (exception) {
      throw AuthFailure.fromFirebaseAuth(exception);
    }
  }

  Future<void> signOut() => _authService.signOut();
}
