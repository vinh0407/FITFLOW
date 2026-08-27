# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Stack

Web: React/Next.js. Android: Flutter. Shared exercise data and product rules should remain platform-neutral.

## Users

People who train on their own and need guidance, exercise selection, workout planning, and progress tracking without depending on a personal trainer.

## Product Purpose

FITFLOW is a self-guided fitness application that helps users discover suitable exercises, follow structured workouts, and record their training progress. Success means a user can move from choosing a goal to completing and tracking a workout with minimal friction.

## Positioning

The product's differentiator is not yet confirmed. The current product foundation is a structured exercise data layer with 1,324 exercises, instructional steps, multilingual content, and exercise media.

## Operating Context

Users may use the web app for browsing, planning, and reviewing progress, and the Android app while actively training. The Android experience must support quick scanning and interaction during a workout, including limited attention and potentially unreliable connectivity.

## Capabilities and Constraints

- The exercise source dataset contains 1,324 records with body-part, equipment, target-muscle, secondary-muscle, multilingual instructions, thumbnails, and GIF media.
- The source dataset must remain immutable; FITFLOW-specific normalized data should be generated separately.
- Web and Android should share the same conceptual data model and API contracts.
- User-owned data must remain separate from the public exercise catalog.
- Media attribution and Gym visual licensing terms must be preserved and reviewed before production reuse.
- Difficulty levels, goals, workout generation rules, offline behavior, authentication, and backend/deployment choices remain undecided.

## Evidence on Hand

- Source dataset: `exercises-dataset-main/data/exercises.json`
- Dataset schema: `exercises-dataset-main/data/exercises.schema.json`
- Exercise media: `exercises-dataset-main/images/` and `exercises-dataset-main/videos/`
- Media terms: `exercises-dataset-main/NOTICE.md` and `exercises-dataset-main/LICENSE`
- Existing asset: `QR/QR.jpg`
- No existing FITFLOW frontend or mobile implementation was found in the workspace.

## Product Principles

- Make independent training understandable and actionable.
- Reduce decisions during an active workout.
- Keep exercise guidance concrete, scannable, and safe.
- Treat the exercise catalog as a reusable shared foundation across platforms.
- Preserve user progress reliably and make it easy to review.

## Accessibility & Inclusion

Platform-specific accessibility requirements are not yet confirmed. The product should support readable text, sufficient contrast, touch-friendly controls, screen-reader labels, and reduced-motion preferences across web and Android.
