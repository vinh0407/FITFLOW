'use client';

import { useEffect, useMemo, useState } from 'react';
import { STORAGE_KEYS, readStorage, writeStorage } from '../lib/storage';
import { BMI_PROFILES } from '@fitflow/contracts/bmi';
import { useScrollReveal } from '../lib/scroll-reveal';

const bodyParts = ['ALL', 'CHEST', 'BACK', 'SHOULDERS', 'UPPER ARMS', 'WAIST', 'UPPER LEGS'];
const types = ['STRENGTH', 'BODY WEIGHT', 'CARDIO', 'STRETCHING'];
const pageSize = 9;

function titleCase(value = '') {
  return value.replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function exerciseBenefit(exercise) {
  const focus = titleCase(exercise?.target || exercise?.body_part || 'full body');
  return `Supports ${focus.toLowerCase()} strength, control, and movement confidence when practiced with steady form.`;
}

function shuffle(items) {
  return [...items].sort(() => Math.random() - 0.5);
}

function getBmiProfile(bmi) {
  return BMI_PROFILES.find((profile) => profile.bmi === bmi) || null;
}

export default function Home() {
  useScrollReveal('.site-shell');
  const [allExercises, setAllExercises] = useState([]);
  const [bodyFilter, setBodyFilter] = useState('ALL');
  const [typeFilter, setTypeFilter] = useState('');
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [dark, setDark] = useState(() => readStorage(STORAGE_KEYS.theme, 'light') === 'dark');
  const [savedProfile, setSavedProfile] = useState(() => readStorage(STORAGE_KEYS.profile, null));
  const [savedPlan, setSavedPlan] = useState(() => readStorage(STORAGE_KEYS.plan, null));
  const [workoutHistory, setWorkoutHistory] = useState(() => { const value = readStorage(STORAGE_KEYS.workoutHistory, []); return Array.isArray(value) ? value : []; });
  const [height, setHeight] = useState(() => String(readStorage(STORAGE_KEYS.profile, {})?.height || '170'));
  const [weight, setWeight] = useState(() => String(readStorage(STORAGE_KEYS.profile, {})?.weight || '70'));
  const [planReady, setPlanReady] = useState(() => Boolean(readStorage(STORAGE_KEYS.plan, null)));
  const [currentDay, setCurrentDay] = useState(1);
  const [planSaved, setPlanSaved] = useState(() => Boolean(readStorage(STORAGE_KEYS.plan, null)));
  const [workoutOpen, setWorkoutOpen] = useState(false);
  const [workoutIndex, setWorkoutIndex] = useState(0);
  const [completedSets, setCompletedSets] = useState(0);
  const [workoutSeconds, setWorkoutSeconds] = useState(0);
  const [sessionExercises, setSessionExercises] = useState([]);
  const [selectedExercise, setSelectedExercise] = useState(null);
  const [customDayCount, setCustomDayCount] = useState('7');
  const [customPlanReady, setCustomPlanReady] = useState(false);
  const [customCurrentDay, setCustomCurrentDay] = useState(1);
  const [customPlanSaved, setCustomPlanSaved] = useState(false);
  const [customExerciseIds, setCustomExerciseIds] = useState(null);
  const [customQuery, setCustomQuery] = useState('');
  const [calorieOpen, setCalorieOpen] = useState(false);
  const [calorieAge, setCalorieAge] = useState('25');
  const [calorieSex, setCalorieSex] = useState('male');
  const [calorieActivity, setCalorieActivity] = useState('1.375');
  const [calorieGoal, setCalorieGoal] = useState('maintain');
  const [donateOpen, setDonateOpen] = useState(false);

  useEffect(() => {
    fetch('/data/exercises.json').then((response) => response.json()).then(setAllExercises).finally(() => setLoading(false));
  }, []);

  useEffect(() => { document.documentElement.dataset.theme = dark ? 'dark' : 'light'; writeStorage(STORAGE_KEYS.theme, dark ? 'dark' : 'light'); }, [dark]);

  const featured = useMemo(() => {
    if (!allExercises.length) return null;
    const today = new Date();
    const daySeed = Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()) / 86400000;
    return allExercises[Math.abs(Math.floor(daySeed)) % allExercises.length];
  }, [allExercises]);
  const filteredExercises = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return allExercises.filter((exercise) => {
      const matchesBody = !bodyFilter || bodyFilter === 'ALL' || exercise.body_part?.toUpperCase() === bodyFilter;
      const exerciseName = exercise.name?.toLowerCase() || '';
      const matchesType = !typeFilter || (typeFilter === 'CARDIO' ? exercise.category === 'cardio' : typeFilter === 'STRETCHING' ? exerciseName.includes('stretch') : typeFilter === 'BODY WEIGHT' ? exercise.equipment === 'body weight' : exercise.category !== 'cardio');
      const matchesQuery = !needle || `${exercise.name} ${exercise.category} ${exercise.body_part} ${exercise.equipment} ${exercise.target}`.toLowerCase().includes(needle);
      return matchesBody && matchesType && matchesQuery;
    });
  }, [allExercises, bodyFilter, typeFilter, query]);
  const pageCount = Math.max(1, Math.ceil(filteredExercises.length / pageSize));
  const visibleExercises = filteredExercises.slice((page - 1) * pageSize, page * pageSize);
  const pageNumbers = Array.from({ length: pageCount }, (_, index) => index + 1).filter((number) => number === 1 || number === pageCount || Math.abs(number - page) <= 1);
  const changeBodyFilter = (value) => { setBodyFilter(value); setPage(1); };
  const changeTypeFilter = (value) => { setTypeFilter(value); setPage(1); };
  const bmi = Number(height) > 0 && Number(weight) > 0 ? Number(weight) / ((Number(height) / 100) ** 2) : 0;
  const roundedBmi = Math.round(bmi);
  const bmiProfile = bmi ? getBmiProfile(roundedBmi) : null;
  useEffect(() => { if (!planReady || !bmiProfile) return; const profile = { height: Number(height), weight: Number(weight), bmi: roundedBmi, savedAt: new Date().toISOString() }; writeStorage(STORAGE_KEYS.profile, profile); setSavedProfile(profile); }, [planReady, bmiProfile, height, weight, roundedBmi]);
  const planExercises = useMemo(() => {
    if (!bmiProfile) return [];
    const preferred = bmiProfile.preferred;
    const compatible = allExercises.filter((exercise) => preferred.includes(exercise.equipment));
    const offset = (roundedBmi - 18) * 2;
    return [...compatible.slice(offset), ...compatible.slice(0, offset)].slice(0, 6);
  }, [allExercises, roundedBmi, bmiProfile]);
  const planDays = Array.from({ length: 7 }, (_, index) => { const rest = index === 2 || index === 6; const count = index % 2 === 0 ? 4 : 3; return { day: index + 1, rest, exercises: rest ? [] : Array.from({ length: count }, (_, offset) => planExercises[(index * 3 + offset) % Math.max(planExercises.length, 1)]).filter(Boolean) }; });
  const selectedDay = planDays[currentDay - 1];
  const savePlan = () => { const profile = { height: Number(height), weight: Number(weight), bmi: roundedBmi, savedAt: new Date().toISOString() }; const plan = { ...profile, focus: bmiProfile?.tone || 'BALANCE', days: planDays, savedAt: new Date().toISOString() }; writeStorage(STORAGE_KEYS.profile, profile); writeStorage(STORAGE_KEYS.plan, plan); setSavedProfile(profile); setSavedPlan(plan); setPlanSaved(true); };
  const customPool = customExerciseIds === null ? allExercises.slice(0, 8) : allExercises.filter((exercise) => customExerciseIds.includes(exercise.id));
  const customPickerExercises = useMemo(() => { const needle = customQuery.trim().toLowerCase(); return allExercises.filter((exercise) => !needle || `${exercise.name} ${exercise.body_part} ${exercise.equipment} ${exercise.target}`.toLowerCase().includes(needle)).slice(0, 18); }, [allExercises, customQuery]);
  const customDays = Array.from({ length: Math.min(7, Math.max(1, Number(customDayCount) || 1)) }, (_, index) => ({ day: index + 1, exercises: Array.from({ length: index % 2 === 0 ? 4 : 3 }, (_, offset) => customPool[(index * 2 + offset) % Math.max(customPool.length, 1)]).filter(Boolean) }));
  const customSelectedDay = customDays[customCurrentDay - 1];
  const todayWorkoutMinutes = 20;
  const todayWorkoutExerciseMinutes = 4;
  const todayWorkoutTargetSeconds = todayWorkoutMinutes * 60;
  const todayWorkoutExerciseTargetSeconds = todayWorkoutExerciseMinutes * 60;
  const calorieBmr = calorieSex === 'male' ? (10 * Number(weight)) + (6.25 * Number(height)) - (5 * Number(calorieAge)) + 5 : (10 * Number(weight)) + (6.25 * Number(height)) - (5 * Number(calorieAge)) - 161;
  const calorieAdjustment = calorieGoal === 'cut' ? -350 : calorieGoal === 'gain' ? 250 : 0;
  const calorieTarget = Math.max(1200, Math.round(calorieBmr * Number(calorieActivity) + calorieAdjustment));
  const toggleCustomExercise = (id) => { const current = customExerciseIds === null ? allExercises.slice(0, 8).map((exercise) => exercise.id) : customExerciseIds; setCustomExerciseIds(current.includes(id) ? current.filter((item) => item !== id) : [...current, id]); setCustomPlanReady(false); setCustomPlanSaved(false); };
  const workoutExercises = sessionExercises.length ? sessionExercises : (planExercises.length ? planExercises.slice(0, 4) : allExercises.slice(0, 4));
  const activeExercise = workoutExercises[workoutIndex];
  useEffect(() => { if (!workoutOpen) return undefined; const timer = setInterval(() => setWorkoutSeconds((value) => value + 1), 1000); return () => clearInterval(timer); }, [workoutOpen]);
  const makeNextRep = () => {
    const cardio = shuffle(allExercises.filter((exercise) => exercise.category === 'cardio'))[0];
    const bodyMoves = shuffle(allExercises.filter((exercise) => exercise.category !== 'cardio'));
    const uniqueBodyMoves = [];
    const seenParts = new Set();
    bodyMoves.forEach((exercise) => { if (uniqueBodyMoves.length < 4 && !seenParts.has(exercise.body_part)) { seenParts.add(exercise.body_part); uniqueBodyMoves.push(exercise); } });
    return shuffle([...uniqueBodyMoves, cardio].filter(Boolean));
  };
  const startWorkout = (exercises = null) => { setSessionExercises(exercises?.length ? exercises : makeNextRep()); setWorkoutIndex(0); setCompletedSets(0); setWorkoutSeconds(0); setWorkoutOpen(true); };
  const finishSet = () => { if (completedSets < 3) setCompletedSets((value) => value + 1); else if (workoutIndex < workoutExercises.length - 1) { setWorkoutIndex((value) => value + 1); setCompletedSets(0); } else { const entry = { completedAt: new Date().toISOString(), durationSeconds: workoutSeconds, exerciseCount: workoutExercises.length, exerciseIds: workoutExercises.map((exercise) => exercise.id) }; const nextHistory = [entry, ...workoutHistory].slice(0, 50); writeStorage(STORAGE_KEYS.workoutHistory, nextHistory); setWorkoutHistory(nextHistory); setWorkoutOpen(false); } };
  const formatTime = (value) => `${String(Math.floor(value / 60)).padStart(2, '0')}:${String(value % 60).padStart(2, '0')}`;

  return (
    <main className="site-shell">
      <div className="storage-strip" role="status" aria-label="FITFLOW local storage status"><span>LOCAL-FIRST STORAGE</span><b>{savedProfile ? 'PROFILE SAVED' : 'PROFILE READY'}</b><b>{savedPlan ? 'PLAN SAVED' : 'PLAN NOT SAVED'}</b><b>{workoutHistory.length} WORKOUT{workoutHistory.length === 1 ? '' : 'S'} LOGGED</b></div>
      <header className="site-header"><a className="wordmark" href="#top" aria-label="FITFLOW home"><span className="mark">F</span> FITFLOW</a><nav className="main-nav" aria-label="Main navigation"><a href="#workouts">WORKOUTS</a><a href="#library">EXERCISES</a><a href="#plans">PLANS</a><a href="/nutrition">NUTRITION</a><a href="#custom-plan">TRAINING GUIDE</a><a href="#about">ABOUT</a></nav><button className="theme-toggle" aria-label="Toggle dark mode" onClick={() => setDark((value) => !value)}>{dark ? '☼' : '☾'}</button><button className="donate-button" onClick={() => setDonateOpen(true)}>DONATE <span>↗</span></button></header>

      <section className="hero" id="top"><div className="hero-feature"><div className="hero-art">{featured ? <><span className="registration">FITFLOW / DAILY {featured.id}</span><img src={`/media/${featured.gif_url.split('/').pop()}`} alt={`Demonstration of ${featured.name}`} /><span className="art-label">EXERCISE OF THE DAY</span></> : <span className="loading-label">LOADING MOVEMENT...</span>}</div><div className="hero-caption"><span className="hero-number">01</span><h1>START<br /><i>WHERE YOU ARE.</i></h1><p>Simple training plans, clear exercise guidance, and no pressure to be anyone but yourself.</p><a href="#library" className="text-link">EXPLORE THE LIBRARY <span>→</span></a></div></div><div className="hero-stack"><a className="poster poster-red" href="#plans"><span>PROGRAM / 07 DAYS</span><strong>BUILD<br />A BASE</strong><small>STARTER PLAN →</small></a><a className="poster poster-ink" href="#workouts"><span>WORKOUT / 20 MIN</span><strong>NO<br />EXCUSES</strong><small>BODYWEIGHT SESSION →</small></a></div></section>

      <section className="promise" id="about"><span>01 / THE FITFLOW PROMISE</span><h2>TRAINING SHOULD<br /><em>FEEL POSSIBLE.</em></h2><div className="about-copy"><p>FITFLOW is for the days when you want to move forward but need a clear place to begin. No perfect routine, expensive gym, or outside pressure—just a simple plan, honest form, and a pace you can return to.</p><p>Built for people training on their own, FITFLOW turns one small decision into momentum. Start where you are, listen to your body, and let the next rep be yours.</p></div></section>

      <section className="catalog-section" id="library"><aside className="catalog-aside"><p className="catalog-count">{loading ? '...' : allExercises.length.toLocaleString()} EXERCISES<br /><small>IN THE DATABASE</small></p><label htmlFor="search">SEARCH</label><input id="search" value={query} onChange={(event) => { setQuery(event.target.value); setPage(1); }} placeholder="Find an exercise" /><div className="filter-group"><span>BODY PART</span>{bodyParts.map((item) => <button className={bodyFilter === item ? 'selected' : ''} key={item} onClick={() => changeBodyFilter(item)}>{item}</button>)}</div><div className="filter-group"><span>TYPE / EQUIPMENT</span>{types.map((item) => <button className={typeFilter === item ? 'selected' : ''} key={item} onClick={() => changeTypeFilter(item)}>{item}</button>)}</div><button className="clear-filter" onClick={() => { setBodyFilter('ALL'); setTypeFilter(''); setQuery(''); setPage(1); }}>CLEAR FILTERS</button></aside><div className="catalog-main"><div className="section-title"><h2>EXERCISE LIBRARY</h2><span>{filteredExercises.length.toLocaleString()} SHOWN / {allExercises.length.toLocaleString()}</span></div>{loading ? <div className="empty-catalog">LOADING ALL MOVEMENTS...</div> : <><div className="exercise-grid">{visibleExercises.map((exercise) => <article className="exercise-card" key={exercise.id} role="button" tabIndex="0" onClick={() => setSelectedExercise(exercise)} onKeyDown={(event) => { if (event.key === 'Enter' || event.key === ' ') setSelectedExercise(exercise); }}><div className="card-art"><span>{exercise.id}</span><img loading="lazy" src={`/media/${exercise.gif_url.split('/').pop()}`} alt={`Video demonstration of ${exercise.name}`} /></div><div className="card-info"><h3>{titleCase(exercise.name)}</h3><p>{titleCase(exercise.body_part)} · {titleCase(exercise.equipment)}</p><span className="card-arrow">↗</span></div></article>)}</div><div className="pagination" aria-label="Exercise library pages"><button disabled={page === 1} onClick={() => setPage((value) => value - 1)}>← PREV</button>{pageNumbers.map((number, index) => <span key={number}>{index > 0 && number - pageNumbers[index - 1] > 1 ? <b>…</b> : null}<button className={page === number ? 'current' : ''} onClick={() => setPage(number)}>{number}</button></span>)}<button disabled={page === pageCount} onClick={() => setPage((value) => value + 1)}>NEXT →</button></div></>}</div></section>

      <section className="closing" id="workouts"><div><span>02 / TODAY&apos;S WORKOUT</span><h2>MAKE THE<br /><em>NEXT REP</em><br />COUNT.</h2></div><div className="closing-action"><p>{todayWorkoutMinutes} minutes total: 5 movements × {todayWorkoutExerciseMinutes} minutes, including 4 body-part movements and 1 cardio movement.</p><button className="red-action" onClick={() => startWorkout()}>LET&apos;S START <span>→</span></button></div></section>
      {workoutOpen && activeExercise && <div className="workout-overlay"><section className="active-workout" role="dialog" aria-modal="true" aria-labelledby="active-workout-title"><header><span>FITFLOW / ACTIVE SESSION</span><button onClick={() => setWorkoutOpen(false)} aria-label="Close workout">×</button></header><div className="workout-status"><span>EXERCISE {workoutIndex + 1} / {workoutExercises.length}</span><strong>{formatTime(workoutSeconds)}</strong></div><div className="workout-target"><span>SESSION TARGET / {formatTime(todayWorkoutTargetSeconds)}</span><strong>THIS MOVEMENT / {formatTime(todayWorkoutExerciseTargetSeconds)}</strong></div><div className="workout-media"><img src={`/media/${activeExercise.gif_url.split('/').pop()}`} alt={`Video demonstration of ${activeExercise.name}`} /></div><h2 id="active-workout-title">{titleCase(activeExercise.name)}</h2><p className="workout-meta">{titleCase(activeExercise.body_part)} · {titleCase(activeExercise.equipment)} · {titleCase(activeExercise.target)}</p><div className="set-tracker">{[0, 1, 2, 3].map((set) => <span className={set < completedSets ? 'done' : ''} key={set}>SET {set + 1}</span>)}</div><button className="complete-set" onClick={finishSet}>{completedSets < 3 ? `COMPLETE SET ${completedSets + 1}` : workoutIndex < workoutExercises.length - 1 ? 'NEXT EXERCISE →' : 'FINISH WORKOUT ✓'}</button></section></div>}
      {selectedExercise && <div className="modal-backdrop" onClick={() => setSelectedExercise(null)}><section className="exercise-modal" role="dialog" aria-modal="true" aria-labelledby="exercise-detail-title" onClick={(event) => event.stopPropagation()}><button className="close-modal" onClick={() => setSelectedExercise(null)} aria-label="Close exercise details">×</button><div className="exercise-modal-media"><img src={`/media/${selectedExercise.gif_url.split('/').pop()}`} alt={`Video demonstration of ${selectedExercise.name}`} /></div><span className="footer-label">EXERCISE {selectedExercise.id} / VIDEO GUIDE</span><h2 id="exercise-detail-title">{titleCase(selectedExercise.name)}</h2><p className="workout-meta">{titleCase(selectedExercise.body_part)} · {titleCase(selectedExercise.equipment)} · TARGET: {titleCase(selectedExercise.target)}</p><div className="exercise-detail-columns"><div><h3>WHY IT MATTERS</h3><p>{exerciseBenefit(selectedExercise)}</p></div><div><h3>HOW TO DO IT</h3><ol>{(selectedExercise.instruction_steps?.en || [selectedExercise.instructions?.en]).map((step) => <li key={step}>{step}</li>)}</ol></div></div></section></div>}
      <section className="plan-section" id="plans"><div className="plan-intro"><span className="footer-label">03 / 7-DAY PLAN BUILDER</span><h2>YOUR<br /><em>STARTING LINE.</em></h2><p>Enter your height and weight. FITFLOW rounds BMI to the nearest whole number and builds a gradual 7-day plan for BMI 18–35.</p><div className="plan-form"><label>HEIGHT / CM<input type="number" min="100" max="250" value={height} onChange={(event) => { setHeight(event.target.value); setPlanReady(false); setPlanSaved(false); }} /></label><label>WEIGHT / KG<input type="number" min="25" max="300" value={weight} onChange={(event) => { setWeight(event.target.value); setPlanReady(false); setPlanSaved(false); }} /></label><button className="red-action" onClick={() => { setCurrentDay(1); setPlanReady(true); setPlanSaved(false); }}>BUILD MY 7 DAYS <span>→</span></button></div><small className="medical-note">BMI is rounded normally: 20.4 → 20, 20.5 → 21. Supported range: 18–35. BMI is a screening measure, not a diagnosis. Consult a qualified health professional if you have a condition, injury, or uncertainty.</small></div><div className="plan-result">{bmiProfile ? <><div className="bmi-readout"><span>BMI / ROUNDED</span><strong>{roundedBmi}</strong><b>{bmiProfile.label}</b></div><div className="plan-focus"><span>PROFILE {roundedBmi} / 18 CASES</span><strong>{bmiProfile.tone}</strong><p>{bmiProfile.focus} · {bmiProfile.note}</p></div>{planReady && selectedDay && <><div className="day-toolbar"><button disabled={currentDay === 1} onClick={() => setCurrentDay((value) => value - 1)}>← PREVIOUS DAY</button><strong>DAY {String(currentDay).padStart(2, '0')} / 7</strong><button disabled={currentDay === 7} onClick={() => setCurrentDay((value) => value + 1)}>NEXT DAY →</button></div><div className="plan-day-detail"><div className="day-detail-heading"><span>{selectedDay.rest ? 'RECOVERY DAY' : `${selectedDay.exercises.length} MOVEMENTS / TODAY`}</span><b>{selectedDay.rest ? 'RESTORE / 15 MIN' : 'COMPLETE IN YOUR PACE'}</b></div>{selectedDay.rest ? <div className="rest-message">LIGHT MOBILITY, WALKING, BREATHING.<br /><small>Recovery keeps the next session useful.</small></div> : <div className="day-exercises">{selectedDay.exercises.map((exercise, index) => <article key={`${selectedDay.day}-${exercise.id}`}><span>0{index + 1}</span><img loading="lazy" src={`/media/${exercise.gif_url.split('/').pop()}`} alt={`Video demonstration of ${exercise.name}`} /><div><strong>{titleCase(exercise.name)}</strong><small>{titleCase(exercise.body_part)} · {titleCase(exercise.equipment)}</small></div></article>)}</div>}</div><button className="save-plan" onClick={() => startWorkout(selectedDay.exercises)} disabled={!selectedDay.exercises.length}>LET&apos;S START DAY {currentDay} <span>→</span></button><button className="save-plan" onClick={savePlan}>{planSaved ? '✓ TRAINING PLAN SAVED' : 'SAVE TRAINING PLAN'}</button></>}</> : <div className="plan-out-of-range">ENTER A BMI FROM 18 TO 35 TO BUILD YOUR PLAN.</div>}</div></section>
      <section className="nutrition-section" id="nutrition"><div><span className="footer-label">04 / NUTRITION MODE</span><h2>FUEL<br /><em>THE WORK.</em></h2><p className="nutrition-lead">Food is part of the training plan. Browse food data and estimate a daily calorie target on the dedicated nutrition page.</p><a className="red-action route-cta" href="/nutrition">OPEN FOOD LIBRARY <span>→</span></a></div><div className="nutrition-grid"><article><span>01 / HYDRATION</span><strong>2.4 L</strong><p>Daily water target. Keep the system moving.</p></article><article><span>02 / PRE-SESSION</span><strong>CARBS + PROTEIN</strong><p>A simple meal 60–90 minutes before training.</p></article><article><span>03 / AFTER</span><strong>RECOVER</strong><p>Build the habit: eat, rest, return.</p></article></div></section>
      <section className="custom-plan-section" id="custom-plan"><div className="training-guide-intro"><span className="footer-label">05 / TRAINING GUIDE</span><h2>FOLLOW<br /><em>THE SPLIT.</em></h2><p>A simple weekly structure for independent training. Keep the form clean, adjust the load, and let recovery count.</p></div><div className="training-table-wrap"><table className="training-table"><thead><tr><th>DAY</th><th>FOCUS</th><th>MOVEMENT</th><th>SETS × REPS</th></tr></thead><tbody><tr className="push-row"><td rowSpan="5">MON</td><td rowSpan="5">PUSH<br /><small>CHEST · SHOULDERS · TRICEPS</small></td><td>Bench Press</td><td>4 × 8–12</td></tr><tr className="push-row"><td>Incline Dumbbell Press</td><td>3 × 10</td></tr><tr className="push-row"><td>Shoulder Press</td><td>3 × 10</td></tr><tr className="push-row"><td>Lateral Raise</td><td>3 × 12–15</td></tr><tr className="push-row"><td>Triceps Pushdown</td><td>3 × 12</td></tr><tr className="pull-row"><td rowSpan="5">TUE</td><td rowSpan="5">PULL<br /><small>BACK · BICEPS</small></td><td>Lat Pulldown</td><td>4 × 8–12</td></tr><tr className="pull-row"><td>Seated Cable Row</td><td>3 × 10</td></tr><tr className="pull-row"><td>One-arm Dumbbell Row</td><td>3 × 10</td></tr><tr className="pull-row"><td>Face Pull</td><td>3 × 15</td></tr><tr className="pull-row"><td>Dumbbell Curl</td><td>3 × 12</td></tr><tr className="legs-row"><td rowSpan="5">WED</td><td rowSpan="5">LEGS<br /><small>QUADS · HAMSTRINGS · CALVES</small></td><td>Squat</td><td>4 × 8–10</td></tr><tr className="legs-row"><td>Leg Press</td><td>3 × 10</td></tr><tr className="legs-row"><td>Romanian Deadlift</td><td>3 × 10</td></tr><tr className="legs-row"><td>Leg Curl</td><td>3 × 12</td></tr><tr className="legs-row"><td>Calf Raise</td><td>4 × 15</td></tr><tr className="push-row"><td rowSpan="5">THU</td><td rowSpan="5">PUSH<br /><small>CHEST · SHOULDERS · TRICEPS</small></td><td>Incline Bench Press</td><td>4 × 8–12</td></tr><tr className="push-row"><td>Chest Fly</td><td>3 × 12</td></tr><tr className="push-row"><td>Arnold Press</td><td>3 × 10</td></tr><tr className="push-row"><td>Lateral Raise</td><td>4 × 15</td></tr><tr className="push-row"><td>Overhead Triceps Extension</td><td>3 × 12</td></tr><tr className="pull-row"><td rowSpan="5">FRI</td><td rowSpan="5">PULL<br /><small>BACK · BICEPS</small></td><td>Pull-up / Assisted Pull-up</td><td>4 × 6–10</td></tr><tr className="pull-row"><td>Barbell Row</td><td>3 × 8–10</td></tr><tr className="pull-row"><td>Cable Row</td><td>3 × 12</td></tr><tr className="pull-row"><td>Rear Delt Fly</td><td>3 × 15</td></tr><tr className="pull-row"><td>Hammer Curl</td><td>3 × 12</td></tr><tr className="legs-row"><td rowSpan="5">SAT</td><td rowSpan="5">LEGS + CORE<br /><small>LOWER BODY · TRUNK STABILITY</small></td><td>Deadlift</td><td>3 × 6–8</td></tr><tr className="legs-row"><td>Bulgarian Split Squat</td><td>3 × 10</td></tr><tr className="legs-row"><td>Leg Extension</td><td>3 × 12</td></tr><tr className="legs-row"><td>Leg Curl</td><td>3 × 12</td></tr><tr className="legs-row"><td>Plank</td><td>3 × 45–60s</td></tr><tr className="recovery-row"><td>SUN</td><td>RECOVERY<br /><small>RESTORE · BREATHE · WALK</small></td><td>Easy walk, mobility, and rest</td><td>—</td></tr></tbody></table></div></section>
      {donateOpen && <div className="modal-backdrop" onClick={() => setDonateOpen(false)}><section className="donate-modal" role="dialog" aria-modal="true" aria-labelledby="donate-title" onClick={(event) => event.stopPropagation()}><button className="close-modal" onClick={() => setDonateOpen(false)} aria-label="Close donation QR">×</button><span className="footer-label">SUPPORT FITFLOW</span><h2 id="donate-title">KEEP<br /><em>FLOWING.</em></h2><p>Scan this QR code to support the project.</p><img className="qr-image" src="/qr.jpg" alt="QR code for FITFLOW donation" /><small>THANK YOU FOR HELPING FITFLOW GROW.</small></section></div>}
      <section className="reviews-section" id="reviews"><div className="reviews-heading"><span className="footer-label">06 / COMMUNITY NOTES</span><h2>THE WORK<br /><em>IS WORKING.</em></h2><p>Real progress is personal. These short notes are illustrative community-style reviews for the FITFLOW prototype.</p></div><div className="reviews-grid"><article><span className="review-mark">“</span><p>“I started with ten minutes a day. The library made choosing feel simple, and now movement is part of my routine instead of another promise I break.”</p><small>ANONYMOUS / AUSTRALIA</small></article><article><span className="review-mark">“</span><p>“Training at home helped me rebuild strength in a season when everything felt exhausting. Small sessions gave me something steady to return to.”</p><small>ANONYMOUS / COMMUNITY NOTE</small></article><article><span className="review-mark">“</span><p>“I did not know how to exercise safely before. Clear instructions, visible form, and a plan I could adapt made starting feel possible.”</p><small>STEEVEN / SWITZERLAND</small></article><article><span className="review-mark">“</span><p>“The best part is the lack of pressure. I can choose a lighter day, come back tomorrow, and still feel like I am moving forward.”</p><small>ANONYMOUS / COMMUNITY NOTE</small></article></div></section>
      <footer className="site-footer" id="footer"><div className="footer-brand"><span className="mark">F</span><strong>FITFLOW</strong><p>TRAIN WITH INTENT.</p><span className="flutter-badge"><i /> FLUTTER / ANDROID APP</span></div><div><span className="footer-label">EXPLORE</span><a href="#workouts">Today&apos;s workout</a><a href="#library">Exercise library</a><a href="#nutrition">Nutrition mode</a><a href="#custom-plan">Training guide</a></div><div><span className="footer-label">SUPPORT</span><button className="footer-qr" onClick={() => setDonateOpen(true)}><img src="/qr.jpg" alt="Open donation QR code" /><span>SCAN TO DONATE</span></button></div><div className="footer-note">FREE TO USE.<br />MADE FOR HUMANS.<br /><br />© 2026 FITFLOW</div></footer>
    </main>
  );
}
