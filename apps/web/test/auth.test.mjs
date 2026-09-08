import test, { beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { register, login, logout, getSession, getCurrentUser, requestPasswordReset, resetPassword, updateProfile } from '../lib/auth.js';

// Only the browser storage boundary is replaced; hashing and auth run unchanged.
let values;
beforeEach(() => {
  values = new Map();
  globalThis.window = { localStorage: {
    getItem: (key) => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, value),
    removeItem: (key) => values.delete(key),
  } };
});
afterEach(() => { delete globalThis.window; });
const account = { name: 'Test member', email: 'test@example.test', password: 'Example1234' };

test('profile updates preserve decimal measurements and shared coaching fields', async () => {
  await register(account);
  const result = updateProfile({ name: account.name, profile: {
    heightCm: '175.5', weightKg: '100.5', gender: 'female', age: '30',
    targetWeightKg: '90.5', equipment: ['DUMBBELL'], focusAreas: ['CORE'],
    sessionMinutes: '45', experience: 'INTERMEDIATE',
  } });
  assert.equal(result.ok, true);
  const { profile } = getCurrentUser();
  assert.equal(profile.heightCm, '175.5');
  assert.equal(profile.weightKg, '100.5');
  assert.equal(profile.gender, 'female');
  assert.equal(profile.targetWeightKg, '90.5');
  assert.deepEqual(profile.equipment, ['DUMBBELL']);
  assert.deepEqual(profile.focusAreas, ['CORE']);
  assert.equal(profile.sessionMinutes, '45');
  assert.equal(profile.experience, 'INTERMEDIATE');
});

test('editing one profile field does not reset existing profile fields', async () => {
  await register(account);
  updateProfile({ profile: { age: '30', heightCm: '175', weightKg: '70', healthNotes: 'Existing note' } });
  assert.equal(updateProfile({ profile: { weightKg: '71' } }).ok, true);
  assert.equal(getCurrentUser().profile.age, '30');
  assert.equal(getCurrentUser().profile.healthNotes, 'Existing note');
});

test('profile storage failure returns an actionable error without claiming a save', async () => {
  await register(account);
  window.localStorage.setItem = () => { throw new DOMException('Full', 'QuotaExceededError'); };
  const result = updateProfile({ name: 'Unsaved', profile: { age: '30' } });
  assert.equal(result.ok, false);
  assert.ok(result.error.includes('storage'));
  assert.equal(getCurrentUser().name, account.name);
});

test('malformed session expiry and missing identity cannot count as signed in', async () => {
  await register(account);
  const valid = getSession();
  for (const changes of [{ expiresAt: 'invalid' }, { expiresAt: null }, { expiresAt: 99999999999999 },
    { email: null }, { token: '' }, { expiresAt: '2000-01-01T00:00:00.000Z' }]) {
    values.set('fitflow-auth-session', JSON.stringify({ ...valid, ...changes }));
    assert.equal(getSession(), null, JSON.stringify(changes));
    assert.equal(values.has('fitflow-auth-session'), false);
  }
});

test('session without its local account does not fabricate a signed-in user', async () => {
  await register(account);
  values.delete('fitflow-auth-users');
  assert.equal(getCurrentUser(), null);
});

test('blocked browser storage remains logged out without crashing page startup', () => {
  Object.defineProperty(window, 'localStorage', { get() { throw new DOMException('Blocked', 'SecurityError'); } });
  assert.equal(getCurrentUser(), null);
  assert.equal(getSession(), null);
});

test('legacy local account can still sign in when the account map has not been created', async () => {
  await register(account);
  const user = JSON.parse(values.get('fitflow-auth-users'))[account.email];
  values.set('fitflow-auth-user', JSON.stringify(user));
  values.delete('fitflow-auth-users');
  logout();
  assert.equal((await login(account)).ok, true);
  assert.equal(getCurrentUser().name, account.name);
});

test('invalid reset expiry cannot change a password', async () => {
  await register(account);
  const { token } = await requestPasswordReset(account.email);
  const reset = JSON.parse(values.get('fitflow-auth-reset'));
  values.set('fitflow-auth-reset', JSON.stringify({ ...reset, expiresAt: 'invalid' }));
  assert.equal((await resetPassword({ email: account.email, token, password: 'NewPassword123' })).ok, false);
  logout();
  assert.equal((await login(account)).ok, true);
});

test('registration, logout, login and valid password reset still work locally', async () => {
  assert.equal((await register(account)).ok, true);
  assert.equal(getCurrentUser().email, account.email);
  logout();
  assert.equal(getSession(), null);
  assert.equal((await login({ ...account, password: 'Wrong123' })).ok, false);
  assert.equal((await login(account)).ok, true);
  const { token } = await requestPasswordReset(account.email);
  assert.equal((await resetPassword({ email: account.email, token, password: 'NewPassword123' })).ok, true);
  logout();
  assert.equal((await login({ ...account, password: 'NewPassword123' })).ok, true);
});
