# Bugs Audit — Dhamma Path (New Buddha APP V2)

> Date: 2026-09-16
> Scope: `apps/mobile`, `packages/core`, `packages/design_system`, `functions/`, `firebase/firestore.rules`
> Method: har bug ko code re-read karke verify kiya gaya. Format: `file:line` + severity + symptom + reproduce + fix hint.
> Status: 33 VERIFIED, 1 PARTLY-CORRECTED (content admin pagination).

Severity legend: CRITICAL = security / paisa / data-loss. HIGH = quota-theft / privacy. MEDIUM = UX / reliability / cost. LOW = polish / a11y.

---

## PART A — Ask Buddha Chat (16 bugs, sab VERIFIED)

### A1. Tab switch par bhi session charging hota rehta hai — HIGH [VERIFIED]
- **File:** `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart:44-61` + `apps/mobile/lib/app/router.dart:213-260`
- **Kya hota hai:** `AskBuddha` ek `StatefulShellBranch indexedStack` tab hai. Tab badalne par `dispose()` call nahi hota, `AppLifecycleListener(onInactive)` bhi fire nahi hota (sirf app background par). 20s wala heartbeat `Timer` chalta rehta hai, `usedSeconds` badhta rehta hai.
- **Reproduce:** Chat kholo > Videos tab jao > 60s ruko > `aiUsage/{uid}_{yyyy-MM-dd}` me `usedSeconds` badha मिलेगा.
- **Fix:** `RouteAware` / `ModalRoute.of(context).isCurrent` / `didPushNext/didPopNext` se hide par `endSession()`, show par `start()`.

### A2. `lang` collect hota hai, bheja hi nahi jata — MEDIUM [VERIFIED]
- **File:** `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart:84,99-102` + `packages/core/lib/src/services/bodhi_ai_functions_service.dart:102-107,115-122` + `functions/src/ai/bodhiChat.ts:56-58`
- **Kya hota hai:** `_submit()` language nikalta hai, `send(text, lang)` leta hai, lekin `streamMessage(message, history)` me `lang` pass hi nahi hota. `_payload` sirf `{message, history}` bhejta hai. Server hamesha `lang="en"` default karta hai. Refusal + scope preamble hamesha English.
- **Reproduce:** App Hindi me rakho, off-topic sawal bhejo → English refusal.
- **Fix:** `streamMessage` / `sendMessage` + `_payload` me `lang` add karo.

### A3. Fail hone par bhi message quota kat jata hai — HIGH [VERIFIED]
- **File:** `functions/src/ai/bodhiChat.ts:69,100-117`
- **Kya hota hai:** `reserveMessage()` pehle `messages+1` kar deta hai. `chatCompletion()` throw kare (timeout/5xx/key dead) to refund ka koi path nahi. Refund sirf off-topic ke liye (`recordOffTopic`) hai.
- **Reproduce:** `OPENROUTER_API_KEY` todo-do > send > error > `messages` increment mila.
- **Fix:** Answer call ko `try/catch` me lapet ke compensating decrement karo, ya reserve successful answer ke baad karo.

### A4. Classifier outage innocent users ko lock karta hai — HIGH [VERIFIED]
- **File:** `functions/src/ai/topicGate.ts:32-49` + `functions/src/ai/bodhiChat.ts:72-78` + `functions/src/ai/quota.ts:171-176`
- **Kya hota hai:** `isOnTopic()` `catch → false` (fail-closed). Caller har `false` par `recordOffTopic()` (+1 strike) karta hai. 20 provider hiccup = `strikes>=20` = `resource-exhausted` lockout.
- **Reproduce:** Invalid model/key rakho, 20 on-topic sawal bhejo → "too many off-topic" lock.
- **Fix:** Classifier-error ko true off-topic se alag karo — `unavailable` throw karo, strike mat do.

