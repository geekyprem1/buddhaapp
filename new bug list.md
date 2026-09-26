# New Bug List — Dhamma Path

Date: 16 September 2026

Ye consolidated list pichhle code audit ke findings par based hai. Isme naye mile bugs aur purani `BUGS_AUDIT.md` se cross-verified bugs dono hain. Original IDs preserve kiye hain, taaki reports ko compare karna easy ho.

## Summary

| Category | Count |
| --- | ---: |
| Purane audit se code-verified issues | 24 |
| Naye mile code-supported issues | 8 |
| Total code-supported issues | **32** |
| In 32 mein directly chat-related issues | **19** |
| Conditional / additional verification wale findings | 7 |
| Current product scope se bahar limitations | 2 |
| Galat finding / false positive | 1 |

**Verification ka matlab:** source code se defect ka path confirm hua hai; har bug device ya production par reproduce nahi hua. N2 aur N3 isolated transaction checks mein reproduce hue. Backend `npm.cmd run lint` (`tsc --noEmit`) pass hua. Device, live Firebase rules, actual AI provider aur real purchase tests nahi hue. Ye app ke har possible bug ki exhaustive count nahi hai.

## 1. Naye mile bugs — 8

### N1. Pending reply ke beech Clear karne se next answer corrupt ho sakta hai

- **Severity:** High | **Area:** Chat | **Status:** Code-verified.
- **Problem:** Clear button sending ke time bhi enabled hai. Clear `sending=false` kar deta hai, lekin purani request cancel nahi hoti. Reply handler kisi request ID ke bajay last assistant bubble update karta hai.
- **Scenario:** Message A bhejo → Clear karo → Message B bhejo → A ka response aaye. A, B ke bubble ko overwrite kar sakta hai aur B pending hone ke bawajood sending false kar sakta hai.
- **Source:** `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart:130`; `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart:155` aur `:184`.
- **Fix direction:** Request/message IDs aur cancellation/generation guard; alternatively pending send ke dauran Clear disable karo.

### N2. Time exhaust hone par heartbeat apna usage update rollback karti hai

- **Severity:** High | **Area:** Chat quota | **Status:** Isolated check mein reproduced.
- **Problem:** Transaction usage update stage karti hai, phir usi transaction ke andar quota error throw karti hai. Update commit nahi hota.
- **Scenario:** 210 seconds limit mein 200 used hain. 20 seconds baad heartbeat error deti hai, lekin stored usage 200 hi rehta hai. Next message accept hota hai aur 10 seconds remaining dikhata hai. Message cap abhi bhi apply hota hai.
- **Source:** `functions/src/ai/quota.ts:99` aur `:131`.
- **Fix direction:** Exhausted usage commit hone do; error transaction ke baad signal karo ya committed zero remaining return karo.

### N3. Session heartbeat ke bina chat minute quota consume nahi karti

- **Severity:** High | **Area:** Chat quota | **Status:** Isolated check mein reproduced.
- **Problem:** Message reservation stored seconds check karti hai, lekin open session require nahi karti aur elapsed time accrue nahi karti.
- **Scenario:** Session start/tick kiye bina authenticated chat calls bhejo. Messages count badhta hai, usedSeconds zero reh sakta hai. Auth, App Check aur daily message cap bypass nahi hote.
- **Source:** `functions/src/ai/quota.ts:164`; `functions/src/ai/bodhiChat.ts:69`.
- **Fix direction:** Answering path mein server-side time accrual/check aur explicit session protocol enforce karo.

### N4. AI provider timeout response body read hone se pehle band ho jata hai

- **Severity:** Medium | **Area:** Chat reliability | **Status:** Code-verified.
- **Problem:** Fetch headers milte hi abort timer clear ho jata hai; JSON body baad mein read hoti hai.
- **Scenario:** Headers jaldi aayein, body stall ho jaye. Advertised 45-second timeout body read ko stop nahi karega.
- **Source:** `functions/src/ai/openRouter.ts:109` aur `:121`.
- **Fix direction:** Timer ko body parsing complete hone tak active rakho.

### N5. Empty AI answer bhi successful maan kar quota charge hota hai

