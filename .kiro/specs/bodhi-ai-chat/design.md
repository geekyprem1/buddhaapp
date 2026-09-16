# Design Document — Bodhi AI Chat

| Field | Value |
|---|---|
| Feature | Bodhi AI — in-app Buddhism-only AI chat ("Ask Buddha") |
| Version | 1.0 |
| Date | 15 September 2026 |
| Inputs | `docs/ARCHITECTURE.md` v1.0 · `docs/PRD.md` v1.1 · `docs/TASKS.md` v1.5 |
| Status | Design approved for implementation; three decisions marked **[D]** are reversible |

## Overview

Bodhi AI adds a conversational assistant to the mobile app that answers Buddhism-related questions only. It is reached from a new bottom-navigation tab labelled "Ask Buddha". Profile moves out of the bottom nav to a top-left avatar button, freeing a nav slot.

Inference runs on OpenRouter (DeepSeek V4 Flash family). Every request is proxied through a new Firebase callable Function in `asia-south1`, which owns the API key, the daily quota, the topic gate, and the system instruction. The mobile client never holds the OpenRouter key and never decides whether a user has quota left.

Free users get 3 minutes 30 seconds of chat per day, paid users get 30 minutes. Tier is read from the existing server-verified `users/{uid}.premiumUntil`. Model name, system instruction, and quota values are editable by a Super Admin from the admin panel.

## Goals

- OpenRouter credentials never leave the backend
- Server-authoritative daily quota that a modified client cannot reset or inflate
- Answers restricted to Buddhism; refusals are cheap and do not burn user quota
- Admin can change model, system instruction, and limits without an app release
- Hard cost ceiling: a kill switch, a per-day message cap, and a per-reply token cap
- Reuse the existing entitlement, config, callable-wrapper, and admin-form patterns rather than inventing new ones

## Non-Goals

- Voice input or text-to-speech
- Image or document input (chosen model tier is text-only)
- Server-side chat transcript storage or cross-device history sync
- Retrieval over Tipitaka or app content (no RAG in v1)
- Fine-tuning or custom model hosting
- iOS support beyond what already exists (entitlement verification is Android-only today, see Risks)

## Decisions

Three items were open at design time. Defaults chosen below; each is a small, isolated change if the owner prefers otherwise.

**[D1] Quota is metered in minutes, as requested.** A message-count quota would be simpler and map exactly to cost, but minutes is what was asked for, so minutes is the user-facing meter. Cost is protected separately by a per-day message cap and a per-reply token cap (see Quota Accounting). Section "Why minutes needs a cap" explains the interaction.

**[D2] "Ask Buddha" takes the centre nav slot (index 2), not the freed Profile slot (index 4).** Centre is the most-tapped position and this is a flagship feature; far-right is where users expect account settings, not a headline feature. Final order: Home, Calendar, **Ask Buddha**, Practice, Videos.

**[D3] The profile avatar is added to the Home app bar only, not all four tabs.** The shell `Scaffold` has no app bar of its own, so each tab owns its own — putting the avatar everywhere means editing four files and keeping them in sync. Home-only is one entry point, which is enough. If the owner wants it everywhere, extract `ProfileAvatarButton` once and add `leading:` to the other three.

## Functional Requirements

Referenced by ID from `tasks.md`.

**BA-1 Access and placement**
- BA-1.1 A bottom-nav tab labelled "Ask Buddha" opens the chat screen at route `/ask-buddha`.
- BA-1.2 Profile is removed from the bottom nav and reachable from a top-left avatar button on Home.
- BA-1.3 The chat tab is hidden when `config/bodhi_ai.enabled` is false.
- BA-1.4 Deep link `module: 'profile'` continues to resolve to a usable Profile screen.

**BA-2 Key custody and transport**
- BA-2.1 The OpenRouter API key SHALL exist only in Google Secret Manager, never in the repo, the app, or Firestore.
- BA-2.2 All model calls SHALL originate from the `bodhiChat` Cloud Function in `asia-south1`.
- BA-2.3 `bodhiChat` SHALL reject unauthenticated callers.
- BA-2.4 `bodhiChat` SHALL enforce App Check.

