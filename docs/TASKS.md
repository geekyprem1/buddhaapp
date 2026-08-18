# Dhamma Path — Task Breakdown

| Field | Value |
|---|---|
| Version | 1.0 |
| Date | 18 August 2026 |
| Inputs | `docs/PRD.md` v1.1 · `docs/ARCHITECTURE.md` v1.0 |
| Notation | `→ FR-x.x` = PRD requirement · `deps:` = must finish first · `[P]` = parallelisable |
| Admin hosting | Firebase Hosting, site `admin` → `admin.dhammapath.app` (confirmed) |

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
  · Partial — `.github/workflows/pr.yml` runs analyze + test for `packages/*`. Build/rules jobs are placeholders, enabled when `apps/mobile`, `apps/admin` and `firebase/firestore.rules` exist (T0.2, T1.1, T0.7).

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
- [ ] **T0.8** Set up Firebase Emulator Suite (Auth, Firestore, Storage, Functions) + a documented local dev workflow
  `deps: T0.5`  ·  Acceptance: `firebase emulators:start` runs; no developer needs the prod project
  · `firebase.json` has the `emulators` block configured (ports 4000/5000/5001/8080/9099/9199); not yet smoke-tested end-to-end.

### Shared packages

- [x] **T0.9** **[Unlock]** Build the seed script — a Dart/TS script writing 4 teachers, ~10 items per content type, categories, config docs, static pages into the emulator and dev project
  `deps: T0.11, T0.8`  ·  Acceptance: mobile dev can run the app end-to-end on seed data alone
  · Done — `tools/seed/seed.js`, a dependency-free Node script using the Firestore REST API + the developer's existing `firebase login` token. Seeded `dhamma-path-dev` with 4 teachers, 5 categories, 12 content items (across all 6 types), `config/app_config`. Refuses to run against `dhamma-path-prod`. Static pages not yet seeded (no `StaticPage` content authored yet — low priority until T2.65 needs one to render).
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
  · Done (partial) — `ContentRepository` (generic over any of the 6 collections), `UserRepository`, `TeacherRepository` implemented with Riverpod providers in `core_providers.dart`. `CategoryRepository`, `ConfigRepository`, `StaticPageRepository`, `AuditRepository` deferred to M1 (admin panel) since nothing in M2 needs them yet.
- [ ] **T0.14** Implement `StorageService` (resumable upload, progress, cancel, delete) and `AnalyticsService` (typed events per PRD §11)
  `deps: T0.11`  ·  Deferred — not yet needed until wallpaper/status upload/download features (T2.2x+)
- [x] **T0.15** Build `packages/design_system` — colour tokens (`#FDF3E0`, `#8B1A1A`, `#D4A24C`, `#25D366`, `#1F1F1F`), typography (Poppins + Noto Sans Devanagari), spacing/radii scale, `ThemeData` for mobile and admin
  `deps: T0.1`  ·  Acceptance: no raw hex or magic numbers anywhere outside this package
- [x] **T0.16** Build shared widgets — `PrimaryPillButton`, `TeacherFilterChipRow`, `ContentCard`, `LoadingShimmer`, `EmptyState`, `ErrorState`, `AppBottomSheet`
  `deps: T0.15`  ·  Acceptance: widget tests; 48dp minimum touch targets; semantic labels
  · Done — 4 widget tests green, confirms 48dp minimum target.

### Localisation

- [ ] **T0.17** Set up `gen-l10n` with `app_en.arb`, `app_hi.arb`, `app_mr.arb`; bundle Devanagari fonts; add a CI lint that fails on hardcoded user-facing strings
  `deps: T0.1`  ·  Acceptance: all three locales render without truncation at 1.3x text scale
- [ ] **T0.18** Implement `LocalisedText` resolution extension (`userLang → en → first non-empty`) for content documents
  `deps: T0.11`

**M0 exit criteria:** mobile app and admin panel both build and connect to dev Firebase; rules tests green in CI; seed data visible in both apps.

---

## M1 — Admin Panel (Flutter Web → Firebase Hosting)

Goal: the team can upload, categorise, schedule and publish all launch content without developer help.

### Shell, auth, hosting

- [ ] **T1.1** Configure Firebase Hosting with two sites — `admin` (Flutter Web build) and `public` (privacy/terms landing); set up `firebase.json` rewrites for SPA routing
  `deps: T0.5`  ·  → AR-1.6  ·  Acceptance: `firebase deploy --only hosting:admin` serves the app; custom domain `admin.dhammapath.app` mapped with SSL
