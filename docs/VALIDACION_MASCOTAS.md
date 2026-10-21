# Validación de mascotas

El catálogo está en `lib/core/pets/pet_catalog.dart`. Para cambiar límites,
actualizar también `maxPetAge` en ambas copias de `firestore.rules` y las
pruebas del emulador. Los máximos son reglas de captura de esta aplicación.

El campo histórico `age` conserva los años y `ageMonths` añade los meses
restantes, de 0 a 11. Los documentos anteriores se leen con cero meses.
La edad total no puede superar el máximo de la especie ni ser negativa.
Un recién nacido admite 0 años y 0 meses.

Para una especie no catalogada se guarda `species: Otro` y su nombre en
`customSpecies`; así el panel administrativo mantiene sus agrupaciones y
puede mostrar el nombre indicado. La raza elegida o escrita se guarda en
`breed`. Cambiar de especie reinicia la selección de raza para no guardar
accidentalmente una variedad de la especie anterior.

Los borrados limpian los registros asociados en lotes de hasta 450 documentos,
conservando los de otras mascotas y horarios. El historial visible valida que
la mascota y el horario sigan existiendo. Las transacciones de generación y
registro de comidas vuelven a comprobar ambos antes de escribir; las reglas
también impiden crear horarios o comidas para padres inexistentes.

Pruebas locales sin modificar datos de producción:

```powershell
flutter test
cd petreminder_admin
flutter test
cd ..
firebase emulators:exec --project demo-petreminder-tests --config firebase.test.json --only firestore "node petreminder_admin/tools/firestore_rules_test.mjs"
```

Instalar las dependencias de herramientas con `npm ci` desde
`petreminder_admin/tools` antes de ejecutar el emulador.
