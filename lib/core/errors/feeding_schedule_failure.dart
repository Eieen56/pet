import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingScheduleFailure implements Exception {
  const FeedingScheduleFailure(this.message, {this.code});

  final String message;
  final String? code;

  factory FeedingScheduleFailure.fromFirebase(FirebaseException exception) {
    final message = switch (exception.code) {
      'permission-denied' => 'No tienes permiso para modificar este horario.',
      'unavailable' || 'network-request-failed' =>
        'No se pudo conectar. Revisa tu conexión a internet.',
      'not-found' => 'El horario ya no existe.',
      _ => 'No se pudo guardar el horario de alimentación.',
    };

    return FeedingScheduleFailure(message, code: exception.code);
  }

  @override
  String toString() => message;
}