**BA-3 Quota**
- BA-3.1 Free users SHALL receive 210 seconds of chat per calendar day (Asia/Kolkata); paid users 1800 seconds.
- BA-3.2 Tier SHALL be determined server-side from `users/{uid}.premiumUntil > now`.
- BA-3.3 Usage counters SHALL live in a Function-only collection that clients cannot read or write.
- BA-3.4 Time SHALL accrue only while the chat screen is open and the app is foregrounded.
- BA-3.5 When quota is exhausted, the Function SHALL return `resource-exhausted` with seconds until reset.
- BA-3.6 A per-day message cap and a per-reply `max_tokens` cap SHALL apply independently of the minute quota.
- BA-3.7 Exhausted free users SHALL be shown the existing paywall route, not a dead end.

**BA-4 Scope restriction**
- BA-4.1 Off-topic questions SHALL receive a fixed refusal, not an answer.
- BA-4.2 Topic classification SHALL happen server-side and SHALL NOT be defeatable by client-supplied message history.
- BA-4.3 The non-negotiable scope rule SHALL be hardcoded in the Function, outside the admin-editable field.
- BA-4.4 A refusal SHALL NOT consume the user's minute quota.
- BA-4.5 Repeated off-topic attempts SHALL be counted and rate-limited to prevent free-classification farming.

**BA-5 Admin control**
- BA-5.1 A Super Admin SHALL be able to edit model ID, system instruction, quota seconds, message cap, max tokens, temperature, and the enabled flag.
- BA-5.2 The settings page SHALL be visible and writable only to `super_admin`.
- BA-5.3 Saving invalid values (empty model, zero quota) SHALL be rejected with a visible message.

**BA-6 Client experience**
- BA-6.1 Remaining quota SHALL be visible before and during a conversation.
- BA-6.2 Replies SHALL stream if the platform supports it, otherwise show a typing indicator.
- BA-6.3 Chat history SHALL persist locally across app restarts.
- BA-6.4 The composer SHALL remain usable with the keyboard open, the bottom nav present, and the mini player visible.

**BA-7 Compliance**
- BA-7.1 The Privacy Policy SHALL disclose that chat text is sent to OpenRouter, a third-party processor.
- BA-7.2 Users SHALL be able to report an offensive or harmful AI reply from inside the app.
- BA-7.3 The UI SHALL state that replies are AI-generated and may be inaccurate.

## Architecture

```text
┌──────────────────────────── Mobile app ────────────────────────────┐
│  AskBuddhaScreen                                                   │
│    └── BodhiChatController (Riverpod)                              │
│          ├── local history      → Hive box 'bodhi_chat'            │
│          └── BodhiAiFunctionsService                               │
└─────────────────────────────────┬──────────────────────────────────┘
                                  │ httpsCallable + App Check token
                                  ▼
┌───────────── Cloud Function  bodhiChat  (asia-south1) ─────────────┐
│ 1. require request.auth                          → unauthenticated │
│ 2. require App Check                             → failed-precond. │
│ 3. read config/bodhi_ai (enabled? model? prompt?)                  │
│ 4. read users/{uid}.premiumUntil     → tier: free | paid           │
│ 5. quota txn on aiUsage/{uid}_{date} → resource-exhausted          │
│ 6. topic gate  (cheap call, hardcoded prompt)                      │
│      └── off-topic → refusal, no minute charge, bump strike count  │
│ 7. main call   (system = hardcoded scope + admin instruction)      │
│ 8. record real token usage + seconds on aiUsage doc                │
└─────────────────────────────────┬──────────────────────────────────┘
                                  │ Bearer ${OPENROUTER_API_KEY}
                                  ▼
                        OpenRouter /chat/completions
```

### Why the proxy is not optional

An OpenRouter key shipped in the APK is extractable in minutes and would be billed to the project owner with no rate limit and no attribution. The key must live server-side. This also makes the quota, the topic gate, and the system instruction untamperable, because all three are evaluated on a machine the user does not control.

