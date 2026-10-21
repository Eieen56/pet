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
| Correcciones de perfil, mascotas y módulo admin | 20/10/2026 | 20/10/2026, código y pruebas locales | Entregadas a tiempo en GitHub; 32 pruebas de app y 2 de admin aprobadas |
| Reglas de Firestore corregidas | 20/10/2026 | 20/10/2026, emulador y despliegue real | Desplegadas correctamente |
| Compilación Android | 20/10/2026 | 20/10/2026, build release e instalación del APK verificadas | Entregada a tiempo |
| Instalador / Release / SHA-256 | 20/10/2026, distribución en Eieen56/app_pet | 20/10/2026 20:20:11 UTC-06:00, Release pública verificada | Entregados a tiempo |
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
- Las pruebas Flutter cubren validadores, modelos, sesiones, widgets de acceso
  y perfil, y resolución de zonas horarias.
- En la auditoría inicial faltaba `../petreminder_admin`. Posteriormente se
  incorporó `petreminder_admin/` dentro de este repositorio y se corrigió la
  ruta en `pubspec.yaml`; la resolución de dependencias ya funciona.
- `flutter test --concurrency=1`: 32 pruebas aprobadas en la app. Las dos
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
- Se conserva el lockfile y se declara la fuente de iconos requerida por la app.
  No se ha realizado una auditoría de vulnerabilidades de todas las dependencias.

## Validación y pendientes

- CI remota del código de ejecución `f6d98fb`: aprobada (32 app, 2 admin, 8 política beta).
- Build release, manifiesto, firma y SHA-256 verificados; Android mínimo API 24.
- Instalación del mismo APK y pantalla «Bienvenido» verificadas en emulador
  Android 16, zona GMT, sin excepciones fatales de la app. El emulador mostró
  avisos de lentitud del sistema y Google Play services por recursos del equipo;
  esta comprobación no certifica todos los flujos en teléfonos reales.
- Actions habilitado y simulación manual aprobada sin bloquear reportes.
- Pendiente: confirmar las cuentas de tres testers y recibir sus reportes reales.
- Pendiente: verificar el bloqueo programado después del corte; no se acredita
  una ejecución futura ni se marcan los reportes como recibidos.

Reportes preparados: https://github.com/Eieen56/pet/issues/1,
https://github.com/Eieen56/pet/issues/2 y https://github.com/Eieen56/pet/issues/3.
No hay testers asignados ni reportes acreditados como completados.

CI remota del código `f6d98fb`: aprobada en
https://github.com/Eieen56/pet/actions/runs/39530072343.
Simulación manual de cierre: aprobada en
https://github.com/Eieen56/pet/actions/runs/39524641369; workflow habilitado.

## Instalador entregado

[Release pública](https://github.com/Eieen56/app_pet/releases/tag/v1.0.0-beta.1) · [APK](https://github.com/Eieen56/app_pet/releases/download/v1.0.0-beta.1/PetReminder-1.0.0-beta.1.apk).
Publicado: **20/10/2026 20:20:11 UTC-06:00**. Código de ejecución: `f6d98fb73cf0c0bb91524465dd9c28e3d77732de`.
Los commits posteriores de esta entrega actualizan documentación y evidencias.

SHA-256: `bbd691d9c7e8ddf7437a4382e6d413ee362e7cba0720c0b02cececdb30890828`. Tamaño: 59,484,631 bytes.
Firma de depuración beta, diferente del APK recibido originalmente; consultar
la guía antes de desinstalar para conservar fotografías locales.
