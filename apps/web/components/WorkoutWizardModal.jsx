'use client';

import { useState, useEffect, useMemo } from 'react';
import { readUserStorage, writeUserStorage, STORAGE_KEYS } from '../lib/storage.js';

// Sleek, modern technical equipment definitions with minimalist vector wireframes
const EQUIPMENT_LIST = [
  {
    id: 'body weight',
    code: 'BW-01',
    label: 'BODYWEIGHT',
    sub: 'Calisthenics & body resistance',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <circle cx="32" cy="14" r="6" />
        <line x1="32" y1="20" x2="32" y2="38" />
        <line x1="32" y1="26" x2="16" y2="20" />
        <line x1="32" y1="26" x2="48" y2="20" />
        <line x1="32" y1="38" x2="22" y2="54" />
        <line x1="32" y1="38" x2="42" y2="54" />
        <circle cx="16" cy="20" r="2" fill="currentColor" />
        <circle cx="48" cy="20" r="2" fill="currentColor" />
      </svg>
    ),
  },
  {
    id: 'dumbbell',
    code: 'DB-02',
    label: 'DUMBBELL',
    sub: 'Handweights & hex dumbbells',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <rect x="8" y="18" width="10" height="28" rx="2" />
        <line x1="13" y1="18" x2="13" y2="46" />
        <rect x="18" y="24" width="6" height="16" rx="1" />
        <line x1="24" y1="32" x2="40" y2="32" strokeWidth="3" />
        <line x1="28" y1="30" x2="36" y2="30" strokeWidth="1" strokeDasharray="2 2" />
        <line x1="28" y1="34" x2="36" y2="34" strokeWidth="1" strokeDasharray="2 2" />
        <rect x="40" y="24" width="6" height="16" rx="1" />
        <rect x="46" y="18" width="10" height="28" rx="2" />
        <line x1="51" y1="18" x2="51" y2="46" />
      </svg>
    ),
  },
  {
    id: 'barbell',
    code: 'BB-03',
    label: 'BARBELL',
    sub: 'Olympic bar & sleeve collars',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <line x1="4" y1="32" x2="60" y2="32" strokeWidth="2.5" />
        <rect x="12" y="14" width="6" height="36" rx="1" />
        <rect x="18" y="18" width="4" height="28" rx="1" />
        <line x1="22" y1="28" x2="22" y2="36" strokeWidth="2" />
        <line x1="42" y1="28" x2="42" y2="36" strokeWidth="2" />
        <rect x="42" y="18" width="4" height="28" rx="1" />
        <rect x="46" y="14" width="6" height="36" rx="1" />
        <line x1="28" y1="31" x2="36" y2="31" strokeDasharray="2 2" />
      </svg>
    ),
  },
  {
    id: 'kettlebell',
    code: 'KB-04',
    label: 'KETTLEBELL',
    sub: 'Cast iron ball & handle',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <path d="M22 24 V16 C22 10.5 26.5 6 32 6 C37.5 6 42 10.5 42 16 V24" strokeWidth="2" />
        <circle cx="32" cy="40" r="18" />
        <circle cx="32" cy="40" r="11" strokeDasharray="3 2" />
        <line x1="27" y1="40" x2="37" y2="40" />
      </svg>
    ),
  },
  {
    id: 'band',
    code: 'RB-05',
    label: 'RESISTANCE BAND',
    sub: 'Loop & tension tube bands',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <ellipse cx="32" cy="32" rx="22" ry="14" strokeWidth="2" />
        <ellipse cx="32" cy="32" rx="16" ry="9" strokeDasharray="4 2" />
        <circle cx="10" cy="32" r="3" fill="currentColor" />
        <circle cx="54" cy="32" r="3" fill="currentColor" />
      </svg>
    ),
  },
  {
    id: 'weighted',
    code: 'PL-06',
    label: 'WEIGHT PLATE',
    sub: 'Olympic disc & bumper plates',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <circle cx="32" cy="32" r="24" strokeWidth="2" />
        <circle cx="32" cy="32" r="18" />
        <circle cx="32" cy="32" r="6" strokeWidth="2" />
        <line x1="32" y1="8" x2="32" y2="14" />
        <line x1="32" y1="50" x2="32" y2="56" />
        <line x1="8" y1="32" x2="14" y2="32" />
        <line x1="50" y1="32" x2="56" y2="32" />
      </svg>
    ),
  },
  {
    id: 'pull-up bar',
    code: 'PB-07',
    label: 'PULL-UP BAR',
    sub: 'Rigid wall & door bar frame',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <line x1="6" y1="16" x2="58" y2="16" strokeWidth="2.5" />
        <line x1="16" y1="16" x2="16" y2="48" strokeWidth="2" />
        <line x1="48" y1="16" x2="48" y2="48" strokeWidth="2" />
        <line x1="16" y1="48" x2="10" y2="54" />
        <line x1="48" y1="48" x2="54" y2="54" />
        <circle cx="16" cy="16" r="3" fill="currentColor" />
        <circle cx="48" cy="16" r="3" fill="currentColor" />
      </svg>
    ),
  },
  {
    id: 'bench',
    code: 'BN-08',
    label: 'WORKOUT BENCH',
    sub: 'Adjustable & flat workout bench',
    svg: (
      <svg viewBox="0 0 64 64" fill="none" stroke="currentColor" strokeWidth="1.75" className="eq-wireframe">
        <line x1="10" y1="28" x2="54" y2="28" strokeWidth="3.5" />
        <line x1="16" y1="28" x2="12" y2="50" strokeWidth="2" />
        <line x1="48" y1="28" x2="52" y2="50" strokeWidth="2" />
        <line x1="8" y1="50" x2="18" y2="50" strokeWidth="2" />
        <line x1="46" y1="50" x2="56" y2="50" strokeWidth="2" />
        <line x1="28" y1="28" x2="36" y2="50" strokeDasharray="3 3" />
      </svg>
    ),
  },
];

