# FITFLOW Structure

## Direction

FITFLOW is a training operating system for self-guided users. The first web surface is the Dashboard / Active Workout entry point. The visual language is Swiss Industrial Brutalism: charcoal substrate, off-white type, one hazard-red action color, square geometry, visible grid rules, oversized structural typography, and compact monospace telemetry.

## Repository boundaries

- `data/source/` holds the immutable upstream exercise dataset.
- `data/normalized/` holds FITFLOW-specific normalized records and translations.
- `apps/web/` owns the Next.js web surface.
- `apps/mobile/` is reserved for the Flutter Android app.
- `packages/` holds shared contracts and exercise rules, not platform UI.
- `database/` owns migrations and seeds.
- `scripts/` owns validation, normalization, media checks, and imports.

## First surface

The dashboard proves the product mechanism immediately: a user sees today's session, its readiness, the next exercises, and weekly consistency. The exercise library now loads all 1,324 source records and renders the matching animated GIF for every record. Labels are derived from the source JSON rather than hardcoded sample names, preventing mismatches between a movement and its media. The active workout flow will reuse the same telemetry vocabulary on Android, prioritizing large controls, timer state, set/rep entry, rest, and offline-safe session persistence.
