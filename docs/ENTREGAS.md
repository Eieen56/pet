# Registro de entregas — 1.0.0-beta.1+2

Zona horaria: `America/Mexico_City` (UTC−06:00 en estas fechas).
Fecha de preparación y validación del código de soporte beta: **20/10/2026**.
Fecha límite de feedback solicitada: **20/10/2026 a las 23:59:00**.
Inicio del bloqueo: **21/10/2026 a las 00:00:00**.

No se recibieron fechas históricas de entrega de funcionalidades. No se
atribuyen fechas anteriores ni se acredita retroalimentación no recibida.

| Elemento | Fecha prevista | Fecha real verificable | Estado |
| --- | --- | --- | --- |
| Código recibido y configuración de versionado beta | 20/10/2026 | 20/10/2026 18:58:57 UTC-06:00, push verificado | Entregado a tiempo en Eieen56/pet |
| Guía, formulario y política de cierre beta | 20/10/2026 | 20/10/2026 18:58:57 UTC-06:00, archivos publicados | Entregados a tiempo; validación de política local aprobada |
| Publicación del código en GitHub | 20/10/2026 | 20/10/2026 18:58:57 UTC-06:00, commit 1a7301a verificado en main | Entregado a tiempo |
| Correcciones de perfil, mascotas y módulo admin | 20/10/2026 | 20/10/2026, código y pruebas locales | Entregadas a tiempo en GitHub; 25 pruebas de app y 2 de admin aprobadas |
| Reglas de Firestore corregidas | 20/10/2026 | 20/10/2026, emulador y despliegue real | Desplegadas correctamente |
| Compilación Android | 20/10/2026 | En proceso | Pendiente de resultado verificable |
| Instalador / Release / SHA-256 | Distribución separada en Eieen56/app_pet | Sin publicación verificada | Pendientes |
| Reporte Tester 1 | 20/10/2026 23:59:00 | No recibido | Pendiente; cuenta por confirmar |
| Reporte Tester 2 | 20/10/2026 23:59:00 | No recibido | Pendiente; cuenta por confirmar |
| Reporte Tester 3 | 20/10/2026 23:59:00 | No recibido | Pendiente; cuenta por confirmar |
| Bloqueo de los tres reportes | Desde 21/10/2026 00:00:00 | Sin ejecución real verificada | Configurado para los issues #1, #2 y #3; ejecución real después del corte pendiente |

Solo marcar «Entregado a tiempo» con un commit publicado verificable antes
de la fecha comprometida. Para feedback, usar el reporte real y su fecha; el
código preparado no acredita que los testers hayan probado la aplicación.

## Diagnóstico y evidencias

- La carpeta recibida no tenía `.git`, historial, ramas ni tags.
- El remoto público consultado no tenía refs; no se reemplazó historial previo.
- Aplicación Android Flutter con Riverpod, GoRouter, Firebase Auth/Firestore,
  fotografías privadas locales y recordatorios diarios.
- Existen dos archivos de pruebas Flutter: validadores/modelos/notificaciones
  y una prueba de widget de inicio de sesión.
- En la auditoría inicial faltaba `../petreminder_admin`. Posteriormente se
  incorporó `petreminder_admin/` dentro de este repositorio y se corrigió la
  ruta en `pubspec.yaml`; la resolución de dependencias ya funciona.
- `flutter test --concurrency=1`: 25 pruebas aprobadas en la app. Las dos
  pruebas del módulo admin también aprobaron. Cubren sesiones, carga del
  nombre, rutas administrativas, borrados, huérfanos, catálogos y validación.
- Emulador Firestore con proyecto demo: reglas aprobadas, incluyendo límites
  por especie, meses y protección contra registros de padres inexistentes.
- `firebase deploy --project petreminder-user-2026 --only firestore:rules`:
  compilación de reglas y despliegue completados correctamente el 20/10/2026.
- `node --test .github/scripts/lock-beta.test.cjs`: 8 pruebas aprobadas,
  0 fallos. Cubren corte temporal, simulación, selección, idempotencia,
  ejecución tardía y errores de API. No se bloquearon issues reales.
- El APK preexistente en `build/` no se distribuye ni se considera verificado.
- No había `.github` ni documentación de Releases en la carpeta original.
- Se conserva la arquitectura, reglas Firebase y fuentes; se excluyen carpetas
  generadas, configuración local, credenciales y binarios. No se añade licencia.
- Las dependencias conservan sus versiones y lockfile. No se ha realizado una
  auditoría de vulnerabilidades de toda la cadena de dependencias.

## Activación pendiente

1. Verificar que la CI remota finalice correctamente; el push a `Eieen56/pet` ya está confirmado.
2. Completar y verificar el build Android antes de distribuir su APK.
3. Confirmar las cuentas de tres testers. Los reportes #1, #2 y #3 y sus
   etiquetas ya están creados; los resultados de las pruebas siguen pendientes.
4. Verificar Actions habilitado, permiso `issues: write` para el workflow y
   ejecutar simulación manual. No hacen falta tokens personales.
5. Entregar el APK por el proceso separado y completar su verificación,
   versión, requisitos y hash antes de solicitar pruebas reales.

Reportes preparados: https://github.com/Eieen56/pet/issues/1,
https://github.com/Eieen56/pet/issues/2 y https://github.com/Eieen56/pet/issues/3.
No hay testers asignados ni reportes acreditados como completados.
