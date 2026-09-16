# Implementation Plan — Bodhi AI Chat

## Overview

Eight ordered waves: de-risking spikes, shared core models, the backend proxy, the admin settings page, the navigation restructure, the chat UI, compliance, then verification.

The backend is built before any UI so that the security posture (key custody, quota, topic gate) is settled and testable via the emulator before a single chat bubble exists. Admin and navigation work are independent of each other and can run in parallel once the shared core lands.

## Task Dependency Graph

```json
{
  "waves": [
    { "wave": 1, "tasks": ["0.1", "0.2", "0.3", "0.4"] },
    { "wave": 2, "tasks": ["1.1", "1.2", "1.3", "1.4"] },
    { "wave": 3, "tasks": ["2.1", "2.2", "2.3", "2.4"] },
    { "wave": 4, "tasks": ["2.5", "2.6", "2.7", "2.8"] },
    { "wave": 5, "tasks": ["3.1", "3.2", "3.3", "4.1", "4.2", "4.3"] },
    { "wave": 6, "tasks": ["5.1", "5.2", "5.3", "5.4"] },
    { "wave": 7, "tasks": ["6.1", "6.2", "6.3"] },
    { "wave": 8, "tasks": ["7.1", "7.2", "7.3"] }
  ]
}
```

Wave 1 gates everything: task 0.3 (App Check) and 0.4 (OpenRouter key + spend cap) are hard prerequisites for any live model call, and 0.1 decides the transport shape used in wave 6. Waves 5a (admin, `3.x`) and 5b (navigation, `4.x`) are `[P]` — different apps, no shared files. Wave 7 is a launch blocker, not a follow-up.

## Notes

- All new callables are pinned to `region: "asia-south1"` per `AppConstants.functionsRegion`; there is no `setGlobalOptions` in this codebase.
- Every new `@riverpod` provider and `freezed` model needs its generated file committed — `.github/workflows/pr.yml` runs `melos exec --depends-on=build_runner -- dart run build_runner build --delete-conflicting-outputs` and will fail the PR otherwise.
- `config/bodhi_ai` ships with `enabled: false`. The feature is dark until task 7.3 flips it, matching the existing `adsEnabled` / `idCardEnabled` dark-ship pattern.
- The OpenRouter key is set via `firebase functions:secrets:set` and must never appear in the repo, a `.env`, or Firestore (T4.5 launch gate).
- Existing tests must keep passing: `flutter test` in `apps/mobile` (40 tests today) and `apps/admin`, plus `firebase/tests/firestore.rules.test.mjs`.
- If a wave-1 spike invalidates a design assumption, stop and amend `design.md` rather than working around it in code.

## Tasks

- [ ] 0. De-risk the unknowns before writing feature code
  - [x] 0.1 Resolve whether the Flutter `cloud_functions` plugin supports streamed callables
    - **Answered by source inspection of the resolved packages — no throwaway code needed.** Streaming is supported end to end: `cloud_functions 5.6.2` exposes `HttpsCallable.stream()` returning `Stream<StreamResponse>` with `Chunk<T>` / `Result<R>`; `cloud_functions_platform_interface 5.8.2` implements it over an `EventChannel`; `FirebaseFunctionsStreamHandler.kt` backs it natively on Android via `httpsCallableReference.stream()`. Server side, `firebase-functions 6.6.0` provides `request.acceptsStreaming` and `CallableResponse.sendChunk`, and `sendChunk` is documented as a safe no-op when the client does not accept streaming.
    - **Decision: `bodhiChat` stays a normal callable. The SSE fallback endpoint is dropped from scope.**
    - Findings and the wire contract (`{message:...}` → `Chunk`, `{result:...}` → `Result`) recorded in `design.md` § "Streaming — RESOLVED".
    - _Requirements: BA-6.2_
  - [x] 0.2 Resolve nested-Scaffold keyboard and inset behaviour
    - **Answered from the Flutter 3.44.8 `Scaffold` source.** Two findings: (a) the M3 `NavigationBar` is positioned at `size.height - barHeight` where `bottom` ignores insets, so it stays pinned to the physical bottom **behind** the keyboard — the feared "nav bar sandwiched above the keyboard" does not occur and `resizeToAvoidBottomInset: false` is unnecessary; (b) the body slot is registered with `removeBottomInset: _resizeToAvoidBottomInset` (default true), so the shell hands the chat subtree a `MediaQuery` with `viewInsets.bottom == 0` **and** `padding.bottom == 0` — there is no double-counting.
    - **Correction to the design**: an "inset-aware composer" is dead code, because `viewInsets.bottom` is always 0 inside the chat screen. The shell already resizes the body; the composer just sits at the bottom of its box. Do not use `SafeArea` bottom or `MediaQuery.padding.bottom` inside the chat screen either.
    - `design.md` § "Keyboard and insets — RESOLVED" and § "Mini player and keyboard" updated accordingly; visual confirmation folded into task 7.2.
    - _Requirements: BA-6.4_
  - [ ] 0.3 Close App Check enforcement prerequisite (`docs/TASKS.md` T0.6)
    - Register the debug tokens from logcat in the Firebase Console for dev, confirm Play Integrity on a release build.
    - Verify a normal signed-in call still succeeds with `enforceAppCheck: true` on a scratch function before relying on it in `bodhiChat`.
    - _Requirements: BA-2.4_
  - [ ] 0.4 Provision OpenRouter and cap spend
    - Create the account, generate the key, set a hard monthly spend limit in the OpenRouter dashboard.
    - `firebase functions:secrets:set OPENROUTER_API_KEY` for both `dhamma-path-dev` and `dhamma-path-prod`.
    - Confirm `deepseek/deepseek-v4-flash-0731` responds and that `structured_outputs` works for the topic gate.
    - _Requirements: BA-2.1_

