# Bug audit cross-verification — 2026-09-16

Scope: existing BUGS_AUDIT.md (all 34 entries), with deeper review of Ask Buddha client, server, quota, persistence and billing dependencies. This is a source audit, not a claim that every issue was reproduced on a device or against production.

## Result

- Existing audit: 24 findings supported by code, 7 conditional/overstated findings, 2 product-scope limitations, 1 false positive.
- Newly identified: 8 additional source-supported findings (6 chat, 2 billing).
- Total: **32 source-supported issues**, plus **7 conditional findings**. Of the 32, **19 concern chat directly** (12 in original A section, C3, and 6 new findings).
- Counts are finding-level, following the original grouping; they are not an exhaustive count of every defect in the app.
- No application code changed. Original audit retained for comparison.

Verification: `npm.cmd run lint` in `functions` passed (`tsc --noEmit`). Executed the actual quota.ts code after in-memory TypeScript transpilation with an isolated Firestore transaction stub that commits only on successful callback completion. Reproduced N2 and N3 below; checked off-topic refund as a control. This is not a Firestore emulator/concurrency test. Device, live provider, purchase, and deployed security-rule tests were not run.

## Existing audit: every entry

References below are the source paths cited in the original audit unless an additional path is named.

| ID | Verdict | Cross-check / correction |
| --- | --- | --- |
| A1 | Supported, high | Indexed-stack chat remains mounted; lifecycle listener does not detect tab visibility. Timer continues and app resume can reopen a hidden chat session. Router + AskBuddhaScreen confirm this. Suggested RouteAware fix alone may not detect an indexed-stack branch switch; pass actual branch visibility. |
| A2 | Supported, medium | Controller accepts lang but service payload contains only message/history. Server therefore selects en instructions/refusals. Do not claim all generated answers must be English: prompt explicitly allows the language the user writes in. |
| A3 | Supported, high | reserveMessage commits before answering; answer failure has no compensating refund. |
| A4 | Supported, high | topicGate catches errors as false; caller refunds message but records an off-topic strike. Twenty failures can lock subsequent requests, assuming time quota remains available. |
| A5 | Supported, medium | Prompt requests REFUSAL_SENTINEL but answering path never interprets it. Conditional on model emitting it; response handling defect is present. |
| A6 | Supported, high | Shared Hive box/key has no UID namespace; controller loads it without auth dependency. Profile logout only signs out, with no transcript cleanup. Next account can view and resend prior user's transcript as history. |
| A7 | Conditional | Missing Done with nonempty delta leaves pending=true. Current server returns a map on all successful paths; the proposed non-map terminal result requires a malformed response/mock or contract change. Not established as a normal production failure. |
| A8 | Supported, medium | On error only assistant is removed; user turn is saved and later included as successful context, with no failed/retry marker. Keeping failed text itself is not inherently wrong; unmarked history contamination is the defect. |
| A9 | Supported, medium | remainingMessages is stored but banner uses only seconds. All resource-exhausted errors become quota/paywall, including an upstream 429 from the answering call. Classifier 429 instead follows A4. |
| A10 | FALSE POSITIVE | accrueSession reads and writes the same usage document inside db.runTransaction. Concurrent conflicting transactions cannot both commit from the same old lastTickAt. Slow heartbeats do not prove double-charge. A client in-flight guard can still reduce unnecessary calls. |
| A11 | Supported, medium | Unawaited start/end requests have no sequence/session ID. A delayed end after a new start can close the current session until another heartbeat. Transactions serialize commits, not user lifecycle intent. |
| A12 | Conditional | Client timeout is 90s; two calls each have a nominal 45s fetch timer plus other work. Boundary risk exists, but a slow first call can fail the classifier and skip answering. Also see N4: current timer does not cover response-body reading. No actual 90s device failure reproduced. |
| A13 | Supported, medium | Backend accepts arbitrary finite config numbers, including negative limits, and arbitrary nonempty model strings. Admin-only configuration validation issue, not an ordinary-user privilege escalation. |
| A14 | Supported, low | Router always registers /ask-buddha and does not consult feature flag. Server correctly rejects disabled calls; this is a dead UI route, not bypass of server disablement. |
| A15 | Conditional / overstated | Reporting lacks an explicit visible discoverable control. However GestureDetector(onLongPress) does not establish that TalkBack has no action; framework semantics/accessibility require device testing. Null-UID silent return exists but normal route is authenticated. No policy violation concluded. |
| A16 | Supported, low | Premium notifier initially returns false while its independent user-doc subscription is pending. Chat paywall reads the bool without loading state. Cold-start timing dependent. |
| B1 | Supported, critical | Owner create has no entitlement-field restrictions, while updates do. Auth trigger merges and preserves pre-existing premium fields. New-document race can seed premiumUntil. Create fix must use keys()/field-value checks, not blindly copy update diff(resource.data) when resource does not exist. |
| B2 | Supported, high | Unauthenticated, non-App-Check callable increments a victim-number counter. Five successful calls consume the window and deny the next official-client request. Availability attack; original critical severity overstates impact. |
| B3 | Conditional / overstated | Missing-doc update can fail and is swallowed, but permission request normally requires an onboarded user doc. Token refresh can still race doc creation. Existing granted-permission path calls getToken again; 'retry only on token refresh' is not accurate. |
| B4 | Supported, high | ID-card update checks only new uid, allowing ownership replacement when card ID is known. Delete cannot satisfy request.resource.data.uid. Phase-2 reserved collection limits current UI exposure. |
| B5 | Supported, high | Deletion only enumerates alarms, leaving favourites/progress and separately stored user-associated records such as aiUsage. Correction: fcmTokens inside the deleted user document are deleted with that document. Retention obligations require policy review; no legal compliance conclusion made. |
| B6 | Conditional / misleading scenario | A second device does not by itself imply a different token. Overwriting a genuinely different token can lose the old association, but applying old-token revocation to an independently valid new subscription can also be wrong. Needs explicit subscription ownership/replacement semantics, not simply an array. See N7 for a concrete ownership defect. |
| B7 | Supported, medium | Multicast failure responses do not remove invalid tokens. Reliability/maintenance issue; direct per-token FCM billing increase is not established. |
| B8 | Supported, medium | Platform query caps at 2,000 documents and stops collecting at >=5,000 tokens; remaining audience silently omitted. Topic broadcasts are a different path and not affected by this cap. |
| B9 | Supported, medium | Best-effort alarm-store init can leave app_prefs unopened; later Hive.box accesses are unguarded. Failure remains timing/storage dependent. |
| B10 | Supported, medium | Unknown installed version becomes 0.0.0 and can trigger force-update incorrectly when configured minimum is higher. |
| B11 | Supported, medium | Build initiates async restore while local list empty; clear + sequential puts is not one atomic restore and has no in-flight guard. Original claim that existing alarms are always wiped on rebuild is overstated: empty-store condition limits it. Partial restore can suppress the next restore and leave native sync incomplete. |
| B12 | Conditional | Fallback is indeed first-page-only. However checked-in indexes cover status+sortOrder and individual teacher/category filters for content collections. Missing deployed indexes or combined filters are prerequisites; normal page 2 failure is not established. Admin pagination accusation remains withdrawn. |
| B13 | Supported, medium | _loadIndex publishes mediaItem before setUrl; repeated load failure leaves selected media visible. Empty mediaUrl is filtered from ordinary playContent input, so that particular reproduction is overstated. |
| B14 | Product-scope limitation | PRD explicitly targets Indian users and Android launch; +91 is intentional scope. Claim that every non-Indian number always fails is also wrong: truncation can produce a number accepted by the Indian regex. International support is not counted as a confirmed current requirement defect. |
| B15 | Supported, medium | events create has no shape validation. Correction: aggregation orders by createdAt, so documents missing that field are not guaranteed to be read/deleted and can remain orphaned. No rate limit or event authenticity enforcement. |
| C1 | Conditional / deployment dependent | App Check enforcement on AI functions is intentional; bootstrap comment is stale and UI error handling generic. Actual chat outage depends on device attestation/provisioning. Letting other app features launch is not itself wrong; hard-failing the whole app is not required. |
| C2 | Deferred platform limitation | Model and auth trigger default platform to android; no actual client-platform write found. This would misclassify iOS, but PRD defers iOS. Excluded from current Android bug count. |
| C3 | Supported, low | Scroll runs only after send completes, not after optimistic insertion or delta. Correction: upstream currently uses stream:false and emits one whole answer chunk, so this is not demonstrated token-by-token streaming. Long send/answer can stay out of view. |