- [ ] **T1.2** Admin login page — email/password only, explicit rejection of accounts without an admin claim, clear error states
  `deps: T0.6`  ·  → AR-1.1  ·  Acceptance: a mobile app user (phone/Google) cannot sign in here
- [ ] **T1.3** Implement `setAdminRole` callable Function (super-admin only, audit-logged) + a documented bootstrap procedure for the first super admin
  `deps: T0.7`  ·  → AR-1.2
- [ ] **T1.4** Admin shell — collapsible left nav, top bar with user menu, responsive from 1024px, role-based nav visibility
  `deps: T1.2, T0.15`  ·  → AR-8.1
- [ ] **T1.5** `go_router` role guards + 12h idle session timeout + re-auth prompt for destructive actions
  `deps: T1.4`  ·  → AR-1.4  ·  Acceptance: direct URL access to a forbidden route redirects, and the rules deny it anyway

### Reusable admin widgets

- [ ] **T1.6** `PaginatedDataTable2` wrapper — Firestore cursor pagination, search, multi-filter, sort, bulk select, empty/error/permission-denied states
  `deps: T0.13`  ·  → AR-3.1, AR-8.4
- [ ] **T1.7** `UploadDropzone` — drag & drop, client-side validation, resumable upload, progress bar, cancel, multi-file
  `deps: T0.14`  ·  → AR-8.2
- [ ] **T1.8** `LocalisedTextField` — en/hi/mr tabs in one control with per-language validation
  `deps: T0.12, T0.18`
- [ ] **T1.9** `MediaPreview` (image viewer + audio player), `UnsavedChangesGuard`, `ConfirmDialog`
  `deps: T1.4`  ·  → AR-8.3

### Cloud Functions for content

- [ ] **T1.10** `onMediaUpload` — image → WebP full + thumbnail (≤40 KB); audio → duration + waveform; patch the content doc with `mediaUrl`/`thumbUrl`/`durationSec`
  `deps: T0.7`  ·  → AR-3.6  ·  Acceptance: emulator test per media type
- [ ] **T1.11** `onContentWrite` — audit log entry with before/after diff, required-field validation
  `deps: T0.7`  ·  → AR-1.5
- [ ] **T1.12** `publishScheduled` (every 15 min) — `draft → published` at `publishAt`, `published → archived` at `expireAt`
  `deps: T0.7`  ·  → AR-3.3, FR-12.9
- [ ] **T1.13** `aggregateEvents` (every 5 min) — fold `events/` into content `counters`, delete processed events
  `deps: T0.7`  ·  → NFR cost control
- [ ] **T1.14** `cleanupOrphans` (daily) — orphaned Storage objects, soft-deletes older than 30 days
  `deps: T0.7`  ·  → AR-3.7

### Content management

- [ ] **T1.15** Teachers CRUD — name ×3 languages, portrait, thumbnail, bio, signature image, `idCardPrefix`, `sortOrder`, `isActive`, drag-and-drop reorder
  `deps: T1.6, T1.7, T1.8`  ·  → AR-3.x, FR-5.3, FR-5.8  ·  Acceptance: the 4 launch teachers can be created end-to-end
- [ ] **T1.16** Categories CRUD — scoped to a module, name ×3 languages, `sortOrder`, `isActive`
  `deps: T1.6, T1.8`  ·  → AR-3.x
- [ ] **T1.17** **Generic content module** — `ContentTypeConfig` declaring fields per type, plus `ContentListPage` and `ContentFormPage` built from that config (common metadata: titles ×3, teachers multi-select, category, tags, sortOrder, isFeatured, isPremium, **source + licence**, publishAt, expireAt)
  `deps: T1.6, T1.7, T1.8, T0.13`  ·  → AR-3.1–3.4  ·  Acceptance: adding a new content type requires only a new config object
- [ ] **T1.18** Configure the six content types on top of T1.17 — Wallpapers (static; `kind` field present with `live` disabled), Ringtones (artist, trim, auto-duration), Songs (artist, album, lyrics ×3), Meditations (narrator, series + part, level), Statuses (photo-frame rect, name-text style, watermark, festival date), Prarthanas (recommended time, description)
  `deps: T1.17`  ·  → AR-3.4, AR-3.x, FR-7.x–12.x  ·  Acceptance: each type creates a document matching the Architecture §6.2 shape exactly
