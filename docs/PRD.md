# Dhamma Path — Product Requirements Document (PRD)

| Field | Value |
|---|---|
| Product Name | **Dhamma Path** |
| Internal Codename | dhamma-path |
| Version | 1.1 (Scope locked) |
| Date | 18 August 2026 |
| Owner | Product Owner (Prem Kumar) |
| Platforms | Android (Phase 1), iOS (Phase 2), Web Admin Panel (Phase 1) |
| Tech Stack | Flutter (mobile + web), Firebase (Auth, Firestore, Storage, FCM, Functions, Remote Config, Analytics, Crashlytics) |
| Status | Scope approved → Architecture next |

> Note: The reference screenshots show the working title **"Nirvana"**. Final product name is **Dhamma Path** (confirmed). All branding strings must come from a single constants/localization source so a rename is a one-line change.

## 0. Locked Scope Decisions

Answers to the review questions, confirmed by the product owner on 18 Aug 2026. These override anything below that conflicts.

| # | Decision | Impact |
|---|---|---|
| D1 | App name is **Dhamma Path** | Branding, package name `app.dhammapath`, store listing |
| D2 | **Login is mandatory before browsing** — no guest mode | Auth gate before Home; FR-2.6 dropped from all phases |
| D3 | **Live wallpapers → Phase 2** | MVP wallpapers are static images only |
| D4 | **Supporter ID Card → Phase 2** | Profile keeps the "My ID Card" row but it shows a "Coming soon" state in MVP |
| D5 | **Ads → Phase 2** | MVP ships ad-free; ad SDK not integrated in MVP, but layouts reserve ad slots |
| D6 | **Content is ready** and will be uploaded through the admin panel | Admin panel content CRUD is a **launch blocker**, must be built before/with the app |

**Assumed defaults for questions not yet answered** (flag now if any is wrong):

| # | Assumption |
|---|---|
| A1 | Tagline stays "Power in Every Voice" |
| A2 | Android only at launch; iOS deferred to Phase 3 |
| A3 | Firebase project on the **Blaze** plan (required for Cloud Functions and FCM targeting) |
| A4 | Domain `dhammapath.app` (or similar) will be registered for admin hosting and deep links |
| A5 | 2–3 admin accounts at launch, using the three proposed roles |
| A6 | No video / YouTube content in MVP |
| A7 | Prarthana tracks come from a **separate admin-curated Prarthana collection**, not the general Songs library |

---

## 1. Product Overview

Dhamma Path is a Buddhist devotional and self-improvement content app for Indian users (primarily Hindi, Marathi and English speakers). It gives followers of Gautam Buddha, Dr. B. R. Ambedkar and other Dhamma teachers one place to get:

- Buddha / Dhamma **wallpapers** (static + live)
- **Ringtones** they can set directly as phone ringtone, alarm or notification tone
- **Songs / Bhajans / Suttas** with a full audio player
- **Guided meditations** (Anapana, Vipassana, stress relief, sleep)
- **Daily Prarthana** alarm with a chosen prarthana track
- **Trending Status** images they can personalise with their own photo + name and share to WhatsApp
- A shareable **Supporter Identity Card** (digital ID card) with their photo, name, unique ID and QR code

Everything the user sees is **teacher-scoped** — the user picks one or more teachers (Gautam Buddha, Dr. B. R. Ambedkar, Dalai Lama, Thich Nhat Hanh, …) during onboarding, and content across all modules is filtered by teacher chips.

All content is **admin-managed**. A Flutter Web admin panel lets the team upload, categorise, schedule and moderate every asset without an app release.

### 1.1 Problem Statement

Buddhist devotional content in India is scattered across YouTube, WhatsApp forwards and low-quality sticker apps. There is no single, respectful, ad-light app that offers high-quality Ambedkarite/Buddhist wallpapers, ringtones, prarthana and meditation audio in Hindi/Marathi with easy WhatsApp sharing.

### 1.2 Product Vision

> "Har din ek Dhamma kadam" — a daily-use companion that makes it effortless to keep Buddha's teachings visible on your phone, audible in your day, and shareable with your community.

---

## 2. Goals and Success Metrics

### 2.1 Business Goals

| # | Goal | Metric | Target (6 months post-launch) |
|---|---|---|---|
| G1 | Acquire users | Play Store installs | 100,000 |
| G2 | Make it a daily habit | DAU / MAU ratio | ≥ 25% |
| G3 | Drive viral growth | Status/ID card shares per active user per month | ≥ 3 |
| G4 | Retain users | D7 retention | ≥ 30% |
| G5 | Monetise sustainably | Ad ARPDAU + premium conversion | Defined in Phase 3 |
| G6 | Zero-release content ops | Content items published via admin panel per week | ≥ 50 |

### 2.2 Product KPIs

- Onboarding completion rate ≥ 80%
- Wallpaper set rate (users who set ≥ 1 wallpaper) ≥ 40%
- Ringtone set rate ≥ 30%
- Daily Prarthana alarm set rate ≥ 20%
- ID Card generation rate ≥ 25%
- Crash-free sessions ≥ 99.5%
- Median audio start time < 1.5s on 4G

---

## 3. Target Users

