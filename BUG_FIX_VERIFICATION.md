# Bug-fix verification — latest recheck, 16 September 2026

## Latest result — supersedes the previous pass below

**32 baseline findings: 26 original cases addressed, 6 still partial / with a remaining related defect.** This is a local source/test verdict, not a statement that deployed Firebase or the installed app has been verified. The 7 separately conditional findings are not included in those 32 and remain unclosed or require broader verification.

Since the previous pass, these 7 previously incomplete IDs have been addressed:

| ID | Latest evidence |
| --- | --- |
| A1 | Real indexed-shell Flutter test now starts session on first mount, ticks after 21 seconds, stops on tab switch and root imperative push, and resumes on return. |
| A11 | The old disposed-WidgetRef error no longer occurs in the lifecycle test. Dispose uses a service rather than accessing the widget ref later. Slow-network/server reordering across client timeouts is not tested. |
| A6 | Actual Hive test: shared legacy transcript is discarded and is not adopted into account B. This deliberately loses unowned legacy history rather than assigning it to a guessed owner. |
| C3 | Large 150-line pending answer followed to the bottom before send completion in Flutter test. |
| N6 | Both previously missed refund branches now pass charge.day. Invoked actual handler with mocked boundaries and asserted classifier-unknown and sentinel refund arguments. |
| N7 | Legacy users.premiumToken claim is now checked; cross-account legacy claim rejected in isolated handler test. Same owner migrates to deterministic SHA-256 ownership doc. Concurrent claims use one document in a transaction, source verified but not emulator concurrency-tested. |
| B15 | Rules now reject empty/slash-containing/overlong IDs; aggregator also skips bad IDs and catches reference-construction errors before proceeding to cleanup. Source verified, rules deployment/emulator test not run. |

### Remaining 6 findings

| ID | Severity | What still prevents closure |
| --- | --- | --- |
| N3 | High | Minute charging remains bypassable by ending a session just after reservation. New lastAnswerAt guard only helps when answered >= cursor; end advances cursor beyond the answer timestamp even when less than one whole second elapsed. |
| B5 | High | RTDN reads user existence/token and later calls set(merge:true) outside a transaction. Deletion between read and write still recreates the user. The stale-token guard has the same check/write race with a concurrent purchase change. |
| B2 | High | Attested callers can still spend five requests on a victim number. IP limit is 30. New logging documents the risk but does not stop the lockout; source explicitly labels it residual. |
| A13 | Medium | Model validation still checks syntax only; nonexistent vendor/model slug is accepted. Numeric clamps are fixed. |
| B11 | Medium | Native-sync recovery now has a fingerprint, but it contains only IDs, not alarm settings. Same-ID changed alarms can remain stale. replaceAll also still deletes stale IDs before writing replacements, so all-new-ID replacement can have an empty intermediate state on failure/crash. |
| B13 | Medium | Concurrent load-vs-load generation handling improved. stop() still does not advance _loadGeneration: a pending/retrying load can remain current after Stop and later retry/play. Source-supported residual; audio-platform race not exercised on a device. |

### Reproduced remaining paths

**N3:** execute start → reserveMessage → advance mocked time by 10ms → end → advance 60 seconds; repeat three times. Actual quota.ts code recorded **3 messages and 0 usedSeconds**. End's cursor is later than lastAnswerAt, so the next start does not charge the gap. Auth/App Check/message limits still apply. Source: `functions/src/ai/quota.ts:130`, `:154`, `:253`.

**B5:** actual RTDN handler with mocked persistence: return an existing user snapshot, simulate deletion immediately after that read, then let handler continue. The final merge write recreated the document. Source: `functions/src/billing/playRtdn.ts:76` and `:91`. Ordinary already-missing-user case now correctly returns without recreation. Use an atomic check/update (and a write that cannot create a deleted document); include the current-token guard in the same atomic operation.

