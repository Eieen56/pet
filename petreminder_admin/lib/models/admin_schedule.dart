import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSchedule {
  const AdminSchedule({
    required this.id,
    required this.userId,
    required this.petId,
    required this.active,
  });

  final String id;
  final String userId;
  final String petId;
  final bool active;

  factory AdminSchedule.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final segments = document.reference.path.split('/');
    return AdminSchedule(
      id: document.id,
      userId: segments.length >= 2 ? segments[1] : '',
      petId: segments.length >= 4 ? segments[3] : '',
      active: data['active'] as bool? ?? false,
    );
  }
}