// Muscle definitions matching anatomical regions (in pure English)
const MUSCLE_GROUPS = [
  { id: 'chest', code: 'PEC', name: 'Chest', category: 'push', target: 'pectorals', bodyPart: 'chest' },
  { id: 'lats', code: 'LAT', name: 'Lats & Back', category: 'pull', target: 'lats', bodyPart: 'back' },
  { id: 'upper_back', code: 'TRP', name: 'Upper Back & Traps', category: 'pull', target: 'traps', bodyPart: 'back' },
  { id: 'delts', code: 'DLT', name: 'Shoulders', category: 'push', target: 'delts', bodyPart: 'shoulders' },
  { id: 'biceps', code: 'BIC', name: 'Biceps', category: 'pull', target: 'biceps', bodyPart: 'upper arms' },
  { id: 'triceps', code: 'TRI', name: 'Triceps', category: 'push', target: 'triceps', bodyPart: 'upper arms' },
  { id: 'abs', code: 'ABS', name: 'Abs & Core', category: 'core', target: 'abs', bodyPart: 'waist' },
  { id: 'quads', code: 'QUD', name: 'Quadriceps', category: 'legs', target: 'quads', bodyPart: 'upper legs' },
  { id: 'hamstrings', code: 'HAM', name: 'Hamstrings', category: 'legs', target: 'hamstrings', bodyPart: 'upper legs' },
  { id: 'glutes', code: 'GLT', name: 'Glutes', category: 'legs', target: 'glutes', bodyPart: 'upper legs' },
  { id: 'calves', code: 'CAL', name: 'Calves', category: 'legs', target: 'calves', bodyPart: 'lower legs' },
  { id: 'forearms', code: 'ARM', name: 'Forearms', category: 'pull', target: 'forearms', bodyPart: 'lower arms' },
];

const PRESETS = [
  { name: 'FULL BODY', muscles: ['chest', 'lats', 'delts', 'biceps', 'triceps', 'abs', 'quads', 'hamstrings'] },
  { name: 'PUSH (CHEST / DELTS / TRICEPS)', muscles: ['chest', 'delts', 'triceps'] },
  { name: 'PULL (BACK / BICEPS / FOREARMS)', muscles: ['lats', 'upper_back', 'biceps', 'forearms'] },
  { name: 'LEGS & CORE', muscles: ['quads', 'hamstrings', 'glutes', 'calves', 'abs'] },
  { name: 'UPPER BODY', muscles: ['chest', 'lats', 'upper_back', 'delts', 'biceps', 'triceps'] },
];

const EXERCISE_COUNT_OPTIONS = [3, 4, 5, 6, 8];

const PUSH_MUSCLES = ['chest', 'delts', 'triceps'];
const PULL_MUSCLES = ['lats', 'upper_back', 'biceps', 'forearms'];
const LEG_MUSCLES = ['quads', 'hamstrings', 'glutes', 'calves'];

function titleCase(str = '') {
  return str.replace(/\b\w/g, (c) => c.toUpperCase());
}

function exerciseMediaUrl(exercise) {
  const fileName = exercise?.gif_url?.split('/').pop();
  return fileName ? `/media-transparent/${fileName}` : '';
}