| Persona | Description | Key needs |
|---|---|---|
| **Devotee Deepak** (32, Nagpur, Marathi) | Ambedkarite Buddhist, follows Dhamma rituals daily | Prarthana alarm, Marathi bhajans, Babasaheb wallpapers |
| **Seeker Sneha** (26, Pune, English/Hindi) | Interested in mindfulness and meditation, not ritual-heavy | Guided meditations, calm wallpapers, sleep audio |
| **Sharer Suresh** (45, Lucknow, Hindi) | Very active in WhatsApp groups, low digital literacy | One-tap status images with his photo/name, ID card, big buttons |
| **Content Admin Anita** (Internal) | Manages uploads and moderation | Fast bulk upload, categorisation, scheduling, analytics |

### 3.1 Accessibility & Device Assumptions

- Primary devices: Android 8.0+ (API 26+), 2–4 GB RAM, budget phones
- Many users have limited data → aggressive caching, compressed thumbnails, download-once
- Large touch targets (min 48dp), high contrast text, full Hindi/Marathi localisation
- Screen reader labels on every interactive element; text scaling up to 1.3x must not break layouts

---

## 4. Scope

### 4.1 In Scope — Phase 1 (MVP)

**Mobile app (Android):** Splash, mandatory Auth (Phone OTP + Google), Language, Person Info, Teacher selection, Home, Wallpapers (**static only**), Meditation, Ringtone, Song, Daily Prarthana, Trending Status with photo frame + name, Profile + static pages, Share app, Push notifications.

**Admin panel (Flutter Web):** Admin auth with roles, Dashboard, Teacher CRUD, Category CRUD, Wallpaper/Ringtone/Song/Meditation/Status/Prarthana CRUD with media upload, Notification composer, User list, App config, Basic analytics, Audit log.

> The admin panel is a **launch blocker** — all launch content is uploaded through it, so its content CRUD must be usable before app QA begins.

### 4.2 Deferred to Phase 2

- **Live wallpapers** (video wallpaper service, Live badge, autoplay previews)
- **Supporter ID Card** (templates, unique ID, QR, share) — Profile row present but disabled with a "Coming soon" state
- **Ads** (AdMob banner / interstitial / native) — layouts reserve the slots, SDK not integrated in MVP
- Favourites, per-item downloads / offline audio, dark theme, notification inbox, playlists, meditation streaks

### 4.3 Out of Scope Entirely (Phase 1 & 2)

- **Guest mode** — login is mandatory, dropped permanently
- iOS build (Phase 3). Note: iOS cannot set ringtones or wallpapers programmatically — those modules would become "download + instructions" there
- User-generated content publishing (users only personalise for themselves)
- Social feed, comments, follows, chat
- In-app purchases / subscriptions / donations / payments
- Full offline-first sync
- Video content and live streaming

---

## 5. Information Architecture

```
Splash
└─ Auth (Phone OTP / Google)
   └─ Onboarding
      ├─ 1. Language        (English / हिन्दी / मराठी)
      ├─ 2. Person Info     (Full Name, Mobile, Email)
      └─ 3. Select Teacher  (multi-select)
         └─ Home
            ├─ Wallpaper        → Wallpaper Detail (Set Wallpaper)
            ├─ Meditation       → Audio Player
            ├─ Ringtone         → Set as Ringtone / Alarm / Notification
            ├─ Song             → Audio Player (queue)
            ├─ Daily Prarthana  → Alarm setup → Choose Prarthana Song
            ├─ Trending Status  → Status Editor (photo + name) → Download / Share
            └─ Profile
               ├─ My ID Card    → Template carousel → Editor → Share
               ├─ Change Language
               ├─ About Us / Contact Us / Privacy Policy / Terms
               └─ Logout / Delete Account
```

**Global pattern:** every content list screen has a horizontal filter chip row — `All | <Selected Teacher 1> | <Selected Teacher 2> | ... | ⊕` where `⊕` opens a teacher picker sheet to add more teachers to the user's selection.

---

## 6. Functional Requirements

Requirement IDs are referenced later by the architecture and task documents.

### 6.1 Splash & App Bootstrap

| ID | Requirement | Priority |
|---|---|---|
| FR-1.1 | Show branded splash (logo + "Dhamma Path" + tagline) for max 2s while bootstrapping | P0 |
| FR-1.2 | Bootstrap = init Firebase, fetch Remote Config, check auth state, check onboarding completion, check force-update flag | P0 |
| FR-1.3 | If `force_update` version > installed version, show blocking update dialog with Play Store link | P0 |
| FR-1.4 | If maintenance mode enabled in config, show maintenance screen with admin-set message | P1 |
| FR-1.5 | Route to Auth / Onboarding step / Home based on saved state (resume onboarding at the exact incomplete step) | P0 |
| FR-1.6 | On first launch, ask for notification permission (Android 13+) after onboarding, not before | P1 |

### 6.2 Authentication

