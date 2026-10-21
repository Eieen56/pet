# Historial de cambios

## [1.0.0-beta.1] — 2026-10-20 (código preparado, distribución pendiente)

Primera línea base del código recibido; no representa una versión estable.
La versión anterior declarada era `1.0.0+1`, sin historial Git ni tags locales.

- Conserva la arquitectura Flutter, Riverpod, GoRouter y Firebase.
- Incluye el código existente de autenticación, mascotas, horarios, historial,
  fotografías locales y acceso administrativo por custom claim.
- Declara `1.0.0-beta.1+2` para identificar el código de la beta.
- Añade documentación de versionado, entrega y pruebas con tres testers.
- Añade formulario de feedback y bloqueo por lista explícita de tres issues.
- Prueba el cierre con API simulada; la aplicación aún requiere validar su build.
- Excluye configuración local de Firebase, credenciales y binarios de Git.
- Integra `petreminder_admin/` dentro del repositorio y conserva la sesión
  al navegar y editar el perfil, con comprobación del claim administrativo.
- Corrige la carga reactiva del nombre y las reparaciones de perfiles vacíos.
- Deja una única entrada para agregar mascotas.
- Limpia comidas al borrar mascotas/horarios y excluye registros huérfanos
  de las estadísticas; evita su recreación mediante transacciones y reglas.
- Añade ocho variedades por especie, captura manual y edad en años y meses,
  con límites equivalentes en el formulario y en Firestore.

El instalador se gestiona en el repositorio separado `Eieen56/app_pet`.
Consultar el registro de entregas para los resultados de compilación y publicación.
