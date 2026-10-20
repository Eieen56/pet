import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingHistoryFailure implements Exception {
  const FeedingHistoryFailure(this.message);

  final String message;

  factory FeedingHistoryFailure.fromFirebase(FirebaseException exception) {
    return switch (exception.code) {
      'permission-denied' => const FeedingHistoryFailure(
        'No tienes permiso para modificar este registro.',
      ),
      'unavailable' => const FeedingHistoryFailure(
        'No hay conexión. Comprueba tu red e inténtalo de nuevo.',
      ),
      _ => const FeedingHistoryFailure(
        'No se pudo actualizar el historial de alimentación.',
      ),
    };
  }

  @override
  String toString() => message;
}
