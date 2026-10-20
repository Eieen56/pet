import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  static const speciesOptions = [
    'Perro',
    'Gato',
    'Conejo',
    'Ave',
    'Hámster',
    'Tortuga',
    'Pez',
    'Otro',
  ];

  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
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
  });

  final String name;
  final String species;
  final String breed;
  final int age;
  final String description;

  Map<String, dynamic> toFirestore() => {
    'name': name.trim(),
    'species': species,
    'breed': breed.trim(),
    'age': age,
    'description': description.trim(),
    // Photos are private files on this device, not Firebase resources.
    'photoUrl': null,
  };
}
