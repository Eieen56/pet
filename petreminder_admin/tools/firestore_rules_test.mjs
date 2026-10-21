import { readFile } from 'node:fs/promises';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  collectionGroup,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
} from 'firebase/firestore';

const projectId = 'demo-petreminder-tests';
const rules = await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8');
const environment = await initializeTestEnvironment({
  projectId,
  firestore: { rules },
});

const userData = (uid, status = 'active') => ({
  uid,
  name: uid === 'owner' ? 'Usuario Prueba' : 'Otro Usuario',
  email: `${uid}@example.com`,
  photoUrl: null,
  createdAt: new Date('2026-01-01T00:00:00Z'),
  lastActivity: new Date('2026-01-01T00:00:00Z'),
  accountStatus: status,
});

const petData = {
  name: 'Max',
  species: 'Perro',
  breed: '',
  age: 3,
  description: '',
  photoUrl: null,
  createdAt: new Date('2026-01-01T00:00:00Z'),
};

try {
  await environment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/owner'), userData('owner'));
    await setDoc(doc(db, 'users/disabled'), userData('disabled', 'disabled'));
    await setDoc(doc(db, 'users/other'), userData('other'));
    await setDoc(doc(db, 'users/owner/pets/max'), petData);
    await setDoc(doc(db, 'users/other/pets/luna'), {
      ...petData,
      name: 'Luna',
      species: 'Gato',
    });
  });

  const guest = environment.unauthenticatedContext().firestore();
  const owner = environment
    .authenticatedContext('owner', { email: 'owner@example.com' })
    .firestore();
  const disabled = environment
    .authenticatedContext('disabled', { email: 'disabled@example.com' })
    .firestore();
  const admin = environment
    .authenticatedContext('admin', { admin: true, email: 'admin@example.com' })
    .firestore();

  await assertFails(getDoc(doc(guest, 'users/owner')));
  await assertSucceeds(getDoc(doc(owner, 'users/owner')));
  await assertFails(getDoc(doc(owner, 'users/other')));
  await assertFails(getDocs(collection(owner, 'users')));
  await assertSucceeds(getDoc(doc(owner, 'users/owner/pets/max')));
  await assertFails(getDoc(doc(owner, 'users/other/pets/luna')));
  await assertFails(getDocs(collectionGroup(owner, 'pets')));
  await assertFails(getDoc(doc(disabled, 'users/disabled/pets/any')));
  await assertFails(
    updateDoc(doc(owner, 'users/owner'), { accountStatus: 'disabled' }),
  );

  await assertSucceeds(getDocs(collection(admin, 'users')));
  await assertSucceeds(getDocs(collectionGroup(admin, 'pets')));
  const limits = {Perro: 30, Gato: 30, Conejo: 20, Ave: 100, 'Hámster': 5, Tortuga: 200, Pez: 100, Otro: 250};
  for (const [species, maxAge] of Object.entries(limits)) {
    const target = doc(owner, `users/owner/pets/limits-${species}`);
    const data = {...petData, species, age: maxAge, ageMonths: 0,
      customSpecies: species === 'Otro' ? 'Hurón' : '', createdAt: serverTimestamp()};
    await assertSucceeds(setDoc(target, data));
    await assertFails(updateDoc(target, {ageMonths: 1}));
    await assertFails(updateDoc(target, {age: -1}));
    await assertFails(updateDoc(target, {age: 0, ageMonths: 12}));
    await assertSucceeds(updateDoc(target, {age: 0, ageMonths: 11}));
    await assertFails(updateDoc(target, {name: 'a'}));
    await assertFails(updateDoc(target, {name: 'a'.repeat(61)}));
    await assertFails(updateDoc(target, {breed: 'a'.repeat(81)}));
    await assertFails(updateDoc(target, {description: 'a'.repeat(501)}));
  }
  const schedule = doc(owner, 'users/owner/pets/max/feedingSchedules/s');
  await assertSucceeds(setDoc(schedule, {id:'s', time:'08:00', active:true, createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(owner, 'users/owner/pets/missing/feedingSchedules/s'),
    {id:'s', time:'08:00', active:true, createdAt:serverTimestamp()}));
  const historyData = {id:'meal', userId:'owner', petId:'max', petName:'Max',
    scheduleId:'s', scheduledTime:'08:00', dateKey:'2026-10-20', status:'pending', fedAt:null, createdAt:serverTimestamp()};
  const meal = doc(owner,'users/owner/feedingHistory/meal');
  await assertSucceeds(setDoc(meal,historyData));
  await assertSucceeds(updateDoc(meal,{scheduledTime:'09:00'}));
  await assertSucceeds(updateDoc(meal,{status:'fed',fedAt:serverTimestamp()}));
  await assertFails(updateDoc(meal,{scheduledTime:'10:00'}));
  await deleteDoc(schedule);
  await assertFails(setDoc(doc(owner,'users/owner/feedingHistory/removed'),
    {...historyData,id:'removed'}));
  await assertSucceeds(
    updateDoc(doc(admin, 'users/owner'), { accountStatus: 'disabled' }),
  );
  await assertFails(updateDoc(doc(admin, 'users/other'), { name: 'Cambio' }));
  await assertFails(setDoc(doc(admin, 'users/other/pets/new'), petData));

  console.log('Firestore rules: todas las pruebas pasaron.');
} finally {
  await environment.cleanup();
}