- [x] 1. Extend the shared core (`packages/core`)
  - [x] 1.1 Add constants
    - `ConfigDocIds.bodhiAi = 'bodhi_ai'` added in `firestore_collections.dart`.
    - `AppConstants.fnBodhiChat` and `fnBodhiSession` added alongside the existing `fn*` entries.
    - **Deviation from plan:** `FirestoreCollections.aiUsage` was **not** added. `aiUsage` is Function-only (clients are denied by rules), and the repo already has a precedent for exactly this: `otpGuards` is likewise absent from the Dart constants and named only in the Function and the rules. Adding it would imply the client touches the collection. The name lives in `functions/src/ai/quota.ts` instead.
    - _Requirements: BA-5.1_
  - [x] 1.2 Add the `BodhiAiConfig` model
    - `packages/core/lib/src/models/bodhi_ai_config.dart`, freezed + json_serializable with `@Default` values from the design table and `@TimestampConverter() DateTime? updatedAt`.
    - Use freezed rather than the plain-class style of `premium_config.dart` because the numeric defaults matter.
    - Export from the core barrel; run build_runner and commit generated files.
    - _Requirements: BA-5.1_
  - [x] 1.3 Add config read/write to `ConfigRepository`
    - `watchBodhiAiConfig()`, `getBodhiAiConfig()`, `saveBodhiAiConfig()` following the existing `guardedStream` / `guardedRead` / `guardedWrite` pattern, defaulted `_fromSnap`, and the `updatedAt` + `SetOptions(merge: true)` write convention.
    - _Requirements: BA-5.1_
  - [x] 1.4 Add `BodhiAiFunctionsService`
    - `bodhi_ai_functions_service.dart` with `streamMessage(...)`, `sendMessage(...)` and `session(action)`, following `AdminFunctionsService`: injectable `FirebaseFunctions?`, region from `AppConstants`, names from `AppConstants.fn*`, typed result classes.
    - Added beyond the plan: `streamMessage` using the 0.1 contract, with a `BodhiChatEvent` / `BodhiChatDelta` / `BodhiChatDone` sealed hierarchy mirroring the plugin's own shape, so the controller never handles raw maps. Stream payloads are parsed defensively rather than hard-cast — a shape change must not throw mid-stream.
    - `BodhiChatTurn` exposes only `.user()` / `.assistant()` named constructors, so the client cannot construct a `system` turn.
    - Chat timeout raised to 90 s (default is 60 s) because `bodhiChat` makes two sequential model calls.
    - `bodhiAiFunctionsServiceProvider` registered `keepAlive` in `core_providers.dart`.
    - _Requirements: BA-2.2_

