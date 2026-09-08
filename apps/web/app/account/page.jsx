'use client';

import { useCallback, useEffect, useState } from 'react';
import { EMPTY_PROFILE, getCurrentUser, getSession, logout, updateProfile } from '../../lib/auth';
import { useModalAccessibility } from '../../lib/modal-accessibility';
import { STORAGE_KEYS, writeUserStorage } from '../../lib/storage';

export default function AccountPage() {
  const [user, setUser] = useState(null);
  const [form, setForm] = useState({ name: '', ...EMPTY_PROFILE });
  const [checking, setChecking] = useState(true);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState('');
  const [logoutConfirmOpen, setLogoutConfirmOpen] = useState(false);
  const closeLogoutConfirm = useCallback(() => setLogoutConfirmOpen(false), []);

  useModalAccessibility(logoutConfirmOpen, closeLogoutConfirm);

  useEffect(() => {
    const session = getSession();
    if (!session) {
      window.location.assign('/auth?next=/account');
      return;
    }
    const currentUser = getCurrentUser();
    if (!currentUser) {
      window.location.assign('/auth?next=/account');
      return;
    }
    setUser(currentUser);
    setForm({ ...EMPTY_PROFILE, ...(currentUser.profile || {}), name: currentUser.name });
    setChecking(false);
  }, []);

  const updateField = (field) => (event) => {
    setSaved(false);
    setError('');
    setForm((current) => ({ ...current, [field]: event.target.value }));
  };

  const save = (event) => {
    event.preventDefault();
    setSaved(false);
    setError('');
    const result = updateProfile({ name: form.name, profile: form });
    if (!result.ok) {
      setError(result.error);
      return;
    }
    setUser(result.user);
    setForm({ ...result.user.profile, name: result.user.name });
    const height = Number(result.user.profile.heightCm);
    const weight = Number(result.user.profile.weightKg);
    if (height > 0 && weight > 0) writeUserStorage(STORAGE_KEYS.profile, { height, weight, bmi: Math.round(weight / ((height / 100) ** 2)), savedAt: new Date().toISOString() });
    setSaved(true);
  };

  if (checking) return <main className="auth-shell"><div className="auth-loading">CHECKING SESSION...</div></main>;

  return <main className="auth-shell">
    <header className="auth-header">
      <a className="wordmark" href="/" aria-label="FITFLOW home">
        <span className="mark">F</span> FITFLOW <span className="os-tag">// OS</span>
      </a>
      <button className="auth-signout" onClick={() => setLogoutConfirmOpen(true)}>LOG OUT</button>
    </header>
    <section className="account-layout">
      <div className="account-intro"><span className="footer-label">PERSONAL PROFILE</span><h1>YOUR<br /><em>STARTING LINE.</em></h1><p>Keep the numbers that shape your training in one place. FITFLOW uses them to guide your plan; it does not diagnose or replace professional health advice.</p><div className="account-links"><a href="/#plans">VIEW MY PLAN →</a><a href="/#workouts">START WORKOUT →</a><a href="/nutrition">OPEN NUTRITION →</a></div></div>
      <form className="account-panel account-form" onSubmit={save}>
        <span className="footer-label">SIGNED IN AS</span><strong>{user?.email}</strong>
        <label>NAME<input value={form.name} onChange={updateField('name')} autoComplete="name" required /></label>
        <div className="account-fields"><label>AGE<input type="number" min="13" max="120" value={form.age} onChange={updateField('age')} /></label><label>HEIGHT / CM<input type="number" min="100" max="250" step="any" value={form.heightCm} onChange={updateField('heightCm')} /></label><label>WEIGHT / KG<input type="number" min="25" max="300" step="any" value={form.weightKg} onChange={updateField('weightKg')} /></label><label>RESTING HEART RATE<input type="number" min="30" max="220" value={form.restingHeartRate} onChange={updateField('restingHeartRate')} /></label></div>
        <label>TRAINING GOAL<select value={form.trainingGoal} onChange={updateField('trainingGoal')}><option>BUILD CONSISTENCY</option><option>BUILD STRENGTH</option><option>IMPROVE CONDITIONING</option><option>MOVE MORE</option><option>IMPROVE MOBILITY</option></select></label>
        <div className="account-fields"><label>TRAINING LEVEL<select value={form.trainingLevel} onChange={updateField('trainingLevel')}><option>BEGINNER</option><option>INTERMEDIATE</option><option>ADVANCED</option></select></label><label>DAYS / WEEK<select value={form.daysPerWeek} onChange={updateField('daysPerWeek')}><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option></select></label></div>
        <label>HEALTH NOTES / LIMITATIONS<textarea value={form.healthNotes} onChange={updateField('healthNotes')} rows="4" placeholder="Optional: injuries, limitations, or preferences" /></label>
        {error && <p className="auth-feedback auth-error" role="alert">{error}</p>}{saved && <p className="auth-feedback auth-success" role="status">PROFILE SAVED ON THIS DEVICE.</p>}
        <button className="red-action auth-submit" type="submit">SAVE PROFILE <span>→</span></button>
        <small className="account-privacy">PRIVATE BY DEFAULT / STORED WITH YOUR LOCAL ACCOUNT</small>
      </form>
    </section>
    {logoutConfirmOpen && <div className="modal-backdrop logout-confirm-backdrop" onClick={closeLogoutConfirm}><section className="donate-modal logout-confirm-modal" role="dialog" aria-modal="true" aria-labelledby="account-logout-title" aria-describedby="account-logout-copy" onClick={(event) => event.stopPropagation()}><button className="close-modal" onClick={closeLogoutConfirm} aria-label="Close logout confirmation">×</button><h2 id="account-logout-title">LEAVE<br /><em>FITFLOW?</em></h2><p id="account-logout-copy">Your saved data stays on this device. You can sign in again whenever you are ready.</p><div className="logout-confirm-actions"><button type="button" className="clear-filter" onClick={closeLogoutConfirm}>CANCEL</button><button type="button" className="red-action" onClick={() => { logout(); window.location.assign('/auth'); }}>LOG OUT <span>→</span></button></div></section></div>}
  </main>;
}