## Newly identified findings

### N1 — Clear while sending can corrupt a later answer (high)

Evidence: `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart:130` exposes clear during sending; `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart:184` resets sending to false without cancelling the request. `_updateLastAssistant` at line 155 finds the last assistant globally, with no request/message ID.

Reproduction: send A, clear before completion, send B, then let A finish before B. A overwrites B's placeholder; A's finally resets sending=false while B is still active. Further sends can interleave and overwrite/drop the wrong bubble. Fix with request generations/cancellation and per-message IDs, or disable clear until pending work settles.

### N2 — Exhausted heartbeat rolls back its own usage update (high; isolated reproduction passed)

Evidence: `functions/src/ai/quota.ts:99`, `:131`. Transaction stages usedSeconds, then throws resource-exhausted inside the callback. The staged write does not commit. Client `_tick` also swallows the exception.

Reproduction: usedSeconds=200, limit=210, lastTickAt=20 seconds ago. Heartbeat throws but stored usage remains 200; reserveMessage subsequently accepts a message and reports 10 seconds left. Repeated exhausted heartbeats do not advance usage to the limit. Message cap still applies. Commit exhaustion state and then signal error, or return committed remaining=0.

### N3 — Minute quota depends on optional client heartbeats (high; isolated reproduction passed)

Evidence: `functions/src/ai/quota.ts:164` reserveMessage checks stored seconds but never requires an open session or accrues elapsed time; `functions/src/ai/bodhiChat.ts:69` calls only reservation.