| ID | Requirement | Priority |
|---|---|---|
| FR-2.1 | Login screen: logo, app name, tagline "Power in Every Voice", Buddha illustration, `+91` prefixed 10-digit mobile input, "Continue with OTP" primary button, "Continue with Google" secondary button, T&C + Privacy links | P0 |
| FR-2.2 | Phone auth via Firebase Auth OTP; 6-digit OTP screen with auto-read (SMS Retriever), 60s resend timer, change-number link | P0 |
| FR-2.3 | Google Sign-In via Firebase Auth | P0 |
| FR-2.4 | On first successful auth, create `users/{uid}` document with auth method, device info, FCM token, createdAt | P0 |
| FR-2.5 | Persist session; user stays logged in until explicit logout | P0 |
| FR-2.6 | ~~Guest / Skip mode~~ — **dropped (D2)**. Login is mandatory; no content is reachable before auth. The auth screen has no skip affordance | — |
| FR-2.7 | Handle errors clearly: invalid number, wrong OTP, too many attempts, network failure, Play Integrity failure | P0 |
| FR-2.8 | Logout clears local state; account deletion request removes user doc + generated assets within 30 days | P0 |
| FR-2.9 | Rate-limit OTP requests per number (Firebase App Check + Cloud Function guard) to prevent SMS-bombing abuse | P0 |

### 6.3 Onboarding

#### 6.3.1 Language Selection

| ID | Requirement | Priority |
|---|---|---|
| FR-3.1 | Grid of language cards: English / Hindi (हिन्दी) / Marathi (मराठी); each shows English name + native name; selected card gets red border + check badge | P0 |
| FR-3.2 | Default preselect based on device locale, fallback English | P1 |
| FR-3.3 | Continue button disabled until a selection exists | P0 |
| FR-3.4 | Save to local prefs + `users/{uid}.language`; app UI switches immediately | P0 |
| FR-3.5 | Language list is admin-configurable so a 4th language can be added without an app release (strings must exist in bundle) | P2 |

#### 6.3.2 Person Information

| ID | Requirement | Priority |
|---|---|---|
| FR-4.1 | Fields: Full Name (required, 2–40 chars, letters/spaces/Devanagari), Mobile Number (required, 10 digits, prefilled and read-only if phone auth), Email (optional, valid format, prefilled if Google auth) | P0 |
| FR-4.2 | Inline validation with localised error messages; Continue enabled only when valid | P0 |
| FR-4.3 | Name captured here is reused as the default name on Status images and the ID Card | P0 |
| FR-4.4 | Save to `users/{uid}` | P0 |

#### 6.3.3 Teacher Selection

| ID | Requirement | Priority |
|---|---|---|
| FR-5.1 | Title "Select Your Teacher / अपने गुरु चुनें", search box, 2-column grid of teacher cards (portrait image + name overlay) | P0 |
| FR-5.2 | **Multi-select** with visible selected state; helper text "You can select multiple Teachers to personalise your experience" | P0 |
| FR-5.3 | Teacher list loaded from Firestore `teachers` collection, ordered by admin `sortOrder`, only `isActive: true` | P0 |
| FR-5.4 | Client-side search by name (all locales) | P1 |
| FR-5.5 | At least 1 teacher required to continue | P0 |
| FR-5.6 | Selection saved to `users/{uid}.selectedTeachers[]`; drives filter chips and default content everywhere | P0 |
| FR-5.7 | Editable later from any content screen's ⊕ chip and from Profile | P1 |
| FR-5.8 | Launch teachers: Gautam Buddha, Dr. B. R. Ambedkar, Dalai Lama, Thich Nhat Hanh (admin can add more) | P0 |

### 6.4 Home Screen

| ID | Requirement | Priority |
|---|---|---|
| FR-6.1 | App bar: profile avatar button (left), app name (center), "Share App" button (right) | P0 |
| FR-6.2 | Module grid — 2x2 tiles: **Wallpaper, Meditation, Ringtone, Song** — plus a full-width **Daily Prarthana** tile; each with icon + label | P0 |
| FR-6.3 | Module tile order, visibility and labels driven by Remote Config so modules can be reordered/hidden remotely | P2 |
| FR-6.4 | "Trending Status" section: teacher filter chips + vertically scrolling status cards | P0 |
| FR-6.5 | Each status card shows the status image, a circular "add your photo" button, the user's name, and Download + Share (WhatsApp) buttons | P0 |
| FR-6.6 | Status feed paginated (10 per page), infinite scroll, shimmer placeholders, cached images | P0 |
| FR-6.7 | Pull-to-refresh reloads status feed and config | P1 |
| FR-6.8 | Optional promo/announcement banner slot controlled by admin (image + deep link) | P2 |
| FR-6.9 | "Share App" shares a localised message + Play Store link via native share sheet | P0 |

### 6.5 Wallpapers

| ID | Requirement | Priority |
|---|---|---|
| FR-7.1 | Screen title "Wallpapers", back button, teacher filter chips (All / selected teachers / ⊕) | P0 |
| FR-7.2 | Vertical list/feed of large wallpaper previews (rounded corners), each with an overlaid **Set Wallpaper** button | P0 |
| FR-7.3 | **Live wallpaper** items show a "Live" badge and auto-play a muted looping video preview when in viewport — **Phase 2 (D3)**. Data model reserves `type: static \| live` from day one | Phase 2 |
| FR-7.4 | Tap opens full-screen detail: pinch-zoom, swipe between wallpapers, actions = Set Wallpaper, Download, Share, Favourite | P0 |
| FR-7.5 | Set Wallpaper sheet: Home screen / Lock screen / Both | P0 |
| FR-7.6 | Live wallpaper set flow: download video → register as Android live wallpaper service → open system chooser — **Phase 2 (D3)** | Phase 2 |
| FR-7.7 | Wallpapers served as compressed thumbnail (list) + full-res (detail/set); WebP preferred | P0 |
| FR-7.8 | Download saves to device gallery in a `Dhamma Path` album with scoped-storage-safe APIs | P0 |
| FR-7.9 | Success/failure toast + haptic feedback on set | P1 |
| FR-7.10 | Sub-categories inside wallpapers (e.g. Buddha, Stupa, Quotes, Nature, Live) as a secondary chip row | P2 |

