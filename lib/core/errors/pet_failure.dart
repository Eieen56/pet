import 'package:cloud_firestore/cloud_firestore.dart';

class PetFailure implements Exception {
  const PetFailure(this.message, {this.code});

  final String message;
  final String? code;

  factory PetFailure.fromFirebase(FirebaseException exception) {
    final message = switch (exception.code) {
      'permission-denied' => 'No tienes permiso para realizar esta acción.',
      'unavailable' || 'network-request-failed' =>
        'No se pudo conectar. Revisa tu conexión a internet.',
      'not-found' => 'La mascota ya no existe.',
      _ => 'No se pudo guardar la información de la mascota.',
    };

    return PetFailure(message, code: exception.code);
  }

  @override
  String toString() => message;
}
