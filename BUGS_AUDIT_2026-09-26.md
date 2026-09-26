# Bug Audit — Dhamma Path (26 Sep 2026)

> **Scope:** current working tree, uncommitted changes bhi shamil. Audit read-only tha — koi application code change nahi hua.
> **Method:** 5 parallel code reviewers ne alag-alag area padha, duplicates merge kiye gaye, aur top findings ko grep/read se dobara check kiya gaya.
> **Static checks:** `flutter analyze` (admin, mobile, core, design_system) → **No issues found**. `npm --prefix functions run lint` (`tsc --noEmit`) → clean. Matlab neeche ke saare bugs logic/behaviour ke hain, compile errors nahi.
> **Runtime:** kisi bhi bug ko device/emulator par reproduce nahi kiya gaya.
> **Purani files** (`BUGS_AUDIT.md`, `new bug list.md`, `BUG_FIX_VERIFICATION.md` waghera, 16–17 Sep) is audit ka input nahi thi. Ye fresh audit hai.

## Summary

| Area | Critical | High | Medium | Low | Total |
|---|---:|---:|---:|---:|---:|
| Admin panel | 1 | 1 | 7 | 6 | 15 |
| Admin + Mobile dono | 0 | 0 | 1 | 0 | 1 |
| Mobile app | 0 | 6 | 12 | 25 | 43 |
| **Total** | **1** | **7** | **20** | **31** | **59** |

- **Severity:** Critical = security/paisa/data loss · High = bada feature toota ya privacy · Medium = galat behaviour/reliability · Low = chhota par asli bug.
- **Confidence:** Confirmed = code path poora trace hua · Likely = device/timing/data par depend karta hai.
- **✔ re-checked** = maine khud code me dobara check kiya: #1, #16, #17 (poori chain), #21 aur #27 ka manifest wala hissa, #30. Baaki findings reviewer reports hain.
- Line numbers me `~` = approximate.

## Ye count adhoora hai — ye areas abhi audit nahi hue

Pehle round me ye 4 dedicated reviews complete nahi hue aur retry roka gaya:

1. **Admin:** access control/router/shell, login/session/idle timeout, Users module (uncommitted changes wala), Premium config, App config, Bodhi AI config, Audit log, Contact inbox, Dashboard.
2. **Admin:** Notifications composer/list, Home banners, Static pages, Places, Videos, Wisdom.
3. **Mobile:** bootstrap/router/splash/onboarding, Login/OTP screens, Profile, Premium/Billing, Push notifications (FCM), Dana.
4. **Backend:** Cloud Functions (ai, billing, auth, users, admin incl. naya `grantPremium.ts`, notifications, content, media, counters, maintenance) + `firestore.rules`, `storage.rules`, indexes ka full review.