### 6.6 Ringtones

| ID | Requirement | Priority |
|---|---|---|
| FR-8.1 | Screen title "Ringtones" with a "▶ Help" button that opens a short how-to (permission explainer) | P0 |
| FR-8.2 | Teacher filter chips | P0 |
| FR-8.3 | List rows: thumbnail with play overlay, title, `artist • duration`, and a **Set** button | P0 |
| FR-8.4 | Inline preview playback — tap thumbnail to play/pause; only one item plays at a time; row shows progress | P0 |
| FR-8.5 | **Set** opens sheet: Set as Ringtone / Set as Alarm / Set as Notification / Assign to Contact (P2) | P0 |
| FR-8.6 | Setting requires `WRITE_SETTINGS`; app must explain and deep-link to the system permission page, then complete the action on return | P0 |
| FR-8.7 | Audio file downloaded to app-visible media dir and registered with MediaStore before being set | P0 |
| FR-8.8 | Download and Share (as audio file) actions per item | P1 |
| FR-8.9 | Show currently-set ringtone with a checked state | P2 |
| FR-8.10 | Mini-player persists across screens while previewing | P1 |

### 6.7 Songs

| ID | Requirement | Priority |
|---|---|---|
| FR-9.1 | Screen title "Song", teacher filter chips | P0 |
| FR-9.2 | List rows: thumbnail with play overlay, song title, artist/author (default "Anonymous") | P0 |
| FR-9.3 | Tap opens full player: artwork, title, artist, seek bar with elapsed/total, play/pause, next/previous, 10s skip, repeat, shuffle | P0 |
| FR-9.4 | Background playback with a media notification (play/pause/next/prev), lock screen controls, audio focus handling | P0 |
| FR-9.5 | Streaming with buffering indicator; retry on network error | P0 |
| FR-9.6 | Per-song download for offline playback; downloaded state indicator; manage downloads in Profile | P1 |
| FR-9.7 | Playlists / albums grouping (admin defined) | P2 |
| FR-9.8 | Lyrics text panel when admin has provided lyrics | P2 |
| FR-9.9 | Favourites (heart) synced to the user's profile | P1 |
| FR-9.10 | Play count incremented per completed play (aggregated server-side, not per-write) | P1 |

### 6.8 Meditation

| ID | Requirement | Priority |
|---|---|---|
| FR-10.1 | Screen title "Meditation", teacher filter chips | P0 |
| FR-10.2 | List rows: thumbnail, title, teacher/narrator (e.g. "S.N. Goenka"); supports multi-part series ("Part 1", "Part 2") | P0 |
| FR-10.3 | Series grouping so parts play sequentially and remember last position | P1 |
| FR-10.4 | Meditation player: same engine as Songs plus a **sleep timer** (5/10/15/30/60 min) and optional background ambience mix | P1 |
| FR-10.5 | Resume from last playback position per item | P1 |
| FR-10.6 | Meditation categories: Anapana, Vipassana, Stress Relief, Sleep, Beginners (admin defined) | P1 |
| FR-10.7 | Track daily meditation minutes and show a simple streak on Profile | P2 |
| FR-10.8 | Screen stays awake / dims gracefully during a session | P2 |

### 6.9 Daily Prarthana (Alarm)

| ID | Requirement | Priority |
|---|---|---|
| FR-11.1 | Screen title "Daily Prarthana" with a "▶ Help" button | P0 |
| FR-11.2 | Wheel time picker (hour : minute : AM/PM) in the app's visual style | P0 |
| FR-11.3 | Repeat section: "Everyday" toggle + individual day chips (M T W T F S S) | P0 |
| FR-11.4 | "Prarthana Song" row showing the selected track or "No Prarthana selected", with "Choose >" opening a picker from the Songs/Prarthana library | P0 |
| FR-11.5 | Primary CTA "🔔 Set Prarthana" schedules an exact local alarm | P0 |
| FR-11.6 | Alarm fires reliably with app killed: exact alarms + foreground service + boot-completed rescheduling; request `SCHEDULE_EXACT_ALARM` on Android 12+ | P0 |
| FR-11.7 | Alarm screen: full-screen intent with Buddha artwork, current time, playing prarthana audio, **Stop** and **Snooze (10 min)** | P0 |
| FR-11.8 | The chosen prarthana audio must be pre-downloaded when the alarm is set so it works offline | P0 |
| FR-11.9 | Multiple alarms (e.g. morning + evening) with enable/disable toggles and a list view | P1 |
| FR-11.10 | Explain and deep-link battery-optimisation exemption for OEMs that kill alarms (MIUI, ColorOS, etc.) | P1 |
| FR-11.11 | Volume/vibrate/fade-in settings per alarm | P2 |

### 6.10 Trending Status (Personalised Status Images)

