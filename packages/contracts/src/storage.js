export function scopeStorageKey(key, accountId) {
  return accountId ? `${key}:${encodeURIComponent(accountId)}` : null;
}
