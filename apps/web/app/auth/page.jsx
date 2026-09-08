'use client';

import { useEffect, useState } from 'react';
import { login, register, requestPasswordReset, resetPassword } from '../../lib/auth';

const copy = {
  login: { eyebrow: 'MEMBER ACCESS', title: 'WELCOME BACK.', action: 'SIGN IN', switch: 'CREATE ACCOUNT', prompt: 'New to FITFLOW?' },
  register: { eyebrow: 'START HERE', title: 'MAKE IT YOURS.', action: 'CREATE ACCOUNT', switch: 'SIGN IN', prompt: 'Already have an account?' },
};

export default function AuthPage() {
  const [mode, setMode] = useState('login');
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [password, setPassword] = useState('');
  const [token, setToken] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [resetLink, setResetLink] = useState('');

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const nextMode = params.get('mode');
    if (['login', 'register', 'forgot', 'reset'].includes(nextMode)) setMode(nextMode);
    setEmail(params.get('email') || '');
    setToken(params.get('token') || '');
  }, []);

  const clearFeedback = () => { setError(''); setMessage(''); setResetLink(''); };
  const switchMode = (nextMode) => { clearFeedback(); setMode(nextMode); setPassword(''); window.history.replaceState({}, '', `/auth${nextMode === 'login' ? '' : `?mode=${nextMode}`}`); };

  async function handleSubmit(event) {
    event.preventDefault();
    clearFeedback();
    setBusy(true);
    try {
      let result;
      if (mode === 'login') result = await login({ email, password });
      if (mode === 'register') result = await register({ name, email, password });
      if (mode === 'forgot') {
        result = await requestPasswordReset(email);
        if (result.token) setResetLink(`/auth?mode=reset&email=${encodeURIComponent(email)}&token=${result.token}`);
      }
      if (mode === 'reset') result = await resetPassword({ email, token, password });
      if (!result?.ok) setError(result?.error || 'Something went wrong. Try again.');
      else if (mode === 'login' || mode === 'register' || mode === 'reset') window.location.assign('/account');
      else setMessage(result.message);
    } catch {
      setError('This device could not complete the request. Try again.');
    } finally {
      setBusy(false);
    }
  }

  const activeCopy = copy[mode] || copy.login;
  return (
    <main className="auth-shell">
      <header className="auth-header"><a className="wordmark" href="/" aria-label="FITFLOW home"><span className="mark">F</span> FITFLOW</a><a className="back-link" href="/">← BACK TO HOME</a></header>
      <section className="auth-layout">
        <div className="auth-intro"><span className="footer-label">FITFLOW / PERSONAL ACCESS</span><h1>{mode === 'forgot' ? 'FIND YOUR WAY BACK.' : mode === 'reset' ? 'SET A NEW PASSWORD.' : activeCopy.title}</h1><p>{mode === 'forgot' ? 'Enter your email to start a local password reset.' : mode === 'reset' ? 'Choose a new password for this device.' : 'Keep your training history, profile, and plans together.'}</p><div className="auth-signal"><strong>PRIVATE BY DEFAULT.</strong><span>Your account stays on this device in this prototype.</span></div></div>
        <form className="auth-form" onSubmit={handleSubmit} noValidate>
          <span className="footer-label">{mode === 'forgot' || mode === 'reset' ? 'ACCOUNT RECOVERY' : activeCopy.eyebrow}</span>
          {mode === 'register' && <label>NAME<input value={name} onChange={(event) => setName(event.target.value)} autoComplete="name" required /></label>}
          <label>EMAIL<input type="email" value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="email" required /></label>
          {mode === 'reset' && <label>RESET TOKEN<input value={token} onChange={(event) => setToken(event.target.value)} autoComplete="one-time-code" required /></label>}
          {mode !== 'forgot' && <label>PASSWORD<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete={mode === 'login' ? 'current-password' : 'new-password'} required /><small>8+ characters, one letter, one number.</small></label>}
          {error && <p className="auth-feedback auth-error" role="alert">{error}</p>}
          {message && <p className="auth-feedback auth-success" role="status">{message}</p>}
          {resetLink && <div className="auth-reset-link"><span>LOCAL RESET LINK</span><a href={resetLink}>OPEN RESET FORM →</a></div>}
          <button className="red-action auth-submit" type="submit" disabled={busy}>{busy ? 'WORKING...' : mode === 'forgot' ? 'SEND RESET LINK' : mode === 'reset' ? 'RESET PASSWORD' : activeCopy.action} <span>→</span></button>
          {mode === 'login' && <button className="auth-text-button" type="button" onClick={() => switchMode('forgot')}>FORGOT PASSWORD?</button>}
          {(mode === 'login' || mode === 'register') && <p className="auth-switch">{activeCopy.prompt} <button type="button" onClick={() => switchMode(mode === 'login' ? 'register' : 'login')}>{activeCopy.switch}</button></p>}
          {(mode === 'forgot' || mode === 'reset') && <button className="auth-text-button" type="button" onClick={() => switchMode('login')}>← BACK TO SIGN IN</button>}
          <p className="auth-disclaimer">Local-first prototype: passwords are hashed with Web Crypto and never stored as plain text. Email delivery and server-side account recovery require a production auth provider.</p>
        </form>
      </section>
    </main>
  );
}