| ID | Requirement | Priority |
|---|---|---|
| FR-12.1 | Feed of admin-uploaded status images (festival greetings, quotes, Dhamma messages) with teacher filter chips | P0 |
| FR-12.2 | Each card composites: base status image + the user's circular photo in an admin-defined frame position + the user's name in an admin-defined text position/style | P0 |
| FR-12.3 | Tap the circular camera button to pick a photo (camera or gallery) with crop-to-circle; photo saved once and reused across all statuses | P0 |
| FR-12.4 | Name defaults to the onboarding name and is editable inline | P0 |
| FR-12.5 | **Download** exports the composited image at full resolution (min 1080px wide) to the gallery | P0 |
| FR-12.6 | **Share** opens WhatsApp directly with the composited image; graceful fallback to the system share sheet if WhatsApp is absent | P0 |
| FR-12.7 | Optional watermark / app branding on exported images, toggleable by admin | P1 |
| FR-12.8 | Categories: Trending, Festival, Quotes, Jayanti, Good Morning (admin defined) | P1 |
| FR-12.9 | Admin can schedule a status to publish and expire on set dates (for festivals) | P1 |
| FR-12.10 | Composition happens on-device; no user photo is uploaded to the server unless the user is signed in and opts into cloud backup | P0 |
| FR-12.11 | Share count tracked per status for a "Most shared" sort | P2 |

### 6.11 Supporter Identity Card — **PHASE 2 (D4)**

> Not in MVP. Profile shows the "My ID Card" row with a "Coming soon" state. Requirements captured here so the MVP data model and design system don't have to be reworked later.

| ID | Requirement | Priority |
|---|---|---|
| FR-13.1 | Entry points: Profile → "My ID Card"; optionally a Home tile | Phase 2 |
| FR-13.2 | Modal shows the teacher name as title, page indicator ("1/4"), close button, swipeable template carousel with dots | P0 |
| FR-13.3 | **4 launch templates** per teacher (admin can add more), rendered as high-quality designs (e.g. gold Gautam Buddha "Supporter Identity Card") | P0 |
| FR-13.4 | Card fields: Photo (user upload, tap to add), **Name**, **Unique ID** (format `BUD-<YEAR>-<6 digits>`), **Member Since** (year), **Signed By** (teacher signature artwork), QR code, values line ("Truth • Compassion • Wisdom") | P0 |
| FR-13.5 | Unique ID generated once per user per teacher and stored permanently; never regenerated | P0 |
| FR-13.6 | QR code encodes a verification deep link (`https://dhammapath.app/id/<cardId>`) | P0 |
| FR-13.7 | Green **Share** button shares the rendered card as an image to WhatsApp | P0 |
| FR-13.8 | Download card to gallery | P0 |
| FR-13.9 | Template layout (field coordinates, fonts, colours, photo frame) defined as admin-editable JSON so new templates need no app release | P1 |
| FR-13.10 | Cards for each selected teacher (Buddha, Ambedkar, …) with teacher-specific prefixes (`BUD-`, `BRA-`) | P1 |
| FR-13.11 | Optional public verification web page rendered from the card ID | P2 |

### 6.12 Profile & Settings

| ID | Requirement | Priority |
|---|---|---|
| FR-14.1 | Header: avatar with edit badge, name, phone, email | P0 |
| FR-14.2 | Menu rows with leading icons: My ID Card (**disabled "Coming soon" in MVP, D4**), Change Language, About Us, Contact Us, Privacy Policy, Terms & Conditions, Logout | P0 |
| FR-14.3 | Additional rows: Edit Profile, My Teachers, Favourites, Downloads, My Alarms, Notifications toggle, Rate Us, Share App, App Version, Delete Account | P1 |
| FR-14.4 | Static pages (About/Privacy/Terms/Contact) rendered from admin-managed rich text per language, cached offline | P0 |
| FR-14.5 | Contact Us provides an in-app form (subject, message, optional screenshot) writing to Firestore + email/WhatsApp fallback | P1 |
| FR-14.6 | Logout confirmation dialog; Delete Account double confirmation with consequences explained | P0 |
| FR-14.7 | Clear cache option showing current cache size | P2 |

### 6.13 Notifications

| ID | Requirement | Priority |
|---|---|---|
| FR-15.1 | FCM push with title, body, optional image, and a deep link target (module / item / URL) | P0 |
| FR-15.2 | Topic subscriptions per teacher and per language so admins can target segments | P0 |
| FR-15.3 | Handle foreground, background and terminated-state taps with correct deep-link routing | P0 |
| FR-15.4 | In-app notification inbox listing the last 30 days of received messages | P2 |
| FR-15.5 | Local daily "Thought of the Day" notification at a user-chosen time | P2 |
| FR-15.6 | Per-category notification preferences in Profile | P1 |

### 6.14 Monetisation — **PHASE 2 (D5)**

> MVP ships **ad-free**. No ad SDK is integrated. MVP list layouts must still reserve the ad slot positions below so adding ads later does not require a layout rewrite.

