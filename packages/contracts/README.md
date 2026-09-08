# FITFLOW shared contracts

This package is the cross-platform source of truth for the FITFLOW catalog and product rules.

- `data/exercises.json` — canonical exercise catalog consumed by Web and available to Flutter.
- `src/nutrition.js` — Nutrition foods and macro values per 100g.
- `src/bmi.js` — BMI rounding, supported range, and the 18–35 training profiles.
- `src/profile.js` — shared profile fields plus the pure `generateTrainingPlan(profile)` engine. Goal, level, BMI, and days/week affect the returned sessions.
- `src/workout.js` — shared workout-log factory and validation for `workoutId`, exercise details, sets/reps, optional weight, duration, estimated kcal, notes, and completion state.
- `flutter/` — Dart package containing the same BMI, training-plan, profile, and workout-log contracts for the Android app.

Workout calories are estimates unless a trusted measurement is available. The shared schema marks this with `kcalEstimated: true`; exercises without load use `weight: null`.

The Web app syncs the canonical exercise JSON into its public asset during `predev`/`prebuild`. Flutter can depend on `packages/contracts/flutter` and load the shared JSON data as app assets.
