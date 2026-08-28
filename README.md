# FITFLOW

FITFLOW is a local-first training companion for people who train independently. It combines a movement library, video guidance, a 20-minute daily workout, BMI-based 7-day planning, a nutrition catalog, and saved progress.

## Web app

The web app is a Next.js project in `apps/web`.

```bash
npm install
npm run dev:web
```

Open `http://localhost:3000`.

To create a production build:

```bash
npm run build:web
```

The Vercel settings for this monorepo are:

- Root Directory: `apps/web`
- Build Command: `npm run build`
- Install Command: `npm install --prefix=../..`
- Output Directory: Next.js default

## Local-first storage

The browser stores the theme, BMI profile, 7-day plan, favorite foods, and workout history locally. No account or external database is required for the current version.

## Shared data contract

`packages/contracts` is the source of truth shared by the Web and Flutter boundaries:

- `data/exercises.json` — exercise catalog.
- `src/nutrition.js` — nutrition values per 100g.
- `src/bmi.js` — BMI rounding and profiles 18–35.
- `flutter/` — Dart models and BMI contract for the Android app.

The Web build synchronizes the canonical exercise catalog automatically before development and production builds.

## Project structure

```text
apps/web                 Next.js web application
apps/mobile              Flutter integration boundary
packages/contracts       Shared catalog and platform contracts
docs                     Product and design notes
```

## Disclaimer

BMI is a screening measure, not a diagnosis. Training and nutrition suggestions are general guidance; consult a qualified health professional when you have an injury, medical condition, or uncertainty.
