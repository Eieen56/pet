# PetReminder Admin

Panel web independiente para consultar métricas, usuarios y mascotas de
PetReminder, y para activar o deshabilitar cuentas.

El mismo modulo visual tambien se utiliza dentro de `petreminder_user` mediante
una dependencia local. En Android sus rutas usan el prefijo `/admin`; el panel
web conserva `/dashboard` y `/users`.

## Seguridad

El acceso requiere Firebase Authentication y el Custom Claim `admin: true`.
Firestore vuelve a validar ese claim en cada lectura administrativa y solo
permite modificar el campo `accountStatus` de un usuario.

## Conceder acceso al primer administrador

1. En Firebase Console abre **Configuración del proyecto > Cuentas de servicio**
   y genera una clave privada.
2. Guarda la clave fuera de este proyecto.
3. En PowerShell configura la credencial y ejecuta el script:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\ruta\service-account.json"
$adminPassword = Read-Host 'Contraseña a asignar (solo si vas a crear o cambiar la cuenta)' -AsSecureString
$env:PETREMINDER_ADMIN_PASSWORD = [System.Net.NetworkCredential]::new('', $adminPassword).Password
cd tools
npm install
npm run seed-admin
Remove-Item Env:PETREMINDER_ADMIN_PASSWORD
```

Esto crea o actualiza la cuenta administrativa:

- Usuario: `eileno`
- Correo interno: `eileno@petreminder.local`
- La contraseña se proporciona localmente, nunca se guarda en este repositorio.

El script conserva los otros custom claims y no altera otras cuentas. Si la
cuenta ya existe y no se define `PETREMINDER_ADMIN_PASSWORD`, conserva su
contraseña. La aplicación acepta tanto el usuario anterior como su correo
interno, y el servidor debe conceder `admin: true`. Escribir ese usuario no
concede permisos por sí solo. No ejecutar el script para crear cuentas sin
autorización del responsable del proyecto.

Para asignar el permiso a otra cuenta existente, usa el mismo entorno y cambia
solo el ultimo comando:

```powershell
npm run set-admin -- correo@ejemplo.com
```

La persona debe cerrar cualquier sesión anterior e iniciar sesión nuevamente
para recibir el claim actualizado.

## Ejecutar

```powershell
flutter pub get
flutter run -d chrome
```

## Verificar y publicar

```powershell
flutter analyze
flutter test
flutter build web
firebase deploy --only firestore:rules,hosting
```

Las fotografías de mascotas permanecen únicamente en el teléfono del usuario,
por lo que el panel muestra un marcador cuando no existe una URL remota.
