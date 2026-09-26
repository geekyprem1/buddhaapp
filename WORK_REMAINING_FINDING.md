# Work Remaining Findings — Dhamma Path

> Review date: 17 September 2026  
> Scope: `REMAINING_WORK.md`, repository configuration, local verification, and Firebase App Check screenshot review.  
> Important: Production par abhi koi deployment nahi kiya gaya hai.

## Current conclusion

`REMAINING_WORK.md` ka overall direction sahi hai, lekin production par use karne se pehle kuch important corrections aur verification required hain. Sabse important issue ye hai ki repository ka default Firebase project `dhamma-path-dev` hai. Isliye production commands mein hamesha explicit `--project dhamma-path-prod` dena zaroori hai.

## Verified findings

### 1. Firebase ka default project production nahi hai

`.firebaserc` ke mutabik:

- Default project: `dhamma-path-dev`
- Production project: `dhamma-path-prod`

Isliye ye command production deploy nahi karegi:

```powershell
firebase deploy --only functions
```

Production ke liye correct command:

```powershell
firebase deploy --only functions --project dhamma-path-prod
```

Ye explicit project flag indexes aur rules deployment mein bhi use hona chahiye.

### 2. App Check abhi registered nahi hai

Firebase Console ke screenshot mein:

- Project: Dhamma Path Prod
- Android app: `app.dhammapath`
- Provider selected: Play Integrity
- Teen SHA-256 certificate fingerprints entered hain
- Current status: **Unregistered**

Iska matlab SHA-256 values form mein hain, lekin App Check registration abhi complete/save nahi hui.

User ko abhi:

1. App Check page par neeche scroll karna hai.
2. `Register` ya `Save` button press karna hai.
3. Status **Registered** hone ka wait karna hai.
4. Uske baad App Check ke `APIs` tab ko check karna hai.

Abhi kisi API ke liye enforcement enable nahi karna chahiye. Pehle release-signed application se attestation aur login flow test hoga.

### 3. OTP flow ke liye deployment risk

`guardOtpAbuse` function mein `enforceAppCheck: true` hai. App Check properly registered/working nahi hua to OTP request fail ho sakti hai aur mandatory login block ho sakta hai.

Exact changed OTP behavior function deploy hone se pehle production par test nahi ho sakta. Safe sequence:

1. App Check registration complete karo.
2. Release-signed/internal-track build ready rakho.
3. Dev/emulator verification complete karo.
4. Production functions deploy ke immediately baad OTP smoke test karo.
5. Failure ki situation mein prepared rollback use karo.

### 4. Changes abhi committed nahi hain

Repository mein multiple modified aur untracked files hain. Production deploy se pehle clean commits banana zaroori hai, warna reliable rollback mushkil hoga.

Important untracked implementation files mein ye shamil hain:

- `functions/src/billing/purchaseTokens.ts`
- `functions/src/lib/userDeletion.ts`
- `apps/mobile/android/app/src/prod/`

Inko commit se pehle review karna hai.

### 5. Accidental file mili hai

`apps/mobile/android/app/src/prod/Untitled` ek source/config file nahi hai. Ismein admin zoom mode se related plain-text note hai. Isko application source ya release commit mein include nahi karna chahiye.

Root ki `.admin_shot.png` bhi verify karni hai ki intentional documentation asset hai ya temporary screenshot.

### 6. Node version documentation mismatch

`docs/LOCAL_DEV.md` Node 20 prerequisite bolta hai, lekin `functions/package.json` Node 22 declare karta hai.

Current machine par Node version `v24.16.0` mila. Functions deployment/runtime compatibility ke liye documentation ko Node 22 ke saath align karna chahiye. Ideally local development aur CI mein Node 22 use ho.

### 7. Local verification result

Ye command successfully complete hui:

```powershell
npm.cmd --prefix functions run build
```

Result: TypeScript build (`tsc`) clean.

Current review session mein `flutter analyze` aur `flutter test` output diye bina hang ho gaye, isliye existing `flutter analyze clean` aur `40/40 tests` claim independently reconfirm nahi hua. In commands ko deployment se pehle dobara successfully complete karna hai.

PowerShell execution policy ki wajah se `npm` ke badle `npm.cmd` use karna pad sakta hai.

### 8. UTF-8 file encoding theek hai

