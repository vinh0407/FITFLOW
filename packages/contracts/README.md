# FITFLOW shared contracts

This package is the cross-platform source of truth for the FITFLOW catalog and product rules.

- `data/exercises.json` — canonical exercise catalog consumed by Web and available to Flutter.
- `src/nutrition.js` — Nutrition foods and macro values per 100g.
- `src/bmi.js` — BMI rounding, supported range, and the 18–35 training profiles.
- `flutter/` — Dart package containing the same BMI contract and models for the Android app.

The Web app syncs the canonical exercise JSON into its public asset during `predev`/`prebuild`. Flutter can depend on `packages/contracts/flutter` and load the shared JSON data as app assets.
