import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petreminder_user/core/pets/pet_catalog.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.ageMonths = 0,
    this.customSpecies = '',
  });

  static List<String> get speciesOptions => PetCatalog.species;

  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final int ageMonths;
  final String customSpecies;
  String get speciesLabel =>
      species == PetCatalog.other && customSpecies.isNotEmpty
      ? customSpecies
      : species;
  String get ageLabel {
    final parts = [
      if (age > 0) '$age ${age == 1 ? 'año' : 'años'}',
      if (ageMonths > 0) '$ageMonths ${ageMonths == 1 ? 'mes' : 'meses'}',
    ];
    return parts.isEmpty ? 'Menos de un mes' : parts.join(' y ');
  }

  final String description;
  final String? photoUrl;
  final DateTime createdAt;

  factory Pet.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    final timestamp = data['createdAt'];

    return Pet(
      id: document.id,
      name: data['name'] as String? ?? '',
      species: data['species'] as String? ?? 'Otro',
      breed: data['breed'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      ageMonths: (data['ageMonths'] as num?)?.toInt() ?? 0,
      customSpecies: data['customSpecies'] as String? ?? '',
      description: data['description'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class PetInput {
  const PetInput({
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.description,
    this.ageMonths = 0,
    this.customSpecies = '',
  });

  final String name;
  final String species;
  final String breed;
  final int age;
  final int ageMonths;
  final String customSpecies;
  final String description;

  Map<String, dynamic> toFirestore() => {
    'name': name.trim(),
    'species': species,
    'breed': breed.trim(),
    'age': age,
    'ageMonths': ageMonths,
    'customSpecies': species == PetCatalog.other ? customSpecies.trim() : '',
    'description': description.trim(),
    // Photos are private files on this device, not Firebase resources.
    'photoUrl': null,
  };
}