- [x] 2. Build the backend proxy (`functions/src/ai/`)
  - [x] 2.1 OpenRouter client
    - `openRouter.ts`: `OPENROUTER_API_KEY = defineSecret(...)`, `chatCompletion({ model, messages, maxTokens, temperature, jsonObject? })` over Node 22's global `fetch` (no new dependency), 45 s `AbortController` timeout, attribution headers, and `HttpsError` normalisation (`deadline-exceeded` / `unavailable` / `resource-exhausted` on 429 / `internal`). Never leaks the provider body. Returns real `usage` token counts.
    - _Requirements: BA-2.1, BA-2.2_
  - [x] 2.2 Prompt assembly
    - `prompt.ts`: hardcoded scope preamble, localised refusals (en/hi/mr), `REFUSAL_SENTINEL`, and `buildMessages()` prepending the preamble to the admin tone. `sanitiseHistory()` keeps only `user`/`assistant`, drops forged `system` turns, trims + caps each turn at 4000 chars, keeps the last 10.
    - Verified by a throwaway Node script (since deleted): a forged `system` turn is dropped, history caps at 10, and the scope rule always precedes the admin text in the built system message.
    - _Requirements: BA-4.2, BA-4.3_
  - [x] 2.3 Quota accounting
    - `quota.ts`: `accrueSession`, `reserveMessage`, `recordOffTopic`, `recordTokens` as `runTransaction` read-modify-writes on `aiUsage/{uid}_{date}`, date via `todayKey()` in Asia/Kolkata (verified: `20:30Z → 2026-09-17`). `IDLE_CAP_SECONDS = 30`, per-day message cap, `MAX_OFFTOPIC_STRIKES = 20`, all throwing `resource-exhausted` with a plain reset message. Tier from `users/{uid}.premiumUntil > now` via `isPremium`.
    - Design refinement: `reserveMessage` charges a message up front; `recordOffTopic` refunds it and adds a strike, so a refusal costs nothing but still can't be farmed. Token counts recorded best-effort (never throws).
    - _Requirements: BA-3.1–BA-3.6, BA-4.5_
  - [x] 2.4 Topic gate
    - `topicGate.ts`: cheap `{"on_topic":bool}` classification via `jsonObject` response format, `maxTokens: 20`, `temperature: 0`. **Fails closed** — any parse/network error is treated as off-topic.
    - _Requirements: BA-4.1, BA-4.2_
  - [x] 2.5 `bodhiChat` callable
    - `bodhiChat.ts` with `{ region: 'asia-south1', secrets: [OPENROUTER_API_KEY], enforceAppCheck: true }`. Order: auth → App Check → config gate (`failed-precondition` if disabled) → tier → `reserveMessage` → topic gate → answer → `recordTokens`. Off-topic path refunds via `recordOffTopic`, returns the localised refusal, charges no seconds. Streams the reply as one chunk when `request.acceptsStreaming` (guarded on `response` being defined), always returns the final map. House style followed.
    - Added `config.ts`: `readBodhiConfig()` reads `config/bodhi_ai` with `BodhiAiConfig` defaults (disabled), `instructionFor()` resolves the admin tone per language with English fallback.
    - _Requirements: BA-2.2, BA-2.3, BA-2.4, BA-3.5, BA-4.1, BA-4.4_
  - [x] 2.6 `bodhiSession` callable
    - `bodhiSession.ts` handling `start`/`heartbeat`/`end` through `accrueSession`, returning `remainingSeconds`/`remainingMessages`. Also `enforceAppCheck: true` for consistency.
    - _Requirements: BA-3.4, BA-6.1_
  - [x] 2.7 Firestore rules for `aiUsage`
    - Added `match /aiUsage/{usageId} { allow read, write: if false; }` next to `otpGuards`.
    - Extended `firestore.rules.test.mjs` with a "denies all client access to aiUsage" case (user read/set/update + super-admin read all fail).
    - **Not executed:** the rules unit test needs the Firestore emulator, which requires JDK 21+. This machine has JDK 17, so `firebase emulators:exec` refuses to start. The rule is a byte-for-byte clone of the already-deployed, already-tested `otpGuards` rule, so risk is low — but the assertion is unverified until run on a JDK 21+ box (folded into 7.x).
    - _Requirements: BA-3.3_
  - [x] 2.8 Export and verify
    - Both callables exported from `functions/src/index.ts`. `npm run lint` (`tsc --noEmit`) and `npm run build` (`tsc`) both pass clean; all seven `lib/ai/*.js` emitted.
    - Live end-to-end (happy path, refusal, quota exhaustion, disabled) needs deploy + a real OpenRouter call, done in wave 8 rollout. Pure-logic paths verified offline as noted in 2.2–2.3.
    - _Requirements: BA-2.2, BA-4.2_

