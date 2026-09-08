import { STORAGE_KEYS, readUserStorage, writeUserStorage } from './storage';

// One repository contract keeps the Web cache and a future Firebase adapter interchangeable.
export function createLocalRepository() {
  return {
    async getProfile() { return readUserStorage(STORAGE_KEYS.profile, null); },
    async saveProfile(profile) { writeUserStorage(STORAGE_KEYS.profile, profile); return profile; },
    async getPlan() { return readUserStorage(STORAGE_KEYS.plan, null); },
    async savePlan(plan) { writeUserStorage(STORAGE_KEYS.plan, plan); return plan; },
    async getWorkoutHistory() { return readUserStorage(STORAGE_KEYS.workoutHistory, []); },
    async appendWorkout(entry) { const history = readUserStorage(STORAGE_KEYS.workoutHistory, []); const next = [entry, ...history].slice(0, 100); writeUserStorage(STORAGE_KEYS.workoutHistory, next); return next; },
    async getFavorites() { return readUserStorage(STORAGE_KEYS.favorites, []); },
    async saveFavorites(favorites) { writeUserStorage(STORAGE_KEYS.favorites, favorites); return favorites; },
  };
}

export function createFirebaseRepository({ firestore, uid }) {
  if (!firestore || !uid) throw new Error('Firebase repository requires firestore and uid.');
  const ref = firestore.collection('users').doc(uid);
  return {
    async getProfile() { return (await ref.get()).data()?.profile || null; },
    async saveProfile(profile) { await ref.set({ profile }, { merge: true }); return profile; },
    async getPlan() { return (await ref.get()).data()?.plan || null; },
    async savePlan(plan) { await ref.set({ plan }, { merge: true }); return plan; },
    async getWorkoutHistory() { return (await ref.get()).data()?.workoutHistory || []; },
    async appendWorkout(entry) { const current = await this.getWorkoutHistory(); const next = [entry, ...current].slice(0, 100); await ref.set({ workoutHistory: next }, { merge: true }); return next; },
    async getFavorites() { return (await ref.get()).data()?.favorites || []; },
    async saveFavorites(favorites) { await ref.set({ favorites }, { merge: true }); return favorites; },
  };
}

export function createRepository({ firestore, uid } = {}) {
  return firestore && uid ? createFirebaseRepository({ firestore, uid }) : createLocalRepository();
}
