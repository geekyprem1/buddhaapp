# Dhamma Path — Dev Seed Script

Writes sample teachers, categories, content items (one or more per content
type) and `config/app_config` into a Firestore project — this is the "unlock"
task (T0.9) that lets mobile app development proceed without waiting for the
admin panel (M1) or real licensed content (M3).

## Usage

```powershell
node seed.js                          # seeds dhamma-path-dev (default)
node seed.js --project=dhamma-path-dev
```

Seeding `dhamma-path-prod` is blocked by the script itself — never run this
against production.

## Requirements

- `firebase login` already completed. The script reuses that OAuth access
  token via the Firestore REST API — no service account key, no
  `firebase-admin` dependency.
- No `npm install` needed — the script only uses Node's built-in `https` and
  `child_process` modules.

## What gets written

| Collection | Count | Notes |
|---|---|---|
| `teachers` | 4 | Gautam Buddha, Dr. B. R. Ambedkar, Dalai Lama, Thich Nhat Hanh |
| `categories` | 5 | 2 wallpaper, 2 meditation, 1 status |
| `wallpapers` | 3 | |
| `ringtones` | 2 | |
| `songs` | 2 | |
| `vandanas` | 1 | |
| `meditations` | 3 | includes a 2-part series |
| `statuses` | 1 | with a status layout (photo frame + name text rects) |
| `prarthanas` | 1 | |
| `config/app_config` | 1 | all Phase 2 flags off |
| `config/home_layout` | 1 | default home module order |

All media URLs are placeholder images (`picsum.photos`) and a sample public
audio file — **not licensed content**. Every seeded content item carries
`source: 'seed-placeholder'` and `licence: 'placeholder-not-for-production'`
so it can never be mistaken for real, cleared content and is easy to bulk
delete before M3 (see `docs/TASKS.md` T3.11).

## Cleaning up before real content ingestion (T3.11)

There is no automated cleanup script yet — before M3, delete all documents
where `source == 'seed-placeholder'` via the Firebase console or a follow-up
script.