- [x] 3. Admin settings page (`apps/admin`) `[P]`
  - [x] 3.1 Providers and route wiring
    - `features/bodhi_ai/application/bodhi_ai_providers.dart` exposes `adminBodhiAiConfig` over `ConfigRepository.watchBodhiAiConfig()` (build_runner ran, `.g.dart` committed).
    - Added `AdminRoutes.bodhiAi = '/bodhi-ai'`, an `AdminDestination(label: 'Bodhi AI', allowed: AdminRole.canEditConfig)` after the Premium entry, an `Icons.auto_awesome_outlined` case in `admin_shell.dart` `_iconFor`, and a `GoRoute` inside the authenticated `ShellRoute`.
    - _Requirements: BA-5.2_
  - [x] 3.2 The settings form
    - `bodhi_ai_config_page.dart` cloned from `config_page.dart`: hydrate-once via post-frame callback, `_loaded`/`_dirty`/`_saving`, `FilledButton` in `AdminPageFrame.actions`, `UnsavedChangesGuard`, `_heading` sections.
    - Fields: enabled switch (with hint), model `TextField` (helper warns against `~…-latest` aliases), `LocalisedTextField` for the system instruction (maxLines 6, with a "rule is enforced in code" note), digits-only fields for the four quota/cap values, a decimal temperature field, and an `updatedAt` footer.
    - All copy added as `bodhiAi*` constants in `admin_strings.dart`.
    - _Requirements: BA-5.1_
  - [x] 3.3 Validation and nav test
    - `_validate()` rejects: empty model, a `~`-prefixed alias, empty instruction (all locales), non-positive or free>paid seconds, non-positive or free>paid messages, `maxTokens` outside 100–4000, temperature outside 0–2; each surfaced via `_snack`.
    - Extended `admin_nav_test.dart`: "Bodhi AI" absent for a content manager, present for a super admin.
    - **Verification note:** a throwaway widget test (Riverpod override on `adminBodhiAiConfigProvider`) confirmed the page hydrates the default model, keeps Save disabled until dirty, enables it on edit, and shows the alias-rejection snackbar. It was then deleted, matching `ConfigPage` which ships without a widget test. The only failure it surfaced was a debug-only "ListTile under ColoredBox" assertion caused by the bare test host lacking the shell's `Scaffold` Material — the real `AdminShell` provides it, and `ConfigPage`'s identical `SwitchListTile`s rely on the same thing. Not a page bug.
    - **Verified:** `flutter analyze` clean and full `flutter test` green in all three packages (core 82, admin 20, mobile 38).
    - _Requirements: BA-5.3, BA-5.2_

