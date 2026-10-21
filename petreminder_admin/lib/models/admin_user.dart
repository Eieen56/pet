import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
    required this.accountStatus,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;
  final String accountStatus;

  bool get isActive => accountStatus == 'active';

  factory AdminUser.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return AdminUser(
      uid: data['uid'] as String? ?? document.id,
      name: data['name'] as String? ?? 'Sin nombre',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      accountStatus: data['accountStatus'] as String? ?? 'active',
    );
  }
}
