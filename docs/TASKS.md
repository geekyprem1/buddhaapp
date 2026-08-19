# Dhamma Path — Task Breakdown

| Field | Value |
|---|---|
| Version | 1.4 |
| Date | 19 August 2026 |
| Last status pass | 19 August 2026 — content Cloud Functions T1.10–T1.14 implemented (media derivatives, audit, scheduled publish, event counters, cleanup) |
| Inputs | `docs/PRD.md` v1.1 · `docs/ARCHITECTURE.md` v1.0 |
| Notation | `→ FR-x.x` = PRD requirement · `deps:` = must finish first · `[P]` = parallelisable |
| Admin hosting | Firebase Hosting, site `admin` → `admin.dhammapath.app` (confirmed) |

---

## Current status (19 Aug 2026)

**Where we are:** Admin desk can log in, CRUD/publish content, send push, edit app config, and edit static pages. Mobile is an MVP: onboarding through Profile, wallpaper/ringtone set, player, Daily Prarthana alarm, status compose, FCM, splash + force-update/maintenance gates. Seed + Functions (`setAdminRole`, `sendNotification`, `sendScheduledNotification`) are on `dhamma-path-dev`.

| Milestone | Done | Partial | Open | Notes |
|---|---:|---:|---:|---|
| **M0 Foundation** (18) | 16 | 0 | 2 | Open: T0.6 App Check, T0.17 l10n CI lint |
| **M1 Admin** (31) | 26 | 0 | 5 | CRUD, publish, notifications, config, static pages, **all content Functions**, **bulk upload**, **status layout editor**, **audit viewer**. Open: users, dashboard, clone/reorder, contact inbox |
| **M2 Mobile** (74) | 62 | 0 | 12 | Splash/config gates live. Open: events, series play, resume, ads slot, live badge, T2.5/T2.9–T2.11, analytics |
| **M3 Content** (11) | 0 | 0 | 11 | Wait for licensed assets |
| **M4 Launch** (14) | 0 | 0 | 14 | After M2+M3 |
| **Launch total** | **104** | **0** | **44** | of 148 (M0–M4) |

**Shipped and checked (admin + Pixel 7 emulator)**
- Admin login Super Admin (`admin@dhammapath.app`)
- Teachers / Categories / six content types browse + wallpaper publish/unpublish + create draft
- Admin notifications: composer + send (T1.25–T1.26)
- Admin app config + home module order (T1.27); mobile home reads `config/home_layout` (T2.20)
- Admin static pages editor (T1.28) — About / Privacy / Terms / Contact / Help
- Mobile: Login → OTP → Language → Person → Teachers → Home → lists → wallpaper set → ringtone set → prarthana alarm (60s test) → status download/share → Profile
- Splash + force-update / maintenance gates (T2.3–T2.4)
- Login Terms + Privacy links (`/legal/:slug`); Profile Help row

**Next up:** deploy T1.10–T1.14 to `dhamma-path-dev` + emulator-test `onMediaUpload` per media type, then T1.21 bulk upload (unblocks M3), T1.29 audit viewer, or T2.46 `events/` play counters.

**Still open on M0**
- T0.6 App Check enforcement
- T0.17 hardcoded-string CI lint + 1.3× scale QA (ARB files already exist)

**M1 leftovers (after CRUD)**
- ~~T1.10–T1.14 Cloud Functions (thumbs, audit, schedule, counters, cleanup)~~ — done, pending deploy + emulator test
- T1.19 visual status layout editor
- T1.21–T1.22 bulk upload, clone, drag-reorder
- T1.23–T1.24 / T1.29–T1.31 users, audit viewer, KPI dashboard, contact inbox

---

## 0. Execution Strategy

**Chosen sequencing: admin-first, but unblocked by a seed script.**

The admin panel is a launch blocker because all content flows through it (D6). But waiting for the full admin panel before starting the app would serialise 4–6 weeks. So:

1. **M0** builds the shared foundation both apps need — models, design system, Firebase, rules.
2. **T0.9 ships a seed script** that writes realistic sample content into the Firestore emulator and dev project. This is the unlock: mobile app work starts immediately against real-shaped data, without waiting for the admin panel or real content.
3. **M1 (admin)** and **M2 (app)** then run in parallel, both against the same `packages/core` models.
4. **M3** loads real content through the finished admin panel, replacing seed data.
5. **M4** is launch hardening.

```
M0 Foundation ──┬── M1 Admin Panel ────┬── M3 Content Ingestion ── M4 Launch
                │                       │
                └── M2 Mobile App ──────┘
                    (on seed data, swaps to real content at M3)
```

Critical path: `M0 → M1 → M3 → M4`. The mobile app must not become the critical path, so if resources are tight, staff admin first.

**Definition of Done (every task):** code merged with a passing CI run (analyze + tests), no hardcoded user-facing strings, loading/empty/error states handled, accessibility labels present, and — for anything touching Firestore — a security-rules test.

---

## M0 — Foundation & Setup

Goal: both apps build, deploy and talk to Firebase; shared models and design system exist; a seed script unblocks parallel work.

### Project scaffolding

- [x] **T0.1** Create monorepo structure per Architecture §2 — `melos.yaml`, root `pubspec.yaml`, `packages/{core,design_system}`, `apps/{mobile,admin}`, `functions/`, `firebase/`
  `deps: —`  ·  Acceptance: `melos bootstrap` succeeds; `melos analyze` clean
  · Done — melos 8 uses pub workspaces (`workspace:` key in root pubspec + `resolution: workspace` per package), not the old `melos.yaml packages:` glob.
