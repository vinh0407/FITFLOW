export const STORAGE_KEYS = {
  theme: 'fitflow-theme',
  profile: 'fitflow-profile',
  plan: 'fitflow-7-day-plan',
  favorites: 'fitflow-favorite-foods',
  workoutHistory: 'fitflow-workout-history',
};

export function readStorage(key, fallback) {
  if (typeof window === 'undefined') return fallback;
  try {
    const value = window.localStorage.getItem(key);
    return value === null ? fallback : JSON.parse(value);
  } catch {
    return fallback;
  }
}

export function writeStorage(key, value) {
  if (typeof window === 'undefined') return;
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
  } catch {
    // Storage can be unavailable in private mode or when the quota is full.
  }
}
