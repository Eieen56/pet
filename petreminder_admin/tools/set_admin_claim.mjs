import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { pathToFileURL } from 'node:url';

const defaultAdmin = {
  username: 'eileno',
  email: 'eileno@petreminder.local',
};

export async function provisionAdmin(auth, login, passwordToSet) {
  if (!login) {
    throw new Error('Indica usuario o correo.');
  }

  const email =
    login.toLowerCase() === defaultAdmin.username ? defaultAdmin.email : login;
  let user;
  try {
    user = await auth.getUserByEmail(email);
    if (passwordToSet) {
      user = await auth.updateUser(user.uid, { password: passwordToSet });
    }
  } catch (error) {
    if (error.code !== 'auth/user-not-found') {
      throw error;
    }
    if (!passwordToSet) {
      throw new Error(`No existe ${email}. Define PETREMINDER_ADMIN_PASSWORD para crearlo.`);
    }
    user = await auth.createUser({
      email,
      password: passwordToSet,
      displayName:
        login.toLowerCase() === defaultAdmin.username
          ? defaultAdmin.username
          : email,
    });
  }

  await auth.setCustomUserClaims(user.uid, {
    ...(user.customClaims ?? {}),
    admin: true,
  });
  await auth.revokeRefreshTokens(user.uid);

  console.log(`Cuenta admin lista: ${login} -> ${email} (${user.uid}).`);
  return auth.getUser(user.uid);
}

async function main() {
  const login = process.argv[2]?.trim() ?? defaultAdmin.username;
  initializeApp({
    credential: applicationDefault(),
    projectId: process.env.GOOGLE_CLOUD_PROJECT || 'petreminder-user-2026',
  });
  await provisionAdmin(getAuth(), login, process.env.PETREMINDER_ADMIN_PASSWORD);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main().catch((error) => {
  if (error.code === 'app/invalid-credential') {
    console.error(
      'No se pudieron cargar credenciales de Firebase Admin. Configura GOOGLE_APPLICATION_CREDENTIALS con la clave de servicio y vuelve a ejecutar npm run seed-admin.',
    );
  } else {
    console.error(`No se pudo preparar el administrador: ${error.code ?? error.message}`);
  }
  process.exitCode = 1;
});
