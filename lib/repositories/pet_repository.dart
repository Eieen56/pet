import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petreminder_user/core/errors/pet_failure.dart';
import 'package:petreminder_user/models/pet.dart';

class PetRepository {
  PetRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Pet>> watchPets(String userId) {
    return _pets(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Pet.fromDocument).toList());
  }

  Future<String> createPet(String userId, PetInput input) async {
    final reference = _pets(userId).doc();

    try {
      await reference.set({
        ...input.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return reference.id;
    } on FirebaseException catch (exception) {
      throw PetFailure.fromFirebase(exception);
    }
  }

  Future<void> updatePet(String userId, String petId, PetInput input) async {
    try {
      await _pets(userId).doc(petId).update(input.toFirestore());
    } on FirebaseException catch (exception) {
      throw PetFailure.fromFirebase(exception);
    }
  }

  Future<void> deletePet(String userId, String petId) async {
    try {
      final petReference = _pets(userId).doc(petId);
      final schedules = await petReference.collection('feedingSchedules').get();
      for (var index = 0; index < schedules.docs.length; index += 450) {
        final batch = _firestore.batch();
        final end = (index + 450).clamp(0, schedules.docs.length);
        for (final document in schedules.docs.sublist(index, end)) {
          batch.delete(document.reference);
        }
        await batch.commit();
      }
      await petReference.delete();
    } on FirebaseException catch (exception) {
      throw PetFailure.fromFirebase(exception);
    }
  }

  CollectionReference<Map<String, dynamic>> _pets(String userId) =>
      _firestore.collection('users').doc(userId).collection('pets');
}