**B11 locations:** `apps/mobile/lib/features/prarthana/presentation/prarthana_list_screen.dart:46` fingerprints only sorted IDs; `apps/mobile/lib/features/prarthana/application/alarm_local_store.dart:71` deletes before `putAll`. The new retry fingerprint does help the previous native-sync failure case, but does not cover all data changes or crash consistency.

**B13 locations:** `apps/mobile/lib/features/player/application/dhamma_audio_handler.dart:165` defines generation; `:193` checks before retry; `:309` stop never invalidates it; `:97` plays when load returns true. A pending load therefore needs invalidation when playback is explicitly stopped, not just when another load begins.

### Latest checks

- Backend TypeScript lint: **passed**.
- Flutter analyzer on changed chat, alarms, audio, premium and router areas: **no issues**.
- Flutter focused recheck plus existing bootstrap suite: **10/10 tests passed** (3 recheck tests + 7 bootstrap tests).
- Isolated TypeScript controls: exhaustion still commits (N2), both day-bound refunds pass (N6), legacy token claim rejection/migration pass (N7), ordinary missing-user RTDN guard passes (B5).
- Two negative isolated checks still reproduce the N3 bypass and B5 deletion race above.
- Other conditional issues and additional notes from the earlier pass remain relevant: missing terminal chat event, 90s total timeout, report accessibility, FCM token retry, content indexes, App Check provisioning, premium auth-switch lifecycle, failed-send restoration overwriting a newer draft, and hardcoded quota text.
- Temporary Flutter test source removed after the check. No application implementation changes or deployment performed by this review.

---

## Historical previous pass — not the latest status

Reviewed the current uncommitted working-tree changes against every entry in [new bug list.md](new%20bug%20list.md).

## Verdict

**No, all bugs are not fixed.** Of the 32 previously code-supported findings:

- **19: original reported case addressed in source** (not a production certification).
- **13: partial fix / remaining gap / regression in the affected flow.**
- The 7 previously conditional findings still need closure/verification.
- A10 remains a false positive; B14 and C2 remain excluded product-scope limitations.

The 13 partial IDs are **N3, N6, N7, A1, A6, A11, A13, C3, B2, B5, B11, B13, B15**. Related defects are grouped under the original ID rather than counted as separate new bugs. These statuses include regressions in a fix, not only the unchanged original symptom.

## Verification performed

- Backend `npm.cmd run lint`: passed (`tsc --noEmit`).
- Flutter analyzer for changed mobile areas: passed, no issues found.
- Existing splash/bootstrap tests: **7 passed**, including the new unknown-version force-update tests.
- Temporary focused Flutter checks against actual app classes:
  - **Reproduced A6:** legacy account A transcript was loaded and persisted under account B's key.
  - **N1 control passed:** delayed A answer after Clear did not overwrite B or reset B's sending flag.
  - First chat mount showed no start/heartbeat after 21 simulated seconds. Test teardown then **failed with `Bad state: Cannot use "ref" after the widget was disposed`** at `ask_buddha_screen.dart:124`.
  - **Reproduced route issue:** after `router.push('/premium')`, displayed page was Premium but `currentConfiguration.uri.path` remained `/ask-buddha`.
  - Runner result: 3 passed / 1 failed. Some passing tests intentionally assert the presence of a defect; they do not mean that defect is fixed.
- Isolated checks execute the actual TypeScript source after in-memory transpilation with mocked external boundaries:
  - N2: exhausted heartbeat committed 220 used seconds and the next send rejected.
  - N3: ordinary sessionless second send accrued 20 seconds; repeated start/reserve/end cycles still consumed three messages at zero seconds.
  - N5: empty answer refunded its original day and returned `unavailable`.
  - N6: explicit off-topic path passed original day; classifier-unknown and sentinel refund paths did not.
  - N7: an existing `users/A.premiumToken` without a new ownership record was accepted for B; both retained premium. Once ownership existed, a subsequent C verification was rejected.
  - N8: retry flag present and lookup failure propagated.
  - B5: retained purchase owner allowed RTDN to recreate a deleted user document.
  - A13: numeric clamps worked; a nonexistent but well-formed vendor/model slug was accepted.
  - B2: five handler calls for the victim number caused a later call from a different IP to reject. App Check is enabled at the wrapper; this demonstrates residual behavior for callers that pass attestation, not bypass of App Check.
  - B15: installed Firestore SDK rejects empty/invalid document paths synchronously; current rules only require `itemId is string`.

