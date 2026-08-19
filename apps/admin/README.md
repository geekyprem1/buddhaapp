# Dhamma Path — Admin desk

Flutter Web admin panel, hosted on Firebase Hosting site `admin`
(`admin.dhammapath.app` once DNS is mapped).

## Run (dev)

```powershell
flutter run -d chrome -t lib/main_dev.dart
```

Against the emulator suite (see `docs/LOCAL_DEV.md`):

```powershell
flutter run -d chrome -t lib/main_dev.dart --dart-define=USE_EMULATOR=true
```

## First login

The panel rejects any account that does not carry an admin custom claim.
Bootstrap the first Super Admin:

```powershell
node tools/admin/bootstrap_super_admin.js --email=you@dhammapath.app --password="choose-a-long-password" --name="Your Name"
```

There is no sign-up screen and no Google / phone path.

## Build & deploy

```powershell
flutter build web -t lib/main_dev.dart --release
firebase deploy --only hosting:admin --project dhamma-path-dev
```

The Hosting public directory is `apps/admin/build/web` (see root
`firebase.json`). Custom domain `admin.dhammapath.app` is mapped in
Firebase Hosting when DNS is ready.

## Layout

See `docs/ARCHITECTURE.md` §11. This sprint ships login, the shell, role
guards, the 12-hour idle timeout, and placeholder module pages. Content
CRUD is the next admin sprint.