### A5. `REFUSAL_SENTINEL` dead code hai — MEDIUM [VERIFIED]
- **File:** `functions/src/ai/prompt.ts:20,48-51` vs `functions/src/ai/bodhiChat.ts:100-124` (koi reference nahi)
- **Kya hota hai:** Model ko bola gaya off-topic par `EXACTLY [[OFF_TOPIC]]` bheje, lekin server usko check hi nahi karta. User ko literally `[[OFF_TOPIC]]` dikhega, `onTopic:true` + full charge ke saath.
- **Reproduce:** Model se sentinel emit karwao (jailbreak/off-topic) → literal text dikhega.
- **Fix:** `if (content.contains(REFUSAL_SENTINEL))` → localised `refusalMessage()` + gate-jaisa refund.

### A6. Chat transcript cross-user leak — HIGH (privacy) [VERIFIED]
- **File:** `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_store.dart:43-77` + `bodhi_chat_controller.dart:70-72`
- **Kya hota hai:** Hive box `bodhi_chat`, key `messages` me `uid` nahi hai. `build()` bina uid check load karta hai.
- **Reproduce:** User A chat > logout > User B login same device > A ki history dikhegi.
- **Fix:** Key `messages_$uid` karo, logout par clear.

### A7. Stream bina `Done` ke atka bubble chhodta hai — MEDIUM [VERIFIED]
- **File:** `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart:120-124` + `packages/core/lib/src/services/bodhi_ai_functions_service.dart:133-139`
- **Kya hota hai:** `Done` sirf `if (data is Map)` par yield hota hai. Shape alag hua aur `buffer.isNotEmpty` to cleanup skip — last bubble `pending:true` permanent. Report disabled, `_history()` aur `save()` se exclude.
- **Reproduce:** Callable string chunks + non-Map result mock karo → bubble kabhi settle nahi hoga.
- **Fix:** Loop ke baad agar `Done` nahi aaya to last bubble `pending:false` karo ya error/drop treat karo.

### A8. Failed send orphan user bubble chhodta hai — MEDIUM [VERIFIED]
- **File:** `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart:89-94,125-134`
- **Kya hota hai:** User turn optimistic add hota hai. `quotaExhausted/disabled/error` par assistant placeholder drop hota hai, user turn reh jata hai aur `finally { save() }` usko persist kar deta hai. Restart ke baad bina jawab ka sawal dikhta hai, next `_history()` me bhi jata hai.
- **Reproduce:** Quota exhaust karke send karo > akela user bubble > restart > abhi bhi wahi.
- **Fix:** Non-ok/refused par just-added user turn hatao ya failed turns `save()` mat karo.

### A9. Message-cap invisible + galat paywall mapping — MEDIUM [VERIFIED]
- **File:** `functions/src/ai/quota.ts:177-188` + `apps/mobile/lib/features/bodhi_ai/presentation/widgets/bodhi_quota_banner.dart:11-28` + `bodhi_chat_controller.dart:138-147` + `functions/src/ai/openRouter.ts:115` + `ask_buddha_screen.dart:83-89`
- **Kya hota hai:** (a) Banner sirf `remainingSeconds` dikhata hai. `freeDailyMessages:15` khatam ho sakta hai jab banner `3:00 left` bole. (b) Har server `resource-exhausted` (message-cap, 20 strikes, upstream OpenRouter 429) `BodhiSendOutcome.quotaExhausted` me map hota hai → non-billing error par bhi paywall khulta hai.
- **Reproduce:** Time bacha ke 15 quick messages bhejo → paywall; ya 429 force karo → paywall.
- **Fix:** Alag codes (`message-limit`, `off-topic-limit`, upstream `unavailable`), banner me message count, paywall sirf true quota par.

### A10. Overlapping heartbeat double-charge — MEDIUM [VERIFIED]
- **File:** `ask_buddha_screen.dart:54` + `bodhi_chat_controller.dart:167-182` + `functions/src/ai/quota.ts:108-112`
- **Kya hota hai:** `Timer.periodic(20s)` `_tick` ka wait nahi karta. Slow network par concurrent `accrueSession` same `lastTickAt` padh ke same elapsed dono add karenge (20s ka 40s charge). `IDLE_CAP_SECONDS=30` hone ke bawajood double-count hota hai.
- **Reproduce:** Network 25s throttle karke chat khula rakho → parallel `bodhiSession` calls.
- **Fix:** `_ticking` guard ya `await` ke baad recursive `Timer` schedule karo.