| ID | Requirement | Priority |
|---|---|---|
| FR-16.1 | AdMob banner on list screens (Wallpapers, Ringtones, Songs, Meditation) | Phase 2 |
| FR-16.2 | Interstitial on Set Wallpaper / Set Ringtone / Download success, frequency-capped (max 1 per 3 minutes) and never during an active meditation or alarm | Phase 2 |
| FR-16.3 | Native ad slots inserted every N status cards, N controlled remotely | Phase 3 |
| FR-16.4 | Rewarded ad to unlock premium wallpapers/templates | Phase 3 |
| FR-16.5 | All ad unit IDs, placements and frequency controlled via Remote Config, with a global ads kill-switch | Phase 2 |
| FR-16.6 | Ads must never appear during onboarding or the first session | Phase 2 |

---

## 7. Admin Panel Requirements (Flutter Web)

### 7.1 Access & Roles

| ID | Requirement | Priority |
|---|---|---|
| AR-1.1 | Email/password login via Firebase Auth, restricted to accounts carrying an admin custom claim | P0 |
| AR-1.2 | Roles: **Super Admin** (everything incl. user & admin management), **Content Manager** (CRUD content, no user data), **Moderator** (publish/unpublish, edit metadata only) | P0 |
| AR-1.3 | Firestore Security Rules must enforce roles server-side; the UI only hides, never protects | P0 |
| AR-1.4 | Session timeout after 12h idle; forced re-auth for destructive actions (delete, role change) | P1 |
| AR-1.5 | Audit log of every create/update/delete: who, what, when, before/after diff | P0 |
| AR-1.6 | Admin panel deployed to Firebase Hosting on a separate site/subdomain (`admin.dhammapath.app`) | P0 |

### 7.2 Dashboard

| ID | Requirement | Priority |
|---|---|---|
| AR-2.1 | KPI cards: total users, DAU, new users today, total content items by type, total downloads, total shares | P0 |
| AR-2.2 | Charts: user growth (30d), content engagement by module, top 10 items by downloads/plays | P1 |
| AR-2.3 | Recent activity feed from the audit log | P1 |
| AR-2.4 | Storage usage and Firestore read/write cost indicators | P2 |

### 7.3 Content Management (common behaviour for all content types)

| ID | Requirement | Priority |
|---|---|---|
| AR-3.1 | Data table per content type: search, filter (teacher, category, language, status), sort, pagination, bulk select | P0 |
| AR-3.2 | Create/Edit form with media upload (drag & drop), live preview, and required-field validation | P0 |
| AR-3.3 | Status workflow: Draft → Published → Unpublished/Archived; publish and expiry scheduling | P0 |
| AR-3.4 | Common metadata: title (per language), teacher(s), category, tags, sortOrder/priority, isPremium, isFeatured, publishAt, expireAt | P0 |
| AR-3.5 | Bulk upload — multi-file drop that creates one draft per file with auto-filled title from filename | P1 |
| AR-3.6 | Automatic derivative generation on upload via Cloud Function: image thumbnails + WebP, audio duration + waveform, video poster frame | P0 |
| AR-3.7 | Soft delete with a 30-day restore window; hard delete only for Super Admin | P1 |
| AR-3.8 | Duplicate/clone an item to speed up similar entries | P2 |
| AR-3.9 | Reorder items by drag & drop within a category | P1 |

### 7.4 Content Types in Admin

| Module | Type-specific fields |
|---|---|
| **Teachers** | name (en/hi/mr), portrait image, thumbnail, short bio, signature image, ID-card prefix (e.g. `BUD`), sortOrder, isActive |
| **Wallpapers** | image file, type = static (`live` reserved for Phase 2), orientation, resolution, sub-category |
| **Ringtones** | audio file, artist, duration (auto), trim start/end, waveform |
| **Songs** | audio file, artist, album/playlist, lyrics (per language), duration (auto), artwork |
| **Meditation** | audio file, narrator, series name + part number, duration, level (beginner/intermediate), category |
| **Status** | base image, photo-frame rect + shape, name text rect + font + colour + alignment, watermark toggle, festival date |
| **ID Card Templates** *(Phase 2)* | teacher, template background image, layout JSON (field rects, fonts, colours), photo frame rect, QR rect, signature asset, isDefault |
| **Prarthana** | audio file (can be flagged from Songs), recommended time, description |

### 7.5 User Management

| ID | Requirement | Priority |
|---|---|---|
| AR-5.1 | Searchable user table: name, phone, email, language, teachers, signup date, last active, platform, app version | P0 |
| AR-5.2 | User detail view: profile, generated ID cards, favourites, alarms count, activity summary | P1 |
| AR-5.3 | Block/unblock a user; blocked users are denied by security rules | P1 |
| AR-5.4 | Export users to CSV (Super Admin only, audit-logged, PII access warning shown) | P1 |
| AR-5.5 | Handle GDPR/DPDP-style deletion requests: view queue, execute deletion, record proof | P1 |

### 7.6 Notification Composer

| ID | Requirement | Priority |
|---|---|---|
| AR-6.1 | Compose title, body, image, deep-link target; live phone preview | P0 |
| AR-6.2 | Audience targeting: all users / by teacher topic / by language / by platform / specific user | P0 |
| AR-6.3 | Send now or schedule for later | P1 |
| AR-6.4 | History with delivery stats (sent, delivered, opened) | P1 |
| AR-6.5 | Test send to a specific device token before broadcasting | P1 |

### 7.7 App Configuration