- [x] 4. Navigation restructure (`apps/mobile`) `[P]`
  - **Rebased on commit `0264ca0`**, which moved the nav bar out of `MainShell` into `PersistentBottomNav` in the root builder. The old index-lockstep problem and the `mini_player.dart` `_mainTabRoutes` problem no longer exist. See design § Navigation Restructure.
  - [x] 4.1 Move Profile to the Home app bar
    - Add `profile_avatar_button.dart` (ConsumerWidget) watching `statusAvatarProvider`, falling back to `AppUser.photoUrl` then `Icons.person_outline`, pushing `AppRoutes.profile`; radius ~16–18 with a semantics label reusing `navProfile`.
    - Set it as `leading:` on the Home `AppBar` (decision D3: Home only).
    - **Done:** `profile_avatar_button.dart` created, set as `leading` on the Home app bar in `home_screen.dart`.
    - _Requirements: BA-1.2_
  - [x] 4.2 Add the Ask Buddha destination and route
    - `router.dart`: add `AppRoutes.askBuddha = '/ask-buddha'`, register it as a `StatefulShellBranch` (so the tab keeps its own stack), and convert the Profile branch to a pushed top-level `GoRoute`.
    - `persistent_bottom_nav.dart`: insert `AppRoutes.askBuddha` at index 2 of `_navRoutes` and add the matching `NavigationDestination` at the same position; remove the Profile entry from both lists. **Set `tooltip: ''`** on the new destination — the bar lives above the `Overlay` and a defaulted tooltip throws.
    - Hide the destination when `config/bodhi_ai.enabled` is false (BA-1.3). Note `PersistentBottomNav` is a plain `StatelessWidget` today; reading config means making it a `ConsumerWidget` or passing the flag down from `app.dart`.
    - Confirm `/ask-buddha` is **not** added to `_hiddenExactRoutes` in `bottom_app_chrome.dart` — the chrome should stay visible on the chat tab.
    - Switch the `module: 'profile'` deep-link dispatch to `push` for a proper back arrow (no longer a stranding bug now that the bar is always present).
    - **Done, with a deviation from plan:** Ask Buddha sits at nav **index 2 (centre)**, not the freed profile slot — the flagship feature earns the centre position (decision D2). `PersistentBottomNav` now carries `_navRoutesWithAi` / `_navRoutesNoAi` and a `bodhiAiEnabled` param, with a `_destinationFor` helper and `tooltip: ''` on the destinations. The `enabled` flag is watched in `app.dart` via `bodhiAiConfigProvider` and threaded through `BottomAppChrome(bodhiAiEnabled:)` down to the nav. `router.dart` adds `AppRoutes.askBuddha = '/ask-buddha'` as an Ask Buddha branch at index 2 and Profile as a pushed top-level `GoRoute`. Deep-link `module: 'profile'` now pushes (`fcm_coordinator.dart`, `home_screen.dart` pending-push).
    - _Requirements: BA-1.1, BA-1.2, BA-1.3, BA-1.4_
  - [x] 4.3 Localisation and the mini-player clearance provider
    - Add `navAskBuddha` and the `aiChat*` keys to `app_en.arb`, `app_hi.arb`, `app_mr.arb`; regenerate and commit l10n output. Prefix `aiChat*` to avoid collision with the existing `calendarBodhiDay`. Keep the Hindi/Marathi nav label short — the bar is height-capped at 62 with text scaling clamped to 1.3×.
    - **Done:** `navAskBuddha` + `aiChat*` keys added to all three ARB files and `flutter gen-l10n` regenerated the localizations. The chat screen reads `currentMediaItemProvider` directly for mini-player clearance rather than adding a wrapper provider (the check is a one-liner used in a single place, so a derived provider earns nothing).
    - **Obsolete:** the old `_mainTabRoutes` / `_kNavBarHeight` fix. Commit `0264ca0` deleted that logic from `mini_player.dart`; positioning now comes from `BottomAppChrome.heightOf(context)` in `app.dart`. Nothing to do.
    - _Requirements: BA-1.1, BA-6.4_

- [x] 5. Chat UI (`apps/mobile/lib/features/bodhi_ai/`)
  - [x] 5.1 Local history store
    - `bodhi_chat_store.dart`: Hive box `bodhi_chat` (opened in `alarm_local_store.dart` bootstrap), with `load` / `save` / `clear` and a `BodhiMessage` model (`role`/`text`/`pending`, `isUser`, `copyWith`), capped at a sane message count.
    - _Requirements: BA-6.3_
  - [x] 5.2 Controller with session lifecycle
    - `bodhi_chat_controller.dart`: messages, `remainingSeconds`, send status.
    - `start` on screen focus, 20 s heartbeat, `end` on blur/dispose, driven by `AppLifecycleListener` so a backgrounded app stops accruing.
    - Truncate history to 10 turns before send; persist through the store.
    - Map errors: `resource-exhausted` → quota sheet (+ `ensurePremium` paywall CTA for free users), `failed-precondition` → disabled/App Check hint, `unavailable` → retry.
    - **Done:** `bodhi_chat_controller.dart` holds `BodhiChatState` (messages, `sending`, `remainingSeconds`, `remainingMessages`), streams sends via `streamMessage` (optimistic pending assistant bubble filled by `BodhiChatDelta`, finalised by `BodhiChatDone`), trims to 10 turns before send, persists through the store, and maps `resource-exhausted`/`failed-precondition`/other to a `BodhiSendOutcome` the screen acts on. Session `start`/`heartbeat`/`end` are best-effort `_tick`s driven by the screen's `AppLifecycleListener` + 20 s timer. `bodhi_chat_controller.g.dart` hand-written (build_runner hangs on this machine) and verified compiling.
    - _Requirements: BA-3.4, BA-3.7, BA-6.1_
  - [x] 5.3 Screen and widgets
    - `ask_buddha_screen.dart` plus `message_bubble`, `composer`, `quota_banner`.
    - Per the 0.2 finding (as amended for `0264ca0`): **no** inset math (`viewInsets.bottom` is 0 here), **no** `resizeToAvoidBottomInset` override, and **no** manual reservation for the nav chrome — `BottomAppChrome` is a `Column` sibling, so the `Expanded` already excludes it. Add mini-player clearance (~64 px) driven only by "is media loaded", since the mini player *is* an overlay.
    - Render streamed text via `HttpsCallable.stream()` per the 0.1 contract, with a typing indicator until the first `Chunk` arrives.
    - Empty state with a few suggested Buddhism questions.
    - **Done:** `ask_buddha_screen.dart` (owns session lifecycle, empty state with 3 suggestions + AI disclaimer, composer, mini-player-aware bottom padding via `currentMediaItemProvider`), `widgets/bodhi_message_bubble.dart` (streamed text + per-reply report action), `widgets/bodhi_quota_banner.dart` (hidden until first tick, "time left today" with a low-time colour), `widgets/bodhi_report_sheet.dart` (writes a `contactMessages` doc tagged `subject: 'ai_report'`). No inset math, no `resizeToAvoidBottomInset` override, chrome stays visible — per the 0.2 finding as amended for `0264ca0`.
    - _Requirements: BA-6.1, BA-6.2, BA-6.4_
  - [x] 5.4 ~~Keep `DaanFloatingOverlay` clear of the composer~~ — **obsolete, nothing to do**
    - Commit `0264ca0` deleted `DaanFloatingOverlay` and replaced the floating bubble with `DonateSupportBanner` inside `BottomAppChrome`, which occupies real layout space instead of overlaying the page. There is no longer a floating element that can cover the send button.
    - _Requirements: BA-6.4_

