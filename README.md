# FITFLOW

FITFLOW is a local-first training companion for people who train independently. It brings exercise guidance, a 20-minute daily workout, BMI-based planning, nutrition references, calculators, and progress logging into one Web and Android-ready project.

## What is included

### Web

- **Exercise Library** — 1,324 movements, server-filtered search, 9 items per page, lazy media, and body-part, training-type, and equipment filters.
- **Exercise guidance** — select a movement to see its video demonstration, target area, benefits, and instructions.
- **Today’s workout** — a five-movement session with four body-part movements and one cardio movement, sized for about 20 minutes.
- **7-day plan builder** — BMI 18–35 plan generation with daily movement detail and local saving.
- **Training Guide** — an interactive weekly split; every available movement opens its matching Exercise Library detail.
- **Nutrition** — food library, saved foods, a random daily menu, and portion/macro references.
- **Fitness Calculators** — BMI, TDEE, 1RM, macros, body-fat estimate, and heart-rate zones in accessible modal dialogs.
- **About FITFLOW** — product introduction, Android companion summary, and an eight-question FAQ at `/about`.
- **Theme and accessibility** — light/dark theme, keyboard-visible focus, reduced-motion support, semantic controls, and modal Escape/focus handling.

### Android companion

The Flutter application lives in `apps/mobile`. It shares fitness contracts with the web app through `packages/contracts/flutter` and follows the same FITFLOW visual language.

## Quick start

Install dependencies from the repository root:

```bash
npm install
```

Run the Web app:

```bash
npm run dev:web
```

Open [http://localhost:3000](http://localhost:3000).

Create a production build:

```bash
npm run build:web
```

Run the Flutter app:

```bash
cd apps/mobile
flutter pub get
flutter run
```

Useful Flutter checks:

```bash
flutter analyze
flutter test
```

## Demo checklist

The following Web demo was verified on **2026-08-29** after a successful `npm run build:web`:

1. Open `/` and select **Open Calculator** — the BMI calculator opens in a modal and reports an estimate.
2. Open `/#library` — search, body-part, type, and equipment filters work with nine exercise cards per page.
3. Open `/#custom-plan` and select **Barbell Romanian Deadlift** from the Training Guide — its exercise detail modal opens successfully.
4. Open `/nutrition` — browse food categories and create a random daily menu.
5. Open `/about` — the introduction page renders eight expandable FAQ items without horizontal overflow.

## Local-first data

### Regression verification

Run the focused Web/API and shared contract tests from the repository root:

```powershell
npm --workspace apps/web test
node --test packages/contracts/test/*.test.mjs
npm run build:web
```

Browser regression checks live in `apps/web/scripts/verify-ui.mjs`. They require
an available Playwright installation and Chromium-compatible browser, but add no
application dependency. Start a fresh production server on port 3002 after the
build (`npm --workspace apps/web run start -- -p 3002`), then run
`npm --workspace apps/web run test:ui` in another terminal. Set `NODE_PATH` if
Playwright is provided by an external runtime, `QA_BROWSER_PATH` for an installed
browser, and `QA_BASE_URL` when using another server. Screenshots are written to
the system temporary directory under `fitflow-visual-qa` (override with
`QA_OUTPUT_DIR`). Tests use isolated browser contexts and disposable local accounts.

From `apps/mobile`, run `flutter analyze`, `flutter test`, and
`flutter build apk --debug`. Tests include cache recovery, same-day calories,
navigation/AI, 320–414px layouts, tablet layouts and 2× text for Home components.

Malformed mobile cache entries are skipped individually; valid sibling records
remain available. Before a subsequent save can replace a damaged value, its first
original value is backed up as JSON under `<original-key>.recovery`. The app shows
a dismissible notice. These backups are local user data, not diagnostics to upload.

Production caveats: authentication/reset remain device-local prototypes, cloud
sync is not enabled, and Android release builds still use the template application
ID and debug signing configuration. A successful local build is not store or
production deployment approval.

Local persistence now also covers mobile schedules, weight measurements and
workout goals (`fitflow.schedules`, `fitflow.weight_records`,
`fitflow.workout_goals`). Existing model fields and original theme colors are
preserved. Entry forms wait for a successful save before closing; invalid body
measurements cannot update the repository. Missing keys retain the existing
first-run defaults, while an explicitly saved empty collection stays empty.

Web profile updates preserve decimal measurements and shared coaching fields.
Legacy storage migration removes the original only after a successful write.
Malformed workout entries are excluded from the rendered summary with a visible
notice; the stored history is not rewritten by that recovery path. Blocked browser
storage leaves browsing available without treating the visitor as signed in.

The current Web experience stores the selected theme, profile, BMI plan, saved foods, and workout history on the current device. This is deliberately local-first; it does **not** provide authenticated cloud sync between devices yet.

## Shared contracts

`packages/contracts` is the cross-platform source of truth:

- `data/exercises.json` — canonical exercise catalog.
- `src/nutrition.js` — food and nutrition values per 100g.
- `src/bmi.js` — BMI rounding and profiles for BMI 18–35.
- `flutter/` — Dart contracts used by the Android boundary.

The Web build synchronizes the exercise catalog before development and production builds.

## Project structure

```text
apps/web                 Next.js Web application
apps/mobile              Flutter Android application
packages/contracts       Shared exercise, nutrition, BMI, and model contracts
docs                     Product and design notes
```

## Deployment

For Vercel in this monorepo:

- **Root Directory:** `apps/web`
- **Build Command:** `npm run build`
- **Install Command:** `npm install --prefix=../..`
- **Output Directory:** Next.js default

## Disclaimer

BMI, calorie, macro, body-fat, 1RM, and heart-rate outputs are estimates, not medical advice. Training and nutrition suggestions are general guidance; consult a qualified health professional when you have an injury, medical condition, medication concern, or uncertainty.
