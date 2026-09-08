import { DEFAULT_PROFILE, validateProfile } from '@fitflow/contracts';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  updateProfile as updateFirebaseProfile,
  sendPasswordResetEmail,
} from 'firebase/auth';
import { auth } from './firebase.js';

const USERS_KEY = 'fitflow-auth-users';
const LEGACY_USER_KEY = 'fitflow-auth-user';
const SESSION_KEY = 'fitflow-auth-session';
const RESET_KEY = 'fitflow-auth-reset';
const SESSION_DAYS = 30;
const RESET_MINUTES = 30;

export const EMPTY_PROFILE = DEFAULT_PROFILE;

function getStorage() {
  if (typeof window === 'undefined') return null;
  return window.localStorage;
}

function read(key, fallback = null) {
  try {
    const value = getStorage()?.getItem(key);
    return value ? JSON.parse(value) : fallback;
  } catch {
    return fallback;
  }
}

function readUsers() {
  const users = read(USERS_KEY);
  if (users && typeof users === 'object' && !Array.isArray(users)) return users;
  const legacyUser = read(LEGACY_USER_KEY);
  return legacyUser?.email ? { [legacyUser.email]: legacyUser } : {};
}

function write(key, value) {
  getStorage()?.setItem(key, JSON.stringify(value));
}

function remove(key) {
  getStorage()?.removeItem(key);
}

function randomToken(bytes = 24) {
  const values = new Uint8Array(bytes);
  crypto.getRandomValues(values);
  return Array.from(values, (value) => value.toString(16).padStart(2, '0')).join('');
}

function encodeBytes(bytes) {
  return btoa(String.fromCharCode(...new Uint8Array(bytes)));
}

async function hashPassword(password, salt) {
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', salt: new TextEncoder().encode(salt), iterations: 120000, hash: 'SHA-256' }, key, 256);
  return encodeBytes(bits);
}

function validatePassword(password) {
  if (typeof password !== 'string' || password.length < 8) return 'Use at least 8 characters for your password.';
  if (!/[A-Za-z]/.test(password) || !/\d/.test(password)) return 'Use at least one letter and one number.';
  return '';
}

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

export async function register({ name, email, password }) {
  const normalizedEmail = normalizeEmail(email);
  if (!normalizedEmail.includes('@')) return { ok: false, error: 'Enter a valid email address.' };
  const passwordError = validatePassword(password);
  if (passwordError) return { ok: false, error: passwordError };

  let firebaseUid = null;
  if (typeof window !== 'undefined' && auth) {
    try {
      const cred = await createUserWithEmailAndPassword(auth, normalizedEmail, password);
      if (cred?.user) {
        firebaseUid = cred.user.uid;
        if (name) {
          try {
            await updateFirebaseProfile(cred.user, { displayName: name });
          } catch {}
        }
      }
    } catch (fbError) {
      if (fbError.code === 'auth/email-already-in-use') {
        return { ok: false, error: 'Email này đã được đăng ký trên hệ thống FITFLOW.' };
      }
      if (fbError.code === 'auth/invalid-email') {
        return { ok: false, error: 'Địa chỉ email không hợp lệ.' };
      }
      if (fbError.code === 'auth/weak-password') {
        return { ok: false, error: 'Mật khẩu quá yếu (yêu cầu ít nhất 6 ký tự).' };
      }
      if (fbError.code === 'auth/operation-not-allowed') {
        return { ok: false, error: 'Chưa kích hoạt Email/Password trên Firebase Console (Authentication > Sign-in method).' };
      }
      console.warn('Firebase Auth registration notice:', fbError?.message);
    }
  }

  const users = readUsers();
  if (users[normalizedEmail]) return { ok: false, error: 'An account already exists on this device.' };

  const salt = randomToken(16);
  const user = {
    name: String(name || 'FITFLOW member').trim().slice(0, 60) || 'FITFLOW member',
    email: normalizedEmail,
    profile: { ...EMPTY_PROFILE },
    salt,
    passwordHash: await hashPassword(password, salt),
    createdAt: new Date().toISOString(),
    firebaseUid,
  };
  write(USERS_KEY, { ...users, [normalizedEmail]: user });
  createSession(user);
  return { ok: true, user: publicUser(user) };
}

export async function login({ email, password }) {
  const normalizedEmail = normalizeEmail(email);
  let firebaseUser = null;

  if (typeof window !== 'undefined' && auth) {
    try {
      const cred = await signInWithEmailAndPassword(auth, normalizedEmail, password);
      firebaseUser = cred.user;
    } catch (fbError) {
      if (
        fbError.code === 'auth/user-not-found' ||
        fbError.code === 'auth/wrong-password' ||
        fbError.code === 'auth/invalid-credential'
      ) {
        return { ok: false, error: 'Email hoặc mật khẩu không chính xác.' };
      }
      if (fbError.code === 'auth/too-many-requests') {
        return { ok: false, error: 'Quá nhiều lần thử thất bại. Vui lòng thử lại sau.' };
      }
      if (fbError.code === 'auth/user-disabled') {
        return { ok: false, error: 'Tài khoản này đã bị tạm khóa.' };
      }
      console.warn('Firebase Auth login notice:', fbError?.message);
    }
  }

  const users = readUsers();
  let user = users[normalizedEmail];

  if (firebaseUser) {
    // If account was created on Mobile or another device, auto-register in local storage for Web!
    if (!user) {
      const salt = randomToken(16);
      user = {
        name: firebaseUser.displayName || 'FITFLOW member',
        email: normalizedEmail,
        profile: { ...EMPTY_PROFILE },
        salt,
        passwordHash: await hashPassword(password, salt),
        createdAt: new Date().toISOString(),
        firebaseUid: firebaseUser.uid,
      };
      write(USERS_KEY, { ...users, [normalizedEmail]: user });
    }
    createSession(user);
    return { ok: true, user: publicUser(user) };
  }

  if (!user || user.email !== normalizedEmail) return { ok: false, error: 'Email or password is incorrect.' };
  const passwordHash = await hashPassword(password, user.salt);
  if (passwordHash !== user.passwordHash) return { ok: false, error: 'Email or password is incorrect.' };
  createSession(user);
  return { ok: true, user: publicUser(user) };
}