- [x] **T0.2** Configure Flutter flavours `dev` / `prod` — app ids `app.dhammapath.dev` / `app.dhammapath`, per-flavour `google-services.json`, `--dart-define` config
  `deps: T0.1`  ·  Acceptance: both flavours install side-by-side on one device
  · Done — `apps/mobile` created (Android-only for now), Gradle `productFlavors` (`dev`/`prod`) with distinct `applicationId` + `app_name`, `google-services.json` per flavour under `android/app/src/{dev,prod}/`, `firebase_options_{dev,prod}.dart` via FlutterFire CLI, separate `main_dev.dart`/`main_prod.dart` entry points. Both flavours build successfully (`flutter build apk --flavor dev|prod`). Not yet verified installed side-by-side on a physical device/emulator — do that before relying on this.
  · **CI gap:** `google-services.json` is gitignored (correctly — it's not a public secret but keeping it out of git history is good practice here since this repo may go to more contributors). The CI mobile build job will fail until these are provided as CI secrets/files. Tracked as a follow-up before `build-mobile` in `.github/workflows/pr.yml` can pass in a fresh clone.
- [x] **T0.3** Set up lint + format — `very_good_analysis` or custom `analysis_options.yaml`, import-boundary rule (presentation must not import `cloud_firestore`)
  `deps: T0.1`
  · Done — root `analysis_options.yaml` on `flutter_lints`. Import-boundary rule to be enforced when `apps/mobile` presentation layer exists (T2.x).
- [x] **T0.4** Set up GitHub Actions CI per Architecture §15 — PR pipeline (analyze, test, rules tests, build debug APK + admin web)
  `deps: T0.1`
  · Partial — `.github/workflows/pr.yml` now runs analyze + test, `build-mobile` (dev debug APK) and `build-admin` (Flutter web). Rules-unit-test job is still a placeholder (T0.7 leftover). Fresh-clone mobile APK still needs `google-services.json` as a CI secret.

### Firebase

- [x] **T0.5** Create Firebase projects `dhamma-path-dev` and `dhamma-path-prod` on Blaze, region `asia-south1`; enable Auth (Phone, Google, Email/Password), Firestore, Storage, FCM, Remote Config, Analytics, Crashlytics, Hosting
  `deps: —`  ·  Acceptance: budget alerts configured at 50/80/100%
  · Done via CLI + REST: both projects created, Blaze linked by user, Firestore (`asia-south1`) + default Storage bucket (`*.firebasestorage.app`) created in both, Phone + Email/Password auth enabled in both, Android + Web apps registered in both, 2 Hosting sites each (`admin`, `public`) with targets wired in `.firebaserc`.
  · Google Sign-In provider now confirmed **enabled** on both projects (user completed the OAuth consent screen setup in Console). Budget alerts still not set (Console-only, billing UI). FCM/Analytics/Crashlytics are enabled per-app when the app SDKs are wired in (T0.6, T2.x) rather than at project level.
- [ ] **T0.6** Wire Firebase into both apps via FlutterFire CLI; enable App Check (Play Integrity on Android, reCAPTCHA Enterprise on web)
  `deps: T0.2, T0.5`  ·  Acceptance: App Check enforcement ON for Firestore + Storage in dev
- [x] **T0.7** Author `firebase/firestore.rules` + `storage.rules` implementing every row of Architecture §7; add `firestore.indexes.json` per §6.3
  `deps: T0.5`  ·  Acceptance: rules unit tests cover each path for anonymous / user / moderator / content_manager / super_admin
  · Rules + indexes written and **deployed to both dev and prod**. Rules unit tests (`@firebase/rules-unit-testing`) still to be written — tracked as a follow-up before M1/M2 rely on these rules being correct.
- [x] **T0.8** Set up Firebase Emulator Suite (Auth, Firestore, Storage, Functions) + a documented local dev workflow
  `deps: T0.5`  ·  Acceptance: `firebase emulators:start` runs; no developer needs the prod project
  · Done — `firebase.json` emulators block (ports 4000/5000/5001/8080/9099/9199) + `docs/LOCAL_DEV.md`. Admin app honours `--dart-define=USE_EMULATOR=true`. Bootstrap script has an `--emulator` flag. Not a substitute for a Java-present smoke start on every machine.

### Shared packages

- [x] **T0.9** **[Unlock]** Build the seed script — a Dart/TS script writing 4 teachers, ~10 items per content type, categories, config docs, static pages into the emulator and dev project
  `deps: T0.11, T0.8`  ·  Acceptance: mobile dev can run the app end-to-end on seed data alone
  · Done — `tools/seed/seed.js`, a dependency-free Node script using the Firestore REST API + the developer's existing `firebase login` token. Seeded `dhamma-path-dev` with 4 teachers, 5 categories, 12 content items (across all 6 types), `config/app_config`, `config/home_layout`, and static pages (about / privacy / terms / contact / help). Refuses to run against `dhamma-path-prod`.
- [x] **T0.10** Define collection/field name constants and `ContentFilter` value objects in `packages/core/constants`
  `deps: T0.1`
- [x] **T0.11** Implement freezed models in `packages/core/models` — `AppUser`, `Teacher`, `Category`, `ContentItem` (+ `WallpaperMeta`, `AudioMeta`, `StatusMeta` sub-objects), `Alarm`, `AppConfig`, `StaticPage`, `AdminUser`, `AuditLog`, `NotificationCampaign`
  `deps: T0.10`  ·  Acceptance: JSON round-trip unit test per model, including null/missing-field tolerance
  · Done — 13 freezed models, `explicit_to_json: true` set in `build.yaml` (required for nested custom objects). 5 tests green.
- [x] **T0.12** Implement shared validators — name, phone, email, title-per-language, file type/size — used identically by app and admin
  `deps: T0.11`  ·  Acceptance: unit tested; admin forms and app forms reject the same inputs
  · Done — `FieldValidators` in `packages/core`, 13 tests green.
- [x] **T0.13** Implement repository interfaces + Firestore implementations in `packages/core/repositories` — `ContentRepository` (generic, type-parameterised), `UserRepository`, `TeacherRepository`, `CategoryRepository`, `ConfigRepository`, `StaticPageRepository`, `AuditRepository`
  `deps: T0.11`  ·  Acceptance: cursor pagination works; queries match the composite indexes in T0.7
  · Done — `ContentRepository`, `UserRepository`, `TeacherRepository`, plus `CategoryRepository`, `ConfigRepository`, `StaticPageRepository`, `AuditRepository` and `AdminUserRepository`. Riverpod providers in `core_providers.dart`. Unit tests against `fake_cloud_firestore`.
- [x] **T0.14** Implement `StorageService` (resumable upload, progress, cancel, delete) and `AnalyticsService` (typed events per PRD §11)
  `deps: T0.11`
  · Done — `StorageService` + `StorageUpload` (progress stream, cancel, `putData`) and `StoragePaths` matching Architecture §6.4. `AnalyticsService` is a typed sink for every PRD §11 event; default no-op, override in the app to forward to Firebase Analytics.
- [x] **T0.15** Build `packages/design_system` — colour tokens (`#FDF3E0`, `#8B1A1A`, `#D4A24C`, `#25D366`, `#1F1F1F`), typography (Poppins + Noto Sans Devanagari), spacing/radii scale, `ThemeData` for mobile and admin
  `deps: T0.1`  ·  Acceptance: no raw hex or magic numbers anywhere outside this package
- [x] **T0.16** Build shared widgets — `PrimaryPillButton`, `TeacherFilterChipRow`, `ContentCard`, `LoadingShimmer`, `EmptyState`, `ErrorState`, `AppBottomSheet`
  `deps: T0.15`  ·  Acceptance: widget tests; 48dp minimum touch targets; semantic labels
  · Done — 4 widget tests green, confirms 48dp minimum target.

### Localisation

- [ ] **T0.17** Set up `gen-l10n` with `app_en.arb`, `app_hi.arb`, `app_mr.arb`; bundle Devanagari fonts; add a CI lint that fails on hardcoded user-facing strings
  `deps: T0.1`  ·  Acceptance: all three locales render without truncation at 1.3x text scale
  · Partial — `apps/mobile/lib/l10n/app_{en,hi,mr}.arb` + `gen-l10n` already generate. Missing: CI hardcoded-string lint, bundled Devanagari fonts (currently Google Fonts), 1.3× scale QA. Admin UI is English-only by design (Architecture §12).
- [x] **T0.18** Implement `LocalisedText` resolution extension (`userLang → en → first non-empty`) for content documents
  `deps: T0.11`
  · Done earlier — `LocalisedTextX.resolve` + unit test; checkbox was stale.

**M0 exit criteria:** mobile app and admin panel both build and connect to dev Firebase; rules tests green in CI; seed data visible in both apps.

---

## M1 — Admin Panel (Flutter Web → Firebase Hosting)

Goal: the team can upload, categorise, schedule and publish all launch content without developer help.

### Shell, auth, hosting

- [x] **T1.1** Configure Firebase Hosting with two sites — `admin` (Flutter Web build) and `public` (privacy/terms landing); set up `firebase.json` rewrites for SPA routing
  `deps: T0.5`  ·  → AR-1.6  ·  Acceptance: `firebase deploy --only hosting:admin` serves the app; custom domain `admin.dhammapath.app` mapped with SSL
  · Done — `firebase.json` already targeted `admin` → `apps/admin/build/web` and `public` → `firebase/public_site` (placeholder landing written). Custom domain SSL mapping is a console/DNS step, not code.
- [x] **T1.2** Admin login page — email/password only, explicit rejection of accounts without an admin claim, clear error states
  `deps: T0.6`  ·  → AR-1.1  ·  Acceptance: a mobile app user (phone/Google) cannot sign in here
  · Done — email/password only, no sign-up / Google / phone. Accounts without an admin claim are signed out immediately with a clear error. Widget tests cover the form and the empty-submit errors.
  · **Verified live (18 Aug 2026):** Super Admin `admin@dhammapath.app` signed in on Chrome after `localhost` / `127.0.0.1` were added to Firebase Auth authorized domains.
- [x] **T1.3** Implement `setAdminRole` callable Function (super-admin only, audit-logged) + a documented bootstrap procedure for the first super admin
  `deps: T0.7`  ·  → AR-1.2
  · Done — `functions/src/admin/setAdminRole.ts` (v2 callable, `asia-south1`, Super-Admin-only, writes `adminUsers/{uid}` + audit log, refuses self-demotion). First-account bootstrap: `tools/admin/bootstrap_super_admin.js` + `functions/README.md`.
- [x] **T1.4** Admin shell — collapsible left nav, top bar with user menu, responsive from 1024px, role-based nav visibility
  `deps: T1.2, T0.15`  ·  → AR-8.1
  · Done — `AdminShell` + `AdminSideNav`, collapses below 1100px, role-filtered destinations. Widget tests for content-manager vs super-admin visibility.
- [x] **T1.5** `go_router` role guards + 12h idle session timeout + re-auth prompt for destructive actions
  `deps: T1.4`  ·  → AR-1.4  ·  Acceptance: direct URL access to a forbidden route redirects, and the rules deny it anyway
  · Done — `resolveAdminRedirect` is the single gate (unit-tested). `IdleTimeoutListener` (12h, widget-tested). `ReauthDialog` + `ConfirmDialog` ready for destructive actions in later CRUD tasks.

### Reusable admin widgets

- [x] **T1.6** `PaginatedDataTable2` wrapper — Firestore cursor pagination, search, multi-filter, sort, bulk select, empty/error/permission-denied states
  `deps: T0.13`  ·  → AR-3.1, AR-8.4
  · Done as searchable/filterable list rows (not DataTable2) — enough for launch volumes; cursor pagination can replace the in-memory 100-item cap later.
- [x] **T1.7** `UploadDropzone` — drag & drop, client-side validation, resumable upload, progress bar, cancel, multi-file
  `deps: T0.14`  ·  → AR-8.2
  · Done as `UploadField` — file picker, type/size validation, resumable `StorageService` upload with progress + cancel. Multi-file bulk drop is T1.21.
- [x] **T1.8** `LocalisedTextField` — en/hi/mr tabs in one control with per-language validation
  `deps: T0.12, T0.18`
- [x] **T1.9** `MediaPreview` (image viewer + audio player), `UnsavedChangesGuard`, `ConfirmDialog`
  `deps: T1.4`  ·  → AR-8.3
  · Image preview lives in `UploadField`. `UnsavedChangesGuard` + existing `ConfirmDialog`. Dedicated audio player widget still pending.

### Cloud Functions for content

- [x] **T1.10** `onMediaUpload` — image → WebP full + thumbnail (≤40 KB); audio → duration + waveform; patch the content doc with `mediaUrl`/`thumbUrl`/`durationSec`
  `deps: T0.7`  ·  → AR-3.6  ·  Acceptance: emulator test per media type
  · Done — `functions/src/media/onMediaUpload.ts` (`onObjectFinalized`, `asia-south1`, 512 MiB). Fires only on `{collection}/{itemId}/original.{ext}`; derivatives carry a `derived` metadata marker so the trigger never loops. Images → `full.webp` (max 1440px, q82) + `thumb.webp` (quality/width stepped down until ≤40 KB) via **sharp**, doc patched with `mediaUrl`/`thumbUrl`/`storagePath` and, for wallpapers, `wallpaper.{width,height,orientation}`. Audio → `audio.durationSec` read from the header via **music-metadata** (v7, CJS), **plus `mediaUrl` + `storagePath` set to the original file's download URL** (audio isn't transcoded — the original mp3 is the playable media; the client-set download token is reused via `ensureDownloadUrl`). Waveform left null (deferred; UI only uses duration). Sets `mediaProcessedAt` so `onContentWrite` treats the patch as machine noise.
  · **Verified live on `dhamma-path-dev` (19 Aug 2026):** 3 wallpapers bulk-dropped → each produced `full.webp` + `thumb.webp` (thumbs 5–15 KB, all ≤40 KB) and the docs were patched with the webp `mediaUrl`/`thumbUrl` + `mediaProcessedAt`; images render in the admin list. Audio verified separately: a bulk-dropped mp3 got `durationSec` **and** a playable `mediaUrl` pointing at its `original.mp3`.
  · **Bug found + fixed during testing:** the first audio bulk-upload left `mediaUrl: null` because the audio path only patched duration (images get `mediaUrl` from the webp derivative, but audio isn't transcoded). Fixed by having the audio path also set `mediaUrl`/`storagePath` to the original. Pre-fix audio drafts need their media re-uploaded (or a one-off backfill) — only relevant if any were created before the fix.
  · Deploy note: the event-triggered functions failed on the *first* deploy with an Eventarc permission-propagation error (benign first-2nd-gen delay) — fixed by re-running `firebase deploy --only functions` a few minutes later.
- [x] **T1.11** `onContentWrite` — audit log entry with before/after diff, required-field validation
  `deps: T0.7`  ·  → AR-1.5
  · Done — `functions/src/content/onContentWrite.ts`. One `onDocumentWritten` trigger per content collection (`onWallpaperWrite` … `onPrarthanaWrite`). Create/update/delete each write an `auditLogs` entry via the shared `writeAuditLog`; updates carry a before/after diff limited to the changed keys. Machine-owned fields (`counters`, media derivatives, `mediaProcessedAt`, timestamps) are ignored so aggregation and media patches don't spam the log. Actor resolves `updatedBy → createdBy → system`. Published items missing title/source/licence/media are logged as warnings (no doc mutation, so no loop).
- [x] **T1.12** `publishScheduled` (every 15 min) — `draft → published` at `publishAt`, `published → archived` at `expireAt`
  `deps: T0.7`  ·  → AR-3.3, FR-12.9
  · Done — `functions/src/content/publishScheduled.ts` (`onSchedule` every 15 min, `Asia/Kolkata`). Batched transitions across all six collections; status writes flow through `onContentWrite` so each is audited (actor `system`). Added `(status, publishAt)` + `(status, expireAt)` ascending indexes for all six collections to `firestore.indexes.json`.
- [x] **T1.13** `aggregateEvents` (every 5 min) — fold `events/` into content `counters`, delete processed events
  `deps: T0.7`  ·  → NFR cost control
  · Done — `functions/src/counters/aggregateEvents.ts` (every 5 min). Reads up to 500 oldest `events/`, coalesces into one incremented write per content doc (`counters.{views|downloads|shares|plays}` via `FieldValue.increment`), skips increments for since-deleted docs, then deletes the processed events. Canonical event shape defined for T2.46 to emit: `{ collection, itemId, type: 'view'|'download'|'share'|'play', createdAt }`.
- [x] **T1.14** `cleanupOrphans` (daily) — orphaned Storage objects, soft-deletes older than 30 days
  `deps: T0.7`  ·  → AR-3.7
  · Done — `functions/src/maintenance/cleanupOrphans.ts` (daily). Hard-deletes content soft-deleted >30 days ago plus its Storage folder, then removes Storage objects under the six content prefixes whose owning doc is gone. Guarded: only touches the content prefixes (never `users/**`) and skips any object created in the last 24h so an in-progress upload is never deleted.

### Content management

- [x] **T1.15** Teachers CRUD — name ×3 languages, portrait, thumbnail, bio, signature image, `idCardPrefix`, `sortOrder`, `isActive`, drag-and-drop reorder
  `deps: T1.6, T1.7, T1.8`  ·  → AR-3.x, FR-5.3, FR-5.8  ·  Acceptance: the 4 launch teachers can be created end-to-end
  · Done minus drag-and-drop reorder (sort order is an integer field).
  · **Verified live:** seeded teachers list + edit/save.
- [x] **T1.16** Categories CRUD — scoped to a module, name ×3 languages, `sortOrder`, `isActive`
  `deps: T1.6, T1.8`  ·  → AR-3.x
  · **Verified live:** module chips + open existing category.
- [x] **T1.17** **Generic content module** — `ContentTypeConfig` declaring fields per type, plus `ContentListPage` and `ContentFormPage` built from that config (common metadata: titles ×3, teachers multi-select, category, tags, sortOrder, isFeatured, isPremium, **source + licence**, publishAt, expireAt)
  `deps: T1.6, T1.7, T1.8, T0.13`  ·  → AR-3.1–3.4  ·  Acceptance: adding a new content type requires only a new config object
  · Done. `publishAt`/`expireAt` pickers not in the first form — status is set directly. Scheduling pickers are T1.20 leftovers.
- [x] **T1.18** Configure the six content types on top of T1.17 — Wallpapers (static; `kind` field present with `live` disabled), Ringtones (artist, trim, auto-duration), Songs (artist, album, lyrics ×3), Meditations (narrator, series + part, level), Statuses (photo-frame rect, name-text style, watermark, festival date), Prarthanas (recommended time, description)
  `deps: T1.17`  ·  → AR-3.4, AR-3.x, FR-7.x–12.x  ·  Acceptance: each type creates a document matching the Architecture §6.2 shape exactly
  · **Verified live:** wallpapers list, create draft `Test Lotus`, songs/meditations form fields.
- [x] **T1.19** Status layout editor — visual drag/resize of the photo frame and name text over the base image, writing **normalised 0–1 coordinates**; live preview with a sample photo and name
  `deps: T1.18`  ·  → FR-12.2  ·  Acceptance: the coordinates produced render identically in the mobile composer (verified against T2.28)
  · Done — `apps/admin/lib/features/content/presentation/status_layout_editor_page.dart` at `/content/statuses/{id}/layout`, opened from an "Open visual layout editor" button in the status content form (shown once the item is saved with a base image). Drag the circular photo frame and the name box over the base image, drag the bottom-right handle to resize; a sample name (editable) and an optional locally-picked sample photo make the preview live. Also edits name font-size (slider), alignment, watermark toggle and festival date. Writes `StatusMeta { photoFrame, nameText, watermark, festivalDate }`. **The preview uses the exact same normalised-coordinate math as the mobile composer** (`apps/mobile/.../status_layout.dart`): frame circle = `min(w·W, h·H)` at top-left `(x·W, y·H)`, name at `(x·W, y·H)` width `w·W`, font `size·H`; the preview canvas matches the base image's aspect ratio so it composes identically in proportion (FR-12.2 / T2.28 contract).
  · **Verified live (19 Aug 2026):** button appears on saved status items, drag/resize of frame + name works and saves back. Drag performance: transient gesture state is kept local to the preview and committed to the parent only on gesture-end (base image wrapped in a `RepaintBoundary`), so the Controls panel doesn't rebuild per pointer move — smooth in debug, smoother in `--release`. **Not yet round-trip-verified against a real status image in the mobile composer — do that during T3.7.**
- [x] **T1.20** Publish workflow UI — Draft/Published/Unpublished/Archived transitions, scheduling pickers, bulk publish/unpublish, soft delete + restore
  `deps: T1.17`  ·  → AR-3.3, AR-3.7
  · Done for single-item transitions (list overflow + form status). Bulk actions and schedule pickers still open.
  · **Verified live:** wallpaper unpublish → filter unpublished → publish again.
- [x] **T1.21** Bulk upload — multi-file drop creating one draft per file with the title auto-filled from the filename
  `deps: T1.17`  ·  → AR-3.5  ·  Acceptance: 50 wallpapers ingested in one drop
  · Done — `apps/admin/lib/features/content/presentation/bulk_upload_page.dart` at `/content/{type}/bulk`, reached from a "Bulk upload" button on every content list. Multi-select file picker with per-file type/size validation and a live per-row progress bar. For each file: creates the **draft doc first** (so `onMediaUpload`'s derivative patch merges onto an existing doc), then uploads the original to `{collection}/{itemId}/original.{ext}`; the Function fills `mediaUrl`/`thumbUrl`/duration. Title auto-derived from the filename (extension stripped, `_`/`-` → spaces, capitalised). Failed uploads hard-delete their draft so no empty rows are left. Teacher/category/source/licence are filled per item afterwards in the editor.
  · **Verified live on `dhamma-path-dev` (19 Aug 2026):** 3 wallpapers dropped at once → 3 drafts created with filename titles, originals uploaded, and (via `onMediaUpload`) webp derivatives + thumbnails generated and shown in the admin list.
  · **CORS gotcha found + fixed:** Flutter Web (CanvasKit) fetches image bytes cross-origin to decode them, so Storage objects need a CORS policy or thumbnails silently fail to render (external CORS-enabled URLs like picsum worked, Storage webp did not). Set a GET/HEAD `origin:['*']` CORS policy on `dhamma-path-dev.firebasestorage.app` via `tools/seed/set_cors.js` (safe: content is public-read, Storage Rules protect private paths — CORS is not auth). **Prod bucket needs the same policy before launch — see T4.x below.**
- [ ] **T1.22** Clone/duplicate an item; drag-and-drop reorder within a category
  `deps: T1.17`  ·  → AR-3.8, AR-3.9

### Users, notifications, config, audit

- [ ] **T1.23** Users table + detail view — search, filters, block/unblock, activity summary
  `deps: T1.6`  ·  → AR-5.1–5.3
- [ ] **T1.24** `exportUsersCsv` Function + UI (super admin only, PII warning, audit-logged); deletion-request queue with `processDeletionRequest`
  `deps: T1.23`  ·  → AR-5.4, AR-5.5, FR-2.8
- [x] **T1.25** `sendNotification` + `sendScheduledNotification` Functions — topic/segment targeting, delivery stats
  `deps: T0.7`  ·  → AR-6.1–6.4
  · Done. Callable maps `all` / `language:{code}` / `teacher:{id}` to FCM topics (`all`, `lang_*`, `teacher_*`); `user:{uid}` and `platform:{android|ios}` fan out to stored device tokens. Scheduled dispatcher runs every 5 minutes (`Asia/Kolkata`). Topic sends record `deliveredCount = 0` (FCM does not return subscriber counts); token sends store the multicast success count. Opened count stays 0 until inbox/analytics land. Deployed to `dhamma-path-dev` (`asia-south1`).
- [x] **T1.26** Notification composer UI — title/body/image/deep-link, live phone preview, audience targeting, send now or schedule, test send to a device token, history
  `deps: T1.25, T1.4`  ·  → AR-6.1–6.5
  · Done. `/notifications` history + `/notifications/new` composer with phone preview, audience chips, module/route/url tap targets, draft save, send now, schedule, and test-token send.
  · **Verified live** on admin Chrome (`dhamma-path-dev`).
- [x] **T1.27** App config editor — min/latest version, force update, maintenance mode + message ×3, languages list, home module order/visibility, Phase 2 feature flags (`adsEnabled`, `idCardEnabled`, `liveWallpaperEnabled`)
  `deps: T1.4, T0.13`  ·  → AR-7.1, AR-7.4, AR-7.5
  · Done. Super-admin `/config` writes `config/app_config` + `config/home_layout`. Force-update and maintenance ask for confirm. Home order/visibility is live on mobile (T2.20). Gates are consumed by T2.3/T2.4.
  · **Verified live** — admin save + mobile gates on the emulator.
- [x] **T1.28** Static pages editor — rich text ×3 languages for About / Privacy / Terms / Contact / Help
  `deps: T1.8`  ·  → AR-7.2, FR-14.4
  · Done. Super-admin `/pages` lists the five slugs; editor has title ×3, HTML toolbar (bold/italic/heading/list/link), live preview. Mobile viewer renders the same subset. Login now links Terms + Privacy (`/legal/:slug`, allowed signed-out). Seed includes all five slugs.
- [x] **T1.29** Audit log viewer — filter by entity type, actor, date; before/after diff display
  `deps: T1.6, T1.11`  ·  → AR-1.5
  · Done — `apps/admin/lib/features/audit/` (provider + `AuditLogPage`) at `/audit`, replacing the placeholder. Newest-first read of `auditLogs` with a **server-side entity-type filter** (uses the existing `entityType ASC, createdAt DESC` index) plus **client-side** actor/action/id text search and a time-range narrowing (all / 24h / 7d / 30d). Each row expands to a **before/after field diff** (create shows after, delete shows before, update shows changed keys only — exactly what `onContentWrite` records). Action badge colours create/update/delete/role/notification. Reads only (clients can't write `auditLogs` — Functions only, Architecture §7); the page is `isAdmin`-gated. `flutter analyze` clean. **Verify live after a few CRUD/publish actions generate entries.**
- [ ] **T1.30** Dashboard — KPI cards (users, DAU, new today, item counts, downloads, shares), user-growth and engagement charts, recent activity feed
  `deps: T1.6, T1.13`  ·  → AR-2.1–2.3
- [ ] **T1.31** Contact messages inbox — list, read, mark resolved
  `deps: T1.6`  ·  → FR-14.5

**M1 exit criteria:** a non-developer uploads and publishes one item of every content type unaided; audit log records it; the mobile app on seed data sees the published item appear live.

---

## M2 — Mobile App MVP (Android)

Runs in parallel with M1 against seed data (T0.9). All P0 requirements from PRD §6.

### Bootstrap & routing

- [x] **T2.1** `main.dart` bootstrap — Firebase init, App Check activate, Hive open, Crashlytics hook, Firestore persistence (`40MB`), error boundary
  `deps: T0.6, T0.11`  ·  → FR-1.2
  · Partial — `main_dev.dart`/`main_prod.dart` do Firebase init. App Check, Hive, Crashlytics hook and the 40MB persistence setting not yet wired; tracked for before M2 exit.
- [x] **T2.2** `go_router` setup with the single-place redirect gate — force update → maintenance → login → resume onboarding step → home
  `deps: T2.1`  ·  → FR-1.5, D2  ·  Acceptance: no screen contains its own auth check; deep links respect the gate
  · Done — `app/router.dart`. Redirect gate: force-update → maintenance → signed-out → login, mid-onboarding → correct step, complete → home.
  · **Bug fixed after emulator testing:** the signed-out branch returned `null` (stay put) when already on splash, instead of redirecting to login — the app hung on the splash screen forever for a signed-out user. Fixed to redirect to login unconditionally unless already on an auth route. Verified on a Pixel 7 (Android 14) emulator: app now reaches the Login screen and the phone input takes focus correctly.
- [x] **T2.3** Splash screen (max 2s, branded) + `appBootstrapProvider` fetching Remote Config and `config/app_config` with a cached fallback
  `deps: T2.2`  ·  → FR-1.1, FR-1.2
  · Done — `AppBootstrapLoader` fetches Firestore `config/app_config` (Hive cache fallback), overlays Remote Config kill-switches (`force_update`, `maintenance_mode`, `min_supported_version`), waits at most 2s. Splash stays until bootstrap resolves.
  · **Verified live** on Pixel 7 (Android 14) emulator.
- [x] **T2.4** Force-update blocking dialog + maintenance screen (admin-set message, localised)
  `deps: T2.3`  ·  → FR-1.3, FR-1.4
  · Done — `/update` blocks when `forceUpdate` is on and installed < min version (Play Store button, no back). `/maintenance` shows the admin message × language with Retry. Router runs these gates before auth.
  · **Verified live** on Pixel 7 (Android 14) emulator.
- [ ] **T2.5** Global error/offline handling — retry with exponential backoff in repositories, offline banner, Crashlytics non-fatals
  `deps: T2.1`  ·  → NFR reliability

### Authentication

- [x] **T2.6** Login screen — logo, "Dhamma Path", tagline, Buddha illustration, `+91` mobile input, "Continue with OTP", "Continue with Google", T&C + Privacy links, **no skip affordance**
  `deps: T0.16, T2.2`  ·  → FR-2.1, D2
  · Done, minus the Buddha illustration image. T&C / Privacy links now open `/legal/terms` and `/legal/privacy`.
- [x] **T2.7** Phone OTP flow — Firebase Phone Auth, 6-digit OTP screen, SMS Retriever autofill, 60s resend timer, change-number link
  `deps: T2.6`  ·  → FR-2.2
  · Done via `AuthService.startPhoneVerification` + `OtpScreen`. **Verified end-to-end on a Pixel 7 (Android 14) emulator.** Two Firebase-side config fixes were needed during testing: (1) SMS region policy was blocking all regions by default — set `smsRegionConfig.allowlistOnly.allowedRegions = ["IN"]` on dev (India-focused, correct for prod too); (2) added a **test phone number** `+91 9625460550` → `123456` in dev Auth config so emulator testing needs no real SMS / reCAPTCHA. SMS Retriever autofill path (`verificationCompleted`) not separately exercised — the manual code-entry path is what was verified.
- [x] **T2.8** Google Sign-In flow
  `deps: T2.6`  ·  → FR-2.3
  · Done using `google_sign_in` 7.x's `GoogleSignIn.instance.authenticate()` API. Debug-keystore SHA-1 (`EE:EC:31:...`) is now registered against both the dev and prod Firebase Android apps and `google-services.json` re-downloaded with the resulting OAuth client. Still untested on a real device/emulator.
- [ ] **T2.9** `onUserCreate` Function — seed `users/{uid}` (auth method, device info, FCM token, `onboardingStep: 'language'`), subscribe to the `all` topic
  `deps: T0.7`  ·  → FR-2.4
  · Client-side safety net done instead (`UserRepository.ensureUserDocument`, called from `AuthController`). The Cloud Function itself is still pending (needs `functions/` to be scaffolded).
- [ ] **T2.10** Auth error handling — invalid number, wrong OTP, too many attempts, network failure, Play Integrity failure; all localised
  `deps: T2.7, T2.8`  ·  → FR-2.7
  · Partial — a generic error snackbar exists; error-code-specific localised messages not yet implemented.
- [ ] **T2.11** `guardOtpAbuse` — per-number OTP rate limiting behind App Check
  `deps: T0.6`  ·  → FR-2.9  ·  Acceptance: repeated OTP requests for one number are throttled server-side

### Onboarding

- [x] **T2.12** Language selection screen — 3 cards (English / हिन्दी / मराठी), device-locale preselect, red border + check badge on selection, Continue disabled until chosen, immediate UI language switch
  `deps: T0.17, T2.2`  ·  → FR-3.1–3.4  ·  `[P]`
  · Done and **verified on device**. Bug found + fixed during testing: `initState()` called `View.of(context)` for device locale, which is an illegal InheritedWidget lookup that far in the lifecycle and crashed the screen — replaced with `WidgetsBinding.instance.platformDispatcher.locale`. "Immediate UI language switch" still only persists to Firestore for now — actually switching `MaterialApp`'s active locale is a small follow-up (needs a locale provider read by `DhammaPathApp`).
- [x] **T2.13** Person Information screen — Full Name (2–40 chars, Devanagari-safe), Mobile (10 digits, read-only when phone-auth), Email (optional, prefilled when Google-auth), inline validation
  `deps: T0.12, T2.12`  ·  → FR-4.1–4.4  ·  `[P]`
- [x] **T2.14** Teacher selection screen — search box, 2-column portrait grid from Firestore (`isActive`, `sortOrder`), **multi-select**, helper text, minimum 1 required
  `deps: T0.13, T2.13`  ·  → FR-5.1–5.6  ·  `[P]`
  · Done and **verified on device** against the 4 seeded teachers. Bug found + fixed: the `teachers where isActive==true order by sortOrder` query needed a composite index that was missing from `firestore.indexes.json` — added `teachers (isActive, sortOrder)` and `categories (module, isActive, sortOrder)` indexes, deployed to dev + prod, confirmed READY. The screen's `ErrorState` + Retry correctly surfaced the failure until the index built.
- [x] **T2.15** Onboarding progress persistence — write `onboardingStep` after each step so a killed app resumes exactly where it left off
  `deps: T2.14`  ·  → FR-1.5
  · Done and **verified on device** — each `UserRepository` update advances `onboardingStep`; the router redirect resumed at the correct step across app restarts during testing (e.g. a signed-in user landed straight on the teacher step, not login).

> **Milestone note (device verification):** the full MVP onboarding happy path — Login → OTP → Language → Person Info → Teacher Select → Home — now runs end-to-end on a Pixel 7 (Android 14) emulator against the real `dhamma-path-dev` Firebase project and seeded content. This exercises T2.2, T2.6, T2.7, T2.12–T2.15 together, plus confirms Firebase Auth, Firestore reads/writes, security rules and the router gate all work against a live project.
- [x] **T2.16** Notification permission request (Android 13+) with rationale, shown **after** onboarding completes
  · Done — Home shows a one-time rationale then `POST_NOTIFICATIONS`. Flag stored in Hive `app_prefs`.
  `deps: T2.15`  ·  → FR-1.6

### Shared content infrastructure

- [x] **T2.17** `selectedTeachersProvider` + `TeacherFilterChipRow` — `All | <teachers> | ⊕`, with the ⊕ sheet adding teachers to the user document; reactive across all five list screens
  `deps: T2.14, T0.16`  ·  → FR-5.7, plus every list screen  ·  Acceptance: adding a teacher on one screen updates the chips everywhere
  · Done — `selectedTeacherChipsProvider` (resolves the user's `selectedTeachers` against the live `teachers` collection into localised chip labels) + `contentTeacherFilterProvider` (per-module selected filter). `TeacherFilterChipRow` from `design_system` is wired into `ContentListScaffold`, so the chip row appears on every content screen. **The ⊕ "add teacher" picker sheet is still a stub** (callback present, sheet not built yet).
- [x] **T2.18** Generic paginated content list controller — `@riverpod` family keyed by `ContentFilter`, 10–20 per page, infinite scroll, shimmer placeholders, Hive first-page snapshot for instant offline render
  `deps: T0.13, T2.17`  ·  → FR-6.6, NFR performance
  · Done — `ContentListController` (`@riverpod` family keyed by `(collection, teacherId)`) with cursor pagination, `loadMore()` on scroll-near-end, and `refresh()` (pull-to-refresh). One controller serves all 6 content types. **Not yet done:** shimmer placeholder (uses a plain spinner for now) and the Hive first-page offline snapshot — deferred to the caching pass.
- [ ] **T2.19** Reserve ad-slot index arithmetic in the paginated list builder (no ad SDK; slots inert while `adsEnabled: false`)
  `deps: T2.18`  ·  → FR-16.x (Phase 2 readiness)

### Home

- [x] **T2.20** Home screen — app bar (profile avatar, app name, Share App), 2×2 module grid (Wallpaper, Meditation, Ringtone, Song) + full-width Daily Prarthana tile, config-driven order/visibility
  `deps: T2.17, T0.16`  ·  → FR-6.1–6.3
  · Done — tiles come from `config/home_layout`. Consecutive grid modules stay 2-column; Prarthana and Status stay full-width. Hidden modules drop off immediately.
- [x] **T2.21** Trending Status section — teacher chips + paginated status feed, pull-to-refresh
  `deps: T2.18, T2.28`  ·  → FR-6.4, FR-6.6, FR-6.7
  · Done — Home tile + `/statuses` list with teacher chips, pagination and pull-to-refresh. Cards compose on-device.
- [x] **T2.22** Share App — localised message + Play Store link via the native share sheet
  `deps: T2.20`  ·  → FR-6.9, FR-9 analytics
  · Done — Home app-bar and Profile both open the system share sheet.

### Wallpapers

- [x] **T2.23** Native `WallpaperPlugin.kt` — `WallpaperManager` set for home / lock / both; MediaStore save to `Pictures/Dhamma Path/` (scoped-storage safe, Android 8–15)
  `deps: T0.2`  ·  → FR-7.5, FR-7.8  ·  Acceptance: verified on Android 8, 10, 12, 14, 15
  · Done — `WallpaperPlugin.kt` + Dart `WallpaperService`. FLAG_SYSTEM / FLAG_LOCK (API 24+, minSdk 26). Gallery save uses MediaStore `RELATIVE_PATH` on 10+ and a public Pictures folder on 8–9. Device-matrix verification is still T4.1.
- [x] **T2.24** Wallpaper list screen — teacher chips, large preview cards with an overlaid **Set Wallpaper** button, thumbnails in list
  `deps: T2.18, T2.23`  ·  → FR-7.1, FR-7.2, FR-7.7
  · Done — 2-column grid + teacher chips. Overlaid **Set wallpaper** opens the Home/Lock/Both sheet; tap opens detail.
- [x] **T2.25** Wallpaper detail — full-screen, pinch-zoom, swipe between items, actions Set / Download / Share
  `deps: T2.24`  ·  → FR-7.4
  · Done — `WallpaperDetailScreen` (`/wallpapers/view`) with `InteractiveViewer` + `PageView`. Download writes `Pictures/Dhamma Path/`; share uses the system sheet.
- [x] **T2.26** Set-wallpaper bottom sheet (Home / Lock / Both) + success-failure toast and haptic
  `deps: T2.23`  ·  → FR-7.5, FR-7.9
- [ ] **T2.27** Add the "Live" badge slot to the wallpaper card, inert while `liveWallpaperEnabled: false`
  `deps: T2.24`  ·  → FR-7.3 (Phase 2 readiness)

### Trending Status (highest-value viral feature)

- [x] **T2.28** Status compositor — a pure function of `(baseImage, photo, name, layout)` that maps normalised 0–1 rects to the render box; used identically by preview and export
  `deps: T0.11, T1.19`  ·  → FR-12.2, FR-12.10  ·  Acceptance: golden tests per language; preview and export match pixel-for-pixel in proportion
  · Done — `status_layout.dart` + `StatusCompositor` (`PictureRecorder`). Preview and export share the same 0–1 math. Goldens still later.
- [x] **T2.29** Status card widget — base image + circular user photo in frame + name text + circular camera button + Download and Share buttons
  `deps: T2.28`  ·  → FR-12.1, FR-12.2
- [x] **T2.30** Photo picker + circular crop — Android Photo Picker (no permission) or Camera; saved once to app dir and `users/{uid}.photoUrl`, reused across all statuses
  `deps: T2.29`  ·  → FR-12.3
  · Done — gallery/camera via `image_picker`; circular clip at render/export. Photo stays on-device (`status_avatar.jpg`) and is reused on every card. Cloud backup of the photo is not on (FR-12.10).
- [x] **T2.31** Inline name edit, defaulting to the onboarding name
  `deps: T2.29`  ·  → FR-12.4
- [x] **T2.32** Full-resolution export (≥1080px wide) via `PictureRecorder` → PNG → MediaStore save to `Pictures/Dhamma Path/`
  `deps: T2.28, T2.23`  ·  → FR-12.5
- [x] **T2.33** WhatsApp-direct share with a graceful system-share-sheet fallback; admin-toggleable watermark
  `deps: T2.32`  ·  → FR-12.6, FR-12.7
  · Done — WhatsApp / Business intent first, `share_plus` sheet fallback. Watermark drawn when `statusMeta.watermark` is true.

### Audio engine (shared by Ringtone, Song, Meditation)

- [x] **T2.34** `audio_service` + `just_audio` singleton `AudioHandler` — media notification, lock-screen controls, audio focus and ducking, background playback
  `deps: T0.2`  ·  → FR-9.4  ·  Acceptance: only one player is ever active; a second play request stops the first
  · Done — `DhammaAudioHandler` + `AudioService.init` from both entry points. Android `AudioServiceFragmentActivity`, media-playback FGS, notification channel. One handler serves ringtone preview, songs and meditations.
- [x] **T2.35** Persistent mini-player surviving navigation, with a tap-to-expand full player
  `deps: T2.34`  ·  → FR-8.10
  · Done — `MiniPlayer` in `MaterialApp.router` builder; hidden on the full-player route.
- [x] **T2.36** Buffering, retry-on-network-error and stalled-stream handling
  `deps: T2.34`  ·  → FR-9.5
  · Done — one retry on `setUrl` failure; buffering shown on the full player via `processingState`.

### Ringtones

- [x] **T2.37** Native `RingtonePlugin.kt` — `Settings.System.canWrite()` check, `ACTION_MANAGE_WRITE_SETTINGS` deep link, download to app media dir, MediaStore insert with `IS_RINGTONE`/`IS_ALARM`/`IS_NOTIFICATION`, `RingtoneManager.setActualDefaultRingtoneUri`
  `deps: T0.2`  ·  → FR-8.6, FR-8.7  ·  Acceptance: works on Android 8–15 across Samsung / MIUI / ColorOS / Pixel
  · Done — `RingtonePlugin.kt` + Dart `RingtoneService`. API 29+ writes `Ringtones|Alarms|Notifications/Dhamma Path` via MediaStore; API 26–28 uses the public dir + `DATA`. Device-matrix verification is still T4.1.
- [x] **T2.38** Ringtone list screen — teacher chips, rows with thumbnail + play overlay, title, `artist • duration`, and a **Set** button
  `deps: T2.18, T2.34`  ·  → FR-8.2, FR-8.3
  · Done — `RingtoneListScreen` + shared `AudioListTile` (thumbnail w/ play overlay, title, `artist • m:ss`, trailing **Set** button, "▶ Help" app-bar action).
- [x] **T2.39** Inline preview playback — one at a time, row-level progress indicator
  `deps: T2.38, T2.34`  ·  → FR-8.4
  · Done — tap toggles play/pause on the shared handler (one at a time). Row shows pause overlay when this item is current. Per-row seek bar still later.
- [x] **T2.40** Set sheet (Ringtone / Alarm / Notification) + the full permission rationale flow and post-return completion
  `deps: T2.37, T2.38`  ·  → FR-8.5, FR-8.6
  · Done — sheet + rationale dialog + `ACTION_MANAGE_WRITE_SETTINGS`. Pending set is keepAlive so resume finishes the write. Assign-to-contact is Phase 2.
- [x] **T2.41** "▶ Help" screen explaining the `WRITE_SETTINGS` permission and how to enable it manually
  `deps: T2.38`  ·  → FR-8.1
  · Done — `/ringtones/help` with 4 steps + a button that opens the system permission page.
- [x] **T2.42** Ringtone download + share-as-audio-file
  `deps: T2.38`  ·  → FR-8.8
  · Done — Download inserts into MediaStore without changing the default; Share uses `share_plus` with the cached file.

### Songs

- [x] **T2.43** Song list screen — teacher chips, rows with thumbnail + play overlay, title, artist (default "Anonymous")
  `deps: T2.18, T2.34`  ·  → FR-9.1, FR-9.2
  · Done — `SongListScreen` using `ContentListScaffold` + `AudioListTile` (artist falls back to "Anonymous"). Tap→full player is a stub (T2.44).
- [x] **T2.44** Full player screen — artwork, title, artist, seek bar with elapsed/total, play/pause, next/prev, 10s skip, repeat, shuffle
  `deps: T2.43, T2.34`  ·  → FR-9.3
  · Done — `FullPlayerScreen` at `/player`. Meditation list opens the same player (sleep timer is T2.49).
- [x] **T2.45** Queue from the current filtered list so next/previous behave as the user expects
  `deps: T2.44`  ·  → FR-9.3
  · Done — play starts with the visible filtered page as the queue.
- [ ] **T2.46** Emit `song_play` / `song_complete` events into `events/` for Function-side counter aggregation
  `deps: T2.44, T1.13`  ·  → FR-9.10

### Meditation

- [x] **T2.47** Meditation list screen — teacher chips, rows with thumbnail, title, narrator; multi-part series display
  `deps: T2.18, T2.34`  ·  → FR-10.1, FR-10.2
  · Done — `MeditationListScreen` using `ContentListScaffold` + `AudioListTile` (narrator shown as artist; part titles like "AnaPana Meditation - Part 1" render from seed). Series grouping + player are later tasks (T2.48/T2.49).
- [ ] **T2.48** Series grouping — sequential playback of parts
  `deps: T2.47, T2.45`  ·  → FR-10.3
- [x] **T2.49** Meditation player with a sleep timer (5/10/15/30/60 min)
  `deps: T2.47, T2.34`  ·  → FR-10.4
  · Done — `SleepTimer` on the shared `DhammaAudioHandler`. Meditation full-player shows a bedtime control + Off/5/10/15/30/60 sheet; on elapse the handler pauses. Survives leaving the player. Background ambience mix is not in this task.
- [ ] **T2.50** Resume from last position — `users/{uid}/progress/{itemId}`
  `deps: T2.49`  ·  → FR-10.5

### Daily Prarthana (highest technical risk)

- [x] **T2.51** Native alarm plugin — `AlarmManager.setExactAndAllowWhileIdle` per repeat day, `SCHEDULE_EXACT_ALARM` request on Android 12+, `BOOT_COMPLETED` + `MY_PACKAGE_REPLACED` rescheduling from Hive
  `deps: T0.2`  ·  → FR-11.6  ·  Acceptance: fires with the app force-stopped, and after a reboot
  · Done — `AlarmPlugin` + `AlarmScheduler` + boot receiver. Next fire is one exact alarm per row (rescheduled on fire). SharedPreferences snapshot is what native reads at boot; Hive/Firestore are the Flutter mirrors. Device-matrix verification is T4.1.
- [x] **T2.52** Alarm foreground service — plays the **local** prarthana file on the alarm audio stream, looping, using a player separate from the media `AudioHandler`
  `deps: T2.51`  ·  → FR-11.6, FR-11.7
  · Done — `AlarmService` `USAGE_ALARM` looping `MediaPlayer`, independent of `DhammaAudioHandler`.
- [x] **T2.53** Alarm ring screen — full-screen intent, Buddha artwork, current time, **Stop** and **Snooze (10 min)**
  `deps: T2.52`  ·  → FR-11.7
  · Done — native `AlarmRingActivity` + full-screen notification. Artwork is the cream/maroon lock screen (no bundled Buddha asset yet).
- [x] **T2.54** Prarthana setup screen — wheel time picker (hour : minute : AM/PM), Everyday toggle + M T W T F S S day chips, "Prarthana Song → Choose >" row, "🔔 Set Prarthana" CTA
  `deps: T0.16, T2.51`  ·  → FR-11.1–11.5
- [x] **T2.55** Prarthana song picker sourced from the curated `prarthanas` collection (A7)
  `deps: T2.54, T2.18`  ·  → FR-11.4
- [x] **T2.56** Mandatory pre-download of the chosen prarthana audio before the alarm is confirmed, with clear failure handling
  `deps: T2.54`  ·  → FR-11.8  ·  Acceptance: the alarm plays correctly in airplane mode
  · Done — copies into app documents `prarthanas/{id}.mp3` before schedule.
- [x] **T2.57** Alarm persistence in **both** Hive (authoritative at fire time) and Firestore `users/{uid}/alarms`
  `deps: T2.54`  ·  → FR-11.9
- [x] **T2.58** Battery-optimisation exemption prompt with OEM-specific guidance (MIUI / ColorOS / Samsung / Vivo)
  `deps: T2.51`  ·  → FR-11.10
  · Done — post-set dialog + Help deep-links. OEM-specific copy still generic.
- [x] **T2.59** Multiple alarms — list view with enable/disable toggles, edit and delete
  `deps: T2.57`  ·  → FR-11.9
- [x] **T2.60** Hidden developer tool: "test alarm in 60 seconds" (**ship blocker for device testing**)
  `deps: T2.51`  ·  → Architecture §9.3
  · Done — debug-only button on the list (`kDebugMode`).
- [x] **T2.61** "▶ Help" screen for Daily Prarthana
  `deps: T2.54`  ·  → FR-11.1

### Profile & settings

- [x] **T2.62** Profile screen — avatar with edit badge, name, phone, email; menu rows (My ID Card *disabled "Coming soon"*, Change Language, About Us, Contact Us, Privacy Policy, Terms & Conditions, Logout)
  `deps: T2.20`  ·  → FR-14.1, FR-14.2, D4
  · Done — Home avatar icon opens `/profile`. Help row opens `staticPages/help`.
- [x] **T2.63** Edit Profile (name, email, avatar upload) + My Teachers editing
  `deps: T2.62`  ·  → FR-14.3
  · Done — avatar stays on-device (same file as status). Name/email write Firestore.
- [x] **T2.64** Change Language from Profile, applying immediately
  `deps: T2.12`  ·  → FR-14.3
  · Done — `setPreferredLanguage` does not rewind onboarding. `MaterialApp.locale` follows `users/{uid}.language`.
- [x] **T2.65** Static page viewer — renders admin rich text per language, Hive-cached for offline
  `deps: T1.28, T0.18`  ·  → FR-14.4
  · Done — Firestore first, Hive cache, bundled fallbacks if empty. Renders the admin HTML subset (`SimpleHtmlText`).
- [x] **T2.66** Contact Us form → `contactMessages` (subject, message, optional screenshot)
  `deps: T2.62`  ·  → FR-14.5
  · Done — subject + message. Screenshot attach left for later.
- [x] **T2.67** Logout confirmation; Delete Account double confirmation writing a `deletionRequest`
  `deps: T2.62, T1.24`  ·  → FR-14.6, FR-2.8
- [x] **T2.68** Notification preferences toggle; Rate Us; app version display
  `deps: T2.62`  ·  → FR-14.3, FR-15.6

### Notifications

- [x] **T2.69** FCM integration — foreground, background and terminated-state handling; token refresh written to `users/{uid}.fcmTokens`
  `deps: T2.9`  ·  → FR-15.1, FR-15.3
  · Done — background handler from both entry points; token + refresh via `arrayUnion`. Foreground snackbar. Admin send is T1.25–T1.26 (deployed on `dhamma-path-dev`).
- [x] **T2.70** Topic subscription per selected teacher and language, resubscribing when the user changes either
  `deps: T2.17, T2.69`  ·  → FR-15.2
  · Done — `all`, `lang_{code}`, `teacher_{id}`. Cleared when Profile notifications are off.
- [x] **T2.71** Deep-link routing from a notification tap to module / item / URL, respecting the auth gate
  `deps: T2.69, T2.2`  ·  → FR-15.3  ·  Acceptance: verified from a cold start
  · Done — `route` / `module` / `url` in data. Pending route waits on Home if mid-auth.

### Analytics & instrumentation

- [ ] **T2.72** Wire the full PRD §11 event taxonomy through the typed `AnalyticsService`
  `deps: T0.14`  ·  → PRD §11
- [ ] **T2.73** Crashlytics `recordError` in every repository catch block; non-fatals for permission denials and failed set actions
  `deps: T2.5`
- [ ] **T2.74** Performance traces — `app_start`, `wallpaper_list_load`, `audio_first_frame`, `status_export`
  `deps: T2.1`  ·  → NFR observability

**M2 exit criteria:** every P0 requirement in PRD §6 is demonstrable on a physical device against seed data; no crashes in a 30-minute exploratory pass.

---

## M3 — Content Ingestion

Goal: replace seed data with the real, licensed launch library.

- [ ] **T3.1** Create the 4 launch teachers with final artwork — Gautam Buddha, Dr. B. R. Ambedkar, Dalai Lama, Thich Nhat Hanh
  `deps: T1.15`  ·  → FR-5.8
- [ ] **T3.2** Create the category taxonomy for all six modules
  `deps: T1.16`
- [ ] **T3.3** Upload 100 static wallpapers with teacher, category, source and licence recorded
  `deps: T1.21`  ·  → PRD §8
- [ ] **T3.4** Upload 40 ringtones (artist, trim, verified durations)
  `deps: T1.21`
- [ ] **T3.5** Upload 60 songs (artist, album, lyrics where available)
  `deps: T1.21`
- [ ] **T3.6** Upload 30 meditations including 3 correctly ordered series
  `deps: T1.21`
- [ ] **T3.7** Upload 50 status images, each with its photo-frame and name-text layout configured in the visual editor
  `deps: T1.19`  ·  Acceptance: each verified in the app composer at two screen sizes
- [ ] **T3.8** Upload 10 prarthana tracks
  `deps: T1.21`
- [ ] **T3.9** Write and publish the static pages — About, Privacy Policy, Terms, Contact, Help — in all three languages
  `deps: T1.28`  ·  → FR-14.4
- [ ] **T3.10** Content QA pass — every item has titles in all three languages, a thumbnail, correct teacher/category, and a recorded licence; no broken media
  `deps: T3.3–T3.9`
- [ ] **T3.11** Remove seed data from the dev project and mirror the final content set to prod
  `deps: T3.10`

**M3 exit criteria:** the app runs entirely on real content; PRD §8 launch minimums met; zero items missing licence provenance.

---

## M4 — Launch Readiness

- [ ] **T4.1** Device matrix testing — Android 8 / 10 / 12 / 14 / 15 across Samsung, Xiaomi (MIUI), Oppo (ColorOS) and stock Pixel, focused on **ringtone set, wallpaper set and alarm firing**
  `deps: M2, M3`  ·  → Architecture §14  ·  Acceptance: prarthana alarm fires on every device with the app force-stopped
- [ ] **T4.2** Localisation QA — all three languages at 1x and 1.3x text scale, no truncation or clipping on any screen
  `deps: M2`  ·  → NFR localisation
- [ ] **T4.3** Accessibility pass — TalkBack labels, 48dp targets, 4.5:1 contrast verified
  `deps: M2`  ·  → NFR accessibility
- [ ] **T4.4** Performance pass — cold start < 2.5s on a 3GB device, 60fps list scrolling, audio start < 1.5s on 4G, APK/AAB < 30 MB
  `deps: M2`  ·  → NFR performance
- [ ] **T4.5** Security review — rules tests complete, App Check enforced in prod, no secrets in the repo, admin roles least-privilege, PII absent from analytics
  `deps: T0.7, T1.5`  ·  → NFR security
- [ ] **T4.6** Cost review — verify no per-event client counter writes, confirm pagination limits, set prod budget alerts, check thumbnail sizes and CDN cache headers
  `deps: T1.13`  ·  → NFR cost control
- [ ] **T4.7** Play Store compliance — Data Safety form matching actual data use, permission rationale for every runtime permission, target SDK current, privacy policy live on the `public` Hosting site
  `deps: T3.9`  ·  → PRD §12, §14
- [ ] **T4.8** Store listing — icon, feature graphic, screenshots ×3 languages, description, content rating questionnaire
  `deps: T4.7`
- [ ] **T4.9** Takedown drill — unpublish an item in admin and confirm it disappears from a live client within 5 minutes
  `deps: T1.20`  ·  → NFR content moderation
- [ ] **T4.10** Integration tests in CI — login → onboarding → set wallpaper; set prarthana → alarm fires via the 60s test hook
  `deps: T2.60`  ·  → Architecture §14
- [ ] **T4.11** Prod deploy — rules, indexes, Functions, admin hosting, custom domains; internal testing AAB
  `deps: T4.1–T4.10`
  · **Also set the Storage CORS policy on `dhamma-path-prod.firebasestorage.app`** (GET/HEAD, origin `*` or the admin domain) or the admin panel will not render Storage thumbnails on Flutter Web — reuse `tools/seed/set_cors.js` with the prod bucket name. Dev bucket already configured (19 Aug 2026).
- [ ] **T4.12** Closed beta with 50 users; triage and fix feedback; confirm crash-free sessions ≥ 99.5%
  `deps: T4.11`  ·  → PRD §2.2
- [ ] **T4.13** Admin runbook — how to add content, send a notification, take content down, handle a deletion request, roll back a bad config
  `deps: M1`
- [ ] **T4.14** Production release to Play Store
  `deps: T4.12`

**M4 exit criteria:** PRD §2.2 KPIs instrumented, crash-free ≥ 99.5%, store approved, admin team self-sufficient.

---

## M5 — Phase 2 (post-launch, flag-gated)

Each of these flips an existing config flag rather than restructuring code.

- [ ] **T5.1** Live wallpapers — video upload in admin, `WallpaperService` implementation, Live badge activation, muted in-viewport autoplay previews; enable `liveWallpaperEnabled`
  → FR-7.3, FR-7.6, D3
- [ ] **T5.2** Supporter ID Card — `idCardTemplates` admin CRUD with the layout-JSON editor, 4 templates per teacher, permanent unique ID generation (`BUD-YYYY-NNNNNN`), QR verification deep link, template carousel, render and WhatsApp share; enable `idCardEnabled`
  → FR-13.1–13.11, D4
- [ ] **T5.3** QR verification page on the `public` Hosting site
  → FR-13.11
- [ ] **T5.4** AdMob — banner, interstitial with frequency cap, Remote Config placement control and kill-switch; enable `adsEnabled`
  → FR-16.1–16.6, D5
- [ ] **T5.5** Favourites and per-item offline downloads with a Downloads manager in Profile
  → FR-7.x, FR-9.6, FR-9.9
- [ ] **T5.6** Dark theme
- [ ] **T5.7** Wallpaper and status sub-category chip rows
  → FR-7.10, FR-12.8
- [ ] **T5.8** Meditation streaks and daily-minutes tracking
  → FR-10.7

---

## M6 — Phase 3

- [ ] **T6.1** iOS target — new platform implementations behind the existing Dart interfaces; wallpaper and ringtone modules become "download + instructions"
- [ ] **T6.2** In-app notification inbox → FR-15.4
- [ ] **T6.3** Playlists and albums → FR-9.7; lyrics panel → FR-9.8
- [ ] **T6.4** Rewarded ads and a premium tier → FR-16.4
- [ ] **T6.5** Referral and deep-link growth loops
- [ ] **T6.6** Thought-of-the-Day local notification → FR-15.5

---

## Appendix A — Ship Blockers

Non-negotiable before any public release:

1. **T2.51–T2.60** — prarthana alarm fires reliably with the app force-stopped, after reboot, and offline, on MIUI and ColorOS. This is the app's single biggest failure risk.
2. **T2.37 / T2.23** — ringtone and wallpaper setting verified on Android 8 through 15.
3. **T0.7 / T4.5** — security rules tested and App Check enforced; a leaked admin path would be catastrophic.
4. **T3.10** — every content item has recorded licence provenance. Copyright is the top takedown risk.
5. **T4.7** — Play Data Safety accuracy; a mismatch means removal, not just rejection.

## Appendix B — Task Count by Milestone

| Milestone | Tasks | Done | Open / partial | Notes |
|---|---|---:|---:|---|
| M0 Foundation | 18 | 16 | 2 | App Check + l10n lint still open |
| M1 Admin Panel | 31 | 26 | 5 | CRUD/publish + notifications + config + static pages + all content Functions + bulk upload + status layout editor + audit viewer |
| M2 Mobile App | 74 | 62 | 12 | Splash + force-update + maintenance gates live |
| M3 Content Ingestion | 11 | 0 | 11 | Content team, not developers |
| M4 Launch | 14 | 0 | 14 | Hardening and compliance |
| M5 Phase 2 | 8 | 0 | 8 | Flag-gated, post-launch |
| M6 Phase 3 | 6 | 0 | 6 | Growth |
| **Total (to launch)** | **148** | **104** | **44** | M0–M4 |