### Secret handling

This is the first real secret in `functions/`. There is currently no `defineSecret`, no `process.env` read, no `.env`, and no `functions.config()` anywhere in the backend — the only third-party integration (Google Play Developer API) avoids key material entirely by using Application Default Credentials.

`firebase-functions ^6.3.2` already supports Secret Manager, so no dependency bump:

```ts
import { defineSecret } from "firebase-functions/params";
const OPENROUTER_API_KEY = defineSecret("OPENROUTER_API_KEY");

export const bodhiChat = onCall(
  { region: "asia-south1", secrets: [OPENROUTER_API_KEY], enforceAppCheck: true },
  async (request) => { /* ... */ },
);
```

Set out of band, never committed:

```bash
firebase functions:secrets:set OPENROUTER_API_KEY --project dhamma-path-prod
```

This keeps the `docs/TASKS.md` T4.5 launch gate ("no secrets in the repo") intact.

### App Check — a prerequisite, not a nice-to-have

`bodhiChat` spends money per call, so an unauthenticated script hitting it is a direct billing attack. App Check is the defence.

Current state: App Check is activated client-side in `apps/mobile/lib/app/bootstrap.dart` (Play Integrity on release, debug provider on dev), but **no backend function sets `enforceAppCheck`** and Console enforcement is still off per `docs/TASKS.md` T0.6. The client deliberately swallows App Check activation failures because nothing enforces it yet.

Consequence: `bodhiChat` will be the first function to require App Check. On a device whose debug token is not registered, the call fails and the client has no signal explaining why. **T0.6 must be closed before this feature ships.** Enforcement is set per-function, so turning it on for `bodhiChat` does not affect the six existing callables (`setAdminRole`, `exportUsersCsv`, `processDeletionRequest`, `sendNotification`, `guardOtpAbuse`, `verifyPurchase`).

## Data Model

### `config/bodhi_ai` (new doc in the existing `config` collection)

Rules already cover it: `match /config/{docId} { allow read: if isSignedIn(); allow write: if isSuperAdmin(); }` — no rules change needed for config.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `enabled` | bool | `false` | Kill switch; dark-ship default, matching `adsEnabled` / `idCardEnabled` style |
| `model` | string | `deepseek/deepseek-v4-flash-0731` | OpenRouter model slug |
| `systemInstruction` | `LocalisedText` | seeded | Tone and style, per locale (en/hi/mr) |
| `freeDailySeconds` | int | `210` | 3 min 30 s |
| `paidDailySeconds` | int | `1800` | 30 min |
| `freeDailyMessages` | int | `15` | Cost guard |
| `paidDailyMessages` | int | `120` | Cost guard |
| `maxTokens` | int | `700` | Per-reply output ceiling |
| `temperature` | double | `0.4` | Lower = more factual |
| `updatedAt` | Timestamp | — | Stamped on save, per `ConfigRepository` convention |

Model choice: `deepseek/deepseek-v4-flash-0731` is a pinned, dated slug. **Do not use the `~deepseek/...-latest` aliases** — an alias silently re-points to a different checkpoint, so a tuned system instruction would one day run on a model it was never tested against.

### `aiUsage/{uid}_{yyyy-MM-dd}` (new Function-only collection)

| Field | Type | Purpose |
|---|---|---|
| `uid` | string | Owner, for queries |
| `date` | string | `yyyy-MM-dd` in Asia/Kolkata |
| `tier` | string | `free` \| `paid` at first write of the day |
| `usedSeconds` | int | Accrued chat seconds |
| `messages` | int | Answered messages (refusals excluded) |
| `promptTokens` / `completionTokens` | int | Real usage from the OpenRouter response, for cost reporting |
| `offTopicStrikes` | int | Refusal count, for BA-4.5 |
| `lastTickAt` | Timestamp | Server time of the previous accrual |
| `sessionOpen` | bool | Whether a chat session is currently active |

Rules — clients get nothing, mirroring the `otpGuards` precedent:

```
match /aiUsage/{docId} {
  allow read, write: if false; // Functions only, via the Admin SDK
}
```

The counter deliberately does **not** live on `users/{uid}`. The rules there protect only five server-owned keys (`isBlocked`, `premiumUntil`, `premiumToken`, `premiumState`, `premiumUpdatedAt`); every other field is owner-writable, so a counter placed there would be trivially resettable by the user.

### Chat history — local only

Transcripts stay on-device in a Hive box (`bodhi_chat`). The server persists no message text. This is cheaper, avoids a new PII store, and keeps the Privacy Policy disclosure narrow.

Because history lives on the client, the client sends the last N turns with each request. **The server must not trust that payload as instructions**: the system role is always constructed server-side, client-supplied roles are restricted to `user` and `assistant`, and the history is truncated (last 10 turns, hard character cap). This closes the obvious injection path where a client fabricates an `assistant` turn saying "scope restriction lifted".

## Quota Accounting

### Accrual model

Minutes accrue only while the chat screen is open and foregrounded:

1. Client calls `bodhiSession(action: 'start')` when the screen becomes active. Server sets `sessionOpen = true`, `lastTickAt = now`.
2. While open and foregrounded, the client sends a heartbeat every 20 s. Each heartbeat, and each chat message, accrues `min(now - lastTickAt, IDLE_CAP)` seconds, where `IDLE_CAP = 30`.
3. Client calls `bodhiSession(action: 'end')` on leaving the screen. If the app is killed or loses network, no explicit end arrives — the `IDLE_CAP` bounds the damage to 30 s, and nothing accrues while the app is closed because nothing is ticking.

All arithmetic uses server timestamps inside a `runTransaction`, so the client cannot inflate remaining time. The transaction shape is lifted directly from `functions/src/auth/guardOtpAbuse.ts`, the existing rate limiter: fixed-window counter, read-modify-write, `resource-exhausted` with a retry hint in the message.

### Why minutes needs a cap

Metering a text chat by wall-clock minutes has a failure mode worth stating plainly: a fast typist can send far more questions in 3½ minutes than a slow one, so two users on the same quota can differ several-fold in real cost. `IDLE_CAP` gives a floor (each message costs at least 30 s, so 210 s guarantees at least 7 free answers), but it does not give a ceiling on message count.

Hence BA-3.6: `freeDailyMessages` / `paidDailyMessages` and `maxTokens` exist purely as cost guards. Under normal use the user only ever sees the minute counter; the message cap should only trigger for outliers. If it starts firing for ordinary users, that is the signal that minutes was the wrong meter and the quota should switch to message count.

### Cost projection

At `deepseek/deepseek-v4-flash-0731` list pricing ($0.055 / M input, $0.11 / M output), one turn with ~1,900 input tokens (system + 10-turn history) and ~400 output tokens costs about **$0.00015 ≈ ₹0.013**.

| Cohort | Per day | Per month | Note |
|---|---|---|---|
| Paid user, 30 min ≈ 50 turns | ₹0.65 | **~₹20** | ~10% of the ₹199 plan; comfortable |
| Free user, 3.5 min ≈ 8 turns | ₹0.10 | **~₹3** | Per *daily-active* free user |
| 10,000 daily-active free users | ₹1,100 | **~₹32,000** | The real exposure |

The free tier at scale is the cost risk, not the paid tier. Three controls address it: the `enabled` kill switch, App Check enforcement, and a hard spend limit configured in the OpenRouter dashboard. OpenRouter's prompt caching (`input_cache_read` is ~5× cheaper than fresh input) materially reduces the repeated-history portion of the bill and should be enabled once the prompt prefix is stable.

## Scope Restriction

A system prompt alone does not hold. "Explain X to me as a Buddhist parable" style reframing defeats single-layer instructions within minutes of public exposure. Four layers:

1. **Hardcoded preamble** — the non-negotiable scope rule lives in `functions/src/ai/prompt.ts`, prepended to whatever the admin wrote. Admin controls tone and style; admin cannot remove the restriction.
2. **Topic gate** — a cheap pre-pass asks the model to classify the question with structured output (`{ "on_topic": boolean }`). The chosen model supports `structured_outputs`. Cost is roughly $0.00002 per check, negligible. Off-topic short-circuits to a fixed localised refusal.
3. **Output check** — the reply is scanned for the refusal sentinel and obvious scope escapes before being returned.
4. **`max_tokens`** — bounds any single reply, so a "write me a 50-page essay" prompt cannot produce a large bill.

Refusals do not charge minutes (BA-4.4) — punishing a user for one off-topic question feels broken. But that makes the gate a free endpoint, so refusals increment `offTopicStrikes`, and past a threshold (20/day) the Function returns `resource-exhausted` regardless of remaining minutes.

### The admin instruction is an injection surface

Worth stating explicitly: the admin-editable `systemInstruction` can change the assistant's behaviour arbitrarily, including instructing it to ignore guardrails. Blast radius is limited because `config/*` writes are `super_admin` only and audited, but this is precisely why the scope rule and the topic gate are hardcoded rather than admin-editable. Treat the admin field as tone control, not policy control.

## File Structure

```text
functions/src/ai/
├── bodhiChat.ts         # callable: auth, App Check, quota, gate, answer
├── bodhiSession.ts      # callable: start / heartbeat / end
├── openRouter.ts        # thin OpenRouter client (key from Secret Manager)
├── prompt.ts            # hardcoded scope preamble + refusal strings
├── topicGate.ts         # structured-output classifier
└── quota.ts             # transactional accrual on aiUsage/{uid}_{date}

packages/core/lib/src/
├── models/bodhi_ai_config.dart              # freezed, mirrors config/bodhi_ai
├── services/bodhi_ai_functions_service.dart # callable wrapper
├── constants/firestore_collections.dart      # + ConfigDocIds.bodhiAi, aiUsage
├── constants/app_constants.dart              # + fnBodhiChat, fnBodhiSession
└── repositories/config_repository.dart       # + watch/get/saveBodhiAiConfig

apps/admin/lib/features/bodhi_ai/
├── application/bodhi_ai_providers.dart
└── presentation/bodhi_ai_config_page.dart

apps/mobile/lib/features/bodhi_ai/
├── application/bodhi_chat_controller.dart
├── application/bodhi_chat_store.dart        # Hive-backed local history
├── presentation/ask_buddha_screen.dart
└── presentation/widgets/{message_bubble,composer,quota_banner,report_sheet}.dart

apps/mobile/lib/features/profile/presentation/widgets/profile_avatar_button.dart
```

Files modified rather than added: `functions/src/index.ts`, `firebase/firestore.rules`, `apps/mobile/lib/app/{main_shell,router}.dart`, `apps/mobile/lib/features/player/presentation/mini_player.dart`, `apps/mobile/lib/features/home/presentation/home_screen.dart`, the three ARB files, `apps/admin/lib/app/{admin_access,router,admin_shell,admin_strings}.dart`, and `firebase/public_site/privacy/index.html`.

## Navigation Restructure

> **Rebased on commit `0264ca0` ("mobile: persistent donate banner + fixed bottom nav on every screen"), which landed after this design was first written and restructured exactly this area.** The original plan described a `NavigationBar` inside `MainShell`'s `Scaffold` coupled positionally to the shell branches. That is no longer how it works, and the change is favourable — see below.

Current structure after `0264ca0`:

- `MainShell` is now only `Scaffold(body: navigationShell)`. It has **no `bottomNavigationBar`**.
- The visible bar is `PersistentBottomNav`, mounted in the root `MaterialApp.router` builder inside `BottomAppChrome`, so it shows on every ordinary screen rather than only on tab roots.
- `BottomAppChrome` = `DonateSupportBanner` + a 2 px painted gap + `PersistentBottomNav`, assembled in a **`Column`** in `app.dart` with the router content in an `Expanded` above it. The chrome therefore occupies **real layout space**, unlike the mini player which is a `Stack` overlay.
- Visibility is gated by `showDaan` (signed in and past the first onboarding steps) AND `BottomAppChrome.isVisibleFor(router)`, which hides the chrome on `_hiddenExactRoutes` (splash, gates, auth, onboarding, full-screen player) and on `/legal/*`.