export function logout() {
  if (typeof window !== 'undefined' && auth) {
    try {
      firebaseSignOut(auth).catch(() => {});
    } catch {}
  }
  remove(SESSION_KEY);
}

export function getSession() {
  const session = read(SESSION_KEY);
  if (!session) return null;
  if (typeof session.email !== 'string' || !session.email ||
      typeof session.token !== 'string' || !session.token || !hasValidExpiry(session.expiresAt)) {
    remove(SESSION_KEY);
    return null;
  }
  return session;
}

export function getCurrentUser() {
  const session = getSession();
  if (!session) return null;
  const user = readUsers()[session.email];
  if (!user || user.email !== session.email) {
    remove(SESSION_KEY);
    return null;
  }
  return publicUser(user);
}

export function updateProfile({ name, profile }) {
  const session = getSession();
  if (!session) return { ok: false, error: 'Sign in to update your profile.' };
  const users = readUsers();
  const user = users[session.email];
  if (!user) return { ok: false, error: 'Your account could not be found on this device.' };
  const mergedProfile = { ...user.profile, ...profile };
  const profileValidation = validateProfile(mergedProfile);
  if (!profileValidation.valid) return { ok: false, error: Object.values(profileValidation.errors)[0] };
  const nextUser = {
    ...user,
    name: String(name || user.name).trim().slice(0, 60) || user.name,
    profile: sanitizeProfile(mergedProfile),
  };
  try {
    write(USERS_KEY, { ...users, [session.email]: nextUser });
    createSession(nextUser);
  } catch (error) {
    if (!['QuotaExceededError', 'SecurityError'].includes(error.name)) throw error;
    return { ok: false, error: 'Could not save. Enable browser storage or free up space, then try again.' };
  }
  return { ok: true, user: publicUser(nextUser) };
}

export async function requestPasswordReset(email) {
  const normalizedEmail = normalizeEmail(email);
  if (typeof window !== 'undefined' && auth && normalizedEmail.includes('@')) {
    try {
      await sendPasswordResetEmail(auth, normalizedEmail);
    } catch (fbError) {
      console.warn('Firebase reset notice:', fbError?.message);
    }
  }
  const user = readUsers()[normalizedEmail];
  if (!user || user.email !== normalizedEmail) return { ok: true, message: 'If an account exists on this device, a reset link is ready.' };
  const token = randomToken(32);
  write(RESET_KEY, { email: normalizedEmail, tokenHash: await hashPassword(token, user.salt), expiresAt: new Date(Date.now() + RESET_MINUTES * 60 * 1000).toISOString() });
  return { ok: true, token, message: 'A local reset link is ready for this device.' };
}

export async function resetPassword({ email, token, password }) {
  const users = readUsers();
  const reset = read(RESET_KEY);
  const normalizedEmail = normalizeEmail(email);
  const passwordError = validatePassword(password);
  if (passwordError) return { ok: false, error: passwordError };
  const user = users[normalizedEmail];
  if (!user || !reset || reset.email !== normalizedEmail || !hasValidExpiry(reset.expiresAt)) return { ok: false, error: 'This reset link is invalid or expired.' };
  const tokenHash = await hashPassword(token, user.salt);
  if (tokenHash !== reset.tokenHash) return { ok: false, error: 'This reset link is invalid or expired.' };
  const nextSalt = randomToken(16);
  write(USERS_KEY, { ...users, [normalizedEmail]: { ...user, salt: nextSalt, passwordHash: await hashPassword(password, nextSalt) } });
  remove(RESET_KEY);
  createSession({ ...user, salt: nextSalt });
  return { ok: true, user: publicUser(user) };
}

function hasValidExpiry(value) {
  return typeof value === 'string' && Number.isFinite(Date.parse(value)) && Date.parse(value) > Date.now();
}

function createSession(user) {
  write(SESSION_KEY, { token: randomToken(), name: user.name, email: user.email, createdAt: new Date().toISOString(), expiresAt: new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000).toISOString() });
}

function publicUser(user) {
  return { name: user.name, email: user.email, createdAt: user.createdAt, profile: { ...EMPTY_PROFILE, ...(user.profile || {}) } };
}

function sanitizeProfile(profile = {}) {
  // Keep the shared profile shape. Numeric text must not lose decimal digits.
  return Object.fromEntries(Object.entries(EMPTY_PROFILE).map(([key, fallback]) => {
    const value = profile[key] ?? fallback;
    return [key, Array.isArray(fallback)
      ? (Array.isArray(value) ? value.filter((item) => typeof item === 'string').slice(0, 30) : fallback)
      : String(value).trim().slice(0, key === 'healthNotes' ? 240 : 60)];
  }));
}