These are local checks, not live provider/Play tests or Firestore-emulator transaction/rule tests. Deployed rules/functions/indexes and installed APK were not inspected. Temporary Flutter test source was removed after verification; application implementation was not changed by this review.

## All 32 original findings

| ID | Status | Evidence / remaining scope |
| --- | --- | --- |
| N1 | Addressed | Generation checks protect incoming events, error paths and finally against Clear/new send/account rebuild. Actual delayed-response control passed. Malformed stream termination remains tracked separately as A7. |
| N2 | Addressed | accrueSession throws after transaction commit. Isolated exhaustion test passed. |
| N3 | Partial | reserveMessage now accrues elapsed time, but start still resets lastTickAt without charging. Immediate start/reserve/end around a slow answer can keep seconds at zero. Message cap, auth and App Check still apply. |
| N4 | Addressed | Provider abort timer remains active through response.json and is cleared in outer finally. Source verified; no live stalled-provider request made. |
| N5 | Addressed | Empty content throws unavailable inside answer try/catch and refund uses charge.day. Isolated test passed. |
| N6 | Partial | Explicit off-topic and answer-error paths pass charge.day; unknown-classifier and answer-sentinel refunds omit it. Cross-midnight accounting remains wrong for those branches. |
| N7 | Partial | New ownership checks prevent sequential reuse after an ownership record exists. Existing users.premiumToken grants are not checked/migrated before claiming a token; legacy reuse still grants two accounts. Concurrent empty-query claims were not emulator-tested. |
| N8 | Addressed | retry:true and thrown lookup error replace swallowed failure. Isolated failure propagation passed. Actual retry policy/deployment not verified. |
| A1 | Partial / regression | Branch listener added, but first visible mount returns early without starting session; imperative pushes leave base configuration URI unchanged, so covered chat can remain charged. |
| A2 | Addressed | lang now flows controller → streamMessage/sendMessage → payload → backend. |
| A3 | Addressed | Answer exceptions compensate the message reservation with original-day refund. Not a guarantee against a process kill or a separate refund-write failure. |
| A4 | Addressed | Classifier failure is unknown and refunds without a strike. It still displays an off-topic refusal rather than an outage explanation; misleading UX remains, but original outage-induced strike lockout is removed. |
| A5 | Addressed | REFUSAL_SENTINEL is detected and replaced with localized refusal/refund. Midnight flaw is counted under N6. |
| A6 | Partial | UID namespacing and auth-dependent reload exist, but unowned shared legacy history is adopted by whichever account loads first. Actual Hive test reproduced cross-account exposure. |
| A8 | Addressed | Error handling removes the failed user turn before saving. Screen restores input for retry. Separately, unconditional retry restoration can replace a new draft typed during the request; see additional notes. |
| A9 | Addressed | Banner includes remainingMessages and reason tags distinguish message/time limits, strike lockout and upstream rate limiting. New text is hardcoded English; layout/localization needs UI QA. |
| A11 | Partial / regression | Future chain sequences normal calls, but dispose queues a future that reads WidgetRef after disposal. Actual Flutter teardown failed. Already queued heartbeats also remain queued after timer cancellation. |
| A13 | Partial | Numeric clamps implemented. Regex only validates model slug syntax; nonexistent vendor/model still accepted and can disable answering. |
| A14 | Addressed | Router listens to feature config and redirects disabled Ask Buddha route to home. Loading config also behaves as disabled; this can discard a cold deep link and should be a deliberate UX choice. |
| A16 | Addressed for original cold-start case | Chat only opens paywall when premiumReady is true. Premium ready/account listener lifecycle is still not reset/reattached on auth changes; original cold-start race is guarded but account-switch behavior needs separate work. |
| C3 | Partial | State listener added, but near-bottom check happens after new layout. A large response can increase maxScrollExtent by >200px, making a previously bottom-aligned user fail the guard. send completion still scrolls as before. |
| B1 | Addressed in rules source | User create now forbids entitlement fields. Existing exploited records are not repaired. Rule deployment/emulator verification pending. |
| B2 | Partial | App Check and IP throttle added. Attestation is not proof of number ownership, and IP threshold 30 still permits the 5 calls needed to lock one victim. Residual handler behavior reproduced. |
| B4 | Addressed in rules source | Create/update/delete separated; update checks both old and new owner, delete checks old owner. Deployed rules not verified. |
| B5 | Partial / regression | Both deletion paths now remove alarms/favourites/progress and aiUsage/contactMessages. New purchaseTokens ownership records remain, and RTDN unconditionally set(merge:true) can recreate deleted users. |
| B7 | Addressed | Multicast permanent-token errors collected by owner and arrayRemove used to prune. Source verified; no live push sent. |
| B8 | Addressed | Platform audience now cursor-paginates without previous document/token cutoffs. Large-audience execution time/memory and deployed index remain untested. |
| B9 | Addressed for original unopened-box access | Permission getter checks isBoxOpen, permission writes open on demand, optional cache reads/writes guarded. Persistent Hive initialization/storage failure can still fail permission operations; not a universal storage recovery guarantee. |
| B10 | Addressed | versionKnown=false skips force-update comparison but preserves maintenance. Both new tests passed. |
| B11 | Partial | Restore guard and batched writes reduce repeated-build races. If native sync fails after local write, retry sees nonempty store and skips native sync forever. replaceAll still deletes stale entries before putAll, so the comment promising no empty intermediate state is too strong. |
| B13 | Partial | Single final load failure clears mediaItem and shared retry flag removed. Concurrent loads have no generation guard: older failure can clear newer successful mediaItem; older retry can reload an obsolete track. |
| B15 | Partial | Collection/type/timestamp checks added. Empty itemId or invalid path string still allowed; aggregator doc(itemId) throws before its update catch and before event deletion, allowing an oldest event to keep poisoning the batch. No rule/emulator test executed. |

