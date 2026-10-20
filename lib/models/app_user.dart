import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
    required this.lastActivity,
    required this.accountStatus,
  });

  static const activeStatus = 'active';
  static const disabledStatus = 'disabled';

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastActivity;
  final String accountStatus;

  factory AppUser.fromFirestore(Map<String, Object?> data) {
    return AppUser(
      uid: data['uid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActivity: (data['lastActivity'] as Timestamp?)?.toDate(),
      accountStatus: data['accountStatus'] as String? ?? activeStatus,
    );
  }
}