| ID | Requirement | Priority |
|---|---|---|
| AR-7.1 | Manage: min supported version, force-update flag, maintenance mode + message, home module order/visibility, ads config, feature flags | P0 |
| AR-7.2 | Manage static pages (About, Privacy, Terms, Contact, Help) with a rich text editor per language | P0 |
| AR-7.3 | Manage the promo banner (image, target, active window) | P2 |
| AR-7.4 | Manage supported languages list | P2 |
| AR-7.5 | Config changes take effect in the app without a release (Remote Config / Firestore-backed) | P0 |

### 7.8 Admin Panel UX

| ID | Requirement | Priority |
|---|---|---|
| AR-8.1 | Responsive layout: collapsible left nav + top bar; usable from 1024px up, tablet-tolerable | P0 |
| AR-8.2 | Upload progress with cancel; resumable uploads for large audio/video | P1 |
| AR-8.3 | Unsaved-changes guard when navigating away from a dirty form | P1 |
| AR-8.4 | Clear empty, loading, error and permission-denied states everywhere | P0 |
| AR-8.5 | Keyboard-accessible tables and forms; WCAG-minded contrast and focus states | P1 |

---

## 8. Content Model & Taxonomy

**Core relationships**

- A `Teacher` is the primary content dimension. Every content item references one or more teachers.
- A `Category` belongs to a module (wallpaper / ringtone / song / meditation / status) and provides the optional second-level chip row.
- Content is localised at the metadata level (title, description) — the media file itself is language-agnostic except for audio, where language is an attribute.
- Every content item carries: `id, type, teacherIds[], categoryId, title{en,hi,mr}, mediaUrl, thumbUrl, language, status, isPremium, isFeatured, sortOrder, tags[], counters{views,downloads,shares,plays}, publishAt, expireAt, createdBy, createdAt, updatedAt, deletedAt`.

**Launch content targets**

Content is already collected (D6) and will be entered via the admin panel before app QA.

| Module | Minimum at launch |
|---|---|
| Teachers | 4 |
| Wallpapers | 100 static (live wallpapers → Phase 2) |
| Ringtones | 40 |
| Songs | 60 |
| Meditation | 30 (incl. 3 series) |
| Status images | 50 |
| Prarthana tracks | 10 |
| ID Card templates | Phase 2 |

---

## 9. Non-Functional Requirements

| Area | Requirement |
|---|---|
| **Performance** | Cold start < 2.5s on a 3GB-RAM device; list scroll at 60fps; images lazy-loaded and disk-cached; audio start < 1.5s on 4G |
| **App size** | Android release APK/AAB < 30 MB; no bundled media beyond branding assets |
| **Offline** | Cached lists and images viewable offline; downloaded audio playable offline; prarthana alarm works fully offline |
| **Reliability** | Crash-free sessions ≥ 99.5%; all network calls retried with exponential backoff; graceful degradation when Firestore is unreachable |
| **Security** | Firestore rules deny-by-default; users can only read published content and read/write their own document; admin writes gated by custom claims; App Check on all Firebase services; no secrets in the client |
| **Privacy** | Explicit consent for personal data; user photos processed on-device by default; privacy policy compliant with India DPDP Act and Play Data Safety; documented data retention and deletion |
| **Cost control** | Aggregate counters via Cloud Functions rather than per-event writes; paginate everything; cache config; Storage lifecycle rules for orphaned files |
| **Localisation** | 100% of UI strings externalised; en/hi/mr complete at launch; Devanagari-capable fonts bundled; no truncation in any locale |
| **Accessibility** | 48dp minimum targets, semantic labels, 4.5:1 text contrast, supports 1.3x text scaling |
| **Observability** | Firebase Analytics for the full event taxonomy, Crashlytics, Performance Monitoring on key traces |
| **Testability** | Unit tests for domain logic, widget tests for key screens, integration test for the onboarding → set wallpaper happy path |
| **Content moderation** | Everything is admin-uploaded; a takedown flow must remove an item from all clients within 5 minutes |

---

## 10. Design & Branding

- **Palette:** cream/ivory background `#FDF3E0`, deep maroon primary `#8B1A1A`, gold accents `#D4A24C`, near-black text `#1F1F1F`, WhatsApp green `#25D366` for share actions.
- **Typography:** a rounded geometric sans for Latin (Poppins/Nunito style) with a Devanagari-complete companion (Noto Sans Devanagari); large friendly weights.
- **Components:** heavily rounded cards (16–24dp radius), soft shadows, pill filter chips (selected = filled maroon), full-width pill primary buttons, disabled buttons in muted beige.
- **Tone:** calm, respectful, uncluttered. No aggressive gamification. Imagery must be dignified and correctly attributed.
- **Iconography:** consistent line icon set with maroon tint on soft tinted square backgrounds.
- Light theme at launch; dark theme in Phase 2.

---

## 11. Analytics Event Taxonomy

`app_open`, `onboarding_step_view {step}`, `onboarding_complete {language, teachers}`, `login_attempt {method}`, `login_success {method}`, `login_fail {method, reason}`, `module_open {module}`, `teacher_filter_change {teacher}`, `wallpaper_view {id}`, `wallpaper_set {id, target}`, `wallpaper_download {id}`, `ringtone_preview {id}`, `ringtone_set {id, target}`, `song_play {id}`, `song_complete {id}`, `meditation_play {id, duration_listened}`, `status_photo_added`, `status_download {id}`, `status_share {id, channel}`, `idcard_template_view {templateId}`, `idcard_generate {templateId}`, `idcard_share {templateId}`, `prarthana_set {time, days, songId}`, `prarthana_fired`, `prarthana_snooze`, `notification_received {campaignId}`, `notification_open {campaignId}`, `share_app`, `permission_prompt {type, result}`, `ad_impression {placement}`, `error {code, screen}`.