In areas ki kuch files counterpart ke taur par padhi gayi (isliye #1, #7, #17–#20 jaise bugs mile), lekin inka dedicated review baaki hai.

---

## A. Admin panel (15)

### #1 — Critical — Archived item "Publish" karne par 30 din baad live item + media permanently delete
- **Files:** `apps/admin/lib/features/content/presentation/content_list_page.dart:33-38` (`_setStatus`), popup ~365-400 (archived item par bhi "Publish"); `packages/core/lib/src/repositories/content_repository.dart:294-302` (`setStatus` sirf `status` + `updatedAt` likhta hai), `:30-34` (`_preserveWhenEmpty` me `deletedAt`), `:318-327` (`softDelete`); `functions/src/maintenance/cleanupOrphans.ts:39-43`.
- **Kya hota hai:** `softDelete` `deletedAt` + `archived` set karta hai. Sirf `restore()` (`:307-316`) `deletedAt` clear karta hai. Popup ka "Publish", moderator ka `setStatus`, ya form ka status dropdown sirf `status` badalte hain, `deletedAt` reh jata hai. Cleanup sirf `deletedAt <= cutoff` par filter karta hai, status check nahi karta.
- **Trigger:** Item archive karo → "Restore" ki jagah "Publish" chuno → archive date ke 30 din baad daily job published doc aur uska `{collection}/{id}/` Storage folder hard-delete kar deta hai.
- **Confidence:** Confirmed ✔ re-checked

### #2 — High — Content form se save karte hi status layout ki name styling aur festivalDate mit jaati hai
- **Files:** `apps/admin/lib/features/content/presentation/content_form_page.dart:287-301` (`_buildItem`), hydration `:196-205`; `packages/core/lib/src/repositories/content_repository.dart:228-251` (`update` nested map replace karta hai).
- **Kya hota hai:** Form `nameText` sirf x/y se banata hai. `w`, `align`, `size`, `color`, `weight`, `font` default (0.6, left, 0.045…) par aa jaate hain aur `festivalDate` null ho jata hai. Mobile (`status_card.dart`, `status_compositor.dart`) yahi fields padhta hai.
- **Trigger:** Layout editor me size 0.07, center align aur festival date set karke save → form me title edit karke Save → sab default par wapas.
- **Confidence:** Confirmed

### #3 — Medium — Audio upload ke baad Save, Function ka nikala `durationSec` mita deta hai
- **Files:** `content_form_page.dart:229-244` (AudioMeta), `:553-570` (`onUploaded` audio refresh nahi karta), `:382-405`; `functions/src/media/onMediaUpload.ts:149-160`.
- **Kya hota hai:** Function `audio.durationSec` dotted path se patch karta hai, par form ka Save poora `audio` map `int.tryParse(_duration.text) ?? _existingDurationSec` ke saath likhta hai — naye item par null, replace par purana. Ringtone ka `trimEndSec` bhi aise hi.
- **Trigger:** Ringtone/song banao → mp3 upload → Function ka wait → Create/Save → `durationSec` null ya stale.
- **Confidence:** Confirmed

### #4 — Medium — Re-upload ke baad polling purani file ka result utha leti hai, Save stale values likhta hai
- **Files:** `content_form_page.dart:305-330` (`_listenForProcessedMedia`), `:335-356` (`_listenForProcessedVideo`), `:274-285`; `packages/core/lib/src/models/content_item.dart` `hasProcessedImage` (~83-91).
- **Kya hota hai:** Pichhle run se `hasProcessedImage` pehle se true hai (`storagePath` `/full.webp` par khatam) aur purana `wallpaper.posterUrl` non-empty hai. Isliye pehla 2-second poll purana mediaUrl/thumbUrl/width/height/orientation (ya videoUrl/posterUrl) accept kar leta hai. Save unhe Function ke naye data ke upar likh deta hai, aur purane tokens 403 dete hain.
- **Trigger:** Existing wallpaper image (portrait → landscape) ya live wallpaper video replace karo; Function 2s se zyada le (cold start); kuch second baad Save.
- **Confidence:** Likely (Function latency par depend)

### #5 — Medium — Live wallpaper uploads `thumb.webp`/`full.webp` par takrate hain, doc me dead URLs
- **Files:** `content_form_page.dart` ~806-818 (poster upload `StoragePaths.contentThumb` use karta hai), `:400-405`; `functions/src/media/onMediaUpload.ts:76-99`; `functions/src/media/onWallpaperVideoUpload.ts:78-84`; `functions/src/lib/storage.ts:9-32` (`saveDerivative` har baar naya token).
- **Kya hota hai:** (a) Manual poster generated grid thumbnail `thumb.webp` ko overwrite karta hai; Save sirf `posterUrl` likhta hai, `thumbUrl` purane token par reh jata hai. (b) Live wallpaper par naya Media image `full.webp` naye token se likhta hai, par `wallpaper.posterUrl` update nahi hota.
- **Trigger:** (a) Video upload → custom poster upload → Save → grid thumbnail 403. (b) Live wallpaper par naya Media image → `posterUrl` 403.
- **Confidence:** (b) Confirmed, (a) Likely

### #6 — Medium — Layout editor ka Save poora document purane snapshot se likhta hai
- **Files:** `apps/admin/lib/features/content/presentation/status_layout_editor_page.dart:72-103` (`item.copyWith(statusMeta: …)` → `update(updated)`, koi `unchangedKeys` nahi).
- **Kya hota hai:** Editor khulne ke baad hue changes (mediaUrl/thumbUrl/storagePath, status, sortOrder, title, tags) Save par revert ho jaate hain.
- **Trigger:** Form me base image re-upload karke `onMediaUpload` khatam hone se pehle editor kholo aur save → purane (dead) URLs wapas. Ya doosra admin beech me publish/reorder kare.
- **Confidence:** Likely (concurrent write chahiye)

### #7 — Medium — Audit log me har content edit "system" ke naam se
- **Files:** `functions/src/content/onContentWrite.ts` `actorOf` (~35-48); `packages/core/lib/src/repositories/content_repository.dart` (create/update/setStatus/softDelete/restore/reorder/clone).
- **Kya hota hai:** `actorOf` actor ko `updatedBy`/`createdBy`/`updatedByEmail` se leta hai, par admin/core ka koi bhi write ye fields set nahi karta. Clients `auditLogs` khud likh nahi sakte, to koi aur rasta nahi.
- **Trigger:** Admin me koi bhi create/edit/publish/archive → `auditLogs` entry me `actorUid: "system"`, email null.
- **Confidence:** Confirmed

### #8 — Medium — Slug collision par nayi category purani ko chupchaap overwrite karti hai
- **Files:** `apps/admin/lib/features/categories/presentation/category_form_page.dart` `_save` (~80-124); `packages/core/lib/src/repositories/category_repository.dart` `createWithId` (~72-77, plain `set()`, existence check nahi); `apps/admin/lib/util/slug.dart:1-5`.
- **Kya hota hai:** `slugify` `[a-z0-9]` ke alawa sab hata deta hai. Sirf Hindi/Marathi naam → id bas module ka naam (jaise `wallpaper`) → har aisi category pichhli ko overwrite karti hai. Existing id type karo to wo bhi overwrite (doosre module ki ho to uska `module` bhi badal jata hai). Edit par id dobara slugify hota hai, to non-slug id wali category ka save galat doc par jata hai (Likely).
- **Trigger:** Do categories sirf Hindi naam se banao → sirf ek bachti hai.
- **Confidence:** Confirmed

### #9 — Medium — Form ↔ layout editor jaane par unsaved edits bina warning ke gayab
- **Files:** `content_form_page.dart` ~853-862 ("Open layout editor" `context.go` karta hai, `_dirty` check nahi); `status_layout_editor_page.dart:132-134` (Back apna `_dirty` ignore karta hai).
- **Kya hota hai:** `UnsavedChangesGuard` ek `PopScope` hai, `context.go` ko nahi rokta.
- **Trigger:** Status title edit karke "Open layout editor" → edits gaye. Editor me frame drag karke Back → layout gaya.
- **Confidence:** Confirmed

### #10 — Low — Moderator ko Archive/Restore/Clone dikhte hain jo hamesha fail hote hain, koi error nahi dikhta
- **Files:** `content_list_page.dart:40-68` (`_archive`/`_restore`/`_clone`, try/catch nahi); `content_form_page.dart` `_archive` (~425-438); `firebase/firestore.rules` ~116-129 (moderator sirf `status`, `isFeatured`, `sortOrder`, `updatedAt` badal sakta hai; create allowed nahi).
- **Kya hota hai:** softDelete/restore `deletedAt` likhte hain aur clone create hai → rules deny karte hain. Exception unhandled rehta hai, snackbar nahi aata.
- **Trigger:** Moderator login → kisi item par Archive → kuch nahi hota.
- **Confidence:** Confirmed

### #11 — Low — Bulk upload rollback sirf super_admin ke liye kaam karta hai
- **Files:** `apps/admin/lib/features/content/presentation/bulk_upload_page.dart:146-153`; `firebase/firestore.rules` (content collections par `allow delete: if isSuperAdmin()`, ~136, ~143).
- **Kya hota hai:** Page kehta hai fail hone par draft hard-delete hoga, par content_manager ke liye `hardDelete` deny hota hai aur error `catchError((_) {})` me swallow ho jata hai.
- **Trigger:** content_manager bulk upload kare aur ek file network par fail ho → file-name wala khaali draft list me reh jata hai.
- **Confidence:** Confirmed

### #12 — Low — Bulk batch ulte order me dikhta hai
- **Files:** `bulk_upload_page.dart:94-109`.
- **Kya hota hai:** Har file ko pick order me `nextSort++` milta hai, aur admin + app lists `sortOrder` descending sort karti hain, to aakhri file sabse upar aati hai.
- **Trigger:** "Part 1…Part 5" bulk upload → list me Part 5 … Part 1.
- **Confidence:** Confirmed

### #13 — Low — Alag extension se media replace karne par purani original file Storage me reh jaati hai
- **Files:** `content_form_page.dart:548-552`; `packages/core/lib/src/services/storage_service.dart` (`contentOriginal`); `functions/src/maintenance/cleanupOrphans.ts` `purgeOrphanObjects` (~53-80, sirf un folders ko saaf karta hai jinka doc delete ho chuka hai).
- **Trigger:** jpg wallpaper ko png se replace karo → `wallpapers/{id}/original.jpg` kabhi delete nahi hota.
- **Confidence:** Confirmed

### #14 — Low — Layout editor me frame/name canvas ke bahar drag ho kar pakad se bahar ho jata hai
- **Files:** `status_layout_editor_page.dart:297`, `:373-381`, `:413-421`.
- **Kya hota hai:** Sirf top-left corner [0,1] me clamp hota hai, element ka size nahi dekha jata. x/y = 1.0 par element clipped Stack ke bahar chala jata hai aur hit-test nahi hota; mobile bhi use image ke bahar draw karta hai.
- **Trigger:** Frame ko right edge tak drag karo → gayab, wapas pakda nahi ja sakta.
- **Confidence:** Confirmed

### #15 — Low — Use ho rahi category delete karne par content missing category par point karta hai
- **Files:** `category_form_page.dart` `_delete` (~126-138); `category_repository.dart` `delete`; `content_list_page.dart` (category chips); `content_form_page.dart:513-535` (dropdown).
- **Kya hota hai:** Na usage check hai, na cascade. Aise items har category filter (admin + app) se bahar ho jaate hain. Form dropdown ki value items me nahi hoti — debug me assert, release me blank field, aur re-save par dead id bani rehti hai.
- **Trigger:** Items wali category delete karo → wo items kisi filter me nahi dikhte.
- **Confidence:** Confirmed

---

## B. Admin + Mobile dono (1)

### #16 — Medium — Email validator valid multi-label domains reject karta hai
- **Files:** `packages/core/lib/src/validators/field_validators.dart:13-15` (`^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$`), `emailOptional` ~48-54, `emailRequired` ~56-62. Callers: `apps/admin/lib/features/auth/presentation/login_page.dart` ~36, `apps/mobile/lib/features/onboarding/presentation/person_info_screen.dart` ~57, `apps/mobile/lib/features/profile/presentation/edit_profile_screen.dart` ~54.
- **Kya hota hai:** `@` ke baad sirf ek label + TLD allowed hai.
- **Trigger:** `x@yahoo.co.in`, `a@mail.company.com`, `a@dept.gov.in` → "invalid email". Aise email wala admin login form submit nahi kar sakta, aur mobile user onboarding/profile me email save nahi kar sakta.
- **Confidence:** Confirmed ✔ re-checked

---

## C. Mobile app (43)

### C1. Login aur account

### #17 — High — Naye user ka `users/{uid}` create Firestore rules deny karte hain
- **Files:** `packages/core/lib/src/repositories/user_repository.dart:44-68` (`:66` par `doc.set(user.toJson()..remove('uid'))`); `packages/core/lib/src/models/app_user.g.dart:55-56` (`premiumUntil`, `premiumState` hamesha map me, null hon tab bhi); `firebase/firestore.rules:46-49` (create par in keys ka hona hi deny), `:50-54` (update).
- **Kya hota hai:** Null value wala field bhi key hai, isliye create deny hota hai. Agar `onUserCreate` ne beech me doc bana diya ho, to wahi `set()` update ban jata hai aur affectedKeys ki wajah se phir deny hota hai.
- **Trigger:** Naya user OTP se sign-in kare aur `onUserCreate` Function ke doc banane se pehle client ka `ensureUserDocument` chale (cold start me common) → permission-denied → auth_controller generic sign-in error dikhata hai, jabki Firebase Auth sign-in ho chuka hai. Onboarding ke `.update()` calls bhi not-found se fail hote hain jab tak Function doc na bana de.
- **Note:** Ye uncommitted `app_user.dart` change (naye `premiumUntil`/`premiumState` fields, `git diff` se confirm) ka regression hai. Release se pehle fix zaroori hai.
- **Confidence:** Confirmed ✔ re-checked (kitni baar dikhega, ye Function latency par depend karta hai)

### #18 — Medium — Android OTP auto-verify me error handle nahi, login spinner atak sakta hai
- **Files:** `packages/core/lib/src/services/auth_service.dart:25-43` (`verificationCompleted` ~35-38); `apps/mobile/lib/features/auth/application/auth_controller.dart:50-57`.
- **Kya hota hai:** `verificationCompleted` me try/catch nahi hai; `signInWithCredential` fail ho (user-disabled, network, invalid credential) to `onFailed` kabhi nahi chalta. `onAutoVerified` async closure hai jise await nahi kiya jata, isliye uske errors (jaise #17 ka permission-denied) uncaught ho jaate hain. Controller ka Completer/state sirf in callbacks me set hota hai.
- **Trigger:** Android instant verification (codeSent fire nahi hota) + naya user (#17) ya disabled account → `sendOtp()` resolve nahi hota, state AsyncLoading me atki rehti hai.
- **Confidence:** Confirmed

### #19 — Low — Analytics Firebase ke reserved event names use karta hai (`notification_open`, `error`)
- **Files:** `packages/core/lib/src/services/analytics_service.dart:105-109`; `apps/mobile/lib/app/bootstrap.dart:220-222` (sink); `apps/mobile/lib/features/notifications/application/fcm_coordinator.dart:200-205`, `:311-316`.
- **Kya hota hai:** firebase_analytics in names par `ArgumentError('Event name is reserved…')` throw karta hai. Campaign-open event kabhi record nahi hota aur har notification tap par uncaught async error aata hai. `error()` ka abhi koi caller nahi (latent).
- **Confidence:** Confirmed

### #20 — Low — Doosri account-deletion request permission-denied, user ko feedback nahi
- **Files:** `packages/core/lib/src/repositories/user_repository.dart:188-200` (`set()`); `firebase/firestore.rules` deletionRequests block (owner sirf create kar sakta hai); `apps/mobile/lib/features/profile/presentation/profile_screen.dart:412-416` (try/catch nahi).
- **Kya hota hai:** Pending request ke rehte doosra `set()` update maana jata hai → deny. Exception bahar nikal jata hai aur `signOut()` nahi chalta.
- **Trigger:** Deletion request → sign out → admin ke process karne se pehle dobara login → phir request → kuch nahi hota, user signed-in rehta hai.
- **Confidence:** Confirmed

### C2. Prarthana alarm aur native Android

### #21 — High — Android 14 par exact-alarm permission na ho to alarm fire hote hi app crash
- **Files:** `apps/mobile/android/app/src/main/kotlin/app/dhammapath/dhamma_path/AlarmScheduler.kt:68-71` (inexact `setAndAllowWhileIdle` fallback); `AlarmReceiver.kt:34-35` (`startForegroundService` bina try/catch); `apps/mobile/lib/features/prarthana/presentation/prarthana_setup_screen.dart` ~221-226, ~247-261; `apps/mobile/android/app/src/main/AndroidManifest.xml:16-17` (sirf `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` nahi).
- **Kya hota hai:** Android 14+ par naye installs ko `SCHEDULE_EXACT_ALARM` default me nahi milti. Inexact alarm background se foreground service start karne ki chhoot nahi deta → `ForegroundServiceStartNotAllowedException` → process crash, alarm nahi bajta. Dart pehle schedule karta hai phir permission maangta hai; grant ke baad re-sync nahi hota aur `ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED` ka receiver bhi nahi hai.
- **Trigger:** Android 14 phone → "Set Vandana" → exact-alarm dialog par "Not now" → app band → 6:00 par silent crash.
- **Confidence:** Likely (API 31+, permission denied, app background) — manifest wala hissa ✔ re-checked

### #22 — High — Bajta hua alarm band karne ka koi rasta nahi bachta
- **Files:** `apps/mobile/lib/features/prarthana/application/prarthana_providers.dart:43`, `:117-121`; `AlarmService.kt:102`, `:179-191`; `apps/mobile/lib/platform/alarm_service.dart:45-47` (`stopRinging()` ka koi caller nahi).
- **Kya hota hai:** Stop/Snooze sirf notification actions me hain (ring screen block hoti hai, #25). Notification permission deny ho to bhi alarm save ho jata hai aur notification dikhti nahi. Android 14+ par ongoing FGS notification swipe ho sakti hai (`deleteIntent` nahi). MediaPlayer `isLooping = true` hai.
- **Trigger:** Set karte waqt notification prompt par "Don't allow" → subah vandana loop me bajti hai, band karne ka UI nahi (force-stop hi rasta).
- **Confidence:** Likely (Android 13+ notification denied, ya 14+ par swipe)

### #23 — High — Offline hone par alarm off/delete ka native schedule update nahi hota
- **Files:** `prarthana_providers.dart:49-50`, `:65-69`, `:71-79`, `:91-97`; `packages/core/lib/src/repositories/alarm_repository.dart` ~36-46; `packages/core/lib/src/utils/repo_guard.dart` `_guard` (timeout nahi).
- **Kya hota hai:** `_persist` Firestore `set()` aur delete `doc.delete()` ko await karta hai, uske baad `_syncNative()`/`cancel()` chalte hain. Offline me ye Futures server ack tak pending rehte hain, to native step kabhi nahi chalta, jabki list (cache se) change dikha deti hai. Offline edit par spinner rukta nahi.
- **Trigger:** Raat ko airplane mode → 6:00 wala alarm off/delete karo → phir bhi bajta hai.
- **Confidence:** Confirmed

### #24 — High — Reinstall/naya phone/backup restore ke baad alarms ON dikhte hain par schedule nahi hote
- **Files:** `apps/mobile/android/app/src/main/res/xml/data_extraction_rules.xml:16-28`, `backup_rules.xml` (sharedpref exclude); `apps/mobile/lib/features/prarthana/presentation/prarthana_list_screen.dart:43-55`; `apps/mobile/lib/features/prarthana/application/alarm_local_store.dart` ~52-61.
- **Kya hota hai:** Hive (fingerprint `__native_sync_ids` samet) restore hota hai, lekin native AlarmStore (shared_prefs `dhamma_alarms`) exclude hai aur AlarmManager khaali hai. IDs aur fingerprint same dikhte hain, isliye `syncAlarms` nahi chalta; boot receiver ko bhi khaali prefs milte hain. Comparison sirf IDs ka hai, isliye doosre device se aaye time/day/enabled changes bhi Hive/native tak nahi pahunchte.
- **Trigger:** Play se reinstall ya naye phone me migrate → sign in → alarms enabled dikhte hain par bajte nahi (jab tak edit/toggle na karo).
- **Confidence:** Confirmed (backup restore scenario chahiye)

### #25 — Medium — Android 10+ par locked phone me ring screen nahi aati, screen on nahi hoti
- **Files:** `AlarmService.kt:140-152`, `:179-191`; `AndroidManifest.xml` (`USE_FULL_SCREEN_INTENT` nahi), ~125-132.
- **Kya hota hai:** Service se `startActivity()` background activity start hai, jo API 29+ par chupchaap block hota hai. Notification me `setFullScreenIntent` nahi hai. Awaaz aati hai, par screen dark aur locked rehti hai.
- **Trigger:** Alarm time par phone locked aur screen off ho.
- **Confidence:** Confirmed (platform behaviour)

### #26 — Medium — Logout ya account delete ke baad bhi purane alarms bajte rehte hain
- **Files:** `packages/core/lib/src/services/auth_service.dart:97` (`signOut()` sirf Firebase sign-out); `prarthana_list_screen.dart:36` (remote list khaali ho to early return); `profile_screen.dart` ~364, ~414-416.
- **Kya hota hai:** Hive, native AlarmStore aur AlarmManager clear nahi hote. Naye account ke zero alarms hon to stale local set kabhi replace/cancel nahi hota.
- **Trigger:** Account delete karo ya bina alarms wale doosre account se login → purana alarm roz bajta hai, list khaali hai, band karne ka UI nahi.
- **Confidence:** Confirmed

### #27 — Medium — PIN wale phone ko reboot karne par boot receiver crash (Direct Boot)
- **Files:** `AndroidManifest.xml:99-109` (`directBootAware="true"` + `LOCKED_BOOT_COMPLETED`); `AlarmBootReceiver.kt:10-20`; `AlarmStore.kt:12-14`.
- **Kya hota hai:** Unlock se pehle receiver credential-encrypted `getSharedPreferences()` call karta hai → `IllegalStateException` (uncaught) → crash. `BOOT_COMPLETED` par alarms recover ho jaate hain.
- **Trigger:** PIN/pattern wala phone reboot karo — pehle unlock se pehle crash.
- **Confidence:** Confirmed (file-based-encryption device) — manifest wala hissa ✔ re-checked

### #28 — Medium — "Share to WhatsApp" hamesha fail, generic share sheet khulti hai
- **Files:** `WallpaperPlugin.kt:172-197`; `apps/mobile/lib/features/status/application/status_providers.dart:88-90`, `:103-112`; share_plus 10.1.4 `flutter_share_file_paths.xml`.
- **Kya hota hai:** Plugin share_plus ki authority `<pkg>.flutter.share_provider` use karta hai, jo sirf `cache/share_plus/` expose karti hai. Status image `getTemporaryDirectory()` ke root me likhi jaati hai → `getUriForFile` IllegalArgumentException → "share_failed" → Dart generic share par chala jata hai. WhatsApp analytics channel kabhi record nahi hota.
- **Trigger:** Kisi bhi status par WhatsApp share.
- **Confidence:** Confirmed

### #29 — Medium — Wallpaper aadhi resolution par set hota hai (blurry)
- **Files:** `WallpaperPlugin.kt:158-170` (`decodeSampled`, maxDim 2048); `functions/src/media/onMediaUpload.ts:15`, `:68-72` (sirf width 1440 par cap).
- **Kya hota hai:** Koi bhi side 2048 se badi ho to `inSampleSize` double ho jata hai. Portrait wallpapers (1080×2400, 1440×3120) 540×1200 / 720×1560 par decode hote hain, phir system upscale karta hai.
- **Trigger:** Koi bhi normal portrait wallpaper set karo.
- **Confidence:** Confirmed

### #30 — Low — Manifest ka `TIME_CHANGED` action exist hi nahi karta
- **Files:** `AndroidManifest.xml:107`; `AlarmBootReceiver.kt:14`.
- **Kya hota hai:** Asli broadcast `android.intent.action.TIME_SET` hai (`Intent.ACTION_TIME_CHANGED` ki value yahi hai). Filter kabhi match nahi hota, isliye time-set branch dead code hai. Clock peeche karne par next occurrence skip ho jaati hai, aage karne par alarm turant fire hota hai.
- **Trigger:** Tuesday 07:00 (6:00 wala alarm baj chuka) → clock 05:00 karo → 6:00 wala alarm nahi bajta.
- **Confidence:** Confirmed ✔ re-checked

### #31 — Low — Android 8.0 (API 26) par ring screen lock screen ke upar nahi aati
- **Files:** `AlarmRingActivity.kt:20-23`; `AndroidManifest.xml` ~129-130; `apps/mobile/android/app/build.gradle.kts` (minSdk 26).
- **Kya hota hai:** `setShowWhenLocked`/`setTurnScreenOn` API 27+ ke hain. API 26 ke liye `FLAG_SHOW_WHEN_LOCKED`/`FLAG_TURN_SCREEN_ON` fallback nahi hai.
- **Confidence:** Confirmed (sirf API 26)

### #32 — Low — Ringtone UUID naam se aati hai, har baar duplicate entry
- **Files:** `RingtonePlugin.kt:82-90`, `:92-105`, ~107-135; `apps/mobile/lib/platform/ringtone_service.dart` ~34-62.
- **Kya hota hai:** MediaStore TITLE cached file ke naam (`<uuid>`) se aata hai; Dart item ka title pass nahi karta. Har set/save ek naya `dhamma_<ts>` file insert karta hai, existing check nahi.
- **Trigger:** Ringtone set → Settings > Sound > Phone ringtone me "5b0c7e40-…", har tap par ek aur entry.
- **Confidence:** Confirmed

### #33 — Low — Existing alarm edit par "No vandana selected", save fail ho sakta hai
- **Files:** `prarthana_setup_screen.dart:50`, ~128-134, ~184-194.
- **Kya hota hai:** Edit me sirf `_prarthanaId` restore hota hai, title/audioUrl null rehte hain. Save pehli 50 published vandanas hi dobara fetch karta hai — chuni hui unme na ho to galat "Choose a prarthana first." aata hai. Ye fetch try/catch ke bahar hai.
- **Trigger:** Kisi existing alarm card par tap karke edit karo.
- **Confidence:** Confirmed

### #34 — Low — Wallpaper/ringtone share fail ho to koi message nahi
- **Files:** `apps/mobile/lib/features/wallpaper/presentation/wallpaper_detail_screen.dart` ~88-112 (try/finally, catch nahi); `apps/mobile/lib/features/ringtone/presentation/set_ringtone_sheet.dart` ~282-293.
- **Trigger:** Offline me Share → kuch nahi hota, SnackBar nahi.
- **Confidence:** Confirmed

### #35 — Low — Alarm UI me English hardcoded
- **Files:** `AlarmService.kt:66`, `:182`, `:189-190`, `:199` ("Daily Prarthana", "Stop", "Snooze 10 min", channel name); `AlarmRingActivity.kt:24`, `:51`, `:57`; `prarthana_setup_screen.dart:31` (day letters), `:135` ('Choose >'), `:218` (label 'Daily Practice' store hota hai aur list/notification/ring screen me dikhta hai), `:387-390` (AM/PM); `prarthana_list_screen.dart:239`, ~287-291; `set_ringtone_sheet.dart` ~266-268. `res/values-hi` / `values-mr` folders bhi nahi hain.
- **Confidence:** Confirmed

### C3. Audio player

### #36 — Medium — Track load hote waqt Stop dabao to ~1 sec baad audio bina controls ke chalu
- **Files:** `apps/mobile/lib/features/player/application/dhamma_audio_handler.dart` `_loadIndex` 170-210, `playContent` 97, `stop()` 308-318.
- **Kya hota hai:** `stop()` `mediaItem`/`queue` clear karta hai par `_loadGeneration` nahi badhata. Chal raha load `current() == true` hi paata hai, retry karke true return karta hai aur caller `play()` kar deta hai. MiniPlayer chhup jata hai aur FullPlayer "Nothing is playing." dikhata hai — app ke andar band karne ka rasta nahi.
- **Trigger:** Slow network par track tap → loading ke dauran mini player ka X → ~1s baad audio.
- **Confidence:** Confirmed (timing par depend)

### #37 — Medium — "Repeat all" sirf current track repeat karta hai
- **Files:** `dhamma_audio_handler.dart` `cycleRepeat` 367-375, `_onComplete` 259-274, `setUrl` 189/194; `apps/mobile/lib/features/player/presentation/full_player_screen.dart:164-175`.
- **Kya hota hai:** Har track akela `setUrl` se load hota hai aur `LoopMode.all` us single source par lagta hai — wahi item loop hota hai, `completed` kabhi emit nahi hota, to "next par jao"/"index 0 par wrap" branch kabhi nahi chalti. Loops ke plays record nahi hote.
- **Trigger:** Multi-item list ka item 1 → Repeat ek baar (off → all) → track khatam → wahi track dobara.
- **Confidence:** Likely (just_audio single-source loop behaviour par depend)

### #38 — Medium — Shuffle button kuch nahi karta
- **Files:** `dhamma_audio_handler.dart` `toggleShuffle` 377-380, `skipToNext` 323-333, `_onComplete` 264-271; `full_player_screen.dart:153-162`.
- **Kya hota hai:** Player me hamesha ek hi source hai, isliye `setShuffleModeEnabled` ka asar nahi. Next/prev/auto-advance list order me `items[index ± 1]` use karte hain. Icon highlight hota hai, order same rehta hai.
- **Confidence:** Confirmed

### #39 — Low — Jaldi-jaldi tracks tap karne par galat track chal sakta hai
- **Files:** `dhamma_audio_handler.dart:88-97`, `:170-176`; `_onComplete` 264-274.
- **Kya hota hai:** Naya queue publish hone ke baad Firestore resume-position read await hota hai, aur generation baad me milti hai — "last tap wins" ki jagah "last read wins". Track khatam hote waqt doosri list ka item tap karo to `_onComplete` naya queue + purana mediaItem dekh kar `stop()` kar deta hai, aur kuch nahi chalta.
- **Trigger:** Meditation A phir turant B tap karo; B ka read pehle aaye to A chalta hai.
- **Confidence:** Likely (timing)

### #40 — Low — Meditation ka sleep timer doosre song par bhi chalta rehta hai
- **Files:** `dhamma_audio_handler.dart:53-57`, `:69-98` (`playContent` cancel nahi karta; sirf `stop()` `:310` karta hai); `full_player_screen.dart:24`, `:176-190` (sleep UI sirf meditation par).
- **Trigger:** Meditation → 15-min sleep timer → Songs se song chalao → timer dikhta nahi, 15 min baad song pause ho jata hai.
- **Confidence:** Confirmed

### C4. Ask Buddha (chat)

### #41 — Low — Failed question restore ya Retry user ka naya draft mita deta hai
- **Files:** `apps/mobile/lib/features/bodhi_ai/presentation/ask_buddha_screen.dart` `_submit` 67-80, `_fill` 283-286, `_retry` 288-291.
- **Kya hota hai:** Send ke dauran TextField editable rehta hai. `quotaExhausted`/`disabled` par `_fill(text)` bina check composer overwrite karta hai. `_retry` bhi overwrite karke `_submit` se clear kar deta hai.
- **Trigger:** RetryCard aaya → naya sawal type karna shuru → Retry → draft gaya.
- **Confidence:** Confirmed

### #42 — Low — Clear chat ke baad "messages left" counter gayab; midnight ke baad purana count
- **Files:** `apps/mobile/lib/features/bodhi_ai/application/bodhi_chat_controller.dart` `clear()` 273-280, `refreshQuota` 261-271; `ask_buddha_screen.dart` `initState` 50-52 (sirf yahin call hota hai).
- **Kya hota hai:** `clear()` `state = const BodhiChatState()` se `remainingMessages` null kar deta hai, to banner next reply tak khaali rehta hai. Tab IndexedStack me mounted rehta hai, isliye IST din badalne par bhi kal ka count (jaise laal "0 messages left") dikhta rehta hai.
- **Confidence:** Confirmed

### #43 — Low — Clear chat ke baad "jump to latest" button khaali screen par dikhta rehta hai
- **Files:** `ask_buddha_screen.dart` `_trackBottom` 128-137, FAB 253-263, `_confirmClear` 299-320.
- **Kya hota hai:** `_showJumpToLatest`/`_wasAtBottom` sirf scroll notifications se update hote hain, clear par reset nahi hote. Button dabane se kuch nahi hota.
- **Confidence:** Confirmed

### #44 — Low — 20 off-topic strikes ke baad Retry card jo kabhi kaam nahi karega, wajah bhi nahi batata
- **Files:** `functions/src/ai/quota.ts` `reserveMessage` 137-143, `readRemaining` 90-101; `bodhi_chat_controller.dart` `_mapError` 216-221, 186-188; `ask_buddha_screen.dart` `_RetryCard` 483-499.
- **Kya hota hai:** Server `off-topic-limit` se reject karta hai; client use generic `error` me map karke "Reply couldn't be loaded." + Retry dikhata hai, jo din bhar fail hoga. Server ka "kal try karo" message nahi dikhta, aur `readRemaining` strikes ignore karta hai, isliye banner "N messages left" bolta rehta hai.
- **Confidence:** Confirmed

### C5. Status, meditation, calendar, wisdom, pages

### #45 — High — Download/share status PNG me center/right aligned naam galat jagah ya image ke bahar
- **Files:** `apps/mobile/lib/features/status/application/status_compositor.dart:94-102`; preview `apps/mobile/lib/features/status/presentation/status_card.dart:103-115`; admin contract `apps/admin/lib/features/content/presentation/status_layout_editor_page.dart:18-24` (name `Positioned(left: n.x*cw, width: n.w*cw)`).
- **Kya hota hai:** Editor aur preview `x` ko `w·W` box ka left edge maante hain; compositor `x` ko text ka center/right anchor maanta hai (`painter.width` sirf text ki width hai).
- **Trigger:** align=right, x=0.06, w=0.6 → preview me naam 0.66W par khatam hota hai, PNG me 0.06W par (lagbhag poora image ke bahar). Center par aadha naam kat jata hai. (Download/share premium feature hai.)
- **Confidence:** Confirmed. Ek reviewer ne Medium, doosre ne High diya; yahan High rakha.

### #46 — Medium — Status preview hamesha 4:5 crop, download image se match nahi karta
- **Files:** `status_card.dart:31-37`, `:43-45` (`AspectRatio(0.8)` + `BoxFit.cover`); `status_compositor.dart:41-52` (image ka asli size).
- **Kya hota hai:** Non-4:5 image par photo frame/naam alag jagah aate hain aur naam ~30% chhota dikhta hai. Preview theme ka Poppins font use karta hai jabki TextPainter platform default; preview watermark bhi nahi dikhata.
- **Trigger:** 1080×1920 (9:16) status image.
- **Confidence:** Likely (image aspect ratio par depend)

### #47 — Medium — Nayi status photo choose karne par bhi purani dikhti hai
- **Files:** `status_providers.dart:36-53` (hamesha `<docs>/status_avatar.jpg` overwrite); `status_card.dart:69-74` (`FileImage(photo)`).
- **Kya hota hai:** `FileImage` ka cache key (path, scale) same rehta hai, to cache se pehli photo aati hai. Export file bytes directly padhta hai aur nayi photo use karta hai — preview aur output app restart tak alag rehte hain.
- **Trigger:** Photo A choose → phir photo B → card A dikhata hai, download me B.
- **Confidence:** Confirmed

### #48 — Medium — Meditation timer screen se back jao to countdown band, audio chalta rehta hai
- **Files:** `apps/mobile/lib/features/meditation/presentation/meditation_timer_screen.dart:15-18`, `:41-46` (dispose), `:103-119` (start); `dhamma_audio_handler.dart` ~61-67 (`setSleepTimer` maujood hai par use nahi hota).
- **Kya hota hai:** Session end sirf widget ke `Timer.periodic` me hai. Dispose use aur bell ko cancel karta hai, par shared audio handler ko stop nahi karta ya deadline hand-over nahi karta.
- **Trigger:** 45-min track ke saath 10-min session → back/home → audio poore 45 min chalta hai, end bell nahi.
- **Confidence:** Confirmed

### #49 — Low — Status export PNG files kabhi delete nahi hoti
- **Files:** `status_providers.dart:79-94` (`download` 96-101, `share` 103-).
- **Kya hota hai:** Har download/share `getTemporaryDirectory()` me ek naya full-resolution timestamped PNG likhta hai; cleanup nahi hai. Roz use karne wale ka cache sau MB tak badh sakta hai.
- **Confidence:** Confirmed

### #50 — Low — DST wale timezones me calendar grid ek din khisak jaati hai
- **Files:** `apps/mobile/lib/features/buddhist_calendar/application/buddhist_calendar_service.dart:89-94` (local DateTime par `Duration(days:)`).
- **Kya hota hai:** Fall-back ke baad har cell pichhle din 23:00 par aata hai → ek date do baar, baaki dates galat weekday column me (markers samet). IST par asar nahi.
- **Trigger:** EU me Oct 2026 (25 Oct ka Poya do baar), US me Nov 2026.
- **Confidence:** Likely. Reviewer ne Medium diya tha; app Indian users (IST) ke liye hai, isliye Low rakha.

### #51 — Low — Chhoti screen/bade font par calendar day cells overflow
- **Files:** `apps/mobile/lib/features/buddhist_calendar/presentation/buddhist_calendar_screen.dart` ~159-163 (`childAspectRatio: 1.25`), `_dayCell` ~211-247.
- **Trigger:** ~360dp phone par aaj ka Uposatha cell default text scale par; text scale ≥1.15 par har marked day.
- **Confidence:** Likely

### #52 — Low — App memory me khula rahe to "Today's Wisdom" midnight par nahi badalta
- **Files:** `apps/mobile/lib/features/wisdom/application/wisdom_providers.dart:22-26` (`DateTime.now()` sirf build par ek baar).
- **Kya hota hai:** Provider sirf tab rebuild hota hai jab `activeWisdomsProvider` emit kare (Firestore data change).
- **Confidence:** Likely

### #53 — Low — Static pages me top-level `<br/>` line break gayab
- **Files:** `packages/design_system/lib/src/widgets/simple_html.dart:32-34`, `:86-97`; admin toolbar `apps/admin/lib/features/pages/presentation/page_editor_page.dart:221` (`<br/>` insert karta hai).
- **Kya hota hai:** `<br>` pehle `\n` banta hai, phir `<p>/<h2>/<h3>/<ul>` ke bahar ka text `_flushParagraphs` me single `\n` → space ho jata hai. Admin toolbar `<p>` nahi banata, isliye zyada text top-level hota hai.
- **Trigger:** `Line one<br/>Line two` → "Line one Line two".
- **Confidence:** Confirmed

### #54 — Low — Nested inline tags ki formatting/link kho jaati hai
- **Files:** `simple_html.dart:99-127` (khaas kar `:113` `_decode(match.group(3)!)`).
- **Trigger:** `<b>Read <a href="https://x">this</a></b>` → bold text, link tappable nahi. `<b><i>x</i></b>` → italic gayab.
- **Confidence:** Confirmed

### #55 — Low — `&lt; … &gt;` ke beech ka asli text delete ho jata hai
- **Files:** `simple_html.dart:129-136` (entities pehle unescape, phir `<[^>]+>` strip).
- **Trigger:** `a &lt; b and c &gt; d` → "a  d". `&amp;lt;` double-decode hota hai.
- **Confidence:** Confirmed (narrow trigger)

### C6. Hardcoded English (hi/mr users ko English dikhegi)

### #56 — Low — Ask Buddha screen
- `ask_buddha_screen.dart:259` ('Jump to latest message'), `:296` ('Response copied.'), `:303-304` (clear dialog), `:312` ('Clear chat' — `l10n.aiChatClear` maujood hai), ~429 ('Sending message'/'Send message'), ~484 ("Reply couldn't be loaded." — `aiChatError` maujood hai), ~499 ('Retry'); `bodhi_message_bubble.dart` ~121, ~128 ('Copy response'/'Report response').

### #57 — Low — Player aur Home
- `full_player_screen.dart:29` ('Nothing is playing.'), `:42` ('Now playing'), `:85` ('Anonymous'), tooltips 117-165; `media_item_mapper.dart:11` + `audio_list_tile.dart:29` ('Anonymous' — mini player aur system notification me bhi); `home_screen.dart:97` ('Could not load your profile.', retry bhi nahi).

### #58 — Low — Meditation, Song, Wisdom, Calendar
- `meditation_list_screen.dart:28` ('No meditations yet.'), `song_list_screen.dart:26` ('No songs yet.'), `wisdom_detail_screen.dart:41-43` ('This wisdom is not available yet.'), `buddhist_calendar_screen.dart` ~390-406 ('Estimated' — `calendarEstimated` key maujood hai).

### #59 — Low — design_system shared widgets
- `packages/design_system/lib/src/widgets/teacher_filter_chip_row.dart:47` ('All'), ~62 ('Add another teacher' semantics); `empty_error_states.dart:84` ('Retry'). App me `filterAll`/`retryButton` keys hain, par ye widgets label parameter nahi lete; har content list aur error state par dikhta hai.

---

## Count me nahi — verify karna baaki (possible issues)

- `cloud_functions` ka `stream()` server errors ko `FirebaseFunctionsException` ki tarah deta hai ya nahi, confirm nahi hua. Agar nahi, to Ask Buddha ke quota/disabled/paywall mappings kabhi fire nahi honge aur sab generic error dikhega.
- `status + teacherIds (array-contains) + categoryId + sortOrder` ka composite index nahi hai. Wallpaper list me teacher + category filter saath lag sakte hain ya nahi, confirm nahi hua.
- `publishScheduled` past `publishAt` wale 'draft' ko re-publish kar sakta hai — sirf legacy data par, kyunki admin UI `publishAt` set nahi karta.
- `reorder()` saare items ek hi batch me likhta hai (500 writes ki limit). Abhi collections 500 se chhote hain, isliye latent hai.
- StatefulShellBranch routes (videos, calendar, prarthana) par go_router `push` ka behaviour verify nahi hua.

## Check kiya, bug nahi mila

- Content pagination duplicate `sortOrder` par safe hai (`startAfterDocument` doc name se tie-break karta hai). Jo queries actually chalti hain, un sab ke composite indexes maujood hain.
- Dart ↔ Kotlin channel contracts (alarm, ringtone, wallpaper) ke names, methods aur argument keys match karte hain. Weekday mapping dono taraf ISO hai; schedule/cancel ke request codes same hain; PendingIntents `FLAG_IMMUTABLE` hain; FGS type `mediaPlayback` declared hai.
- Callable names/region (asia-south1) `functions/src/index.ts` exports se match karte hain; admin/AI/OTP payload aur response shapes clients se match karte hain.
- Ask Buddha: per-uid transcript, generation guard (clear/new send/account switch), IST day key, transactional refunds, config clamps aur OpenRouter 45s abort theek hain.
- Timestamp converters null (pending serverTimestamp), int, String, Timestamp aur DateTime handle karte hain; core me `dart:io`/`Platform` nahi hai.
- Status photo-frame math admin editor, mobile preview aur export me same hai; meditation countdown wall clock par chalta hai; YouTube ID extraction saare common URL forms handle karta hai.
