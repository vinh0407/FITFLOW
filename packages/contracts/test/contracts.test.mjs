import test from 'node:test';
import assert from 'node:assert/strict';
import { createWorkoutLog, generateTrainingPlan, getExercisePrescription, scopeStorageKey, validateWorkoutLog } from '../src/index.js';

test('BMI uses centimetres and rounds normally', () => {
  const plan = generateTrainingPlan({ height: 175, weight: 61.25, daysPerWeek: 3 });
  assert.equal(plan.roundedBmi, 20);
  for (const bmi of [18, 20, 22, 25, 30, 35]) {
    assert.equal(generateTrainingPlan({ height: 100, weight: bmi }).roundedBmi, bmi);
  }
});

test('goal, level and days per week change plan output', () => {
  const base = generateTrainingPlan({ height: 175, weight: 70, trainingGoal: 'general_fitness', trainingLevel: 'beginner', daysPerWeek: 3 });
  const strength = generateTrainingPlan({ height: 175, weight: 70, trainingGoal: 'muscle_gain', trainingLevel: 'advanced', daysPerWeek: 6 });
  assert.equal(base.goal, 'general_fitness');
  assert.equal(strength.goal, 'muscle_gain');
  assert.equal(base.daysPerWeek, 3);
  assert.equal(strength.daysPerWeek, 6);
  assert.ok(strength.sessions.filter((session) => !session.isRest).length > base.sessions.filter((session) => !session.isRest).length);
  assert.ok(strength.sessions.find((session) => !session.isRest).sets > base.sessions.find((session) => !session.isRest).sets);
});

test('workout logs normalize optional weight to null and validate required fields', () => {
  const log = createWorkoutLog({ workoutId: 'day-1', exerciseId: '0001', exerciseName: '3/4 sit-up', sets: 3, reps: 12, duration: 240, kcal: 30, completed: true });
  assert.equal(log.weight, null);
  assert.equal(validateWorkoutLog(log).valid, true);
  assert.equal(validateWorkoutLog({}).valid, false);
});

test('exercise prescription uses reps for strength and seconds for cardio or plank', () => {
  const profile = { height: 175, weight: 70, trainingLevel: 'beginner', trainingGoal: 'general_fitness' };
  const strength = getExercisePrescription({ name: 'Push-Up', category: 'strength' }, profile, { sets: 2 });
  const cardio = getExercisePrescription({ name: 'Jumping Jacks', category: 'cardio' }, profile, { sets: 2 });
  const plank = getExercisePrescription({ name: 'Front Plank', category: 'strength' }, profile, { sets: 2 });
  assert.equal(strength.mode, 'reps');
  assert.ok(strength.reps > 0);
  assert.equal(cardio.mode, 'seconds');
  assert.ok(cardio.seconds > 0);
  assert.equal(plank.mode, 'seconds');
});

test('account storage keys isolate users', () => {
  assert.notEqual(scopeStorageKey('fitflow-plan', 'alice@example.com'), scopeStorageKey('fitflow-plan', 'bob@example.com'));
  assert.match(scopeStorageKey('fitflow-plan', 'alice@example.com'), /alice%40example.com/);
});
