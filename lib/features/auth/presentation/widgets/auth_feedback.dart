import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/core/errors/auth_failure.dart';
import 'package:petreminder_user/providers/auth_providers.dart';

void listenForAuthErrors(WidgetRef ref, BuildContext context) {
  ref.listen(authControllerProvider, (previous, next) {
    if (!next.hasError || previous?.error == next.error) {
      return;
    }

    final error = next.error;
    final message = error is AuthFailure
        ? error.message
        : 'Ocurrió un error inesperado. Inténtalo de nuevo.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  });
}