- **Severity:** Medium | **Area:** Chat response | **Status:** Code-verified.
- **Problem:** Missing/empty content ko empty string banakar success return hota hai. Client empty assistant bubble hata deta hai, user ko error nahi dikhata.
- **Scenario:** Provider `choices=[]` ya empty message content return kare. User ko answer nahi milta, quota phir bhi kat jata hai.
- **Source:** `functions/src/ai/openRouter.ts:126`; `functions/src/ai/bodhiChat.ts`; `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart`.
- **Fix direction:** Nonempty answer validate karo; defined retry/refund handling add karo.

### N6. Midnight cross karne par refusal galat din ka quota refund karta hai

- **Severity:** Medium | **Area:** Chat quota | **Status:** Code-verified; clock-boundary integration test pending.
- **Problem:** Reservation aur refund independently current IST date ka usage document choose karte hain.
- **Scenario:** Request midnight se pehle reserve hui, off-topic result midnight ke baad aaya. Kal ka charge reh jata hai aur aaj ke usage par refund/strike lagta hai. Aaj ki counted request ho to uska count galat decrement ho sakta hai.
- **Source:** `functions/src/ai/quota.ts:69`, `reserveMessage()` aur `recordOffTopic()`.
- **Fix direction:** Reservation ka original day/document reference refund aur token accounting mein pass karo.

### N7. Same valid purchase token multiple app accounts ko premium de sakta hai

- **Severity:** High | **Area:** Billing | **Status:** Code-verified; real purchase test pending.
- **Problem:** Token verify hota hai, lekin unique app-account ownership enforce nahi hoti. RTDN handler matching users mein sirf ek ko update karta hai.
- **Scenario:** Do authenticated app accounts same valid active token submit karein. Dono premium paa sakte hain; later subscription update sirf ek par apply ho sakta hai. Valid token possession required hai.
- **Source:** `functions/src/billing/verifyPurchase.ts:43` aur `:57`; `functions/src/billing/playRtdn.ts:41`.
- **Fix direction:** Atomic token-owner record aur explicit restore/transfer policy.

### N8. RTDN verification failure swallow hone se subscription update miss hota hai

- **Severity:** High | **Area:** Billing | **Status:** Code-verified.
- **Problem:** Play subscription status lookup fail hone par handler normal return karta hai. Comment retry promise karta hai, lekin invocation failure signal nahi karti aur function options retries enable nahi karte.
- **Scenario:** Renewal/revocation notification ke time transient lookup failure ho. Entitlement update nahi hota; later notification/restore se recovery guaranteed nahi hai.
- **Source:** `functions/src/billing/playRtdn.ts:49`.
- **Fix direction:** Retryable errors propagate karo aur idempotent processing ke saath bounded retry configure karo.

## 2. Purane audit se verified chat bugs — 13

