# Dhamma Path — Technical Architecture

| Field | Value |
|---|---|
| Version | 1.0 |
| Date | 18 August 2026 |
| Source of truth | `docs/PRD.md` v1.1 (scope decisions D1–D6, assumptions A1–A7) |
| Scope | Android app (Flutter) + Admin panel (Flutter Web) + Firebase backend |

---

## 1. Guiding Principles

1. **One codebase, three targets.** Mobile app, admin panel and shared domain live in one monorepo so models and validation rules are never duplicated.
2. **Serverless, admin-driven.** No custom backend server. Firebase provides auth, data, storage, push and compute. Content and config change without app releases.
3. **Security in the rules, not the UI.** Firestore Security Rules are the real authorisation layer. Admin panel UI hiding is convenience only.
4. **Read-cheap by design.** Firestore reads are the dominant cost driver. Denormalise, paginate, cache aggressively, and never write counters per-event from the client.
5. **Platform work behind interfaces.** Ringtone setting, wallpaper setting, exact alarms and image compositing are Android-specific. Each sits behind a Dart interface with a platform-channel implementation, so Phase 3 iOS work means writing new implementations, not rewriting features.
6. **Phase 2 shape reserved.** Live wallpapers, ID cards and ads are absent from MVP code but present in the data model and layout structure.

---

## 2. Repository Structure

A Flutter monorepo using `melos` for multi-package orchestration.

```
dhamma-path/
├── melos.yaml
├── pubspec.yaml                     # workspace root
├── docs/
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   └── TASKS.md
├── packages/
│   ├── core/                        # shared, no Flutter UI dependency where possible
│   │   ├── lib/
│   │   │   ├── models/              # freezed models + JSON serialisation
│   │   │   ├── repositories/        # abstract repo interfaces + Firestore impls
│   │   │   ├── services/            # auth, storage, config, analytics wrappers
│   │   │   ├── constants/           # collection names, app strings keys, regexes
│   │   │   ├── validators/          # shared field validation (app + admin agree)
│   │   │   └── utils/               # result types, extensions, date/duration fmt
│   │   └── test/
│   └── design_system/               # shared tokens; app + admin both consume
│       └── lib/
│           ├── theme/               # colours, typography, spacing, radii
│           ├── widgets/             # buttons, chips, cards, empty/error states
│           └── icons/
├── apps/
│   ├── mobile/                      # Android app (iOS target added Phase 3)
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── app/                 # app widget, router, providers, bootstrap
│   │   │   ├── features/            # one folder per feature (see §5)
│   │   │   ├── platform/            # method-channel wrappers
│   │   │   └── l10n/                # arb files: en, hi, mr
│   │   ├── android/                 # native Kotlin: ringtone, wallpaper, alarm
│   │   └── test/
│   └── admin/                       # Flutter Web admin panel
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app/                 # router (go_router), shell, guards
│       │   ├── features/            # dashboard, teachers, wallpapers, ...
│       │   └── widgets/             # data table, upload dropzone, form fields
│       └── web/
├── functions/                       # Cloud Functions (TypeScript)
│   ├── src/
│   │   ├── index.ts
│   │   ├── media/                   # thumbnails, audio duration, waveform
│   │   ├── counters/                # aggregation from events
│   │   ├── notifications/           # FCM send + scheduling
│   │   ├── admin/                   # custom claims, user deletion, CSV export
│   │   └── triggers/                # onUserCreate, onContentWrite, cleanup
│   └── package.json
├── firebase/
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   ├── storage.rules
│   └── firebase.json
└── .github/workflows/               # CI: analyze, test, build, deploy
```

**Why a monorepo:** the admin panel writes the exact documents the app reads. Sharing `packages/core` models means a field rename breaks the build instead of breaking production silently.

---

## 3. Technology Choices