### A11. start/end race on quick background/foreground — MEDIUM [VERIFIED]
- **File:** `ask_buddha_screen.dart:51-61`
- **Kya hota hai:** `_openSession()` / `_closeSession()` `unawaited()`. Rapid `onInactive → onResume` me `end` phir `start` ka network order invert ho sakta hai, `quota.ts:124 sessionOpen` galat state me.
- **Fix:** Chained future / generation counter se serialize karo.

### A12. Client timeout worst-case server path se chhota — MEDIUM [VERIFIED]
- **File:** `packages/core/lib/src/services/bodhi_ai_functions_service.dart:100` (90s) vs `functions/src/ai/openRouter.ts:13` (45s × 2 sequential: gate + answer)
- **Kya hota hai:** 45s + 45s + Firestore/premium reads 90s cross kar sakta hai. Client `deadline-exceeded` ke baad bhi server quota kata chuka hota hai + dono model calls ka bill laga chuka hota hai.
- **Fix:** `_chatTimeout` ~120s karo ya gate timeout chhota karo.

### A13. Unvalidated admin config — cost/availability footgun — MEDIUM [VERIFIED]
- **File:** `functions/src/ai/config.ts:30-60`
- **Kya hota hai:** `num()` har finite number, `str()` har non-empty model accept karta hai. Typo (`maxTokens:100000`, `temperature:9`, `model:"foo"`) → outsized bill ya total outage.
- **Fix:** `maxTokens` clamp (e.g. 50–2000), `temperature` 0–2, `model` allowlist + safe fallback.

### A14. Disabled feature deep-link se reachable — LOW [VERIFIED]
- **File:** `apps/mobile/lib/app/router.dart:235-242` + `apps/mobile/lib/app/app.dart:34-35`
- **Kya hota hai:** `bodhiAiEnabled` sirf bottom-nav tab chhupata hai. `/ask-buddha` branch hamesha registered, `redirect` me koi check nahi. Firestore me disabled karke bhi `go('/ask-buddha')` se full composer khulta hai; har action `failed-precondition` dega.
- **Fix:** `redirect` me guard: `!bodhiAiEnabled && path==askBuddha → home`.

### A15. Report action undiscoverable + silent failure — LOW [VERIFIED]
- **File:** `apps/mobile/lib/features/bodhi_ai/presentation/widgets/bodhi_message_bubble.dart:49-55` + `bodhi_report_sheet.dart:47-49`
- **Kya hota hai:** Report sirf `onLongPress` par, koi button/tooltip/`Semantics` nahi — TalkBack users ko nahi milega (Play generative-AI flagging requirement risk). `uid==null` par silent return, koi snackbar nahi.
- **Fix:** Visible report affordance + semantics; `uid==null` par snackbar.

### A16. Paid-vs-free paywall race on cold start — LOW [VERIFIED]
- **File:** `ask_buddha_screen.dart:86-89` + `premium_controller.dart:40-61`
- **Kya hota hai:** `premiumControllerProvider.build()` user-doc stream resolve hone tak `false` return karta hai. Us window me quota error paid user ko bhi `ensurePremium` paywall dikhata hai.
- **Fix:** Paywall decision se pehle premium loading state ka wait/observe karo.

---

## PART B — App-wide (mobile + core + functions)

### B1. `users/{uid}` create par self-grant premium — CRITICAL [VERIFIED]
- **File:** `firebase/firestore.rules:41-46` + `functions/src/users/onUserCreate.ts:30-47` + `packages/core/lib/src/repositories/user_repository.dart:44-68` + `apps/mobile/lib/features/premium/application/premium_controller.dart:77-80`
- **Kya hota hai:** `update` `premiumUntil/premiumToken/premiumState/premiumUpdatedAt` block karta hai, `allow create: if isOwner(uid)` me koi field check nahi. Fresh user SDK/REST se `premiumUntil=future` ke saath pehla write jeet sakta hai. `onUserCreate` un fields ko chhuta hi nahi (`merge:true`) aur `ensureUserDocument` `exists→return` — dono exploit ko preserve karenge. Controller future `premiumUntil` ko premium manta hai.
- **Reproduce:** Naya auth user pehle `users/{uid}` `premiumUntil=future` ke saath set kare (Function se pehle) → premium mil jayega.
- **Fix:** `create` par bhi same `!affectedKeys().hasAny([...])` guard lagao.