**The positional-coupling risk is gone.** `PersistentBottomNav` drives navigation from a plain path list and resolves the active tab by path lookup, not by index:

```dart
const _navRoutes = <String>[ home, buddhistCalendar, prarthana, videos, profile ];
int? _currentIndex() => _navRoutes.indexOf(currentPath) is var i, i < 0 ? null : i;
void _onTap(int i) => router.go(_navRoutes[i]);
```

So adding "Ask Buddha" no longer requires keeping two index-ordered lists in lockstep. Target state:

| Index | `_navRoutes` after |
|---:|---|
| 0 | `/home` |
| 1 | `/buddhist-calendar` |
| 2 | **`/ask-buddha`** |
| 3 | `/prarthana` |
| 4 | `/videos` |
| — | Profile leaves the bar → Home app-bar avatar |

Consequences traced:

- Because the bar calls `router.go(path)` on top-level paths, a destination does not have to be a `StatefulShellBranch`. `/ask-buddha` is still added as a branch so the tab keeps its own stack and state.
- `/profile` is removed from `_navRoutes` and from the `destinations` list, and its shell branch is converted to a pushed top-level route. Everything reachable from Profile (`/profile/edit`, `/language`, `/contact`, `/page`) is already top-level and pushed, so those are unaffected.
- `ProfileScreen` holds no local state (all Riverpod; `statusAvatarProvider` is `keepAlive`), so losing branch state costs only a scroll offset.
- The `push_deep_link.dart` `module: 'profile'` → `/profile` dispatch is **lower risk than originally assessed**: the persistent bar is present on every ordinary screen, so even a `go` that replaces the stack leaves the user with a working escape. Switching it to `push` is still preferred for a proper back arrow (BA-1.4), but it is no longer a stranding bug.
- `PersistentBottomNav` sets `tooltip: ''` on every destination deliberately — it lives above the `Navigator`/`Overlay`, and `NavigationDestination` defaults its tooltip to the label, which would throw "No Overlay widget found". **The new Ask Buddha destination must set `tooltip: ''` too.**
- The bar is height-capped at 62 with `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)`. A longer label than "Ask Buddha" risks overflow at large system fonts; keep the Hindi/Marathi strings short.
- No existing test references `MainShell`, `PersistentBottomNav`, or `NavigationBar`.

### Mini player and keyboard

`MiniPlayer` is mounted in the `MaterialApp.router` builder, outside every `Scaffold`, and clears the nav bar using a hardcoded `_kNavBarHeight = 80` whenever the current location is in a hardcoded `_mainTabRoutes` set. That set contains `AppRoutes.profile` and must be updated: remove profile, add the chat route. Miss this and the mini player floats 80 px up on Profile and overlaps the composer on the chat tab.

Layout constraints after `0264ca0`, which simplify the chat screen considerably:

- **The chat screen does not need to reserve space for the nav chrome.** `BottomAppChrome` is a `Column` sibling of the router content, not an overlay, so the `Expanded` holding the page already excludes the donate banner + gap + nav bar + system inset. `BottomAppChrome.heightOf(context)` exists for things that *are* overlays.
- **The mini player still overlaps page content and still needs clearance.** It is a `Stack` overlay, lifted by `BottomAppChrome.heightOf(context)` in `app.dart` so it floats directly above the chrome — which puts it on top of the page's bottom edge. The message list therefore needs ~64 px bottom clearance whenever media is loaded. Trigger it on "is media loaded" (`currentMediaItemProvider != null`, worth exposing as a small derived provider) rather than on insets.
- **The chrome is keyboard-unaware** — it lives in the root builder at the physical bottom, so the keyboard covers it. Combined with `MainShell`'s `Scaffold` shrinking its body by the full `viewInsets.bottom` (measured from the physical bottom), the page over-reserves by roughly the chrome height while the keyboard is open. That is cosmetic slack, not a bug: content sits a little higher than strictly necessary. Confirm visually in task 7.2.
- `DaanFloatingOverlay` **no longer exists** — `0264ca0` replaced the floating bubble with `DonateSupportBanner` inside the chrome. The old "overlay lands on the send button" problem is gone, which removes the need for task 5.4.