| Original ID | Severity | Verified problem | Source |
| --- | --- | --- | --- |
| A1 | High | Chat se doosre tab par jaane ke baad bhi heartbeat aur time charging chalti rehti hai; hidden tab app resume par session reopen kar sakta hai. | `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart`; `apps/mobile/lib/app/router.dart` |
| A2 | Medium | Selected language controller leta hai, lekin request mein bhejta nahi; server English instruction/refusal select karta hai. Har generated answer necessarily English nahi hoga. | `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart`; `packages/core/lib/src/services/bodhi_ai_functions_service.dart`; `functions/src/ai/bodhiChat.ts` |
| A3 | High | Answer call fail hone par reserved message quota refund nahi hota. | `functions/src/ai/bodhiChat.ts`; `functions/src/ai/quota.ts` |
| A4 | High | Classifier outage/invalid response ko off-topic maan kar user ko strike milti hai; enough failures daily lockout kar sakte hain. | `functions/src/ai/topicGate.ts`; `functions/src/ai/bodhiChat.ts`; `functions/src/ai/quota.ts` |
| A5 | Medium | Model `[[OFF_TOPIC]]` emit kare to server usko localized refusal/refund mein convert nahi karta; literal sentinel aur normal charge aa sakta hai. | `functions/src/ai/prompt.ts`; `functions/src/ai/bodhiChat.ts` |
| A6 | High | Hive transcript UID-specific nahi aur logout cleanup nahi; next account prior user's history dekh aur server ko context mein bhej sakta hai. | `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_store.dart`; `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart`; `apps/mobile/lib/features/profile/presentation/profile_screen.dart` |
| A8 | Medium | Failed send ka user bubble unmarked save hota hai aur next request ki history mein include hota hai. | `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart` |
| A9 | Medium | Message limit banner mein nahi dikhti; answering-provider 429 aur off-topic strike limit bhi quota/paywall error ban jate hain. | `apps/mobile/lib/features/bodhi_ai/presentation/widgets/bodhi_quota_banner.dart`; `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart`; `functions/src/ai/openRouter.ts` |
| A11 | Medium | Rapid background/foreground par unawaited start/end requests reorder ho sakti hain; old end new session close kar sakta hai. | `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart`; `functions/src/ai/quota.ts` |
| A13 | Medium | Backend admin config arbitrary finite numbers aur model strings accept karta hai; invalid limits/settings outage ya cost risk create karte hain. Admin-only issue hai. | `functions/src/ai/config.ts` |
| A14 | Low | Feature disabled hone par bhi direct route se chat UI khulti hai. Backend calls correctly reject hoti hain; server disablement bypass nahi hota. | `apps/mobile/lib/app/router.dart`; `apps/mobile/lib/app/app.dart` |
| A16 | Low | Premium status loading ke dauran false hota hai; quota error paid user ko temporary wrong paywall dikha sakta hai. | `apps/mobile/lib/features/premium/application/premium_controller.dart`; `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart` |
| C3 | Low | Auto-scroll send complete hone par hota hai, optimistic insert/delta par nahi; long answer out of view reh sakta hai. Upstream currently full reply ek chunk mein bhejta hai. | `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart`; `functions/src/ai/bodhiChat.ts` |

## 3. Purane audit se verified app-wide bugs — 11

| Original ID | Severity | Verified problem / correction | Source |
| --- | --- | --- | --- |
| B1 | Critical | User document create par premium fields restricted nahi; first-write race mein user future premiumUntil seed kar sakta hai. Update restriction isko protect nahi karti. | `firebase/firestore.rules`; `functions/src/users/onUserCreate.ts`; `packages/core/lib/src/repositories/user_repository.dart` |
| B2 | High | Unauthenticated OTP guard victim-number counter consume karne deta hai; five calls ke baad victim ki next request window ke liye deny ho sakti hai. | `functions/src/auth/guardOtpAbuse.ts` |
| B4 | High | ID-card update sirf new UID check karta hai, existing owner nahi; known card ID par ownership overwrite possible. Delete bhi current rule satisfy nahi karta. Collection Phase-2 reserved hai. | `firebase/firestore.rules` |
| B5 | High | Account deletion favourites/progress subcollections aur separate user-linked records, jaise aiUsage, chhod deti hai. Correction: user document ke andar wale fcmTokens us doc ke saath delete hote hain. | `functions/src/admin/processDeletionRequest.ts`; `functions/src/users/onUserDelete.ts` |
| B7 | Medium | Invalid/unregistered FCM tokens multicast results se prune nahi hote. Direct per-token billing increase establish nahi hua. | `functions/src/notifications/dispatch.ts` |
| B8 | Medium | Platform notification audience 2,000 user docs / token collection cutoff ke baad silently truncate hoti hai; campaign sent mark ho sakta hai. Topic broadcasts is cap se affected nahi. | `functions/src/notifications/dispatch.ts` |
| B9 | Medium | Best-effort init fail/timeout hone par app_prefs unopened reh sakta hai; unguarded Hive.box access crash/error kar sakta hai. | `apps/mobile/lib/app/bootstrap.dart`; `apps/mobile/lib/features/notifications/application/fcm_coordinator.dart`; `apps/mobile/lib/features/splash/application/app_bootstrap.dart` |
| B10 | Medium | Installed version fetch fail hone par 0.0.0 fallback configured force-update gate ko galat trigger kar sakta hai. | `apps/mobile/lib/features/splash/application/app_bootstrap.dart`; `packages/core/lib/src/utils/app_version.dart` |
| B11 | Medium | Build ke andar async alarm restore, in-flight guard ke bina clear + sequential puts karta hai. Interrupted/overlapping restore partial data aur incomplete native sync chhod sakta hai. Existing nonempty alarms har rebuild par wipe nahi hote. | `apps/mobile/lib/features/prarthana/presentation/prarthana_list_screen.dart`; `apps/mobile/lib/features/prarthana/application/alarm_local_store.dart` |
| B13 | Medium | Audio URL load success se pehle mediaItem publish hota hai; repeated load failure stale/unplayable mini-player chhodti hai. Normal playContent empty URLs filter karta hai. | `apps/mobile/lib/features/player/application/dhamma_audio_handler.dart` |
| B15 | Medium | events create par shape validation nahi; malformed/spam events accept ho sakte hain. createdAt missing docs aggregation query se miss hokar persist reh sakte hain. | `firebase/firestore.rules`; `functions/src/counters/aggregateEvents.ts` |