### B2. `guardOtpAbuse` victim-keyed lockout — CRITICAL [VERIFIED]
- **File:** `functions/src/auth/guardOtpAbuse.ts:24-64` + `apps/mobile/lib/features/auth/application/auth_controller.dart:22-40`
- **Kya hota hai:** No `auth`/AppCheck (comment khud kehta hai). Counter key victim ka number hai. Koi bhi 5 calls karke victim ko 15 min (`WINDOW_MS`, `MAX_REQUESTS`) `resource-exhausted` de sakta hai. `sendOtp` guard ke bina aage nahi badhta.
- **Reproduce:** `guardOtpAbuse {phoneNumber:"+91 victim"}` ×5 → victim OTP nahi maang payega.
- **Fix:** `enforceAppCheck:true` + per-IP throttling, failed/invalid ko same tarah count mat karo.

### B3. FCM token chup-chaap drop — MAJOR [VERIFIED]
- **File:** `packages/core/lib/src/repositories/user_repository.dart:170-177` + `apps/mobile/lib/features/notifications/application/fcm_coordinator.dart:126-132`
- **Kya hota hai:** `addFcmToken` `.update()` use karta hai (doc missing par throw); `_saveToken` `catch(_){}` swallow karta hai. Permission `ensureUserDocument`/`onUserCreate` se pehle grant hua to token lost, retry sirf next refresh par.
- **Fix:** `.set(..., SetOptions(merge:true))` + next login par retry.

### B4. Koi bhi kisi ka ID card overwrite kar sakta hai — MAJOR [VERIFIED + nuance]
- **File:** `firebase/firestore.rules:185-189`
- **Kya hota hai:** `allow write: if isSignedIn() && request.resource.data.uid == request.auth.uid` sirf **naya** data check karta hai, `resource.data.uid` (purana owner) kabhi nahi. `cardId` pata/gess ho to victim ka card overwrite karke `uid` self kar do. Nuance: `write` me `delete` bhi aata hai, par delete me `request.resource` null hota hai → rule error → deny. Matlab owner apna card **delete bhi nahi** kar sakta, lekin attacker update kar sakta hai.
- **Fix:** Update/delete par `resource.data.uid == request.auth.uid` mandatory karo (create-only carve-out ke saath).

### B5. Deletion flows `favourites`/`progress` orphan chhodte hai — MAJOR (DPDP gap) [VERIFIED]
- **File:** `functions/src/admin/processDeletionRequest.ts:61-84` + `functions/src/users/onUserDelete.ts:22-29` + `firebase/firestore.rules:47`
- **Kya hota hai:** Sirf `alarms` + user doc + Storage `users/{uid}/` + Auth delete hota hai. `users/{uid}/favourites`, `users/{uid}/progress` subcollections hai — user doc delete se subcollection delete nahi hote, orphan rehte hai. `contactMessages`, `aiUsage`, `events`, `fcmTokens` ka bhi koi deleter nahi.
- **Fix:** Saari user subcollections enumerate + delete karo, `fcmTokens` scrub karo.

### B6. Single `premiumToken` multi-device par toot-ta hai — MAJOR [VERIFIED]
- **File:** `functions/src/billing/verifyPurchase.ts:57-68` + `functions/src/billing/playRtdn.ts:38-44`
- **Kya hota hai:** 2nd device ka verify `premiumToken` overwrite kar deta hai. Purane token ka RTDN event `where("premiumToken","==",token)` empty payega → cancel/expire kabhi apply nahi hoga.
- **Fix:** `premiumTokens: string[]` (`arrayUnion/remove`) + `array-contains` query.

