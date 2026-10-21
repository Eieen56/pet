/// Límites de captura de la aplicación, no estimaciones de esperanza de vida.
abstract final class PetCatalog {
  static const other = 'Otro';
  static const breeds = <String, List<String>>{
    'Perro': [
      'Labrador retriever',
      'Pastor alemán',
      'Golden retriever',
      'Bulldog',
      'Chihuahua',
      'Poodle',
      'Beagle',
      'Pug',
    ],
    'Gato': [
      'Siamés',
      'Persa',
      'Maine Coon',
      'Bengalí',
      'Ragdoll',
      'British shorthair',
      'Abisinio',
      'Europeo común',
    ],
    'Conejo': [
      'Holandés',
      'Belier',
      'Rex',
      'Angora',
      'Cabeza de león',
      'Gigante de Flandes',
      'Californiano',
      'Nueva Zelanda',
    ],
    'Ave': [
      'Periquito australiano',
      'Canario',
      'Ninfa',
      'Agapornis',
      'Diamante mandarín',
      'Cotorra argentina',
      'Loro amazónico',
      'Cacatúa',
    ],
    'Hámster': [
      'Sirio dorado',
      'Sirio de pelo corto',
      'Sirio de pelo largo',
      'Sirio satinado',
      'Ruso',
      'Campbell',
      'Roborovski',
      'Chino',
    ],
    'Tortuga': [
      'De orejas rojas',
      'De orejas amarillas',
      'Mapa',
      'Pintada',
      'De almizcle',
      'Mediterránea',
      'Rusa',
      'Sulcata',
    ],
    'Pez': [
      'Goldfish',
      'Betta',
      'Guppy',
      'Molly',
      'Platy',
      'Neón tetra',
      'Cebra',
      'Escalar',
    ],
  };
  static const maxYears = <String, int>{
    'Perro': 30,
    'Gato': 30,
    'Conejo': 20,
    'Ave': 100,
    'Hámster': 5,
    'Tortuga': 200,
    'Pez': 100,
    other: 250,
  };
  static List<String> get species => maxYears.keys.toList(growable: false);
  static int maximumYears(String species) =>
      maxYears[species] ?? maxYears[other]!;
}
