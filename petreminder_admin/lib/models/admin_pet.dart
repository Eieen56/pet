import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPet {
  const AdminPet({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    required this.breed,
    required this.photoUrl,
    this.customSpecies = '',
    this.age = 0,
    this.ageMonths = 0,
  });

  final String id;
  final String userId;
  final String name;
  final String species;
  final String breed;
  final String? photoUrl;
  final String customSpecies;
  final int age;
  final int ageMonths;
  String get speciesLabel =>
      species == 'Otro' && customSpecies.isNotEmpty ? customSpecies : species;
  String get ageLabel {
    final parts = [
      if (age > 0) '$age ${age == 1 ? 'año' : 'años'}',
      if (ageMonths > 0) '$ageMonths ${ageMonths == 1 ? 'mes' : 'meses'}',
    ];
    return parts.isEmpty ? 'Menos de un mes' : parts.join(' y ');
  }

  factory AdminPet.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final segments = document.reference.path.split('/');
    return AdminPet(
      id: document.id,
      userId: segments.length >= 2 ? segments[1] : '',
      name: data['name'] as String? ?? 'Sin nombre',
      species: data['species'] as String? ?? 'Otro',
      breed: data['breed'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      customSpecies: data['customSpecies'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      ageMonths: (data['ageMonths'] as num?)?.toInt() ?? 0,
    );
  }
}