## 4. Conditional / overstated findings — 7, confirmed count mein nahi

| ID | Finding | Cross-verification result |
| --- | --- | --- |
| A7 | Stream bina Done ke pending bubble | Defensive cleanup gap present hai, lekin current server successful calls mein Map return karta hai. Non-Map terminal result/malformed stream scenario ka runtime verification chahiye. |
| A12 | Client timeout server path se chhota | 90s client vs two nominal 45s calls boundary risk hai; slow gate fail ho to answer call skip hoti hai. Actual timeout reproduction pending. N4 separately verified timeout coverage bug hai. |
| A15 | Report action inaccessible / silent failure | Visible report affordance nahi hai, lekin GestureDetector se TalkBack action impossible conclude nahi kar sakte. Accessibility device test chahiye. Null-UID silent return hai, normal route authenticated hai. |
| B3 | FCM token permanently lost | Missing-doc update failure swallow hota hai, lekin permission flow usually existing onboarded user require karta hai. Granted-permission path getToken retry bhi karta hai. Token-refresh race possible hai; original permanent-loss claim overstated hai. |
| B6 | Second device premium token tod deta hai | Second device automatically new token imply nahi karta. Different-token replacement policy investigate karni hai; sirf token array banana sufficient fix nahi. Concrete ownership bug N7 mein listed hai. |
| B12 | Content page 2 index error | First-page-only fallback present hai, lekin normal individual filters ke indexes repo mein hain. Missing deployed index/combined filter prerequisite verify karna hai. Admin query allegation supported nahi. |
| C1 | App Check se chat dead | Failure device attestation/provisioning par depend hai. Bootstrap comment stale aur errors generic hain; AI endpoint App Check enforcement intentional hai. Other app features launch hona apne aap bug nahi. |

In entries ke source paths aur detailed reasoning [BUGS_CROSS_VERIFY.md](BUGS_CROSS_VERIFY.md) mein original IDs ke against hain.

## 5. Confirmed bug count se excluded — 3

| ID | Verdict | Reason |
| --- | --- | --- |
| A10 | False positive | Overlapping heartbeat se claimed double-charge supported nahi. Same usage document read/write Firestore transaction ke andar hai; conflicting transactions same old lastTickAt se dono commit nahi kar sakti. |
| B14 | Product-scope limitation | PRD Indian users ke liye hai, +91 current scope ka part hai. International phone support ko confirmed requirement defect nahi count kiya. Har foreign number necessarily validation fail kare, ye claim bhi incorrect hai. |
| C2 | Deferred platform limitation | Platform default android hai; iOS par misclassification hogi, lekin iOS current launch scope mein nahi hai. Future iOS support mein address karna hai. |

## 6. Suggested fix order

1. **Security/privacy:** B1, N7, A6, B2, B4.
2. **Chat correctness:** A1, A11, N1, N2, N3, A3, A4, N5.
3. **Deletion/billing:** B5, N8.
4. **Chat language/reliability:** A2, A5, N4, N6, A9; phir remaining medium/low issues.

## References aur implementation status

- Original audit: [BUGS_AUDIT.md](BUGS_AUDIT.md).
- Detailed cross-verification: [BUGS_CROSS_VERIFY.md](BUGS_CROSS_VERIFY.md).
- Ye file previous audit ko consolidate karti hai; is document creation ke dauran fresh runtime retesting nahi hui.
- **Is audit/document task mein application bugs fix nahi kiye gaye aur application code change nahi hua.**