Reproduction: invoke chat without opening/ticking a session, or end the session and continue sending. Message reservations leave usedSeconds=0. Auth and App Check are still required; daily message cap remains enforced. The claimed server-authoritative minute limit is not independently enforced on the answering path. Accrue/check elapsed usage server-side when answering and define an explicit session protocol.

### N4 — Provider timeout stops before response body is read (medium)

Evidence: `functions/src/ai/openRouter.ts:109` clears abort timer when fetch returns headers; `:121` reads response.json afterwards.

Reproduction: upstream returns headers promptly and stalls the JSON body. The 45s abort is already cancelled, so body reading can outlive the advertised request timeout. Keep timer active through body parsing, with cleanup in an outer finally.

### N5 — Empty model response is charged as a successful answer (medium)

Evidence: `functions/src/ai/openRouter.ts:126` defaults missing content to empty string; bodhiChat returns onTopic=true after reservation. Controller settles then removes an empty assistant while returning ok.

Reproduction: valid provider response containing choices=[] or empty message content. User gets no answer or error, and message quota remains consumed. This differs from A3: there is no thrown provider error. Validate nonempty answer and apply a defined retry/refund policy.

### N6 — Midnight refusal refunds a different day's usage (medium)

Evidence: `functions/src/ai/quota.ts:69` recomputes todayKey on each docRef call; reserveMessage and recordOffTopic resolve their own references independently.

Reproduction: reserve just before midnight IST, finish classification as off-topic after midnight. Yesterday's message stays charged; today's usage gets the strike/refund. If today's account already has a counted request, its count is incorrectly decremented. Pass reservation day/document identity into refund and token-accounting operations. Local code path verified; clock-boundary integration test not run.

### N7 — One valid purchase token can grant multiple app accounts premium (high)

Evidence: `functions/src/billing/verifyPurchase.ts:43` checks Play status, then `:57` writes entitlement to request.auth.uid without a unique token-owner check; `functions/src/billing/playRtdn.ts:41` later processes only one matching user. androidPublisher derives status/expiry without binding a Play account identifier to the app user.

Reproduction: two authenticated app accounts submit the same valid active token. Both can receive premium; subsequent RTDN updates find at most one owner. Token possession is required. Use an atomic token ownership record and explicit transfer/restore rules. Not exercised against real purchases.

### N8 — Transient RTDN verification failure is acknowledged as success (high)

Evidence: `functions/src/billing/playRtdn.ts:49` catches fetchSubscriptionStatus failure and returns normally despite comment promising retry; function options do not enable retries.

Reproduction: Play status lookup throws during renewal/revocation notification. Handler resolves without updating entitlement, so this invocation does not signal a failure for retry. A later independent notification/restore might reconcile, but is not guaranteed. Propagate retryable failures and configure bounded retries with idempotent processing.

## Priority

1. Premium create loophole B1, token ownership N7, cross-account chat history A6, OTP lockout B2, ID-card ownership B4.
2. Chat lifecycle A1/A11/N1, quota N2/N3, refund/error handling A3/A4/N5.
3. Deletion B5 and RTDN N8, then language A2, sentinel A5, timeout N4 and date-boundary N6.

Before release, add targeted chat controller tests for clear/send interleaving and auth switching; Firestore-emulator tests for entitlement create and ID-card ownership; quota transaction tests for exhaustion and midnight reservation identity. The current mobile test inventory has no dedicated Bodhi chat tests.
