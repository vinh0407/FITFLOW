export const BMI_MIN = 18;
export const BMI_MAX = 35;

export const BMI_PROFILES = [
  { bmi: 18, label: 'LOWER WEIGHT', tone: 'BUILD', focus: 'Foundational strength', note: 'Low-impact strength with extra recovery and steady nutrition support.', preferred: ['body weight', 'dumbbell', 'cable'] },
  { bmi: 19, label: 'LOWER HEALTHY', tone: 'BUILD', focus: 'Strength + mobility', note: 'Build control and confidence before adding more training volume.', preferred: ['body weight', 'dumbbell', 'cable'] },
  { bmi: 20, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Full-body strength', note: 'A balanced mix of strength, mobility, and moderate conditioning.', preferred: ['body weight', 'dumbbell', 'barbell', 'cable'] },
  { bmi: 21, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Strength + conditioning', note: 'Progress gradually while keeping movement quality consistent.', preferred: ['body weight', 'dumbbell', 'barbell', 'cable'] },
  { bmi: 22, label: 'HEALTHY RANGE', tone: 'PERFORM', focus: 'Strength + cardio', note: 'Use a steady strength base and short conditioning finishers.', preferred: ['body weight', 'dumbbell', 'barbell', 'cable'] },
  { bmi: 23, label: 'HEALTHY RANGE', tone: 'PERFORM', focus: 'Progressive strength', note: 'Increase reps or load slowly while protecting clean form.', preferred: ['body weight', 'dumbbell', 'barbell', 'cable'] },
  { bmi: 24, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Strength + conditioning', note: 'Keep a balanced week with strength, mobility, and moderate cardio.', preferred: ['body weight', 'dumbbell', 'barbell', 'cable'] },
  { bmi: 25, label: 'UPPER HEALTHY', tone: 'PROGRESS', focus: 'Joint-friendly strength', note: 'Use controlled reps and build workload without rushing impact.', preferred: ['body weight', 'cable', 'band'] },
  { bmi: 26, label: 'OVERWEIGHT RANGE', tone: 'PROGRESS', focus: 'Low-impact strength', note: 'Favor stable positions, moderate volume, and repeatable sessions.', preferred: ['body weight', 'cable', 'band'] },
  { bmi: 27, label: 'OVERWEIGHT RANGE', tone: 'PROGRESS', focus: 'Strength + walking', note: 'Pair full-body strength with accessible, low-impact conditioning.', preferred: ['body weight', 'cable', 'assisted'] },
  { bmi: 28, label: 'OVERWEIGHT RANGE', tone: 'FOUNDATION', focus: 'Low-impact conditioning', note: 'Keep sessions consistent and increase duration before intensity.', preferred: ['body weight', 'cable', 'assisted'] },
  { bmi: 29, label: 'OVERWEIGHT RANGE', tone: 'FOUNDATION', focus: 'Mobility + strength', note: 'Prioritize range of motion, controlled strength, and recovery days.', preferred: ['body weight', 'cable', 'assisted'] },
  { bmi: 30, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Supported movement', note: 'Choose joint-friendly exercises and consider professional guidance.', preferred: ['body weight', 'assisted', 'cable'] },
  { bmi: 31, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Seated + supported strength', note: 'Start with stable positions and short, repeatable movement blocks.', preferred: ['assisted', 'body weight', 'cable'] },
  { bmi: 32, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Low-impact movement', note: 'Keep effort conversational and build tolerance one session at a time.', preferred: ['assisted', 'body weight', 'cable'] },
  { bmi: 33, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Mobility + daily movement', note: 'Prioritize comfortable range, walking, and gradual strength exposure.', preferred: ['assisted', 'body weight'] },
  { bmi: 34, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Gentle full-body work', note: 'Use short sessions, stable exercises, and extra recovery between days.', preferred: ['assisted', 'body weight'] },
  { bmi: 35, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Supported full-body work', note: 'Keep intensity gradual and seek qualified guidance before starting.', preferred: ['assisted', 'body weight'] },
];

export function roundBmi(value) { return Math.round(value); }
export function getBmiProfile(value) { return BMI_PROFILES.find((profile) => profile.bmi === roundBmi(value)) || null; }
