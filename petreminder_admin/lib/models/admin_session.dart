import 'package:firebase_auth/firebase_auth.dart';

class AdminSession {
  const AdminSession({required this.user, required this.isAdmin});

  final User user;
  final bool isAdmin;
}
