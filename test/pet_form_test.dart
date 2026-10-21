import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:petreminder_user/core/pets/pet_catalog.dart';
import 'package:petreminder_user/core/validators/input_validators.dart';
import 'package:petreminder_user/features/pets/presentation/pet_form_screen.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/pet_providers.dart';

class RecordingPetController extends PetController {
  PetInput? saved;
  @override
  Future<String?> createPet({
    required PetInput input,
    String? photoPath,
  }) async {
    saved = input;
    return 'new-pet';
  }
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  test(
    'cada catálogo tiene ocho variedades distintas y la edad tiene límites por especie',
    () {
      for (final entry in PetCatalog.breeds.entries) {
        expect(
          entry.value.toSet().length,
          greaterThanOrEqualTo(8),
          reason: entry.key,
        );
      }
      for (final entry in PetCatalog.maxYears.entries) {
        expect(
          InputValidators.petAge('0', species: entry.key, months: 11),
          isNull,
        );
        expect(
          InputValidators.petAge('${entry.value}', species: entry.key),
          isNull,
        );
        expect(
          InputValidators.petAge(
            '${entry.value}',
            species: entry.key,
            months: 1,
          ),
          isNotNull,
        );
        expect(
          InputValidators.petAge('${entry.value + 1}', species: entry.key),
          isNotNull,
        );
        expect(InputValidators.petAge('-1', species: entry.key), isNotNull);
      }
      expect(InputValidators.petMonths('11'), isNull);
      expect(InputValidators.petMonths('12'), isNotNull);
      expect(InputValidators.petMonths('-1'), isNotNull);
      expect(InputValidators.petMonths('1.5'), isNotNull);
    },
  );

  test('valida longitudes de nombres, raza, especie y descripción', () {
    expect(InputValidators.petName('a'), isNotNull);
    expect(InputValidators.petName('a' * 60), isNull);
    expect(InputValidators.petName('a' * 61), isNotNull);
    expect(InputValidators.petBreed('a'), isNotNull);
    expect(InputValidators.petBreed('a' * 80), isNull);
    expect(InputValidators.petBreed('a' * 81), isNotNull);
    expect(InputValidators.customSpecies('a' * 40), isNull);
    expect(InputValidators.customSpecies('a' * 41), isNotNull);
    expect(InputValidators.petDescription('a' * 500), isNull);
    expect(InputValidators.petDescription('a' * 501), isNotNull);
  });

  test('modelos conservan años y meses y leen documentos anteriores', () async {
    final db = FakeFirebaseFirestore();
    final doc = db.doc('pets/p');
    await doc.set({'name': 'Max', 'species': 'Gato', 'age': 2});
    final old = Pet.fromDocument(await doc.get());
    expect(old.ageMonths, 0);
    expect(old.ageLabel, '2 años');
    const input = PetInput(
      name: 'Mini',
      species: 'Otro',
      customSpecies: 'Hurón',
      breed: '',
      age: 0,
      ageMonths: 6,
      description: '',
    );
    await doc.set(input.toFirestore());
    final current = Pet.fromDocument(await doc.get());
    expect(current.speciesLabel, 'Hurón');
    expect(current.ageLabel, '6 meses');
  });

  Future<RecordingPetController> openForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RecordingPetController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [petControllerProvider.overrideWith(() => controller)],
        child: MaterialApp(
          initialRoute: '/form',
          routes: {
            '/': (_) => const Scaffold(body: Text('Guardado')),
            '/form': (_) => const PetFormScreen(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> chooseSpecies(WidgetTester tester, String species) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(species).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'gato: catálogo, edad de seis meses y guardado con raza elegida',
    (tester) async {
      final controller = await openForm(tester);
      await chooseSpecies(tester, 'Gato');
      final breed = find.byKey(const ValueKey('breed-Gato'));
      final dropdown = tester.widget<DropdownButton<String>>(
        find.descendant(
          of: breed,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      expect(dropdown.items!.length, greaterThanOrEqualTo(9));
      await tester.tap(breed);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siamés').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Nombre'), 'Michi');
      await tester.enterText(find.byKey(const ValueKey('ageMonths')), '6');
      await tester.ensureVisible(find.byIcon(Icons.save_outlined));
      await tester.tap(find.byIcon(Icons.save_outlined));
      await tester.pumpAndSettle();
      expect(controller.saved?.species, 'Gato');
      expect(controller.saved?.breed, 'Siamés');
      expect(controller.saved?.age, 0);
      expect(controller.saved?.ageMonths, 6);
    },
  );

  testWidgets(
    'Otro permite escribir especie y variedad y rechaza exceder la edad máxima',
    (tester) async {
      final controller = await openForm(tester);
      await chooseSpecies(tester, 'Otro');
      await tester.enterText(field('Nombre'), 'Mini');
      await tester.enterText(
        find.byKey(const ValueKey('customSpecies')),
        'Hurón',
      );
      await tester.enterText(
        find.byKey(const ValueKey('customBreed')),
        'Albino',
      );
      await tester.enterText(field('Edad en años'), '251');
      await tester.ensureVisible(find.byIcon(Icons.save_outlined));
      await tester.tap(find.byIcon(Icons.save_outlined));
      await tester.pumpAndSettle();
      expect(controller.saved, isNull);
      expect(find.textContaining('edad máxima para Otro'), findsOneWidget);
      await tester.enterText(field('Edad en años'), '1');
      await tester.ensureVisible(find.byIcon(Icons.save_outlined));
      await tester.tap(find.byIcon(Icons.save_outlined));
      await tester.pumpAndSettle();
      expect(controller.saved?.customSpecies, 'Hurón');
      expect(controller.saved?.breed, 'Albino');
    },
  );
}