---

## 12. Permissions (Android)

| Permission | Purpose | When requested |
|---|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE` | Content delivery | Install time |
| `POST_NOTIFICATIONS` | Push + alarm notifications | After onboarding, with rationale |
| `WRITE_SETTINGS` | Set ringtone / alarm / notification tone | On first Set action, with explainer |
| `READ_MEDIA_IMAGES` / Photo Picker | Pick user photo | On first photo add (prefer Photo Picker to avoid the permission) |
| `CAMERA` | Take photo for status / ID card | On camera choice |
| `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` | Daily Prarthana | On first alarm set |
| `RECEIVE_BOOT_COMPLETED` | Reschedule alarms after reboot | Install time |
| `FOREGROUND_SERVICE` (+ mediaPlayback) | Background audio and alarm | Install time |
| `SET_WALLPAPER` | Set wallpaper | Install time |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Alarm reliability on aggressive OEMs | Optional, explained |

Every runtime permission needs a pre-prompt rationale screen and a graceful denied path with a "how to enable in Settings" route.

---

## 13. Release Plan

| Phase | Scope | Exit criteria |
|---|---|---|
| **M0 — Foundation** | Monorepo + shared package, Firebase project, security rules, design system, routing, localisation (en/hi/mr), admin auth + shell | App builds on Android; admin logs in; rules unit-tested |
| **M1 — Admin panel** | Teacher/Category CRUD, all content-type CRUD with upload + derivative Functions, publish workflow, config, static pages, notification composer, audit log | Team can upload all launch content unassisted |
| **M2 — Content ingestion** | Real content loaded via admin (D6) | 100 wallpapers, 40 ringtones, 60 songs, 30 meditations, 50 statuses, 10 prarthana live in Firestore |
| **M3 — App MVP** | Auth (mandatory), onboarding, home, wallpapers (static), ringtones, songs, meditation, prarthana alarm, trending status, profile, notifications | All P0 requirements met against real content |
| **M4 — Launch** | Analytics, performance pass, permission rationale polish, Play Data Safety, closed beta, store listing | Crash-free ≥ 99.5%, store approved, 50-user beta feedback addressed |
| **M5 — Phase 2** | Live wallpapers, Supporter ID Card, ads, favourites, offline downloads, dark theme | Metric-driven, post-launch |
| **M6 — Phase 3** | iOS, notification inbox, playlists, streaks, rewarded ads, premium tier, referrals | Post-launch |

---

## 14. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Copyright on devotional audio/images | Play takedown, legal notice | Only upload licensed/original/public-domain content; store a source + licence field per item; documented takedown process |
| Alarms killed by Chinese OEM battery managers | Core feature fails silently | Exact alarms + foreground service + boot receiver + battery-exemption prompt + a "test alarm in 1 min" tool |
| Android ringtone/wallpaper API restrictions | Feature breaks on new Android versions | Abstract behind a platform channel with per-version implementations; test on Android 8–15 |
| Firebase cost blowout from image/audio egress | Unsustainable unit economics | CDN caching headers, compressed derivatives, thumbnails in lists, consider Cloudflare R2 in front of Storage if egress grows |
| Play Store policy rejection (photos, wallpapers, permissions) | Launch delay | Data Safety form accuracy, permission rationale, avoid `MANAGE_EXTERNAL_STORAGE`, use Photo Picker |
| Religious/political sensitivity of content | Community backlash | Editorial review before publish, respectful copy, no comparative or political claims |
| PII in user table (phone, email, photos) | Privacy breach | Least-privilege admin roles, audit logs, no PII in analytics, encryption in transit, retention policy |
| Scope creep across 8 modules | Slipped timeline | Strict P0/P1/P2 priorities in this PRD; phase gates |

---

## 15. Decision Log & Remaining Questions

**Resolved** — see Section 0 for D1–D6 (app name, mandatory login, live wallpaper → Phase 2, ID card → Phase 2, ads → Phase 2, content ready).

**Still open** — proceeding on the assumptions in Section 0 (A1–A7). Correct any of these and the architecture adjusts:

| # | Question | Working assumption |
|---|---|---|
| Q1 | Final tagline? | "Power in Every Voice" (A1) |
| Q2 | iOS release timing? | Phase 3 (A2) |
| Q3 | Is the Firebase project on the Blaze plan? | Yes (A3) — required for Cloud Functions |
| Q4 | Which domain do we own? | `dhammapath.app` to be registered (A4) |
| Q5 | How many admin accounts, and are the 3 roles right? | 2–3 accounts, 3 roles (A5) |
| Q6 | Any Dhamma video/discourse content planned? | No video in MVP (A6) |
| Q7 | Prarthana tracks: reuse Songs, or separate collection? | Separate curated collection (A7) |
| Q8 | Do we have written licence/source proof for the collected content? | Assumed yes; a `source` + `licence` field is mandatory per item regardless |

---

*Next: `docs/ARCHITECTURE.md` → then `docs/TASKS.md`.*