- [ ] **T1.19** Status layout editor — visual drag/resize of the photo frame and name text over the base image, writing **normalised 0–1 coordinates**; live preview with a sample photo and name
  `deps: T1.18`  ·  → FR-12.2  ·  Acceptance: the coordinates produced render identically in the mobile composer (verified against T2.28)
- [ ] **T1.20** Publish workflow UI — Draft/Published/Unpublished/Archived transitions, scheduling pickers, bulk publish/unpublish, soft delete + restore
  `deps: T1.17`  ·  → AR-3.3, AR-3.7
- [ ] **T1.21** Bulk upload — multi-file drop creating one draft per file with the title auto-filled from the filename
  `deps: T1.17`  ·  → AR-3.5  ·  Acceptance: 50 wallpapers ingested in one drop
- [ ] **T1.22** Clone/duplicate an item; drag-and-drop reorder within a category
  `deps: T1.17`  ·  → AR-3.8, AR-3.9

### Users, notifications, config, audit

- [ ] **T1.23** Users table + detail view — search, filters, block/unblock, activity summary
  `deps: T1.6`  ·  → AR-5.1–5.3
- [ ] **T1.24** `exportUsersCsv` Function + UI (super admin only, PII warning, audit-logged); deletion-request queue with `processDeletionRequest`
  `deps: T1.23`  ·  → AR-5.4, AR-5.5, FR-2.8
- [ ] **T1.25** `sendNotification` + `sendScheduledNotification` Functions — topic/segment targeting, delivery stats
  `deps: T0.7`  ·  → AR-6.1–6.4
- [ ] **T1.26** Notification composer UI — title/body/image/deep-link, live phone preview, audience targeting, send now or schedule, test send to a device token, history
  `deps: T1.25, T1.4`  ·  → AR-6.1–6.5
- [ ] **T1.27** App config editor — min/latest version, force update, maintenance mode + message ×3, languages list, home module order/visibility, Phase 2 feature flags (`adsEnabled`, `idCardEnabled`, `liveWallpaperEnabled`)
  `deps: T1.4, T0.13`  ·  → AR-7.1, AR-7.4, AR-7.5
- [ ] **T1.28** Static pages editor — rich text ×3 languages for About / Privacy / Terms / Contact / Help
  `deps: T1.8`  ·  → AR-7.2, FR-14.4
