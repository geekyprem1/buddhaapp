# Baaki Kaam — Dhamma Path (deploy + residuals + app update)

> Date: 16 September 2026
> Status: Round-1 (27 fixes) + Round-2 (12 partials) **code-complete**, verified (`tsc` clean, `flutter analyze` clean, `flutter test` 40/40). **Kuch commit/deploy nahi hua** — sab working tree me hai.
> Source of truth for bugs: [new bug list.md](new%20bug%20list.md). Fix verification: [BUG_FIX_VERIFICATION.md](BUG_FIX_VERIFICATION.md).

---

## 1. Deploy se PEHLE — console checks (bina inke deploy mat karo)

- [ ] **Play Integrity setup confirm karo** (Firebase Console → App Check): Play Integrity API enabled hai + **prod keystore ke SHA-256 fingerprints** registered hain. Kyun: `guardOtpAbuse` ab App Check enforce karta hai (B2) — attestation fail = OTP fail = login lockout (login mandatory hai).
- [ ] **`config/bodhi_ai` ke live values note karo**: `maxTokens` (50–2000?), `temperature` (0–2?), `model` (pinned slug, `latest` to nahi?), quota numbers sane hain? A13 clamps deploy ke baad out-of-range values **silently** badal dega — pehle pata ho kya change hoga.
- [ ] **Closed-track/internal build se real device par OTP test karo** (release signature wala build, Play Integrity path).
- [ ] **Exploited records check karo (B1):** `users` me aise docs hain jisme `premiumUntil` future me hai par koi valid purchase/RTDN history nahi? Rules aage se rokenge, purane records repair nahi hue — mile to manual cleanup karo.
- [ ] **Duplicate legacy tokens check karo (N7):** kya ek hi `premiumToken` do `users` docs par hai? Mile to pehle decide karo kaun asli owner hai (deploy ke baad pehla re-verify jeetega, doosra reject hoga).

## 2. Deploy order (sequence mat todo)

- [ ] **Step 1 — Indexes:** `firebase/firestore.indexes.json` deploy karo, Console me status **Ready/Enabled** hone ka wait karo. Naya `(users: platform + __name__)` index Ready hue bina `dispatch` ka platform query fail karega. (Index build ke dauran purana code purani query chalata hai — safe.)
- [ ] **Step 2 — Rules:** `firebase/firestore.rules` deploy karo, phir dummy account se negative tests:
  - `users/{testUid}` create with `premiumUntil` future → **DENY** hona chahiye.
  - Normal signup/create (bina premium fields) → **ALLOW**.
  - `events` create with bad shape (galat type / missing createdAt / `x/y` itemId) → **DENY**; valid event → **ALLOW**.
  - Kisi doosre ka `idCards` overwrite attempt → **DENY**; apna card delete → **ALLOW**.
- [ ] **Step 3 — Functions:** `firebase deploy --only functions` karo.

## 3. Deploy ke BAAD — monitoring (24–48h, roz dekho)

- [ ] `guardOtpAbuse` error rate — App Check/failures spike? Login-success rate girा kya? (Spike = §5 rollback.)
- [ ] `bodhiChat` error ratio + quota paths (`time-limit` vs `message-limit` vs `off-topic-limit` breakdown).
- [ ] `playRtdn` retries/failures (N8 redelivery kaam kar rahi? poison loop to nahi?).
- [ ] Platform notification campaigns — koi `failed` to nahi (B8 index live hai?).
- [ ] `aggregateEvents` logs — skip/poison warnings normal range me?
- [ ] `guardOtpAbuse` warn logs review (`number throttle hit` / `IP throttle hit`) — real abuse dikhe to numbers note karo.
- [ ] Firestore usage/cost glance (naye `purchaseTokens` writes tiny hone chahiye; FCM prune se invalid tokens ghatne chahiye).

## 4. Rollback plan (ready rakho, dua karo zaroorat na pade)

- **Functions:** previous build redeploy karo (ek command) — sabse likely rollback point (OTP/App Check issue aaye to).
- **OTP emergency:** sirf `guardOtpAbuse` me `enforceAppCheck: false` karke redeploy — baaki fixes intact rahenge.
- **Rules:** Firebase Console → Rules history se previous version restore.
- **Indexes:** rollback ki zaroorat nahi (extra index harmless hai).

## 5. Known residuals (code me documented, future work — chhupaya nahi)

| ID | Baaki kya hai | Rasta |
|---|---|---|
| B2 | Ek attested device abhi bhi 1 victim ka number lock kar sakta hai (counting se close nahi hota) | reCAPTCHA Enterprise score-verification (client + server + keys) — alag change |
| A4 | Classifier outage par user ko off-topic refusal text dikhta hai (lockout fixed, messaging misleading) | Outage-specific UX copy + client handling |
| A9/UI | 2 naye strings hardcoded English hain (message-limit snackbar, banner `· N messages left`) | Normal l10n flow se hi/mr translations (arb + regen) |
| N7 | Concurrent same-token claim ka emulator race-test pending | Firestore-emulator transaction test |
| N3/N6/B5 | Server paths `tsc` + logic-trace tak verified; live/emulator verification pending | Emulator quota/billing/deletion tests |
| A15 | TalkBack report-action + null-UID path ka device test pending | Accessibility device QA |
| B12 | Combined teacher+category filter ka missing-index scenario untested | Deploy-condition check |
| C1 | Bootstrap ka "App Check isn't enforced" comment ab aur stale hai (OTP bhi enforce karta hai) | Comment correct karo (2-line change) |
| B3 | FCM token race (conditional) — retry paths exist, permanent-loss claim pehle hi withdraw hua | Koi action nahi (noted) |
| B6 | Multi-subscription policy (purana token expiry vs naya valid token) unresolved | Product decision + ownership-expiry policy |
| A7 | No-`Done` defensive gap open hai (prod me normal path Map return karta hai) | Done-timeout fallback (optional hardening) |
| A12 | 90s client vs 45s×2 server boundary unchanged (N4 ne body-timer fix kiya) | Budget alignment ya client-timeout bump (optional) |

## 6. Client app update (Play Store — alag release, backend deploy se independent)

Server purane app ke saath compatible hai, to jaldi nahi hai — par mobile fixes users tak **sirf app update se** pahunchenge:
- User-facing: sahi quota/session cut-off (A1), transcript privacy (A6), banner me message count (A9), sahi paywall triggers (A9/A16), Prarthana reliability (B11), mini-player correctness (B13), force-update false-lock fix (B10), streaming follow-scroll (C3).
- Release se pehle: §5 wale hi/mr strings add karo (warna English fallback jayega), banner layout chhoti screens/bade fonts par check karo.
- Rollout: internal → closed → production staged. Forced update ki zaroorat nahi.

## 7. Test gaps (permanent tests banao, temp wale hataye ja chuke hain)

- [ ] Emulator tests: rules (B1/B4/events-deny), quota transactions incl. concurrency (N2/N3/N6), purchase-ownership race (N7), deletion scope (B5).
- [ ] Widget/controller tests: chat generation guard (N1 controls pass hue the — permanent banao), A1 visibility transitions, A6 namespacing.
- [ ] Device QA: Play-Integrity-fail device par OTP, TalkBack report flow, hi/mr UI, small-screen banner.