| Concern | Choice | Rationale |
|---|---|---|
| UI framework | Flutter 3.x (stable), Dart 3 | Single codebase for app + admin web |
| State management | **Riverpod 2** (code-gen `@riverpod`) | Compile-safe DI, easy async/stream providers, testable without widget trees |
| Routing | **go_router** | Declarative, deep-link friendly (needed for FCM targets), redirect guards for the auth gate |
| Models | **freezed** + `json_serializable` | Immutable models, exhaustive unions, generated `copyWith`/equality |
| Local storage | **Hive** (typed boxes) for cached content and prefs; `flutter_secure_storage` for nothing sensitive in MVP | Fast, no SQL needed; SharedPreferences too limited for cached lists |
| Images | `cached_network_image` + `flutter_cache_manager` | Disk cache is essential for data-light users |
| Audio | **just_audio** + **audio_service** | Background playback, media notification, lock-screen controls, audio focus |
| Alarms | **android_alarm_manager_plus** or a custom `AlarmManager` channel + `flutter_local_notifications` (full-screen intent) | Exact alarms with the app killed require native `setExactAndAllowWhileIdle` + a boot receiver |
| Image compositing | `dart:ui` `PictureRecorder` / `RepaintBoundary` capture | Renders status + name + photo at full resolution on-device (FR-12.10 keeps photos local) |
| Wallpaper | Native channel → `WallpaperManager` | No reliable maintained plugin; ~40 lines of Kotlin |
| Ringtone | Native channel → `RingtoneManager` + `MediaStore` + `WRITE_SETTINGS` | Same reasoning |
| Localisation | `flutter_localizations` + ARB (`gen-l10n`) | Standard, compile-checked keys |
| Admin tables | `data_table_2` or a custom paginated table | Server-side pagination against Firestore cursors |
| Analytics | Firebase Analytics + Crashlytics + Performance | Free, integrated |
| Config | Firebase Remote Config **for kill-switches/flags**; Firestore `config/*` docs **for admin-editable content config** | Remote Config has no good admin-panel write API; Firestore does |
| Functions | Cloud Functions v2 (TypeScript, Node 20) | Media derivatives, counters, FCM fan-out, claims |
| Hosting | Firebase Hosting, two sites: `admin` and `public` | Admin panel + privacy policy / QR verification pages |
| CI/CD | GitHub Actions | analyze → test → build AAB → deploy hosting + rules |

