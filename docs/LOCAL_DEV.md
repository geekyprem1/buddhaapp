# Local development

Run the stack against the Firebase Emulator Suite so nobody needs the
prod project (TASKS T0.8).

## Prerequisites

- Flutter stable (3.22+)
- Node 20
- Java 21+ (required by the emulators)
- `firebase login` completed once

## Start the emulators

```powershell
npm --prefix functions install
npm --prefix functions run build
firebase emulators:start
```

| Service | Port |
|---|---|
| Emulator UI | 4000 |
| Hosting | 5000 |
| Functions | 5001 |
| Firestore | 8080 |
| Auth | 9099 |
| Storage | 9199 |

The default project alias is `dhamma-path-dev` (see `.firebaserc`).

## Seed data

Against the **live** dev project (what the mobile app uses today):

```powershell
node tools/seed/seed.js
```

Against the emulator, create documents in the Emulator UI or extend the
seed script later — `seed.js` currently talks to the live Firestore REST
API, not `localhost:8080`.

## First Super Admin

Live dev:

```powershell
node tools/admin/bootstrap_super_admin.js --email=you@dhammapath.app --password="choose-a-long-password" --name="Your Name"
```

Emulator (emulators must already be running):

```powershell
node tools/admin/bootstrap_super_admin.js --emulator --email=dev@local.test --password=password123 --name="Dev"
```

## Mobile app

```powershell
cd apps/mobile
flutter run --flavor dev -t lib/main_dev.dart
```

Talks to live `dhamma-path-dev` unless you later wire `USE_EMULATOR`.

### App Check (T0.6)

The mobile **dev** flavour uses the App Check **debug** provider. First
run prints a debug token in logcat (`D DebugAppCheckProvider`). Register
it in Firebase Console → App Check → Apps → Manage debug tokens.

The admin panel on `localhost` sets `FIREBASE_APPCHECK_DEBUG_TOKEN` in
`apps/admin/web/index.html`. Register that token the same way.

Production / release builds use Play Integrity (Android) and reCAPTCHA
Enterprise (admin web, pass `--dart-define=RECAPTCHA_SITE_KEY=…`).

**Enforcement is a Console step**, not code: App Check → APIs →
Firestore / Storage → Enforce. Do this on `dhamma-path-dev` only after
debug tokens are registered, or every request will be rejected.

## Admin panel

```powershell
cd apps/admin
flutter run -d chrome -t lib/main_dev.dart
```

To point Auth / Firestore / Functions / Storage at the emulators:

```powershell
flutter run -d chrome -t lib/main_dev.dart --dart-define=USE_EMULATOR=true
```

## Deploy (dev)

```powershell
firebase deploy --only functions,hosting:admin,firestore --project dhamma-path-dev
```

Admin hosting serves `apps/admin/build/web`. Build first:

```powershell
cd apps/admin
flutter build web -t lib/main_dev.dart --release
```