- [ ] 6. Compliance (launch blocking)
  - [ ] 6.1 Amend the Privacy Policy for third-party AI processing
    - Update `firebase/public_site/privacy/index.html` to disclose that chat text is sent to OpenRouter for inference, what is sent (message text and recent turns, no profile data), that transcripts are not stored server-side, and the purpose.
    - The current policy lists only Google/Firebase processors, so shipping without this makes it inaccurate. Deploy `hosting:public` only.
    - _Requirements: BA-7.1_
  - [ ] 6.2 In-app reporting of AI replies
    - Long-press action on an assistant bubble writes a `contactMessages` doc tagged `type: 'ai_report'` with the reported turn, reusing the existing admin inbox as the sink.
    - Confirm the rule `request.resource.data.uid == request.auth.uid` is satisfied by the payload.
    - Re-check the current Play Console generative-AI policy wording before submission rather than relying on the design summary.
    - _Requirements: BA-7.2_
  - [ ] 6.3 AI disclosure in the UI
    - First-run dismissible note stating replies are AI-generated and may be inaccurate, plus a persistent short line in the empty state. Localised in all three ARB files.
    - _Requirements: BA-7.3_

- [ ] 7. Verification and rollout
  - [ ] 7.1 Automated checks
    - `flutter analyze` clean across `apps/mobile`, `apps/admin`, `packages/core`; `npm --prefix functions run lint` clean.
    - Full `flutter test` green in both apps (mobile is 40 tests today), plus the extended rules tests from 2.7 and the admin nav test from 3.3.
    - Add widget tests for the quota-exhausted state and the off-topic refusal rendering.
    - _Requirements: BA-3.5, BA-4.1_
  - [ ] 7.2 Manual matrix on a physical device
    - Free user: consume 210 s, confirm the quota sheet and paywall CTA; confirm the counter does not move while the app is backgrounded.
    - Paid user: confirm 1800 s and that a trialing user is treated as paid (known behaviour — trial and paid are indistinguishable today).
    - Off-topic question → refusal with no minutes charged; 20 refusals → rate limited.
    - Admin: change model and system instruction, confirm the next reply reflects it without an app release.
    - `enabled: false` → tab hidden and callable rejects.
    - Layout: keyboard open with mini player playing, on a small screen and at 1.3× text scale.
    - _Requirements: BA-1.3, BA-3.1, BA-3.2, BA-3.4, BA-3.7, BA-4.1, BA-4.5, BA-5.1, BA-6.4_
  - [ ] 7.3 Staged enable and cost watch
    - Deploy functions to dev, seed `config/bodhi_ai`, verify end to end, then deploy to prod with `enabled: false`.
    - Enable for a small audience first; watch the OpenRouter dashboard against the design's ₹0.013/turn projection for 48 hours before a wider rollout.
    - Enable prompt caching once the prompt prefix has stopped changing.
    - Update `docs/TASKS.md` with the shipped tasks and current status.
    - _Requirements: BA-2.1_
