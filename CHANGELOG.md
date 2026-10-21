# Historial de cambios

## [1.0.0-beta.1] — 2026-10-20 (beta publicada)

Primera línea base del código recibido; no representa una versión estable.
La versión anterior declarada era `1.0.0+1`, sin historial Git ni tags locales.

- Conserva la arquitectura Flutter, Riverpod, GoRouter y Firebase.
- Incluye el código existente de autenticación, mascotas, horarios, historial,
  fotografías locales y acceso administrativo por custom claim.
- Declara `1.0.0-beta.1+2` para identificar el código de la beta.
- Añade documentación de versionado, entrega y pruebas con tres testers.
- Añade formulario de feedback y bloqueo por lista explícita de tres issues.
- Prueba el cierre con API simulada y valida compilación Android.
- Excluye configuración local de Firebase, credenciales y binarios de Git.
- Integra `petreminder_admin/` dentro del repositorio y conserva la sesión
  al navegar y editar el perfil, con comprobación del claim administrativo.
- Corrige la carga reactiva del nombre y las reparaciones de perfiles vacíos.
- Deja una única entrada para agregar mascotas.
- Limpia comidas al borrar mascotas/horarios y excluye registros huérfanos
  de las estadísticas; evita su recreación mediante transacciones y reglas.
- Añade ocho variedades por especie, captura manual y edad en años y meses,
  con límites equivalentes en el formulario y en Firestore.
- Corrige el arranque en dispositivos que identifican su zona horaria como GMT,
  UTC o un desfase fijo, manteniendo las reglas de las zonas IANA conocidas.

Instalador y SHA-256: [Release beta](https://github.com/Eieen56/app_pet/releases/tag/v1.0.0-beta.1).
Consultar el registro de entregas para las validaciones y limitaciones.
