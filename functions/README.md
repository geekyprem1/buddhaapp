# Dhamma Path — Cloud Functions

TypeScript, Node 22, region `asia-south1` (Architecture §8).
Node 20 was deprecated on Cloud Functions in April 2026.

## Setup

```powershell
cd functions
npm install
npm run build
```

## Local emulators

From the repo root (see `docs/LOCAL_DEV.md`):

```powershell
npm --prefix functions run build
firebase emulators:start --only auth,firestore,storage,functions,ui
```

## Deploy

```powershell
firebase deploy --only functions --project dhamma-path-dev
```

`firebase.json` runs `npm --prefix functions run build` as a predeploy hook.

## First Super Admin (T1.3 bootstrap)

`setAdminRole` is itself Super-Admin-only, so the first account cannot be
created from the admin panel. Use the bootstrap script, which reuses your
`firebase login` token (same pattern as `tools/seed`):

```powershell
node tools/admin/bootstrap_super_admin.js --email=you@dhammapath.app --password="choose-a-long-password" --name="Your Name"
```

That script:

1. Creates the Auth user (or reuses it if the email already exists)
2. Sets the `role: super_admin` custom claim
3. Writes `adminUsers/{uid}`

Then sign in at the admin panel with that email and password.

**Never run bootstrap against `dhamma-path-prod` without `--allow-prod`.**

Further admins are created from the panel (or by calling `setAdminRole`)
once you are signed in as this first Super Admin.

## Shipped callables

| Function | Trigger | Who |
|---|---|---|
| `setAdminRole` | callable | Super Admin |

Remaining Architecture §8 functions (`onUserCreate`, `onMediaUpload`,
`onContentWrite`, …) land in later M1 tasks.