### B7. Invalid FCM tokens kabhi prune nahi hote — MAJOR [VERIFIED]
- **File:** `functions/src/notifications/dispatch.ts:85-111`
- **Kya hota hai:** `sendEachForMulticast` responses me sirf first error ka message pakda jata hai. `messaging-registration-token-not-registered` tokens `users[].fcmTokens` se kabhi nahi nikalte → cost badhta hai, deliverability ghat-ti hai.
- **Fix:** Har chunk ke unregistered tokens batch-remove karo.

### B8. Platform broadcasts silently truncate — MAJOR [VERIFIED]
- **File:** `functions/src/notifications/dispatch.ts:71-83` + `173-188`
- **Kya hota hai:** `where("platform","==",…).limit(2000)` + `if (tokens.length >= 5000) break` → cap ke baad users ko message kabhi nahi jata, phir bhi campaign `sent` mark hota hai.
- **Fix:** Full audience paginate karo ya topics se fan-out karo.

### B9. `Hive.box('app_prefs')` bina open-check — MAJOR [VERIFIED]
- **File:** `apps/mobile/lib/features/notifications/application/fcm_coordinator.dart:71-83` + `apps/mobile/lib/features/splash/application/app_bootstrap.dart:119-144` + `apps/mobile/lib/app/bootstrap.dart:53-66,108-121`
- **Kya hota hai:** `AlarmLocalStore.init` `_guardInit` me timeout+swallow ke saath chalta hai; app phir bhi launch hoti hai. Baad me `Hive.box('app_prefs')` `StateError: Box not found` throw karta hai (permission prompt, cached config).
- **Reproduce:** `alarm_store` step 10s hang → home permission dialog crash.
- **Fix:** `if (!Hive.isBoxOpen('app_prefs')) await Hive.openBox(...)` ya fail-closed init.

### B10. `0.0.0` fallback bogus force-update lock — MAJOR [VERIFIED]
- **File:** `apps/mobile/lib/features/splash/application/app_bootstrap.dart:99-106` + `packages/core/lib/src/utils/app_version.dart:16-23` + `apps/mobile/lib/app/router.dart:120-122`
- **Kya hota hai:** `PackageInfo` fail → `version='0.0.0'`. `needsForceUpdate` `0.0.0 < minSupported` → admin ke `forceUpdate` on karte hi router `/update` par pin, chahe real version fine ho.
- **Fix:** Version unknown ho to fail-open karo (force-update gate skip).

### B11. Prarthana list `build` me destructive Hive rewrite — MAJOR [VERIFIED]
- **File:** `apps/mobile/lib/features/prarthana/presentation/prarthana_list_screen.dart:47-55` + `apps/mobile/lib/features/prarthana/application/alarm_local_store.dart:42-47`
- **Kya hota hai:** `data:` builder me `unawaited(replaceAll+syncAlarms)`, guard sirf "local empty". Rebuilds re-fire karte hai; `replaceAll` `clear()` + sequential `put` hai (non-atomic — beech me crash = saare alarms lost) + unawaited native sync `PrarthanaActions._syncNative` se race karta hai.
- **Fix:** One-shot effect (`initState`/listener + once-flag) me le jao + batched `putAll`.

### B12. Content pagination index fallback sirf page-1 par — MAJOR [PARTLY-CORRECTED]
- **File:** `packages/core/lib/src/repositories/content_repository.dart:34-46,83-95`
- **Kya hota hai:** `_publishedQuery` hamesha `where(status)+orderBy(sortOrder)` (+ optional `teacherIds`/`categoryId`) — filter combo par composite index chahiye. `failed-precondition` fallback unordered retry **sirf `startAfter==null`** par (`if (e.code != … || startAfter != null) rethrow`). Correction: `fetchAdminPage`/`watchAdminPage:102-125` single `orderBy(sortOrder)` hai, unko composite nahi chahiye, unko fallback ki zaroorat nahi — wo part fine hai. Asli bug: filtered published list ka page-2+ index missing par hard error.
- **Reproduce:** Index missing + filtered list me page-2 scroll → hard error UI tak.
- **Fix:** Composite indexes ship karo ya sab pages ke liye unordered fallback.