## Most important remaining defects and exact locations

### 1. First chat mount does not start the session; pushed page is not detected

- `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart:44` initializes `_routeVisible=true`.
- At `:87`, initial actual visibility=true causes early return. No `_refreshSession`, start or heartbeat is scheduled until a later visibility/lifecycle transition.
- At `:86`, `currentConfiguration.uri.path` is the base route. Installed go_router 14.8.1 explicitly excludes imperative matches from this URI; actual router test confirmed Premium push leaves it at `/ask-buddha`.
- Fix direction: initialize/apply activity state once and track the actual top route/branch visibility, including pushes.

### 2. Session cleanup reads ref after disposal

- `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart:124`: `_sessionChain.then((_) => _controller.endSession())` executes after disposal; `_controller` reads WidgetRef at `:53`.
- Actual error: `Bad state: Cannot use "ref" after the widget was disposed`.
- Fix direction: capture a safe service/session owner before disposal; lifecycle cleanup must not later access a disposed widget or notifier.

### 3. Legacy transcript privacy leak remains

- `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_store.dart:59`–`:64` loads shared `messages` when UID-specific key absent and immediately returns that content.
- `_adoptLegacy` at `:97` writes it under current UID without evidence of original ownership.
- Reproduced: seed legacy account A question, load account B, and inspect B's namespaced value: A's private content is present.
- Fix direction: do not attach unowned legacy history to an arbitrary signed-in account; require trusted ownership evidence or discard/quarantine legacy content.

### 4. Two refund paths still ignore reservation day

- `functions/src/ai/bodhiChat.ts:82`: classifier-unknown refund missing `day: charge.day`.
- `functions/src/ai/bodhiChat.ts:152`: sentinel refund missing the same field.
- Both omissions verified by invoking actual handler with mocked quota boundary and inspecting refund arguments.

