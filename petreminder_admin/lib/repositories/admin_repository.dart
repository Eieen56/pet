import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petreminder_admin/models/admin_pet.dart';
import 'package:petreminder_admin/models/admin_schedule.dart';
import 'package:petreminder_admin/models/admin_user.dart';

class AdminRepository {
  AdminRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<AdminUser>> watchUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final users = snapshot.docs.map(AdminUser.fromDocument).toList();
      users.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return users;
    });
  }

  Stream<List<AdminPet>> watchAllPets() {
    return _firestore
        .collectionGroup('pets')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AdminPet.fromDocument).toList());
  }

  Stream<List<AdminSchedule>> watchAllSchedules() {
    return _firestore
        .collectionGroup('feedingSchedules')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(AdminSchedule.fromDocument).toList(),
        );
  }

  Future<void> setAccountStatus(String userId, String status) {
    if (status != 'active' && status != 'disabled') {
      throw ArgumentError.value(status, 'status', 'Estado no permitido');
    }
    return _firestore.collection('users').doc(userId).update({
      'accountStatus': status,
    });
  }
}