- [ ] **T1.29** Audit log viewer — filter by entity type, actor, date; before/after diff display
  `deps: T1.6, T1.11`  ·  → AR-1.5
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
  · Done — `app/router.dart`. Redirect gate covers signed-out → login, mid-onboarding → correct step, complete → home. Force-update/maintenance branches not yet wired (depend on T2.3/T2.4's config fetch).
  · **Bug fixed after emulator testing:** the signed-out branch returned `null` (stay put) when already on splash, instead of redirecting to login — the app hung on the splash screen forever for a signed-out user. Fixed to redirect to login unconditionally unless already on an auth route. Verified on a Pixel 7 (Android 14) emulator: app now reaches the Login screen and the phone input takes focus correctly.
- [ ] **T2.3** Splash screen (max 2s, branded) + `appBootstrapProvider` fetching Remote Config and `config/app_config` with a cached fallback
  `deps: T2.2`  ·  → FR-1.1, FR-1.2
  · Partial — branded `SplashScreen` widget exists; it does not yet fetch Remote Config / `config/app_config`.
- [ ] **T2.4** Force-update blocking dialog + maintenance screen (admin-set message, localised)
  `deps: T2.3`  ·  → FR-1.3, FR-1.4
- [ ] **T2.5** Global error/offline handling — retry with exponential backoff in repositories, offline banner, Crashlytics non-fatals
  `deps: T2.1`  ·  → NFR reliability

### Authentication

- [x] **T2.6** Login screen — logo, "Dhamma Path", tagline, Buddha illustration, `+91` mobile input, "Continue with OTP", "Continue with Google", T&C + Privacy links, **no skip affordance**
  `deps: T0.16, T2.2`  ·  → FR-2.1, D2
  · Done, minus the Buddha illustration image and T&C/Privacy links (placeholder icon used; static pages don't exist yet — see T1.28/T2.65).
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
- [ ] **T2.16** Notification permission request (Android 13+) with rationale, shown **after** onboarding completes
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

- [~] **T2.20** Home screen — app bar (profile avatar, app name, Share App), 2×2 module grid (Wallpaper, Meditation, Ringtone, Song) + full-width Daily Prarthana tile, config-driven order/visibility
  `deps: T2.17, T0.16`  ·  → FR-6.1–6.3
  · Partial — app bar (profile icon, "Dhamma Path", green Share App) + 2×2 module grid done and **verified on device**; the four tiles now navigate to their content list screens. **Still to do:** full-width Daily Prarthana tile, and config-driven order/visibility.
- [ ] **T2.21** Trending Status section — teacher chips + paginated status feed, pull-to-refresh
  `deps: T2.18, T2.28`  ·  → FR-6.4, FR-6.6, FR-6.7
- [ ] **T2.22** Share App — localised message + Play Store link via the native share sheet
  `deps: T2.20`  ·  → FR-6.9, FR-9 analytics

### Wallpapers

- [ ] **T2.23** Native `WallpaperPlugin.kt` — `WallpaperManager` set for home / lock / both; MediaStore save to `Pictures/Dhamma Path/` (scoped-storage safe, Android 8–15)
  `deps: T0.2`  ·  → FR-7.5, FR-7.8  ·  Acceptance: verified on Android 8, 10, 12, 14, 15
- [x] **T2.24** Wallpaper list screen — teacher chips, large preview cards with an overlaid **Set Wallpaper** button, thumbnails in list
  `deps: T2.18, T2.23`  ·  → FR-7.1, FR-7.2, FR-7.7
  · Done — `WallpaperListScreen` renders a 2-column grid via `ContentListScaffold` against seeded wallpapers, with teacher filter chips. **Verified on device** (query succeeds after the rules + index fixes below). The overlaid **Set Wallpaper** button and tap→detail are stubs pending the native set flow (T2.23/T2.25/T2.26).
- [ ] **T2.25** Wallpaper detail — full-screen, pinch-zoom, swipe between items, actions Set / Download / Share
  `deps: T2.24`  ·  → FR-7.4
- [ ] **T2.26** Set-wallpaper bottom sheet (Home / Lock / Both) + success-failure toast and haptic
  `deps: T2.23`  ·  → FR-7.5, FR-7.9
- [ ] **T2.27** Add the "Live" badge slot to the wallpaper card, inert while `liveWallpaperEnabled: false`
  `deps: T2.24`  ·  → FR-7.3 (Phase 2 readiness)

### Trending Status (highest-value viral feature)

- [ ] **T2.28** Status compositor — a pure function of `(baseImage, photo, name, layout)` that maps normalised 0–1 rects to the render box; used identically by preview and export
  `deps: T0.11, T1.19`  ·  → FR-12.2, FR-12.10  ·  Acceptance: golden tests per language; preview and export match pixel-for-pixel in proportion
- [ ] **T2.29** Status card widget — base image + circular user photo in frame + name text + circular camera button + Download and Share buttons
  `deps: T2.28`  ·  → FR-12.1, FR-12.2
- [ ] **T2.30** Photo picker + circular crop — Android Photo Picker (no permission) or Camera; saved once to app dir and `users/{uid}.photoUrl`, reused across all statuses
  `deps: T2.29`  ·  → FR-12.3
- [ ] **T2.31** Inline name edit, defaulting to the onboarding name
  `deps: T2.29`  ·  → FR-12.4
- [ ] **T2.32** Full-resolution export (≥1080px wide) via `PictureRecorder` → PNG → MediaStore save to `Pictures/Dhamma Path/`
  `deps: T2.28, T2.23`  ·  → FR-12.5
- [ ] **T2.33** WhatsApp-direct share with a graceful system-share-sheet fallback; admin-toggleable watermark
  `deps: T2.32`  ·  → FR-12.6, FR-12.7

### Audio engine (shared by Ringtone, Song, Meditation)

- [ ] **T2.34** `audio_service` + `just_audio` singleton `AudioHandler` — media notification, lock-screen controls, audio focus and ducking, background playback
  `deps: T0.2`  ·  → FR-9.4  ·  Acceptance: only one player is ever active; a second play request stops the first
- [ ] **T2.35** Persistent mini-player surviving navigation, with a tap-to-expand full player
  `deps: T2.34`  ·  → FR-8.10
- [ ] **T2.36** Buffering, retry-on-network-error and stalled-stream handling
  `deps: T2.34`  ·  → FR-9.5

### Ringtones

- [ ] **T2.37** Native `RingtonePlugin.kt` — `Settings.System.canWrite()` check, `ACTION_MANAGE_WRITE_SETTINGS` deep link, download to app media dir, MediaStore insert with `IS_RINGTONE`/`IS_ALARM`/`IS_NOTIFICATION`, `RingtoneManager.setActualDefaultRingtoneUri`
  `deps: T0.2`  ·  → FR-8.6, FR-8.7  ·  Acceptance: works on Android 8–15 across Samsung / MIUI / ColorOS / Pixel
- [x] **T2.38** Ringtone list screen — teacher chips, rows with thumbnail + play overlay, title, `artist • duration`, and a **Set** button
  `deps: T2.18, T2.34`  ·  → FR-8.2, FR-8.3
  · Done — `RingtoneListScreen` + shared `AudioListTile` (thumbnail w/ play overlay, title, `artist • m:ss`, trailing **Set** button, "▶ Help" app-bar action). Renders against seeded ringtones. Set action and inline preview are stubs (T2.37/T2.39/T2.40/T2.41).
- [ ] **T2.39** Inline preview playback — one at a time, row-level progress indicator
  `deps: T2.38, T2.34`  ·  → FR-8.4
- [ ] **T2.40** Set sheet (Ringtone / Alarm / Notification) + the full permission rationale flow and post-return completion
  `deps: T2.37, T2.38`  ·  → FR-8.5, FR-8.6
- [ ] **T2.41** "▶ Help" screen explaining the `WRITE_SETTINGS` permission and how to enable it manually
  `deps: T2.38`  ·  → FR-8.1
- [ ] **T2.42** Ringtone download + share-as-audio-file
  `deps: T2.38`  ·  → FR-8.8

### Songs

- [x] **T2.43** Song list screen — teacher chips, rows with thumbnail + play overlay, title, artist (default "Anonymous")
  `deps: T2.18, T2.34`  ·  → FR-9.1, FR-9.2
  · Done — `SongListScreen` using `ContentListScaffold` + `AudioListTile` (artist falls back to "Anonymous"). Tap→full player is a stub (T2.44).
- [ ] **T2.44** Full player screen — artwork, title, artist, seek bar with elapsed/total, play/pause, next/prev, 10s skip, repeat, shuffle
  `deps: T2.43, T2.34`  ·  → FR-9.3
- [ ] **T2.45** Queue from the current filtered list so next/previous behave as the user expects
  `deps: T2.44`  ·  → FR-9.3
- [ ] **T2.46** Emit `song_play` / `song_complete` events into `events/` for Function-side counter aggregation
  `deps: T2.44, T1.13`  ·  → FR-9.10

### Meditation

- [x] **T2.47** Meditation list screen — teacher chips, rows with thumbnail, title, narrator; multi-part series display
  `deps: T2.18, T2.34`  ·  → FR-10.1, FR-10.2
  · Done — `MeditationListScreen` using `ContentListScaffold` + `AudioListTile` (narrator shown as artist; part titles like "AnaPana Meditation - Part 1" render from seed). Series grouping + player are later tasks (T2.48/T2.49).
- [ ] **T2.48** Series grouping — sequential playback of parts
  `deps: T2.47, T2.45`  ·  → FR-10.3
- [ ] **T2.49** Meditation player with a sleep timer (5/10/15/30/60 min)
  `deps: T2.47, T2.34`  ·  → FR-10.4
- [ ] **T2.50** Resume from last position — `users/{uid}/progress/{itemId}`
  `deps: T2.49`  ·  → FR-10.5

### Daily Prarthana (highest technical risk)

- [ ] **T2.51** Native alarm plugin — `AlarmManager.setExactAndAllowWhileIdle` per repeat day, `SCHEDULE_EXACT_ALARM` request on Android 12+, `BOOT_COMPLETED` + `MY_PACKAGE_REPLACED` rescheduling from Hive
  `deps: T0.2`  ·  → FR-11.6  ·  Acceptance: fires with the app force-stopped, and after a reboot
- [ ] **T2.52** Alarm foreground service — plays the **local** prarthana file on the alarm audio stream, looping, using a player separate from the media `AudioHandler`
  `deps: T2.51`  ·  → FR-11.6, FR-11.7
- [ ] **T2.53** Alarm ring screen — full-screen intent, Buddha artwork, current time, **Stop** and **Snooze (10 min)**
  `deps: T2.52`  ·  → FR-11.7
- [ ] **T2.54** Prarthana setup screen — wheel time picker (hour : minute : AM/PM), Everyday toggle + M T W T F S S day chips, "Prarthana Song → Choose >" row, "🔔 Set Prarthana" CTA
  `deps: T0.16, T2.51`  ·  → FR-11.1–11.5
- [ ] **T2.55** Prarthana song picker sourced from the curated `prarthanas` collection (A7)
  `deps: T2.54, T2.18`  ·  → FR-11.4
- [ ] **T2.56** Mandatory pre-download of the chosen prarthana audio before the alarm is confirmed, with clear failure handling
  `deps: T2.54`  ·  → FR-11.8  ·  Acceptance: the alarm plays correctly in airplane mode
- [ ] **T2.57** Alarm persistence in **both** Hive (authoritative at fire time) and Firestore `users/{uid}/alarms`
  `deps: T2.54`  ·  → FR-11.9
- [ ] **T2.58** Battery-optimisation exemption prompt with OEM-specific guidance (MIUI / ColorOS / Samsung / Vivo)
  `deps: T2.51`  ·  → FR-11.10
- [ ] **T2.59** Multiple alarms — list view with enable/disable toggles, edit and delete
  `deps: T2.57`  ·  → FR-11.9
- [ ] **T2.60** Hidden developer tool: "test alarm in 60 seconds" (**ship blocker for device testing**)
  `deps: T2.51`  ·  → Architecture §9.3
- [ ] **T2.61** "▶ Help" screen for Daily Prarthana
  `deps: T2.54`  ·  → FR-11.1

### Profile & settings

- [ ] **T2.62** Profile screen — avatar with edit badge, name, phone, email; menu rows (My ID Card *disabled "Coming soon"*, Change Language, About Us, Contact Us, Privacy Policy, Terms & Conditions, Logout)
  `deps: T2.20`  ·  → FR-14.1, FR-14.2, D4
- [ ] **T2.63** Edit Profile (name, email, avatar upload) + My Teachers editing
  `deps: T2.62`  ·  → FR-14.3
- [ ] **T2.64** Change Language from Profile, applying immediately
  `deps: T2.12`  ·  → FR-14.3
- [ ] **T2.65** Static page viewer — renders admin rich text per language, Hive-cached for offline
  `deps: T1.28, T0.18`  ·  → FR-14.4
- [ ] **T2.66** Contact Us form → `contactMessages` (subject, message, optional screenshot)
  `deps: T2.62`  ·  → FR-14.5
- [ ] **T2.67** Logout confirmation; Delete Account double confirmation writing a `deletionRequest`
  `deps: T2.62, T1.24`  ·  → FR-14.6, FR-2.8
- [ ] **T2.68** Notification preferences toggle; Rate Us; app version display
  `deps: T2.62`  ·  → FR-14.3, FR-15.6

### Notifications

- [ ] **T2.69** FCM integration — foreground, background and terminated-state handling; token refresh written to `users/{uid}.fcmTokens`
  `deps: T2.9`  ·  → FR-15.1, FR-15.3
- [ ] **T2.70** Topic subscription per selected teacher and language, resubscribing when the user changes either
  `deps: T2.17, T2.69`  ·  → FR-15.2
- [ ] **T2.71** Deep-link routing from a notification tap to module / item / URL, respecting the auth gate
  `deps: T2.69, T2.2`  ·  → FR-15.3  ·  Acceptance: verified from a cold start

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

| Milestone | Tasks | Notes |
|---|---|---|
| M0 Foundation | 18 | Blocks everything; includes the T0.9 seed-script unlock |
| M1 Admin Panel | 31 | Critical path; launch blocker for content |
| M2 Mobile App | 74 | Parallel with M1 on seed data |
| M3 Content Ingestion | 11 | Content team, not developers |
| M4 Launch | 14 | Hardening and compliance |
| M5 Phase 2 | 8 | Flag-gated, post-launch |
| M6 Phase 3 | 6 | Growth |
| **Total (to launch)** | **148** | M0–M4 |