## Client Design

`BodhiChatController` is a Riverpod notifier holding `List<BodhiMessage>`, `remainingSeconds`, and a send/streaming status. It owns:

- session lifecycle — `start` on screen focus, 20 s heartbeat timer, `end` on blur or dispose, driven by an `AppLifecycleListener` so a backgrounded app stops ticking (BA-3.4)
- history truncation before send (last 10 turns)
- Hive persistence (BA-6.3)
- error mapping — `resource-exhausted` → quota sheet with paywall CTA for free users (BA-3.7), `failed-precondition` → App Check hint, `unavailable` → retry

`BodhiAiFunctionsService` follows the existing wrapper pattern exactly: injectable `FirebaseFunctions?`, region from `AppConstants.functionsRegion`, function name from `AppConstants.fnBodhiChat`, `call<Map<Object?, Object?>>` then decode into a typed result. (Note: `premium_controller.dart` deviates from this by calling `'verifyPurchase'` as a string literal with no service wrapper — do not copy that deviation.)

### Streaming — RESOLVED (task 0.1)

Streaming is supported end to end on the versions already resolved in this repo. **No SSE fallback endpoint is needed**; `bodhiChat` stays a normal callable.

Client — `cloud_functions 5.6.2` exposes `HttpsCallable.stream()`:

```dart
Stream<StreamResponse> stream<T, R>([Object? input]);

sealed class StreamResponse {}
class Chunk<T>  extends StreamResponse { final T partialData; }
class Result<R> extends StreamResponse { final HttpsCallableResult<R> result; }
```

Wire contract: the Dart layer maps a `{message: ...}` event to `Chunk<T>` and a `{result: ...}` event to `Result<R>`. So `T` is the type of one `sendChunk` payload and `R` is the type of the function's return value.

Android native path is real, not web-only: `cloud_functions_platform_interface 5.8.2` implements `stream()` over an `EventChannel` (`method_channel_https_callable.dart`), backed by `FirebaseFunctionsStreamHandler.kt` → `httpsCallableReference.stream(parameters)` with a reactive-streams `Publisher<StreamResponse>`. The base `platform_interface_https_callable.dart` throws `UnimplementedError`, so any platform without an implementation fails loudly rather than silently — acceptable.

Server — `firebase-functions 6.6.0` (installed) provides `request.acceptsStreaming` and `CallableResponse.sendChunk`. Its own docs note that `sendChunk` is **a safe no-op when `acceptsStreaming` is false**, so `bodhiChat` can call it unconditionally and degrade to a single non-streamed reply for older clients with no branching.

App Check is compatible: the stream event payload carries `limitedUseAppCheckToken` alongside the same parameters as a unary call.

### Keyboard and insets — RESOLVED (task 0.2)

Read from the Flutter 3.44.8 `Scaffold` source rather than guessed. Two behaviours were in question; both are now settled, and one of them **invalidates the original plan**.

**1. The `NavigationBar` does not ride above the keyboard.** In `_ScaffoldLayout.performLayout`, `bottom` is `size.height` — unaffected by insets — and the bar is placed at `bottomNavigationBarTop = max(0, bottom - bottomWidgetsHeight)`. So it stays pinned to the physical bottom and the keyboard covers it. There is no "nav bar sandwiched between composer and keyboard" problem, and no need for `resizeToAvoidBottomInset: false`.

**2. There is no inset double-counting, because the outer Scaffold strips the inset.** The body slot is registered with:

```dart
removeBottomInset: _resizeToAvoidBottomInset,   // defaults to true
removeBottomPadding: widget.bottomNavigationBar != null || persistentFooterButtons != null,
```