### B13. Audio load fail par stale mini-player — MAJOR [VERIFIED]
- **File:** `apps/mobile/lib/features/player/application/dhamma_audio_handler.dart:86-99,163-185` + `media_item_mapper.dart:5-24`
- **Kya hota hai:** `playContent` `setUrl` se **pehle** `queue`+`mediaItem` publish karta hai; `_loadIndex` empty URL par early return / throw-after-one-retry karta hai → stale `mediaItem` mini-player visible rakhta hai unplayable track ke liye. `_retrying` instance-wide hai, concurrent loads corrupt karte hai.
- **Fix:** `mediaItem` sirf successful `setUrl` ke baad publish karo; per-load retry state; failure par clear.

### B14. Onboarding phone flow India-hardcoded — MAJOR [VERIFIED]
- **File:** `apps/mobile/lib/features/auth/presentation/login_screen.dart:62-66` + `apps/mobile/lib/features/onboarding/presentation/person_info_screen.dart:37-39,105-110` + `packages/core/lib/src/validators/field_validators.dart:27-46`
- **Kya hota hai:** Login `'+91$phone'` bhejta hai; person-info sirf `'+91'` strip karta hai. `normalizeIndianMobile` 10-digit me truncate karta hai, pattern `^[6-9]\d{9}$`, field `maxLength:10`. Non-+91 E.164 number truncate → `phone` validation hamesha fail → onboarding atak jata hai.
- **Fix:** Proper E.164 parse/format + country-code-aware field/validation.

### B15. `events/` arbitrary writes (spam/cost amplifier) — MAJOR [VERIFIED]
- **File:** `firebase/firestore.rules:220-223` + `functions/src/counters/aggregateEvents.ts:40-56,28-32`
- **Kya hota hai:** `allow create: if isSignedIn()` — koi shape check nahi. `aggregateEvents` har junk doc read + delete karta hai (5 min me 500 batch). Junk flood Firestore reads/writes jalata hai.
- **Fix:** Rules me validate karo (`collection` allowlist, `type` allowlist, `itemId` string, `createdAt` timestamp).

---

## PART C — Second pass me pakde 3 NAYE bugs [VERIFIED]

### C1. App Check contradiction — Ask Buddha dead ho sakta hai jabki app chalegi — MEDIUM [VERIFIED]
- **File:** `functions/src/ai/bodhiChat.ts:41` + `functions/src/ai/bodhiSession.ts:21` (`enforceAppCheck:true`) vs `apps/mobile/lib/app/bootstrap.dart:48-57,82-104` (App Check best-effort + comment "isn't enforced, safe")
- **Kya hota hai:** Device par App Check fail/emulator/unregistered ho to poori app chalegi, sirf Ask Buddha fail karega. Session `_tick` silent fail (banner null rehta), `send()` App Check error ko `error`/`disabled` me galat map karega.
- **Fix:** Ya bootstrap me App Check hard-fail karo, ya Bodhi callers me App Check error ka alag user message + retry, aur comment correct karo.

### C2. iOS user hamesha `android` platform par — MEDIUM [VERIFIED]
- **File:** `functions/src/users/onUserCreate.ts:42`
- **Kya hota hai:** `platform: existing?.platform ?? "android"`. Pehli baar iOS se signup = platform android. `tokensForPlatform('ios')` usko kabhi ping nahi karega.
- **Fix:** Client se actual platform bhejo ya default null rakho, guess mat karo.

### C3. Streaming me auto-scroll nahi — LOW [VERIFIED]
- **File:** `ask_buddha_screen.dart:72-78,105-115`
- **Kya hota hai:** `_scrollToBottom()` sirf `send()` complete hone par call hota hai, har `Delta` par nahi. Lamba jawab aate waqt user ko manually scroll karna padta hai.
- **Fix:** Streaming updates par throttled auto-scroll (sirf user pehle se bottom ke paas ho to).

---

## Priority order (suggested)
1. B1, B2, B4 (security) — pehle.
2. A1, A3, A4, A6 (quota-theft / fairness / privacy).
3. B5, B6 (billing/deletion correctness).
4. A2, A5, B14 (Hindi/Marathi + onboarding).
5. Baaki MEDIUM/LOW batch me.
