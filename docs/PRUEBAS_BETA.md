# Pruebas beta — ronda beta-2026-10

Objetivo: comprobar registro e inicio de sesión, recuperación de contraseña,
mascotas, horarios de alimentación, recordatorios, historial y perfil en Android.
Usar exclusivamente cuentas y datos de prueba. No compartir contraseñas,
capturas con información personal ni credenciales administrativas.

## Versión y distribución

Código candidato: `1.0.0-beta.1+2`. Los tres testers deben recibir exactamente
el mismo APK y SHA-256. La publicación del instalador se gestiona por separado:
en esta entrega NO hay APK publicado ni Release verificada.

Página prevista: https://github.com/Eieen56/pet/releases.
No descargar archivos de terceros ni asumir que el código fuente es instalable.
El responsable debe completar el enlace directo, SHA-256 y requisitos Android
tras compilar y probar la app en un dispositivo. El mínimo efectivo de Android
depende del SDK de Flutter y de los plugins; aún no está certificado.

Cuando se distribuya: descargar el APK identificado, verificar su hash,
instalar siguiendo las indicaciones de Android y conceder solo los permisos
necesarios para notificaciones, alarmas y fotografías. Un APK sin firma de
distribución puede mostrar advertencias. No desactivar antivirus ni protecciones.
La configuración actual de release usa firma de depuración; no es una firma
de producción. No sustituir un APK ya distribuido: corregir en una nueva beta.

## Lista de comprobación

1. Registrar una cuenta de prueba, entrar/salir y recuperar contraseña.
2. Probar Google Sign-In; anotar fallos de configuración o de conectividad.
3. Crear, editar y consultar mascotas y sus fotografías.
4. Crear y modificar horarios; probar los recordatorios de cinco minutos antes
   y de la hora exacta con los permisos necesarios y la app en segundo plano.
5. Registrar alimentación y consultar historial, evitando duplicados.
6. Editar perfil y comprobar persistencia tras reiniciar.
7. Comprobar que una cuenta normal no accede al panel administrativo.
8. Anotar comportamiento sin conexión, permisos denegados y mensajes de error.

Estas son pruebas propuestas, no funcionalidades certificadas por esta entrega.
Si no se instala o ejecuta, registrar dispositivo, versión Android, paso y
mensaje exacto; elegir «No pude instalar o ejecutar» en el reporte.

## Tres reportes independientes

Usuarios de GitHub: pendientes de confirmar; no se asignan cuentas inventadas.
Usar una cuenta GitHub sin permisos de escritura al repositorio.
Cada tester completa un solo reporte mediante «Issues → New issue → Reporte de
prueba beta» y mantiene allí sus resultados y comentarios.

Títulos exactos: `[beta-2026-10] Tester 1`, `[beta-2026-10] Tester 2` y
`[beta-2026-10] Tester 3`. El responsable crea las etiquetas `tester-feedback`
y `beta-2026-10`, las aplica a los tres reportes y registra sus números en
`.github/beta-round.json` (por ejemplo `[12, 13, 14]`, usando los números reales).
Comprobar que no son pull requests ni reportes ajenos antes de enviar ese cambio.

La plantilla incluye versión/hash, dispositivo, funcionalidad, pasos, resultado
esperado/obtenido, errores, usabilidad, sugerencias y resultado general.

Fecha límite inclusiva solicitada: **20 de octubre de 2026, 23:59:00**,
`America/Mexico_City`. Inicio del bloqueo: **21 de octubre de 2026, 00:00:00**
(06:00 UTC). GitHub no impide automáticamente comentarios durante la espera
del workflow: el límite administrativo se mantiene aunque haya retrasos.
La entrega de un reporte solo se acredita con su contenido y fecha reales.

## Cierre, comprobación y recuperación

Workflow «Cierre de comentarios beta»: cada 15 minutos, en los minutos
7/22/37/52, zona `America/Mexico_City`, y ejecución manual. Siempre comprueba
la fecha real antes de bloquear. No depende del estado abierto/cerrado del issue.
Requiere tres números únicos, ambas etiquetas y tres títulos con testers distintos.
La lista vacía inicial impide bloquear cualquier conversación.

En Actions, ejecutar manualmente con `dry_run` activado. Antes del corte solo
debe informar que no bloquea; después debe mostrar los tres números que
bloquearía. Las pruebas locales usan una API ficticia, sin tocar issues reales:
`node --test .github/scripts/lock-beta.test.cjs`.
Para activar el cierre real, integrar la lista correcta en `main`; el horario
o una ejecución manual con `dry_run` desactivado realizará los bloqueos
únicamente después del corte. Revisar en los logs el resultado por número y
en cada issue el evento de bloqueo. Un 403 requiere revisar permisos de Actions
y la política del repositorio; no crear tokens personales para sortearlo.

Conserva los comentarios existentes. Repetir el workflow omite issues ya
bloqueados y reintenta los pendientes. En caso de bloqueo accidental, deshabilitar
primero el workflow en Actions, corregir la lista en `main` y usar «Unlock
conversation» en el issue con permisos de escritura. Verificar antes de reactivar.

El bloqueo limita comentarios de testers sin escritura; personas con acceso de
escritura pueden seguir comentando. No otorgar escritura a los testers.
GitHub puede retrasar u omitir ejecuciones programadas: no hay garantía al minuto.
El archivo debe estar en la rama predeterminada. Tras 60 días sin actividad,
GitHub puede desactivar horarios en repositorios públicos. Revisar «Actions →
Cierre de comentarios beta», confirmar que está habilitado y revisar la última
ejecución; si está desactivado, habilitarlo y ejecutar manualmente con simulación.

Fuentes: [horarios de GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
y [bloqueo de conversaciones](https://docs.github.com/en/communities/moderating-comments-and-conversations/locking-conversations).