export default function WorkoutWizardModal({ isOpen, onClose, onStartWorkout }) {
  const [step, setStep] = useState(1);
  const [selectedEquipment, setSelectedEquipment] = useState(['body weight', 'dumbbell', 'barbell', 'bench']);
  // Initial muscles is strictly EMPTY (user clicks to select)
  const [selectedMuscles, setSelectedMuscles] = useState([]);
  const [targetExerciseCount, setTargetExerciseCount] = useState(5);

  const [catalog, setCatalog] = useState([]);
  const [loadingCatalog, setLoadingCatalog] = useState(false);
  // Initial exercises is strictly EMPTY (never auto-picked without user action)
  const [generatedExercises, setGeneratedExercises] = useState([]);
  const [showAddPicker, setShowAddPicker] = useState(false);
  const [searchFilter, setSearchFilter] = useState('');
  const [hoveredMuscle, setHoveredMuscle] = useState(null);
  const [previewDetail, setPreviewDetail] = useState(null);
  const [validationNotice, setValidationNotice] = useState('');
  const [randomBanner, setRandomBanner] = useState('');

  // Yesterday training detection state (can be auto-detected from history or toggled)
  const [yesterdaySplit, setYesterdaySplit] = useState('none'); // 'none' | 'push' | 'pull' | 'legs'

  // Load catalog and check workout history on mount/open
  useEffect(() => {
    if (!isOpen) return;

    // Detect if user worked out yesterday or within the last 36 hours
    try {
      const history = readUserStorage(STORAGE_KEYS.workoutHistory, []) || [];
      if (Array.isArray(history) && history.length > 0) {
        const last = history[0];
        const lastDate = last?.date ? new Date(last.date) : null;
        if (lastDate && !isNaN(lastDate.getTime())) {
          const diffHours = (Date.now() - lastDate.getTime()) / (1000 * 60 * 60);
          if (diffHours >= 6 && diffHours <= 40) {
            const muscles = last.muscles || [];
            const hasPush = muscles.some((m) => PUSH_MUSCLES.includes(m));
            const hasPull = muscles.some((m) => PULL_MUSCLES.includes(m));
            const hasLegs = muscles.some((m) => LEG_MUSCLES.includes(m));

            if (hasPush && !hasPull) setYesterdaySplit('push');
            else if (hasPull && !hasPush) setYesterdaySplit('pull');
            else if (hasLegs) setYesterdaySplit('legs');
          }
        }
      }
    } catch {}

    if (catalog.length > 0) return;
    setLoadingCatalog(true);
    fetch('/api/exercises?scope=home&pageSize=36')
      .then((res) => res.json())
      .then((data) => {
        setCatalog(data.items || []);
      })
      .catch(() => {})
      .finally(() => setLoadingCatalog(false));
  }, [isOpen, catalog.length]);

  // Toggle equipment selection
  const toggleEquipment = (id) => {
    setSelectedEquipment((prev) =>
      prev.includes(id) ? (prev.length > 1 ? prev.filter((x) => x !== id) : prev) : [...prev, id]
    );
  };

  const selectAllEquipment = () => {
    setSelectedEquipment(EQUIPMENT_LIST.map((e) => e.id));
  };

  const clearEquipment = () => {
    setSelectedEquipment(['body weight']);
  };

  // Toggle muscle selection
  const toggleMuscle = (id) => {
    setValidationNotice('');
    setSelectedMuscles((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const clearMuscles = () => {
    setSelectedMuscles([]);
    setValidationNotice('');
    setRandomBanner('');
  };

  const applyPreset = (presetMuscles) => {
    setValidationNotice('');
    setSelectedMuscles(presetMuscles);
  };

  // Feature 1: RANDOM MUSCLE SPLIT GENERATOR
  const handleRandomizeMuscles = () => {
    const splitPool = [
      { name: 'PULL SPLIT (Lats, Upper Back, Biceps)', muscles: ['lats', 'upper_back', 'biceps'] },
      { name: 'PUSH SPLIT (Chest, Shoulders, Triceps)', muscles: ['chest', 'delts', 'triceps'] },
      { name: 'LEGS & CORE (Quads, Hamstrings, Glutes, Abs)', muscles: ['quads', 'hamstrings', 'glutes', 'abs'] },
      { name: 'UPPER BODY BLAST (Chest, Back, Shoulders, Arms)', muscles: ['chest', 'lats', 'delts', 'biceps', 'triceps'] },
      { name: 'ANTAGONIST PRESS/PULL (Chest, Lats, Arms)', muscles: ['chest', 'lats', 'biceps', 'triceps'] },
      { name: 'POSTERIOR CHAIN (Lats, Traps, Glutes, Hamstrings)', muscles: ['lats', 'upper_back', 'glutes', 'hamstrings'] },
      { name: 'DELTS & ARMS SPECIALIZATION', muscles: ['delts', 'biceps', 'triceps', 'forearms'] },
    ];

    // Favor picking a split that doesn't conflict with yesterday's training
    let candidates = splitPool;
    if (yesterdaySplit === 'push') {
      candidates = splitPool.filter((s) => !s.muscles.includes('chest'));
    } else if (yesterdaySplit === 'pull') {
      candidates = splitPool.filter((s) => !s.muscles.includes('lats'));
    } else if (yesterdaySplit === 'legs') {
      candidates = splitPool.filter((s) => !s.muscles.includes('quads'));
    }

    const picked = candidates[Math.floor(Math.random() * candidates.length)] || splitPool[0];
    setSelectedMuscles(picked.muscles);
    setValidationNotice('');
    setRandomBanner(`🎲 RANDOMIZED SPLIT: ${picked.name}`);
    setTimeout(() => setRandomBanner(''), 4000);
  };

  // Feature 2: SMART SYNERGISTIC RECOMMENDATIONS
  // When pulling or pushing or leg muscles are selected, advise complementary muscles
  const synergyAdvisory = useMemo(() => {
    if (selectedMuscles.length === 0) return null;

    const hasPull = selectedMuscles.some((m) => PULL_MUSCLES.includes(m));
    const hasPush = selectedMuscles.some((m) => PUSH_MUSCLES.includes(m));
    const hasLegs = selectedMuscles.some((m) => LEG_MUSCLES.includes(m));

    // Pull synergy
    if (hasPull && !hasPush) {
      const missingPull = PULL_MUSCLES.filter((m) => !selectedMuscles.includes(m));
      if (missingPull.length > 0 && missingPull.length <= 3) {
        const missingLabels = missingPull.map((id) => MUSCLE_GROUPS.find((mg) => mg.id === id)?.name).join(', ');
        return {
          type: 'pull',
          title: 'PULL SYNERGY DETECTED',
          message: `You selected pulling muscles. Pairing with ${missingLabels} activates the complete kinetic pulling chain for maximum back and arm hypertrophy.`,
          actionLabel: `+ ADD ${missingPull.map((id) => MUSCLE_GROUPS.find((mg) => mg.id === id)?.name).join(' & ').toUpperCase()}`,
          onApply: () => setSelectedMuscles((prev) => Array.from(new Set([...prev, ...missingPull]))),
        };
      }
    }

    // Push synergy
    if (hasPush && !hasPull) {
      const missingPush = PUSH_MUSCLES.filter((m) => !selectedMuscles.includes(m));
      if (missingPush.length > 0) {
        const missingLabels = missingPush.map((id) => MUSCLE_GROUPS.find((mg) => mg.id === id)?.name).join(', ');
        return {
          type: 'push',
          title: 'PUSH SYNERGY DETECTED',
          message: `You selected pressing muscles. Pairing with ${missingLabels} optimizes anterior chain pressing mechanics and tricep lockout power.`,
          actionLabel: `+ ADD ${missingPush.map((id) => MUSCLE_GROUPS.find((mg) => mg.id === id)?.name).join(' & ').toUpperCase()}`,
          onApply: () => setSelectedMuscles((prev) => Array.from(new Set([...prev, ...missingPush]))),
        };
      }
    }

    // Leg synergy
    if (hasLegs && !hasPush && !hasPull) {
      const missingLegs = ['hamstrings', 'glutes'].filter((m) => !selectedMuscles.includes(m));
      if (missingLegs.length > 0 && selectedMuscles.includes('quads')) {
        return {
          type: 'legs',
          title: 'LOWER BODY SYNERGY DETECTED',
          message: 'Balancing Quadriceps with Hamstrings and Glutes maintains knee joint symmetry and hip extension power.',
          actionLabel: '+ ADD POSTERIOR CHAIN (HAMSTRINGS & GLUTES)',
          onApply: () => setSelectedMuscles((prev) => Array.from(new Set([...prev, 'hamstrings', 'glutes']))),
        };
      }
    }

    return null;
  }, [selectedMuscles]);

  // Feature 3: YESTERDAY TRAINING WARNING CHECK
  const yesterdayWarning = useMemo(() => {
    if (yesterdaySplit === 'none') return null;

    if (yesterdaySplit === 'push') {
      const conflicting = selectedMuscles.filter((m) => PUSH_MUSCLES.includes(m));
      if (conflicting.length > 0) {
        const names = conflicting.map((id) => MUSCLE_GROUPS.find((m) => m.id === id)?.name).join(', ');
        return `RECOVERY ALERT: You trained PUSH yesterday (${names}). These muscles are inside the 48-hour recovery window. Training PULL or LEGS today avoids overtraining.`;
      }
    } else if (yesterdaySplit === 'pull') {
      const conflicting = selectedMuscles.filter((m) => PULL_MUSCLES.includes(m));
      if (conflicting.length > 0) {
        const names = conflicting.map((id) => MUSCLE_GROUPS.find((m) => m.id === id)?.name).join(', ');
        return `RECOVERY ALERT: You trained PULL yesterday (${names}). Today is optimal for PUSH or LEGS to maximize protein synthesis.`;
      }
    } else if (yesterdaySplit === 'legs') {
      const conflicting = selectedMuscles.filter((m) => LEG_MUSCLES.includes(m));
      if (conflicting.length > 0) {
        const names = conflicting.map((id) => MUSCLE_GROUPS.find((m) => m.id === id)?.name).join(', ');
        return `RECOVERY ALERT: You trained LEGS yesterday (${names}). Upper body PUSH or PULL is recommended today.`;
      }
    }
    return null;
  }, [yesterdaySplit, selectedMuscles]);

  // Equipment matching
  const matchesEquipment = (exercise, chosenEq) => {
    const eq = (exercise.equipment || '').toLowerCase();
    for (const chosen of chosenEq) {
      if (chosen === 'body weight' && (eq.includes('body') || eq === 'assisted')) return true;
      if (chosen === 'dumbbell' && eq.includes('dumbbell')) return true;
      if (chosen === 'barbell' && (eq.includes('barbell') || eq.includes('smith') || eq.includes('olympic') || eq.includes('ez'))) return true;
      if (chosen === 'kettlebell' && eq.includes('kettlebell')) return true;
      if (chosen === 'band' && (eq.includes('band') || eq.includes('rope'))) return true;
      if (chosen === 'weighted' && (eq.includes('weighted') || eq.includes('plate') || eq.includes('ball'))) return true;
      if (chosen === 'pull-up bar' && (exercise.name.toLowerCase().includes('pull-up') || exercise.name.toLowerCase().includes('chin-up') || eq.includes('cable'))) return true;
      if (chosen === 'bench' && exercise.name.toLowerCase().includes('bench')) return true;
    }
    return false;
  };

  // Muscle matching
  const matchesMuscle = (exercise, muscleId) => {
    const muscleDef = MUSCLE_GROUPS.find((m) => m.id === muscleId);
    if (!muscleDef) return false;
    const target = (exercise.target || '').toLowerCase();
    const bodyPart = (exercise.body_part || '').toLowerCase();
    const name = (exercise.name || '').toLowerCase();

    if (muscleDef.target && target.includes(muscleDef.target)) return true;
    if (muscleDef.bodyPart && bodyPart.includes(muscleDef.bodyPart)) return true;
    if (name.includes(muscleId.replace('_', ' '))) return true;
    return false;
  };

  // Generate workout only when explicitly triggered by user
  const generateWorkout = () => {
    if (!catalog.length) return;
    const available = catalog.filter((ex) => matchesEquipment(ex, selectedEquipment));
    const pool = available.length > 0 ? available : catalog;

    const result = [];
    const usedIds = new Set();
    const activeMuscles = selectedMuscles.length > 0 ? selectedMuscles : ['chest', 'lats', 'quads'];

    let muscleIdx = 0;
    let attempts = 0;
    while (result.length < targetExerciseCount && attempts < 40) {
      attempts++;
      const currentMuscle = activeMuscles[muscleIdx % activeMuscles.length];
      muscleIdx++;

      const candidates = pool.filter((ex) => !usedIds.has(ex.id) && matchesMuscle(ex, currentMuscle));
      if (candidates.length > 0) {
        const picked = candidates[Math.floor(Math.random() * candidates.length)];
        result.push(picked);
        usedIds.add(picked.id);
      }
    }

    const remaining = pool.filter((ex) => !usedIds.has(ex.id));
    while (result.length < targetExerciseCount && remaining.length > 0) {
      const idx = Math.floor(Math.random() * remaining.length);
      result.push(remaining[idx]);
      usedIds.add(remaining[idx].id);
      remaining.splice(idx, 1);
    }

    setGeneratedExercises(result);
  };

  const handleNextStep = () => {
    if (step === 1) {
      setStep(2);
    } else if (step === 2) {
      if (selectedMuscles.length === 0) {
        setValidationNotice('PLEASE SELECT AT LEAST ONE TARGET MUSCLE OR CLICK "RANDOM SPLIT" TO PROCEED.');
        return;
      }
      setValidationNotice('');
      setStep(3);
      // Auto-generate exercises when entering step 3
      setTimeout(() => generateWorkout(), 0);
    }
  };

  const handlePreviousStep = () => {
    if (step > 1) {
      setValidationNotice('');
      setStep(step - 1);
    }
  };

  const handleShuffleExercise = (idx) => {
    const current = generatedExercises[idx];
    const pool = catalog.filter((ex) => {
      if (ex.id === current.id) return false;
      if (generatedExercises.some((g) => g.id === ex.id)) return false;
      return matchesEquipment(ex, selectedEquipment);
    });

    const candidatePool = pool.filter(
      (ex) =>
        ex.target === current.target ||
        ex.body_part === current.body_part ||
        (current.target && (ex.target || '').includes(current.target))
    );

    const replacement =
      candidatePool.length > 0
        ? candidatePool[Math.floor(Math.random() * candidatePool.length)]
        : pool[Math.floor(Math.random() * pool.length)];

    if (replacement) {
      const next = [...generatedExercises];
      next[idx] = replacement;
      setGeneratedExercises(next);
    }
  };

  const handleDeleteExercise = (idx) => {
    setGeneratedExercises((prev) => prev.filter((_, i) => i !== idx));
  };

  const handleAddExercise = (exercise) => {
    if (!generatedExercises.some((e) => e.id === exercise.id)) {
      setGeneratedExercises((prev) => [...prev, exercise]);
    }
    setShowAddPicker(false);
  };

  const handleFinalStart = () => {
    // Record to workout history so yesterday's detection remembers it
    try {
      const history = readUserStorage(STORAGE_KEYS.workoutHistory, []) || [];
      const newRecord = {
        id: `wo_${Date.now()}`,
        date: new Date().toISOString(),
        exercises: generatedExercises.map((e) => e.name),
        muscles: selectedMuscles,
        equipment: selectedEquipment,
        exerciseCount: generatedExercises.length,
      };
      writeUserStorage(STORAGE_KEYS.workoutHistory, [newRecord, ...history]);
    } catch {}

    if (onStartWorkout) {
      onStartWorkout(generatedExercises);
    }
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="workout-wizard-overlay" role="dialog" aria-modal="true" aria-labelledby="wizard-title">
      <div className="workout-wizard-modal">
        {/* Header Bar */}
        <header className="wizard-modal-header">
          <div className="wizard-brand">
            <span className="wizard-badge-dot" />
            <span className="wizard-telemetry">FITFLOW // WORKOUT BUILDER</span>
          </div>
          <button
            type="button"
            className="wizard-close-btn"
            onClick={onClose}
            aria-label="Close workout builder"
          >
            ✕
          </button>
        </header>

        {/* Technical Stepper: completed steps are dark monochrome, active is hazard red */}
        <nav className="wizard-stepper" aria-label="Workout Builder Stepper">
          <div
            className={`step-node ${step === 1 ? 'active' : step > 1 ? 'completed' : ''}`}
            onClick={() => setStep(1)}
          >
            <div className="step-circle">
              {step > 1 ? '✓' : '01'}
            </div>
            <div className="step-meta">
              <span className="step-title">EQUIPMENT</span>
              <span className="step-desc">Available Gear</span>
            </div>
          </div>

          <div className={`step-connector ${step > 1 ? 'completed' : ''}`} />

          <div
            className={`step-node ${step === 2 ? 'active' : step > 2 ? 'completed' : ''}`}
            onClick={() => setStep(2)}
          >
            <div className="step-circle">
              {step > 2 ? '✓' : '02'}
            </div>
            <div className="step-meta">
              <span className="step-title">TARGET MUSCLES</span>
              <span className="step-desc">Focus & Volume</span>
            </div>
          </div>

          <div className={`step-connector ${step > 2 ? 'completed' : ''}`} />

          <div
            className={`step-node ${step === 3 ? 'active' : ''}`}
            onClick={() => {
              if (selectedMuscles.length > 0) setStep(3);
            }}
          >
            <div className="step-circle">03</div>
            <div className="step-meta">
              <span className="step-title">EXERCISE MATRIX</span>
              <span className="step-desc">Review & Start</span>
            </div>
          </div>
        </nav>

        {/* ================= STEP 1: EQUIPMENT ================= */}
        {step === 1 && (
          <div className="wizard-step-content step-equipment">
            <div className="step-instruction-bar">
              <div>
                <h2 id="wizard-title">SELECT AVAILABLE EQUIPMENT</h2>
                <p>Choose the equipment you have on hand. The system calibrates exercise selections accordingly.</p>
              </div>
              <div className="step-actions-quick">
                <button type="button" onClick={selectAllEquipment} className="btn-text-action">
                  SELECT ALL
                </button>
                <button type="button" onClick={clearEquipment} className="btn-text-action">
                  CLEAR
                </button>
              </div>
            </div>

            <div className="equipment-grid">
              {EQUIPMENT_LIST.map((eq) => {
                const isSelected = selectedEquipment.includes(eq.id);
                return (
                  <div
                    key={eq.id}
                    className={`equipment-card ${isSelected ? 'selected' : ''}`}
                    onClick={() => toggleEquipment(eq.id)}
                    role="checkbox"
                    aria-checked={isSelected}
                    tabIndex={0}
                    onKeyDown={(e) => {
                      if (e.key === ' ' || e.key === 'Enter') toggleEquipment(eq.id);
                    }}
                  >
                    <div className="card-top-row">
                      <span className="card-code-tag">{eq.code}</span>
                      <span className={`indicator-dot ${isSelected ? 'active' : ''}`} />
                    </div>
                    <div className="card-wireframe-wrap">{eq.svg}</div>
                    <strong className="card-title">{eq.label}</strong>
                    <span className="card-sub">{eq.sub}</span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ================= STEP 2: MUSCLES (INITIAL STATE IS EMPTY) ================= */}
        {step === 2 && (
          <div className="wizard-step-content step-muscles">
            <div className="step-instruction-bar">
              <div>
                <h2 id="wizard-title">CHOOSE YOUR TARGET MUSCLES</h2>
                <p className="instruction-subtitle">
                  Click anatomical regions to select target muscles. Click &quot;RANDOM SPLIT&quot; to auto-generate a balanced split.
                </p>
              </div>
              <div className="muscle-status-box">
                {hoveredMuscle ? (
                  <span className="hover-readout">
                    HOVER: <strong>{hoveredMuscle}</strong>
                  </span>
                ) : (
                  <span className="hover-readout">
                    SELECTED: <strong>{selectedMuscles.length} GROUPS</strong>
                  </span>
                )}
              </div>
            </div>

            {/* Validation Notice if empty */}
            {validationNotice && (
              <div className="wizard-alert-bar" role="alert">
                <span className="alert-hazard">⚠</span>
                <span>{validationNotice}</span>
              </div>
            )}

            {/* Random split announcement banner */}
            {randomBanner && (
              <div className="wizard-random-banner" role="status">
                <span className="random-dot" />
                <span>{randomBanner}</span>
              </div>
            )}

            {/* Yesterday Training Detection & Warning */}
            <div className="yesterday-advisory-container">
              <div className="yesterday-toggle-bar">
                <span className="yesterday-label">YESTERDAY LOGGED:</span>
                <div className="yesterday-chips">
                  <button
                    type="button"
                    className={`yesterday-chip ${yesterdaySplit === 'none' ? 'active' : ''}`}
                    onClick={() => setYesterdaySplit('none')}
                  >
                    REST DAY
                  </button>
                  <button
                    type="button"
                    className={`yesterday-chip ${yesterdaySplit === 'push' ? 'active' : ''}`}
                    onClick={() => setYesterdaySplit('push')}
                  >
                    PUSH (CHEST/SHOULDERS)
                  </button>
                  <button
                    type="button"
                    className={`yesterday-chip ${yesterdaySplit === 'pull' ? 'active' : ''}`}
                    onClick={() => setYesterdaySplit('pull')}
                  >
                    PULL (BACK/BICEPS)
                  </button>
                  <button
                    type="button"
                    className={`yesterday-chip ${yesterdaySplit === 'legs' ? 'active' : ''}`}
                    onClick={() => setYesterdaySplit('legs')}
                  >
                    LEGS (QUADS/HAMSTRINGS)
                  </button>
                </div>
              </div>

              {yesterdayWarning && (
                <div className="recovery-warning-banner" role="alert">
                  <span className="warning-icon">⚡</span>
                  <span>{yesterdayWarning}</span>
                </div>
              )}
            </div>

            {/* Smart Synergistic Recommendations (Pull/Push/Legs Optimization) */}
            {synergyAdvisory && (
              <div className="synergy-recommendation-box" role="region">
                <div className="synergy-header">
                  <span className="synergy-tag">{synergyAdvisory.title}</span>
                  <p className="synergy-message">{synergyAdvisory.message}</p>
                </div>
                <button
                  type="button"
                  className="btn-synergy-apply"
                  onClick={synergyAdvisory.onApply}
                >
                  {synergyAdvisory.actionLabel}
                </button>
              </div>
            )}

            {/* Target Exercise Count Selector */}
            <div className="target-volume-selector">
              <div className="volume-label-col">
                <span className="volume-title">TARGET EXERCISE COUNT</span>
                <span className="volume-sub">Choose how many movements to generate for today&apos;s session:</span>
              </div>
              <div className="volume-pill-group">
                {EXERCISE_COUNT_OPTIONS.map((count) => (
                  <button
                    key={count}
                    type="button"
                    className={`volume-pill ${targetExerciseCount === count ? 'active' : ''}`}
                    onClick={() => setTargetExerciseCount(count)}
                  >
                    {count} EXERCISES
                  </button>
                ))}
              </div>
            </div>

            {/* Anatomical Body Maps (Front & Back Views) */}
            <div className="anatomy-interactive-wrapper">
              {/* FRONT VIEW (ANTERIOR) */}
              <div className="anatomy-figure-panel">
                <div className="figure-header">
                  <span>ANTERIOR (FRONT VIEW)</span>
                </div>
                <div className="svg-canvas-container">
                  <svg
                    viewBox="0 0 240 480"
                    className="anatomy-svg"
                    aria-label="Front anatomical body diagram"
                  >
                    {/* Head & Neck Base Outline */}
                    <ellipse cx="120" cy="38" rx="20" ry="26" className="body-silhouette" />
                    <path d="M110 64 L130 64 L136 82 L104 82 Z" className="body-silhouette" />

                    {/* CHEST (PECTORALS) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('chest') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('chest')}
                      onMouseEnter={() => setHoveredMuscle('Chest (Pectorals)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M118 88 L86 92 C80 98 80 114 88 126 C98 132 116 130 118 122 Z" />
                      <path d="M122 88 L154 92 C160 98 160 114 152 126 C142 132 124 130 122 122 Z" />
                    </g>

                    {/* SHOULDERS (DELTOIDS) FRONT */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('delts') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('delts')}
                      onMouseEnter={() => setHoveredMuscle('Shoulders (Deltoids)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M82 88 C70 94 62 108 64 124 C68 130 76 130 82 120 C84 108 84 96 82 88 Z" />
                      <path d="M158 88 C170 94 178 108 176 124 C172 130 164 130 158 120 C156 108 156 96 158 88 Z" />
                    </g>

                    {/* BICEPS */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('biceps') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('biceps')}
                      onMouseEnter={() => setHoveredMuscle('Biceps (Upper Arms)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M64 126 C58 136 56 154 62 168 C68 170 74 166 76 154 C78 142 74 130 64 126 Z" />
                      <path d="M176 126 C182 136 184 154 178 168 C172 170 166 166 164 154 C162 142 166 130 176 126 Z" />
                    </g>

                    {/* FOREARMS FRONT */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('forearms') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('forearms')}
                      onMouseEnter={() => setHoveredMuscle('Forearms')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M60 174 C52 190 44 212 38 234 C44 238 52 234 58 220 C64 204 68 188 64 174 Z" />
                      <path d="M180 174 C188 190 196 212 202 234 C196 238 188 234 182 220 C176 204 172 188 176 174 Z" />
                    </g>

                    {/* Hands */}
                    <path d="M34 238 C30 248 24 260 28 268 C34 270 42 262 44 250 Z" className="body-silhouette" />
                    <path d="M206 238 C210 248 216 260 212 268 C206 270 198 262 196 250 Z" className="body-silhouette" />

                    {/* ABDOMINALS (ABS & OBLIQUES) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('abs') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('abs')}
                      onMouseEnter={() => setHoveredMuscle('Abs & Core (Abdominals)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <rect x="106" y="132" width="12" height="15" rx="2" />
                      <rect x="122" y="132" width="12" height="15" rx="2" />
                      <rect x="106" y="150" width="12" height="15" rx="2" />
                      <rect x="122" y="150" width="12" height="15" rx="2" />
                      <rect x="106" y="168" width="12" height="17" rx="2" />
                      <rect x="122" y="168" width="12" height="17" rx="2" />
                      <path d="M88 132 C82 144 80 162 86 182 C94 182 102 178 102 168 C102 152 98 138 88 132 Z" />
                      <path d="M152 132 C158 144 160 162 154 182 C146 182 138 178 138 168 C138 152 142 138 152 132 Z" />
                    </g>

                    {/* Pelvis */}
                    <path d="M100 190 L140 190 L132 212 L108 212 Z" className="body-silhouette" />

                    {/* QUADRICEPS */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('quads') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('quads')}
                      onMouseEnter={() => setHoveredMuscle('Quadriceps (Front Thighs)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M84 212 C74 236 72 278 78 318 C86 322 96 322 104 316 C110 290 112 250 108 212 Z" />
                      <path d="M156 212 C166 236 168 278 162 318 C154 322 144 322 136 316 C130 290 128 250 132 212 Z" />
                    </g>

                    {/* Knees */}
                    <circle cx="92" cy="330" r="7" className="body-silhouette" />
                    <circle cx="148" cy="330" r="7" className="body-silhouette" />

                    {/* CALVES / SHINS */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('calves') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('calves')}
                      onMouseEnter={() => setHoveredMuscle('Calves & Tibialis')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M84 340 C76 360 76 398 84 430 C90 432 98 428 100 412 C104 388 102 360 98 340 Z" />
                      <path d="M156 340 C164 360 164 398 156 430 C150 432 142 428 140 412 C136 388 138 360 142 340 Z" />
                    </g>

                    {/* Feet */}
                    <path d="M78 436 C70 450 64 466 74 470 C88 472 96 466 94 446 Z" className="body-silhouette" />
                    <path d="M162 436 C170 450 176 466 166 470 C152 472 144 466 146 446 Z" className="body-silhouette" />
                  </svg>
                </div>
              </div>

              {/* BACK VIEW (POSTERIOR) */}
              <div className="anatomy-figure-panel">
                <div className="figure-header">
                  <span>POSTERIOR (BACK VIEW)</span>
                </div>
                <div className="svg-canvas-container">
                  <svg
                    viewBox="0 0 240 480"
                    className="anatomy-svg"
                    aria-label="Back anatomical body diagram"
                  >
                    {/* Head & Neck Base */}
                    <ellipse cx="120" cy="38" rx="20" ry="26" className="body-silhouette" />

                    {/* TRAPS & UPPER BACK */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('upper_back') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('upper_back')}
                      onMouseEnter={() => setHoveredMuscle('Traps & Upper Back')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M120 62 L144 82 L152 108 L120 134 L88 108 L96 82 Z" />
                    </g>

                    {/* REAR DELTOIDS */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('delts') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('delts')}
                      onMouseEnter={() => setHoveredMuscle('Rear Deltoids (Shoulders)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M88 88 C74 94 66 108 68 124 C74 128 82 124 88 116 Z" />
                      <path d="M152 88 C166 94 174 108 172 124 C166 128 158 124 152 116 Z" />
                    </g>

                    {/* LATS & MID BACK */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('lats') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('lats')}
                      onMouseEnter={() => setHoveredMuscle('Lats & Mid Back')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M86 114 C74 130 76 156 86 178 C98 176 108 166 116 142 C104 132 94 122 86 114 Z" />
                      <path d="M154 114 C166 130 164 156 154 178 C142 176 132 166 124 142 C136 132 146 122 154 114 Z" />
                      <path d="M116 146 L124 146 L124 190 L116 190 Z" />
                    </g>

                    {/* TRICEPS */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('triceps') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('triceps')}
                      onMouseEnter={() => setHoveredMuscle('Triceps (Arms)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M66 124 C58 136 56 154 62 168 C68 170 76 166 78 152 C80 138 76 126 66 124 Z" />
                      <path d="M174 124 C182 136 184 154 178 168 C172 170 164 166 162 152 C160 138 164 126 174 124 Z" />
                    </g>

                    {/* FOREARMS BACK */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('forearms') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('forearms')}
                      onMouseEnter={() => setHoveredMuscle('Forearms (Posterior)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M60 174 C52 190 44 212 38 234 C44 238 52 234 58 220 C64 204 68 188 64 174 Z" />
                      <path d="M180 174 C188 190 196 212 202 234 C196 238 188 234 182 220 C176 204 172 188 176 174 Z" />
                    </g>

                    {/* Hands */}
                    <path d="M34 238 C30 248 24 260 28 268 C34 270 42 262 44 250 Z" className="body-silhouette" />
                    <path d="M206 238 C210 248 216 260 212 268 C206 270 198 262 196 250 Z" className="body-silhouette" />

                    {/* GLUTES */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('glutes') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('glutes')}
                      onMouseEnter={() => setHoveredMuscle('Glutes (Gluteus Maximus)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M84 188 C74 198 76 226 84 246 C94 252 110 248 118 238 C118 212 110 194 84 188 Z" />
                      <path d="M156 188 C166 198 164 226 156 246 C146 252 130 248 122 238 C122 212 130 194 156 188 Z" />
                    </g>

                    {/* HAMSTRINGS */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('hamstrings') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('hamstrings')}
                      onMouseEnter={() => setHoveredMuscle('Hamstrings (Posterior Thighs)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M84 250 C76 268 74 298 80 322 C88 326 96 324 104 316 C110 292 112 266 108 250 Z" />
                      <path d="M156 250 C164 268 166 298 160 322 C152 326 144 324 136 316 C130 292 128 266 132 250 Z" />
                    </g>

                    {/* Knee joint back */}
                    <circle cx="92" cy="330" r="7" className="body-silhouette" />
                    <circle cx="148" cy="330" r="7" className="body-silhouette" />

                    {/* CALVES (GASTROCNEMIUS) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('calves') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('calves')}
                      onMouseEnter={() => setHoveredMuscle('Calves (Gastrocnemius)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M82 338 C72 358 72 392 82 422 C90 426 102 422 102 404 C104 378 100 354 94 338 Z" />
                      <path d="M158 338 C168 358 168 392 158 422 C150 426 138 422 138 404 C136 378 140 354 146 338 Z" />
                    </g>

                    {/* Feet */}
                    <path d="M80 430 C72 444 68 458 76 464 C88 466 94 460 92 440 Z" className="body-silhouette" />
                    <path d="M160 430 C168 444 172 458 164 464 C152 466 146 460 148 440 Z" className="body-silhouette" />
                  </svg>
                </div>
              </div>
            </div>

            {/* Quick Presets, Random Split, & Individual Muscle Chips */}
            <div className="muscle-selection-dashboard">
              <div className="preset-row">
                <span className="preset-label">PRESETS:</span>
                {PRESETS.map((p) => (
                  <button
                    key={p.name}
                    type="button"
                    className="preset-chip"
                    onClick={() => applyPreset(p.muscles)}
                  >
                    {p.name}
                  </button>
                ))}

                {/* Random Muscle Generator */}
                <button
                  type="button"
                  className="preset-chip random-chip"
                  onClick={handleRandomizeMuscles}
                  title="Randomly generate a physiologically balanced split"
                >
                  🎲 RANDOM SPLIT
                </button>

                {selectedMuscles.length > 0 && (
                  <button
                    type="button"
                    className="preset-chip clear"
                    onClick={clearMuscles}
                  >
                    CLEAR
                  </button>
                )}
              </div>

              <div className="muscle-tags-row">
                {MUSCLE_GROUPS.map((m) => {
                  const active = selectedMuscles.includes(m.id);
                  const isConflictingYesterday =
                    (yesterdaySplit === 'push' && PUSH_MUSCLES.includes(m.id)) ||
                    (yesterdaySplit === 'pull' && PULL_MUSCLES.includes(m.id)) ||
                    (yesterdaySplit === 'legs' && LEG_MUSCLES.includes(m.id));

                  return (
                    <button
                      key={m.id}
                      type="button"
                      className={`muscle-tag ${active ? 'active' : ''} ${isConflictingYesterday ? 'recently-worked' : ''}`}
                      onClick={() => toggleMuscle(m.id)}
                      title={isConflictingYesterday ? 'Trained yesterday (<24h ago)' : ''}
                    >
                      <span className="tag-code">{m.code}</span>
                      <span>{m.name}</span>
                      {isConflictingYesterday && <span className="recovery-dot" title="Trained yesterday">⚡</span>}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        {/* ================= STEP 3: EXERCISES MATRIX (INITIALLY EMPTY) ================= */}
        {step === 3 && (
          <div className="wizard-step-content step-exercises">
            <div className="step-instruction-bar">
              <div>
                <h2>CUSTOMIZE TRAINING MATRIX</h2>
                <p>
                  {`Generated ${generatedExercises.length} movements matching your target volume. Reorder, shuffle, or add movements.`}
                </p>
              </div>
              <div className="matrix-top-actions">
                  <button
                    type="button"
                    className="btn-action-outline"
                    onClick={generateWorkout}
                    title="Re-generate all exercises"
                  >
                    SHUFFLE ALL
                  </button>
                  <button
                    type="button"
                    className="btn-action-primary"
                    onClick={() => setShowAddPicker(true)}
                  >
                    + ADD MOVEMENT
                  </button>
                </div>
            </div>

            <div className="wizard-exercise-list">
                {generatedExercises.map((exercise, idx) => {
                  const media = exerciseMediaUrl(exercise);
                  const badgeLetter = (exercise.target || exercise.body_part || 'E').slice(0, 3).toUpperCase();

                  return (
                    <div className="wizard-exercise-card" key={`${exercise.id}-${idx}`}>
                      <div className="card-index-indicator">
                        {String(idx + 1).padStart(2, '0')}
                      </div>

                      {/* Animated thumbnail */}
                      <div className="card-thumbnail">
                        {media ? (
                          <img
                            src={media}
                            alt={exercise.name}
                            onError={(e) => {
                              e.currentTarget.style.display = 'none';
                            }}
                          />
                        ) : (
                          <div className="placeholder-thumb">{badgeLetter}</div>
                        )}
                      </div>

                      {/* Technical Muscle Badge */}
                      <div className="card-badge" title={exercise.target || exercise.body_part}>
                        {badgeLetter}
                      </div>

                      {/* Title & Metadata */}
                      <div className="card-info">
                        <strong className="exercise-name">{titleCase(exercise.name)}</strong>
                        <span className="exercise-meta">
                          {titleCase(exercise.body_part)} · {titleCase(exercise.equipment)} · {titleCase(exercise.target)}
                        </span>
                      </div>

                      {/* Action buttons */}
                      <div className="card-actions">
                        <button
                          type="button"
                          className="btn-action-shuffle"
                          onClick={() => handleShuffleExercise(idx)}
                          title="Shuffle for another matching exercise"
                        >
                          SHUFFLE
                        </button>

                        <button
                          type="button"
                          className="btn-action-icon"
                          onClick={() => setPreviewDetail(exercise)}
                          title="View exercise instructions"
                        >
                          INFO
                        </button>

                        <button
                          type="button"
                          className="btn-action-icon delete"
                          onClick={() => handleDeleteExercise(idx)}
                          title="Remove movement"
                        >
                          ✕
                        </button>
                      </div>
                    </div>
                  );
                })}

                {/* Add Button at bottom of generated list */}
                <div className="add-row-container">
                  <button
                    type="button"
                    className="btn-add-more-row"
                    onClick={() => setShowAddPicker(true)}
                  >
                    + ADD ANOTHER MOVEMENT
                  </button>
                </div>
              </div>
          </div>
        )}

        {/* Modal Bottom Navigation Bar */}
        <footer className="wizard-modal-footer">
          <button
            type="button"
            className="btn-wizard-nav prev"
            onClick={handlePreviousStep}
            disabled={step === 1}
          >
            ← PREVIOUS
          </button>

          {step < 3 ? (
            <button
              type="button"
              className="btn-wizard-nav next red-action"
              onClick={handleNextStep}
            >
              CONTINUE <span>→</span>
            </button>
          ) : (
            <button
              type="button"
              className="btn-wizard-nav start-workout red-action"
              onClick={handleFinalStart}
              disabled={generatedExercises.length === 0}
            >
              START WORKOUT <span>→</span>
            </button>
          )}
        </footer>

        {/* Picker Modal for Adding Additional Exercises */}
        {showAddPicker && (
          <div className="picker-overlay" role="dialog" aria-modal="true">
            <div className="picker-modal">
              <header className="picker-header">
                <h3>ADD MOVEMENT TO WORKOUT</h3>
                <button type="button" onClick={() => setShowAddPicker(false)}>✕</button>
              </header>
              <div className="picker-search">
                <input
                  type="text"
                  placeholder="Search by exercise name, muscle, equipment..."
                  value={searchFilter}
                  onChange={(e) => setSearchFilter(e.target.value)}
                  autoFocus
                />
              </div>
              <div className="picker-list">
                {catalog
                  .filter((ex) => {
                    const q = searchFilter.toLowerCase();
                    return (
                      !q ||
                      ex.name.toLowerCase().includes(q) ||
                      (ex.body_part || '').toLowerCase().includes(q) ||
                      (ex.equipment || '').toLowerCase().includes(q)
                    );
                  })
                  .slice(0, 30)
                  .map((item) => (
                    <div
                      key={item.id}
                      className="picker-item"
                      onClick={() => handleAddExercise(item)}
                    >
                      <div className="picker-item-info">
                        <strong>{titleCase(item.name)}</strong>
                        <span>{titleCase(item.body_part)} · {titleCase(item.equipment)}</span>
                      </div>
                      <button type="button" className="btn-picker-add">+ SELECT</button>
                    </div>
                  ))}
              </div>
            </div>
          </div>
        )}

        {/* Exercise Quick Detail Preview Modal */}
        {previewDetail && (
          <div className="picker-overlay" role="dialog" aria-modal="true">
            <div className="picker-modal detail-modal">
              <header className="picker-header">
                <h3>{titleCase(previewDetail.name)}</h3>
                <button type="button" onClick={() => setPreviewDetail(null)}>✕</button>
              </header>
              <div className="detail-body">
                {exerciseMediaUrl(previewDetail) && (
                  <div className="detail-media">
                    <img src={exerciseMediaUrl(previewDetail)} alt={previewDetail.name} />
                  </div>
                )}
                <div className="detail-meta">
                  <p><strong>PRIMARY TARGET:</strong> {titleCase(previewDetail.target)}</p>
                  <p><strong>BODY PART:</strong> {titleCase(previewDetail.body_part)}</p>
                  <p><strong>REQUIRED GEAR:</strong> {titleCase(previewDetail.equipment)}</p>
                  {previewDetail.instructions && (
                    <div className="instructions-box">
                      <strong>EXECUTION INSTRUCTIONS:</strong>
                      <p>{Array.isArray(previewDetail.instructions) ? previewDetail.instructions.join(' ') : previewDetail.instructions}</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
