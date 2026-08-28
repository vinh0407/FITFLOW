# FITFLOW Android

Flutter application boundary. The Android app will share the exercise contract and product rules with `apps/web`, while keeping interaction patterns native to active training: large controls, timer-first states, offline-safe session writes, and reduced visual density.

Flutter SDK was not available in the current environment, so the Flutter project scaffold is intentionally deferred until the SDK is installed.

Shared data contract: add `packages/contracts/flutter` as a local Dart dependency. The canonical exercise catalog is `packages/contracts/data/exercises.json`; nutrition and BMI rules are exported by `@fitflow/contracts` and mirrored in the Dart contract package.
