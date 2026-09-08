import test, { beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { register, logout } from '../lib/auth.js';
import { STORAGE_KEYS, readUserStorage, writeStorage, userStorageKey } from '../lib/storage.js';

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

test('migration retains the original workout history when scoped storage is full', async () => {
  await register({ name: 'Member', email: 'member@example.test', password: 'Example1234' });
  const history = [{ id: 'session-1', date: '2026-09-01' }];
  writeStorage(STORAGE_KEYS.workoutHistory, history);
  window.localStorage.setItem = () => { throw new DOMException('Full', 'QuotaExceededError'); };
  assert.deepEqual(readUserStorage(STORAGE_KEYS.workoutHistory, []), history);
  assert.equal(values.has(STORAGE_KEYS.workoutHistory), true, 'Original history must survive a failed migration');
  assert.deepEqual(JSON.parse(values.get(STORAGE_KEYS.workoutHistory)), history);
  assert.equal(values.has(userStorageKey(STORAGE_KEYS.workoutHistory)), false);
});

test('successful migration preserves content and cannot expose it to a second account', async () => {
  await register({ name: 'First', email: 'first@example.test', password: 'Example1234' });
  writeStorage(STORAGE_KEYS.favorites, ['apple']);
  assert.deepEqual(readUserStorage(STORAGE_KEYS.favorites, []), ['apple']);
  assert.equal(values.has(STORAGE_KEYS.favorites), false);
  logout();
  await register({ name: 'Second', email: 'second@example.test', password: 'Example1234' });
  assert.deepEqual(readUserStorage(STORAGE_KEYS.favorites, []), []);
});
