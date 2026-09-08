import { getCurrentUser } from './auth.js';
import { scopeStorageKey } from '@fitflow/contracts/storage';

export const STORAGE_KEYS = {
  theme: 'fitflow-theme',
  profile: 'fitflow-profile',
  plan: 'fitflow-7-day-plan',
  favorites: 'fitflow-favorite-foods',
  workoutHistory: 'fitflow-workout-history',
};

export function userStorageKey(key, email = getCurrentUser()?.email) {
  return scopeStorageKey(key, email);
}

export function readUserStorage(key, fallback) {
  const scopedKey = userStorageKey(key);
  if (!scopedKey) return fallback;
  const scopedValue = readStorage(scopedKey, null);
  if (scopedValue !== null) return scopedValue;
  const legacyValue = readStorage(key, fallback);
  if (legacyValue !== fallback && writeStorage(scopedKey, legacyValue)) {
    removeStorage(key);
  }
  return legacyValue;
}

export function writeUserStorage(key, value) {
  const scopedKey = userStorageKey(key);
  return scopedKey ? writeStorage(scopedKey, value) : false;
}

export function removeStorage(key) {
  if (typeof window === 'undefined') return;
  try {
    window.localStorage.removeItem(key);
  } catch {
    // Storage can be unavailable in private mode.
  }
}

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
  if (typeof window === 'undefined') return false;
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
    return true;
  } catch {
    // Storage can be unavailable in private mode or when the quota is full.
    return false;
  }
}