`MainShell`'s `Scaffold` does not override `resizeToAvoidBottomInset`, so it defaults to true and the subtree containing the chat screen is handed a `MediaQuery` with **`viewInsets.bottom == 0`**, while the body itself is shrunk by the keyboard.

**Consequence — correction to the original plan.** The design previously called for an "inset-aware composer" reading `MediaQuery.viewInsets.bottom`. Inside the chat screen that value is **always 0**, so such a check is dead code. The body has already been resized, so the composer simply sits at the bottom of its box.

> **Amended after commit `0264ca0`.** That commit removed the `bottomNavigationBar` from `MainShell` (`Scaffold(body: navigationShell)` only), which changes one half of this finding:
>
> - `removeBottomPadding` is now **false**, so `MediaQuery.padding.bottom` is **preserved** in the chat subtree. An earlier draft of this section said not to rely on it; that no longer holds. In practice the chat screen still should not add bottom safe-area padding, because `BottomAppChrome` already absorbs the system inset below the page — but the reason is the chrome, not a zeroed `MediaQuery`.
> - `bottomWidgetsHeight` is now 0 for `MainShell`, so the body shrinks by `viewInsets.bottom` alone rather than `max(inset, navBarHeight)`.
> - Finding 1 survives unchanged, and for a stronger reason: the bar is no longer inside a `Scaffold` at all, so `_ScaffoldLayout` never positions it. It sits at the physical bottom of a root-level `Column` and the keyboard covers it.
>
> Net effect on the plan: unchanged. No inset math, no `resizeToAvoidBottomInset` override, no manual chrome reservation.

A device pass is still worth doing for visual confirmation at 1.3× text scale (task 7.2), but this is no longer a design risk.

## Compliance

**Privacy Policy (BA-7.1).** Chat text is sent to OpenRouter, a third-party processor outside the Google/Firebase set the current policy discloses. The live policy at `firebase/public_site/privacy/index.html` lists only Google/Firebase services and states that it will not claim inactive services are active — shipping AI chat without amending it makes the policy inaccurate. This is a launch blocker, not a follow-up.

**Play AI-generated content policy (BA-7.2).** Apps with generative AI features are expected to offer an in-app way to report offensive AI output. The existing `contactMessages` collection and its admin inbox give us the reporting sink cheaply: a long-press "Report reply" action on any assistant bubble writes a `contactMessages` doc tagged `type: 'ai_report'` with the offending turn. Verify the current wording on the Play Console policy page before submission rather than trusting this summary.

**Disclosure (BA-7.3).** A persistent, dismissible first-run note stating replies are AI-generated and may be inaccurate. This is a Buddhism app; users may treat answers as doctrinal authority, so the disclaimer matters beyond policy compliance.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Free tier cost at scale | ₹32k/month at 10k DAU free | Kill switch, App Check, OpenRouter spend cap, prompt caching |
| App Check enforcement breaks clients | Chat fails silently on unregistered devices | Close T0.6 first; enforce on this function only |
| Scope jailbreak | Off-brand answers in a religious app | Hardcoded preamble + topic gate + output check |
| Minutes meter mismatches cost | Heavy users cost several× light users | Message cap + token cap as guards; switch meter if caps fire often |
| ~~Streaming unsupported on client~~ | — | **Closed (0.1)**: supported on `cloud_functions 5.6.2` + `firebase-functions 6.6.0`, Android native path verified |
| ~~Nested-Scaffold keyboard breakage~~ | — | **Closed (0.2)**: nav bar stays behind the keyboard, shell zeroes `viewInsets` for the body, no double-count |
| iOS has no entitlement path | Every iOS user is "free" | Pre-existing (`verifyPurchase` is Play-only); out of scope, but do not assume paid tier works on iOS |
| Alias model drift | Untested checkpoint in production | Pin dated slug, never `~...-latest` |
| Admin prompt misuse | Guardrails weakened from the panel | Scope rule hardcoded; `config/*` is super-admin only and audited |
