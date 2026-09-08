export const DEFAULT_PROFILE = {
  name: '',
  gender: '',
  age: '',
  heightCm: '',
  weightKg: '',
  targetWeightKg: '',
  experience: 'BEGINNER',
  equipment: [],
  focusAreas: [],
  sessionMinutes: '30',
  restingHeartRate: '',
  healthNotes: '',
  trainingGoal: 'BUILD CONSISTENCY',
  trainingLevel: 'BEGINNER',
  daysPerWeek: '3',
};

export function buildProfile(values = {}) {
  return { ...DEFAULT_PROFILE, ...values };
}

export function validateProfile(profile = {}) {
  const errors = {};
  const age = Number(profile.age);
  const height = Number(profile.heightCm);
  const weight = Number(profile.weightKg);
  const days = Number(profile.daysPerWeek);
  if (profile.age && (!Number.isFinite(age) || age < 13 || age > 120)) errors.age = 'AGE MUST BE BETWEEN 13 AND 120.';
  if (profile.heightCm && (!Number.isFinite(height) || height < 100 || height > 250)) errors.heightCm = 'HEIGHT MUST BE BETWEEN 100 AND 250 CM.';
  if (profile.weightKg && (!Number.isFinite(weight) || weight < 25 || weight > 300)) errors.weightKg = 'WEIGHT MUST BE BETWEEN 25 AND 300 KG.';
  if (profile.daysPerWeek && (!Number.isFinite(days) || days < 2 || days > 6)) errors.daysPerWeek = 'CHOOSE 2–6 TRAINING DAYS PER WEEK.';
  return { valid: Object.keys(errors).length === 0, errors };
}

const GOAL_RULES = {
  weight_loss: { focus: 'CONDITIONING', cardio: true, volume: 3 },
  muscle_gain: { focus: 'STRENGTH', cardio: false, volume: 4 },
  maintenance: { focus: 'BALANCE', cardio: true, volume: 3 },
  general_fitness: { focus: 'BALANCE', cardio: true, volume: 3 },
};

const LEVEL_RULES = {
  beginner: { sets: 2, reps: '8–10', minutes: 24 },
  intermediate: { sets: 3, reps: '10–12', minutes: 32 },
  advanced: { sets: 4, reps: '8–12', minutes: 40 },
};

function normalizeChoice(value, fallback) {
  return String(value || fallback).trim().toLowerCase().replace(/\s+/g, '_');
}

const GOAL_ALIASES = {
  build_strength: 'muscle_gain',
  improve_conditioning: 'weight_loss',
  move_more: 'general_fitness',
  improve_mobility: 'maintenance',
};

function prescriptionBase(profile = {}) {
  const heightCm = Number(profile.heightCm ?? profile.height ?? 0);
  const weightKg = Number(profile.weightKg ?? profile.weight ?? 0);
  const bmi = heightCm > 0 && weightKg > 0 ? weightKg / ((heightCm / 100) ** 2) : 0;
  const roundedBmi = Math.round(bmi) || 22;
  const level = normalizeChoice(profile.trainingLevel, 'beginner');
  const goal = GOAL_ALIASES[normalizeChoice(profile.trainingGoal, 'general_fitness')] || normalizeChoice(profile.trainingGoal, 'general_fitness');
  return { bmi, roundedBmi, level, goal };
}

export function getExercisePrescription(exercise = {}, profile = {}, session = {}) {
  const { roundedBmi, level, goal } = prescriptionBase(profile);
  const name = String(exercise.name || '').toLowerCase();
  const isTimed = exercise.category === 'cardio' || name.includes('plank');
  const sets = Number(session.sets) || (level === 'advanced' ? 4 : level === 'intermediate' ? 3 : 2);
  if (isTimed) {
    const levelSeconds = level === 'advanced' ? 60 : level === 'intermediate' ? 45 : 30;
    const bmiAdjustment = roundedBmi >= 30 ? -10 : roundedBmi <= 19 ? 10 : 0;
    return { mode: 'seconds', sets, reps: null, seconds: Math.max(20, levelSeconds + bmiAdjustment), goal };
  }
  let target = roundedBmi <= 19 ? 10 : roundedBmi <= 24 ? 12 : roundedBmi <= 29 ? 10 : 8;
  if (goal === 'muscle_gain') target = Math.max(6, target - 1);
  if (level === 'advanced') target = Math.max(6, target - 1);
  return { mode: 'reps', sets, reps: target, seconds: null, goal };
}

export function generateTrainingPlan(profile = {}) {
  const heightCm = Number(profile.heightCm ?? profile.height ?? 0);
  const weightKg = Number(profile.weightKg ?? profile.weight ?? 0);
  const bmi = heightCm > 0 && weightKg > 0 ? weightKg / ((heightCm / 100) ** 2) : 0;
  const roundedBmi = Math.round(bmi);
  const rawGoal = normalizeChoice(profile.trainingGoal, 'general_fitness').replace('build_consistency', 'general_fitness');
  const goalKey = GOAL_ALIASES[rawGoal] || rawGoal;
  const levelKey = normalizeChoice(profile.trainingLevel, 'beginner');
  const goal = GOAL_RULES[goalKey] || GOAL_RULES.general_fitness;
  const level = LEVEL_RULES[levelKey] || LEVEL_RULES.beginner;
  const defaultReps = getExercisePrescription({}, { ...profile, trainingLevel: levelKey, trainingGoal: goalKey }, { sets: level.sets }).reps;
  const daysPerWeek = Math.min(6, Math.max(2, Number(profile.daysPerWeek) || 3));
  const restOrder = [6, 2, 4, 0, 5, 1, 3];
  const restDays = new Set(restOrder.slice(0, 7 - daysPerWeek));

  return {
    bmi,
    roundedBmi,
    goal: goalKey,
    level: levelKey,
    daysPerWeek,
    focus: goal.focus,
    sessions: Array.from({ length: 7 }, (_, dayIndex) => {
      const isRest = restDays.has(dayIndex);
      return {
        day: dayIndex + 1,
        isRest,
        focus: isRest ? 'RECOVERY' : goal.focus,
        exerciseCount: isRest ? 0 : goal.cardio && dayIndex === 5 ? 4 : goal.volume,
        sets: isRest ? 0 : level.sets,
        reps: isRest ? '—' : `${defaultReps}–${defaultReps + 2}`,
        prescriptionMode: isRest ? 'rest' : 'reps',
        targetReps: isRest ? null : defaultReps,
        targetSeconds: null,
        durationMinutes: isRest ? 15 : level.minutes,
      };
    }),
  };
}