**Deliberately avoided:** a custom Node/Django backend (unnecessary), BLoC (more boilerplate than Riverpod for this app's size), Firestore for media (Storage + CDN instead), storing base64 images in Firestore (cost trap).

---

## 4. System Architecture

```
┌─────────────────────────────┐        ┌──────────────────────────────┐
│  Mobile App (Flutter/Android)│        │ Admin Panel (Flutter Web)    │
│  ─ Presentation (widgets)    │        │ ─ Tables, forms, uploaders   │
│  ─ Riverpod providers        │        │ ─ Riverpod providers         │
│  ─ Repositories (interfaces) │        │ ─ Repositories (same core)   │
│  ─ Hive cache / platform ch. │        │                              │
└──────────┬──────────────────┘        └──────────────┬───────────────┘
           │           packages/core (models, repos, validators)
           └───────────────┬──────────────────────────┘
                           ▼
        ┌──────────────────────────────────────────────┐
        │                  Firebase                     │
        │  Auth (Phone OTP, Google, Email for admin)   │
        │  Firestore (content, users, config, audit)   │
        │  Storage (images, audio, video)              │
        │  Cloud Functions (derivatives, counters, FCM)│
        │  FCM (topics: teacher_*, lang_*, all)       │
        │  Remote Config (flags, kill-switches)        │
        │  App Check (Play Integrity / reCAPTCHA)      │
        │  Analytics · Crashlytics · Performance       │
        │  Hosting (admin site + public site)          │
        └──────────────────────────────────────────────┘
```

### 4.1 Layering (both apps)

```
Presentation   Widgets + Screens          — no Firebase imports, ever
     ↓ watches
Application    Riverpod providers/notifiers — orchestration, UI state
     ↓ calls
Domain         Repository interfaces, models, validators  (packages/core)
     ↑ implements
Data           FirestoreXRepository, StorageService, HiveCache, PlatformChannels
```

Rule enforced in review: nothing under `features/**/presentation` may import `cloud_firestore`.

---

## 5. Mobile App Feature Modules

Each feature folder follows the same internal shape:

```
features/wallpaper/
├── presentation/
│   ├── wallpaper_list_screen.dart
│   ├── wallpaper_detail_screen.dart
│   └── widgets/wallpaper_card.dart
├── application/
│   ├── wallpaper_list_controller.dart      # @riverpod, paginated
│   └── set_wallpaper_controller.dart
└── domain/  (only if feature-specific; shared models live in core)
```

| Feature | Screens | Key providers | Platform needs |
|---|---|---|---|
| `bootstrap` | Splash, ForceUpdate, Maintenance | `appBootstrapProvider`, `remoteConfigProvider` | — |
| `auth` | Login, OtpVerify | `authStateProvider`, `phoneAuthController` | SMS autofill |
| `onboarding` | Language, PersonInfo, TeacherSelect | `onboardingProgressProvider`, `teachersProvider` | — |
| `home` | Home | `homeModulesProvider`, `statusFeedProvider` | — |
| `wallpaper` | List, Detail | `wallpaperListProvider(filter)` | WallpaperManager, MediaStore |
| `ringtone` | List | `ringtoneListProvider(filter)`, `previewPlayerProvider` | RingtoneManager, WRITE_SETTINGS |
| `song` | List, Player | `songListProvider(filter)`, `audioHandlerProvider` | audio_service |
| `meditation` | List, Player | `meditationListProvider(filter)`, `sleepTimerProvider` | audio_service |
| `prarthana` | AlarmSetup, SongPicker, AlarmRing | `alarmsProvider`, `alarmSchedulerProvider` | AlarmManager, full-screen intent, boot receiver |
| `status` | Feed (in Home), Editor | `statusFeedProvider`, `statusComposerController` | Photo Picker, Camera, canvas render, share |
| `profile` | Profile, EditProfile, Language, StaticPage, Contact | `userProfileProvider`, `staticPageProvider(slug)` | — |
| `shared` | teacher chip row, mini player, empty/error/loading states | `selectedTeachersProvider`, `teacherFilterProvider` | — |
| `idcard` *(Phase 2)* | — | — | — |

### 5.1 The teacher filter, shared across five screens

`selectedTeachersProvider` streams `users/{uid}.selectedTeachers`. Every list screen watches a family provider keyed by `ContentFilter(teacherId, categoryId)`:

```dart
@riverpod
Stream<PagedContent> wallpaperList(Ref ref, ContentFilter filter) { ... }
```

`teacherId == null` means "All" and queries `where('teacherIds', arrayContains: ...)` per selected teacher — or, when a user has many teachers, falls back to an unfiltered published query and filters client-side (Firestore `arrayContainsAny` caps at 30 values, which is more than enough headroom here).

The ⊕ chip opens a bottom sheet that adds a teacher to the user document; every screen updates reactively because they all watch the same provider.

---

## 6. Data Model (Firestore)

Denormalised, read-optimised, deny-by-default.

### 6.1 Collections

```
users/{uid}
teachers/{teacherId}
categories/{categoryId}
wallpapers/{id}
ringtones/{id}
songs/{id}
meditations/{id}
statuses/{id}
prarthanas/{id}
  users/{uid}/alarms/{alarmId}          (subcollection)
  users/{uid}/favourites/{itemId}       (subcollection, Phase 2)
  users/{uid}/progress/{itemId}         (subcollection: last position)
idCardTemplates/{id}                    (Phase 2)
idCards/{cardId}                        (Phase 2)
config/{docId}                          app_config | home_layout | languages | promo
staticPages/{slug}                      about | privacy | terms | contact | help
notifications/{campaignId}
adminUsers/{uid}
auditLogs/{logId}
contactMessages/{id}
events/{eventId}                        write-only client counter events → Functions aggregate
deletionRequests/{uid}
```

### 6.2 Key documents

**`users/{uid}`**
```jsonc
{
  "uid": "abc123",
  "name": "Prem Kumar",
  "phone": "+919625460555",
  "email": "user@example.com",
  "photoUrl": null,                  // profile avatar (Storage)
  "language": "hi",                  // en | hi | mr
  "selectedTeachers": ["buddha", "ambedkar"],
  "authMethod": "phone",             // phone | google
  "onboardingStep": "complete",      // language | person_info | teacher | complete
  "fcmTokens": ["..."],
  "notificationPrefs": { "push": true, "prarthana": true },
  "isBlocked": false,
  "platform": "android",
  "appVersion": "1.0.0",
  "createdAt": "<ts>",
  "lastActiveAt": "<ts>"
}
```
`onboardingStep` is what makes FR-1.5 (resume at the exact step) work across reinstalls.

**Content document — identical shape for `wallpapers`, `ringtones`, `songs`, `meditations`, `statuses`, `prarthanas`**
```jsonc
{
  "id": "wp_001",
  "type": "wallpaper",
  "teacherIds": ["buddha"],
  "categoryId": "cat_buddha_calm",
  "title": { "en": "Golden Buddha", "hi": "स्वर्ण बुद्ध", "mr": "सुवर्ण बुद्ध" },
  "artist": "Anonymous",             // ringtone/song/meditation narrator
  "mediaUrl": "https://.../full.webp",
  "thumbUrl": "https://.../thumb.webp",
  "storagePath": "wallpapers/wp_001/full.webp",
  "language": null,                  // null = language-agnostic; set for audio
  "status": "published",             // draft | published | unpublished | archived
  "sortOrder": 10,
  "isFeatured": false,
  "isPremium": false,
  "tags": ["buddha", "golden", "meditation"],
  "counters": { "views": 0, "downloads": 0, "shares": 0, "plays": 0 },
  "source": "own-artwork",           // licence provenance — mandatory (PRD Q8)
  "licence": "original",
  "publishAt": "<ts>",
  "expireAt": null,
  "createdBy": "adminUid",
  "createdAt": "<ts>",
  "updatedAt": "<ts>",
  "deletedAt": null,

  // type-specific
  "wallpaper": { "kind": "static", "width": 1080, "height": 1920, "orientation": "portrait" },
  "audio":     { "durationSec": 31, "waveformUrl": null, "seriesId": null, "partNumber": null },
  "status":    { "photoFrame": { "x":0.62,"y":0.70,"w":0.22,"h":0.22,"shape":"circle" },
                 "nameText":   { "x":0.06,"y":0.92,"w":0.6,"align":"left",
                                 "font":"Poppins","size":0.045,"color":"#1F1F1F","weight":700 },
                 "watermark": true, "festivalDate": null }
}
```

Design notes:
- **One shape, many types.** A single `ContentItem` freezed model with optional type-specific sub-objects means one repository, one admin table component, one list widget — instead of six near-duplicates.
- **Coordinates are normalised 0–1**, not pixels. The status card composites identically on a 720p phone and in a 1080p export (FR-12.5).
- **`teacherIds` is an array** because a status image can legitimately belong to both Buddha and Ambedkar.
- **`counters` are Function-written only.** Clients append to `events/` and a Function aggregates, so 10k users sharing an image is 10k small writes to a throwaway collection rather than 10k contended updates on one hot document.

**`users/{uid}/alarms/{alarmId}`**
```jsonc
{
  "timeHour": 6, "timeMinute": 45,
  "repeatDays": [1,2,3,4,5,6,7],     // ISO weekday; [] = one-shot
  "isEveryday": true,
  "prarthanaId": "pr_003",
  "prarthanaLocalPath": "/data/.../pr_003.mp3",   // pre-downloaded (FR-11.8)
  "isEnabled": true,
  "label": "Morning Prarthana",
  "snoozeMinutes": 10,
  "createdAt": "<ts>"
}
```
Alarms are also mirrored into Hive because the alarm must fire with no network and no Firestore access.

**`config/app_config`**
```jsonc
{
  "minSupportedVersion": "1.0.0",
  "latestVersion": "1.0.0",
  "forceUpdate": false,
  "maintenanceMode": false,
  "maintenanceMessage": { "en": "", "hi": "", "mr": "" },
  "languages": [{ "code":"en","name":"English","native":"English" }, ...],
  "adsEnabled": false,               // Phase 2 (D5)
  "idCardEnabled": false,            // Phase 2 (D4)
  "liveWallpaperEnabled": false,     // Phase 2 (D3)
  "updatedAt": "<ts>"
}
```
Feature flags exist in MVP set to `false`, so Phase 2 features ship dark and get enabled remotely.

**`adminUsers/{uid}`**
```jsonc
{ "email": "admin@dhammapath.app", "name": "Anita",
  "role": "content_manager",         // super_admin | content_manager | moderator
  "isActive": true, "createdBy": "superAdminUid", "lastLoginAt": "<ts>" }
```
The role also lives in an **Auth custom claim** so security rules can check it without an extra document read on every request.

### 6.3 Required composite indexes

| Collection | Fields |
|---|---|
| each content collection | `status ASC, teacherIds ARRAY, sortOrder DESC, createdAt DESC` |
| each content collection | `status ASC, categoryId ASC, sortOrder DESC` |
| each content collection | `status ASC, publishAt DESC` (scheduled publish) |
| `statuses` | `status ASC, teacherIds ARRAY, createdAt DESC` (trending feed) |
| `meditations` | `status ASC, audio.seriesId ASC, audio.partNumber ASC` |
| `auditLogs` | `entityType ASC, createdAt DESC` |
| `users` | `createdAt DESC`, `lastActiveAt DESC`, `language ASC, createdAt DESC` |

### 6.4 Cloud Storage layout

```
teachers/{teacherId}/{portrait|thumb|signature}.webp
wallpapers/{itemId}/{full.webp, thumb.webp}
ringtones/{itemId}/{audio.mp3, thumb.webp}
songs/{itemId}/{audio.mp3, artwork.webp, thumb.webp}
meditations/{itemId}/{audio.mp3, thumb.webp}
statuses/{itemId}/{base.webp, thumb.webp}
prarthanas/{itemId}/{audio.mp3, thumb.webp}
users/{uid}/avatar.webp
idcards/{cardId}/... (Phase 2)
```
Admin uploads the original; a Function writes the derivatives beside it. Storage rules make all content paths **public read, admin-only write**; `users/{uid}/**` is owner-only.

---

## 7. Security Rules Strategy

`firebase/firestore.rules`, deny-by-default:

```
function isSignedIn()   { return request.auth != null; }
function isOwner(uid)   { return isSignedIn() && request.auth.uid == uid; }
function role()         { return request.auth.token.role; }
function isAdmin()      { return role() in ['super_admin','content_manager','moderator']; }
function isSuperAdmin() { return role() == 'super_admin'; }
function notBlocked()   { return !(get(/databases/$(db)/documents/users/$(request.auth.uid)).data.isBlocked); }
```

| Path | Read | Write |
|---|---|---|
| content collections | signed-in AND `status == 'published'` AND `deletedAt == null`; admins read all | admin only; `moderator` limited to `status` + metadata fields; `counters` **immutable from clients** |
| `teachers`, `categories` | signed-in, `isActive == true` | admin |
| `config/*`, `staticPages/*` | signed-in (any) | `super_admin` |
| `users/{uid}` | owner or admin | owner (field-whitelisted: cannot set `isBlocked`, `role`); admins may set `isBlocked` |
| `users/{uid}/alarms/**`, `progress/**` | owner | owner |
| `adminUsers/**` | admin | `super_admin` only |
| `auditLogs/**` | admin | **Functions only** (client writes denied) |
| `events/**` | none | create-only by signed-in user, no read/update/delete |
| `notifications/**` | admin | admin create; send executed by a Function |
| `contactMessages/**` | admin | create-only by owner |

Additional controls:
- **App Check** (Play Integrity on Android, reCAPTCHA Enterprise on web) enforced on Firestore, Storage and Functions — this is the main defence for FR-2.9 OTP abuse.
- Custom claims set by a `setAdminRole` callable Function restricted to super admins; claims refresh forced on the client after a role change.
- Rules are unit-tested with `@firebase/rules-unit-testing` in CI. A rules change without a passing test fails the build.

---

## 8. Cloud Functions

| Function | Trigger | Purpose |
|---|---|---|
| `onUserCreate` | Auth create | Seed `users/{uid}`, subscribe to `all` topic |
| `onUserDelete` | Auth delete | Cascade-delete user docs, avatar, alarms |
| `onMediaUpload` | Storage finalize | Generate WebP thumbnails (image), read audio duration + waveform (audio), extract poster frame (video, Phase 2); patch the content doc |
| `onContentWrite` | Firestore write on content collections | Write an audit log entry; validate required fields; invalidate CDN if needed |
| `aggregateEvents` | Scheduled, every 5 min | Fold `events/` into content `counters`, then delete processed events |
| `publishScheduled` | Scheduled, every 15 min | Flip `draft → published` at `publishAt`, `published → archived` at `expireAt` (FR-12.9) |
| `sendNotification` | Callable (admin) | FCM send to topic/segment; record delivery stats |
| `sendScheduledNotification` | Scheduled, every 5 min | Dispatch queued campaigns |
| `setAdminRole` | Callable (super admin) | Set/revoke custom claims, audit-logged |
| `exportUsersCsv` | Callable (super admin) | Generate signed-URL CSV, audit-logged with a PII warning |
| `processDeletionRequest` | Firestore create on `deletionRequests` | 30-day DPDP-compliant deletion with proof record |
| `cleanupOrphans` | Scheduled, daily | Delete Storage objects with no owning document; purge soft-deletes older than 30 days |
| `guardOtpAbuse` | Callable / App Check | Per-number OTP rate limit (FR-2.9) |

All Functions are region-pinned to `asia-south1` (Mumbai) to keep latency low for Indian users.

---

## 9. Critical Flows

### 9.1 App bootstrap and the auth gate (FR-1.5, D2)

```
main() → Firebase.initializeApp → App Check activate → Hive open
      → appBootstrapProvider:
          fetch Remote Config + config/app_config (cached fallback)
          if forceUpdate            → ForceUpdateScreen (blocking)
          if maintenanceMode        → MaintenanceScreen
          authState == null         → LoginScreen
          onboardingStep != complete→ resume at that step
          else                      → HomeScreen
```
`go_router`'s `redirect` implements the gate in one place; individual screens never check auth. Because login is mandatory, there is no anonymous read path — security rules require `isSignedIn()` for all content.

### 9.2 Set ringtone (FR-8.5–8.7) — the trickiest permission flow

```
User taps Set → sheet: Ringtone / Alarm / Notification
  ↓
Check Settings.System.canWrite()
  ├─ false → rationale dialog → ACTION_MANAGE_WRITE_SETTINGS intent
  │           → on resume, re-check; if still denied, show how-to and abort
  └─ true  ↓
Download audio to app media dir (skip if cached)
  ↓
Insert into MediaStore.Audio with IS_RINGTONE/IS_ALARM/IS_NOTIFICATION
  ↓
RingtoneManager.setActualDefaultRingtoneUri(type, uri)
  ↓
Success toast + haptic + log `ringtone_set`
```
Implemented in `android/.../RingtonePlugin.kt` behind `abstract class RingtoneService`. Android 8→15 behaviour differences (scoped storage from 10, MediaStore ownership from 11) are handled inside the Kotlin layer, not in Dart.

### 9.3 Daily Prarthana alarm (FR-11.6–11.8) — the biggest reliability risk

```
Set Prarthana
  → validate time + days + prarthana selected
  → download prarthana audio to app files dir (must succeed; alarm needs offline audio)
  → write alarms/{id} to Firestore AND Hive
  → request SCHEDULE_EXACT_ALARM (Android 12+) if not granted
  → offer battery-optimisation exemption (OEM killers)
  → AlarmManager.setExactAndAllowWhileIdle() per repeat day

On fire → BroadcastReceiver
  → start ForegroundService (mediaPlayback)
  → play local audio, loop, respect alarm volume stream
  → post full-screen-intent notification → AlarmRingActivity (Buddha art, Stop, Snooze 10m)
  → on Stop: stop service, reschedule next occurrence
  → on Snooze: setExact(+10 min)

BOOT_COMPLETED / MY_PACKAGE_REPLACED → read Hive → reschedule all enabled alarms
```
Hive, not Firestore, is the alarm source of truth at fire time. A ship blocker for M3: a hidden "test alarm in 60s" developer tool, plus manual verification on MIUI/ColorOS/Samsung.

### 9.4 Status personalisation and share (FR-12.2–12.6)

```
Status card renders: CachedNetworkImage(base) + user photo clipped to photoFrame rect
                     + user name positioned per nameText rect
        (all rects normalised → multiply by the rendered box size)
  ↓
Tap camera → Android Photo Picker (no permission needed) or Camera
  → crop to circle → save once to app dir + users/{uid}.photoUrl → reused everywhere
  ↓
Download / Share → render the same composition into a PictureRecorder
                   at the base image's native resolution (≥1080px wide)
  → PNG bytes
  → Download: MediaStore → Pictures/Dhamma Path/
  → Share:    temp file → share_plus with WhatsApp package hint, fallback to sheet
```
Compositing is a pure function of `(baseImage, photo, name, layout)` shared by preview and export, so what the user sees is exactly what gets shared. The user's photo never leaves the device unless they are signed in and the avatar upload succeeds.

### 9.5 Audio playback (FR-9.4, FR-10.4)

One `audio_service` `AudioHandler` singleton serves ringtone previews, songs and meditations. Behaviour differences (queue vs single item, sleep timer, resume position) are handled by the calling controller, not by separate players — this avoids the classic bug where two players fight over audio focus. Ringtone preview requests `AndroidAudioUsage.media` with `willPauseWhenDucked`, and the alarm service uses a **separate** player on the alarm stream so a running meditation cannot suppress an alarm.

### 9.6 Admin content upload

```
Admin drops file → client-side validate (type, size, dimensions)
  → resumable upload to Storage at {collection}/{newId}/original.{ext}
  → create Firestore doc with status: 'draft', storagePath set
  → onMediaUpload Function: derivatives → patch mediaUrl/thumbUrl/durationSec
  → admin sees preview, fills metadata (titles ×3 languages, teacher, category, source/licence)
  → Publish → status: 'published' → onContentWrite writes audit log
  → app clients see it within one Firestore snapshot tick
```
Takedown (NFR, 5-minute SLA) is the same path in reverse: set `status: 'unpublished'`, and every live listener drops the item immediately.

---

## 10. Caching and Offline Strategy

| Data | Strategy |
|---|---|
| Content lists | Firestore persistence enabled + Hive snapshot of the first page per filter, so lists render instantly offline |
| Images | `cached_network_image` disk cache, 200 MB cap, thumbnails in lists and full-res only in detail/set |
| Audio streaming | `just_audio` progressive streaming; no cache in MVP (per-item download is Phase 2) |
| Prarthana audio | **Always downloaded** to app files dir when an alarm is set — non-negotiable |
| Config + static pages | Hive cached with a stale-while-revalidate read |
| User profile | Firestore offline persistence + Hive mirror |
| Alarms | Hive is authoritative at fire time |

Firestore `Settings(persistenceEnabled: true, cacheSizeBytes: 40MB)` on mobile; persistence **disabled** in the admin panel so admins never act on stale data.

---

## 11. Admin Panel Architecture

```
apps/admin/lib/
├── app/
│   ├── router.dart              # go_router with role-based redirect guards
│   └── admin_shell.dart         # collapsible left nav + top bar
├── features/
│   ├── auth/                    # email+password login, claim check
│   ├── dashboard/               # KPI cards, charts (fl_chart)
│   ├── teachers/                # CRUD
│   ├── categories/              # CRUD
│   ├── content/                 # ONE generic module, configured per type
│   │   ├── content_list_page.dart
│   │   ├── content_form_page.dart
│   │   └── content_type_config.dart   # fields, validators, labels per type
│   ├── users/                   # table, detail, block, CSV export
│   ├── notifications/           # composer, preview, history
│   ├── config/                  # app config, static page editor, languages
│   └── audit/                   # audit log viewer
└── widgets/
    ├── paginated_data_table.dart      # cursor pagination
    ├── upload_dropzone.dart           # resumable, progress, cancel
    ├── localised_text_field.dart      # en/hi/mr tabs in one control
    ├── media_preview.dart             # image / audio player preview
    └── unsaved_changes_guard.dart
```

The **generic content module** is the key decision: `ContentTypeConfig` declares which fields each of the six content types exposes, and the list/form pages are built from that config. Adding "ID Card Templates" in Phase 2 means adding one config object, not a seventh CRUD screen.

Role gating: `router.dart` redirects on claim; forms disable non-permitted fields; Firestore rules enforce it for real. Login on the admin site does **not** accept phone or Google auth — email/password with an admin claim only, so a mobile app user can never reach the admin panel.

---

## 12. Localisation Architecture

- UI strings: `apps/mobile/lib/l10n/app_{en,hi,mr}.arb` → `gen-l10n`. Zero hardcoded user-facing strings; enforced by a CI lint.
- Content strings: stored per-language in the document (`title.en/hi/mr`); a `LocalisedText` extension resolves with fallback `userLang → en → first non-empty`.
- Fonts: Poppins (Latin) + Noto Sans Devanagari, bundled to keep Hindi/Marathi rendering identical across OEMs.
- Admin panel UI is English-only; it *edits* all three languages via `LocalisedTextField`.
- Layouts tested at 1.3x text scale in all three languages before any screen is called done.

---

## 13. Analytics, Monitoring, Cost

- Analytics events exactly as in PRD §11, wrapped in a typed `AnalyticsService` so event names cannot drift.
- Crashlytics with `recordError` in every repository catch block; non-fatals for permission denials and failed sets.
- Performance traces: `app_start`, `wallpaper_list_load`, `audio_first_frame`, `status_export`.
- **Cost guards:** paginate at 10–20 docs; `counters` via aggregation Functions; thumbnails ≤ 40 KB; long-cache CDN headers on Storage objects; Blaze budget alerts at 50/80/100% of a monthly cap.

---

## 14. Testing Strategy

| Layer | Coverage |
|---|---|
| Unit | Models (serialisation round-trip), validators, layout-rect maths, filter/query builders, alarm next-occurrence logic |
| Widget | Onboarding steps, teacher chip row, content list states (loading/empty/error), status card composition |
| Golden | Status composite and (Phase 2) ID card render, per language |
| Rules | `@firebase/rules-unit-testing` for every table row in §7 |
| Functions | Emulator tests for `onMediaUpload`, `aggregateEvents`, `publishScheduled` |
| Integration | Login → onboarding → set wallpaper; set prarthana → alarm fires (60s test hook) |
| Manual device matrix | Android 8/10/12/14/15 × Samsung, Xiaomi (MIUI), Oppo (ColorOS), stock Pixel — required for ringtone, wallpaper and alarm |

Firebase Emulator Suite (Auth, Firestore, Storage, Functions) is the local dev default; no developer touches the production project.

---

## 15. Environments and CI/CD

| Environment | Firebase project | Flutter flavour |
|---|---|---|
| dev | `dhamma-path-dev` | `dev` — app id `app.dhammapath.dev` |
| prod | `dhamma-path-prod` | `prod` — app id `app.dhammapath` |

Both flavours coexist on one device. Config comes from `--dart-define` at build time; `google-services.json` per flavour directory. No API keys or secrets in the repo beyond Firebase client config (which is not a secret, but App Check is what makes that safe).

GitHub Actions:
1. **PR:** `melos analyze` → `melos test` → rules tests → build debug APK + admin web
2. **main:** the above → build AAB → upload to Play internal testing → deploy admin hosting + rules + indexes + Functions to dev
3. **tag `v*`:** deploy everything to prod, promote the AAB to closed testing

---

## 16. Key Architectural Risks

| Risk | Mitigation |
|---|---|
| Alarm reliability on aggressive OEMs | Native exact alarms + foreground service + boot receiver + battery-exemption prompt + device matrix testing + in-app 60s test alarm |
| Android version drift breaking ringtone/wallpaper | All of it behind Kotlin plugins with per-API-level branches; tested on 8→15 |
| Firestore read costs at scale | Pagination, Hive caching, aggregated counters, budget alerts |
| Storage egress costs for images/audio | WebP + small thumbnails, long CDN cache; escape hatch is fronting Storage with Cloudflare R2 if egress dominates |
| Flutter Web admin bundle size / slow first load | `CanvasKit` with deferred route loading; admins are on desktop broadband |
| Six content types → six CRUD screens (maintenance sprawl) | One generic content module driven by `ContentTypeConfig` |
| Shared-model drift between app and admin | Single `packages/core`; a field rename is a compile error in both apps |
| Status/ID-card layout breaking across resolutions | Normalised 0–1 coordinates + golden tests |

---

## 17. Phase 2 Extension Points (built now, activated later)

| Phase 2 feature | Already reserved in MVP |
|---|---|
| Live wallpapers | `wallpaper.kind: 'static' \| 'live'`, `config.liveWallpaperEnabled` flag, "Live" badge slot in the card widget |
| Supporter ID Card | `teachers.idCardPrefix` + `signatureImage` fields, `idCardTemplates`/`idCards` collections defined, Profile row present but disabled, normalised layout-JSON approach proven by the status composer |
| Ads | `config.adsEnabled` flag, reserved slot positions in list layouts, ad-slot index arithmetic in the paginated list builder |
| Favourites / downloads | `users/{uid}/favourites` and `progress` subcollections defined |
| iOS | All platform code behind Dart interfaces; only new implementations needed |

---

*Next: `docs/TASKS.md` — milestone-wise, dependency-ordered task breakdown mapped to the FR/AR IDs in the PRD.*
