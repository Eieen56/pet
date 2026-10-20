import 'package:petreminder_user/core/auth/admin_credentials.dart';

abstract final class InputValidators {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre.';
    }
    if (value.trim().length < 2) {
      return 'El nombre es demasiado corto.';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ingresa tu correo.';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  static String? emailOrAdminUsername(String? value) {
    final login = value?.trim() ?? '';
    if (login.isEmpty) {
      return 'Ingresa tu usuario o correo.';
    }
    if (AdminCredentials.isUsername(login) || _emailPattern.hasMatch(login)) {
      return null;
    }
    return 'Ingresa un usuario o correo válido.';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (value.length < 6) {
      return 'Usa al menos 6 caracteres.';
    }
    return null;
  }

  static String? petName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Ingresa el nombre de la mascota.';
    }
    if (name.length < 2) {
      return 'El nombre es demasiado corto.';
    }
    if (name.length > 60) {
      return 'Usa un nombre de hasta 60 caracteres.';
    }
    return null;
  }

  static String? petAge(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null) {
      return 'Ingresa la edad en años.';
    }
    if (age < 0 || age > 100) {
      return 'Ingresa una edad entre 0 y 100.';
    }
    return null;
  }
}
