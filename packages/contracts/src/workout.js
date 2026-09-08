export function validateWorkoutLog(log = {}) {
  const required = ['workoutId', 'date', 'exerciseId', 'exerciseName', 'sets', 'reps', 'duration', 'kcal', 'completed'];
  const missing = required.filter((field) => log[field] === undefined || log[field] === null || log[field] === '');
  if (missing.length) return { valid: false, missing };
  return { valid: Number(log.sets) >= 0 && Number(log.reps) >= 0 && Number(log.duration) >= 0 && Number(log.kcal) >= 0, missing: [] };
}

export function createWorkoutLog(values = {}) {
  return {
    workoutId: String(values.workoutId || ''),
    date: values.date || new Date().toISOString(),
    exerciseId: String(values.exerciseId || ''),
    exerciseName: String(values.exerciseName || ''),
    sets: Number(values.sets || 0),
    reps: Number(values.reps || 0),
    weight: values.weight == null || values.weight === '' ? null : Number(values.weight),
    duration: Number(values.duration || 0),
    kcal: Number(values.kcal || 0),
    kcalEstimated: values.kcalEstimated !== false,
    notes: String(values.notes || ''),
    completed: Boolean(values.completed),
  };
}