Markdown mein pehle `â€”` aur `Â·` jaise characters PowerShell ke default decoding ke karan dikh rahe the. `REMAINING_WORK.md` ko explicit UTF-8 ke saath read karne par content correct mila. File corruption ka evidence nahi mila.

### 9. Firestore index requirement valid hai

Notification dispatch code query karta hai:

```text
users where platform == value, ordered by document name
```

Iske liye `(platform, __name__)` index addition code ke query pattern se consistent hai. Functions deploy se pehle index deploy karke uska `Ready/Enabled` hona wait karna sahi sequence hai.

## User ko kya karna hai

### Abhi

- [ ] Firebase Console mein Play Integrity registration ko `Register`/`Save` karo.
- [ ] Confirm karo ki App Check status **Registered** ho gaya.
- [ ] App Check ke `APIs` tab ka screenshot share karo.
- [ ] Abhi enforcement manually enable mat karo.
- [ ] Internal ya closed testing track ka release-signed Android build available rakho.

### Production deployment ke samay

- [ ] Release-signed app par OTP/login smoke test karna.
- [ ] Hindi/Marathi UI aur small-screen layout device par check karna.
- [ ] Play Console rollout: Internal → Closed → Staged Production.

## Codex ko kya karna hai

### Phase 1 — Repository cleanup and documentation

- [ ] Accidental `apps/mobile/android/app/src/prod/Untitled` file remove/exclude karna.
- [ ] `.admin_shot.png` ka purpose verify karna.
- [ ] Untracked implementation files review karna.
- [ ] Secrets ya accidental production credentials check karna.
- [ ] `REMAINING_WORK.md` mein explicit project commands add karna.
- [ ] `docs/LOCAL_DEV.md` ko Node 22 ke saath align karna.
- [ ] Real rollback procedure document karna.

### Phase 2 — Local and emulator verification

- [ ] Functions dependencies/build verify karna.
- [ ] `flutter analyze` successfully complete karna.
- [ ] `flutter test` successfully complete karna.
- [ ] Firestore rules negative/positive tests run karna.
- [ ] Purchase-token ownership race test karna.
- [ ] Quota/concurrency tests run karna.
- [ ] User-deletion scope test karna.

### Phase 3 — Dev rehearsal

```powershell
firebase deploy --only "firestore:indexes" --project dhamma-path-dev
```

Index ready hone ke baad:

```powershell
firebase deploy --only "firestore:rules" --project dhamma-path-dev
firebase deploy --only functions --project dhamma-path-dev
```

Dev par signup, rules, quota, purchase, notifications aur deletion smoke tests run karne hain.

### Phase 4 — Commits and rollback preparation

- [ ] Accidental files exclude karke clean commits banana.
- [ ] Pre-deployment revision clearly identify/tag karna.
- [ ] Previous revision redeploy command pehle se prepare karna.
- [ ] Emergency `guardOtpAbuse` App Check rollback procedure prepare karna.

### Phase 5 — Production deployment

Production deployment sirf successful local/dev verification aur user confirmation ke baad karna hai.

#### Step 1: Indexes

```powershell
firebase deploy --only "firestore:indexes" --project dhamma-path-prod
```

Firebase Console mein index `Ready/Enabled` hone ka wait karo.

#### Step 2: Rules

```powershell
firebase deploy --only "firestore:rules" --project dhamma-path-prod
```

Rules ke positive aur negative smoke tests run karo.

#### Step 3: Functions

```powershell
firebase deploy --only functions --project dhamma-path-prod
```

Immediately release-signed application se OTP/login test karo.

## Production se pehle mandatory gate

Production deploy tabhi karna hai jab ye sab true hon:

- [ ] App Check status Registered
- [ ] Play Integrity release-signed app par working
- [ ] Production SHA-256 fingerprints verified
- [ ] Functions TypeScript build clean
- [ ] Flutter analyze clean
- [ ] Flutter tests pass
- [ ] Required emulator/security tests pass
- [ ] Dev deployment rehearsal pass
- [ ] Clean commits and rollback revision ready
- [ ] `config/bodhi_ai` live values reviewed/backed up
- [ ] Suspicious premium records audited
- [ ] Duplicate legacy purchase tokens audited
- [ ] User ne production deployment explicitly confirm kiya

## Current status

**Blocked before production:** App Check screenshot mein status abhi `Unregistered` hai. Agla immediate step registration save karke status `Registered` confirm karna hai.