### 5. Minute enforcement is still resettable through session calls

- `functions/src/ai/quota.ts:117` skips accrual for start; `:134` still resets lastTickAt.
- Reproduced immediate start/reserve/end, then advancing clock a minute, repeated three times: three messages, zero usedSeconds. A real caller can close before a slow answer completes. Message cap remains effective.
- Fix direction: define server-owned active intervals/minimum charges and prevent start from discarding accrued time; enforce against answering time independent of optional client lifecycle.

### 6. Billing migration and account deletion are incomplete

- `functions/src/billing/verifyPurchase.ts:66` only queries purchaseTokens, ignoring a legacy users.premiumToken claim.
- `functions/src/lib/userDeletion.ts:22` only lists aiUsage/contactMessages; purchaseTokens ownership remains after erasure.
- `functions/src/billing/playRtdn.ts:64` selects the retained owner UID; `:82` set(merge:true) recreates a missing user.
- Both legacy double-grant and deleted-document recreation reproduced with actual handlers and mocked persistence.
- Fix direction: establish ownership for existing grants, define retention/tombstone policy for purchase ownership, and prevent RTDN from resurrecting erased accounts.

### 7. Malformed event can prevent aggregation cleanup

- `firebase/firestore.rules:250` only checks itemId is a string.
- `functions/src/counters/aggregateEvents.ts` constructs `db.collection(collection).doc(itemId)` outside the update try/catch and before deleting events.
- Empty string and `x/y` both throw with the installed SDK. A correctly shaped event with such an ID passes the current field predicates but can block the scheduled batch.
- Fix direction: validate a nonempty single-segment ID with length bounds and defensively reject/delete malformed events before reference creation.

## Conditional and excluded findings

| ID | Current status |
| --- | --- |
| A7 | Still open as defensive gap: no terminal Done + nonempty delta can remain pending; no done-received fallback was added. |
| A12 | Still conditional: client timeout remains 90s and two upstream request budgets remain 45s each. Body timer N4 improved, not total budget alignment. |
| A15 | Unchanged: long-press report UI and null-UID silent return remain; accessibility device testing still required. |
| B3 | Unchanged: FCM token update failure still swallowed; prior caveats about existing retry paths still apply. |
| B6 | Not closed: new ownership records retain old tokens, and RTDN now uses them without checking the currently effective subscription. An old-token expiry can overwrite a newer valid token's entitlement. Multiple-subscription policy is unresolved. |
| B12 | Unchanged: first-page-only content fallback remains; added index is for users.platform, not combined content filters. Actual missing-index deployment condition not checked. |
| C1 | Unchanged: best-effort App Check bootstrap and stale comment remain. OTP now also enforces App Check, so provisioning failure can affect OTP too. Actual device configuration not checked. |
| A10 | Still excluded: original double-charge claim ignored Firestore transaction conflict handling. |
| B14 | Still excluded: Indian phone scope is intentional. |
| C2 | Still excluded: deferred iOS platform support. |

## Additional review notes

- Chat failed-send restore at `ask_buddha_screen.dart:149` calls `_fill(text)` unconditionally. Composer stays editable while sending, so a new draft typed during the request can be replaced by the failed previous question.
- Premium ready becomes true on first user snapshot but is not reset on auth switch; premium controller still does not subscribe to auth changes. Do not treat the cold-start guard as full account-switch correctness.
- Classifier unknown still shows an off-topic refusal even for valid questions. Lockout is fixed; outage messaging is not.
- Newly introduced quota text uses hardcoded English and a non-flexible Row/Text. Hindi/Marathi, small screens and large font sizes need visual checks before declaring UI complete.

Suggested order: session startup/disposal and legacy privacy first; then quota/day accounting and purchase/deletion migration; then OTP, event validation, restore/load races and scroll behavior. No fixes or deployment were performed during this verification.
