P0 — Play upload से पहले जरूरी
1. Production signing setup
अभी 
build.gradle.kts
 में release build debug key से signed हो रहा है:

signingConfig = signingConfigs.getByName("debug")
करना होगा:

Secure upload keystore generate करना
key.properties locally configure करना
Release signing config जोड़ना
Keystore और passwords GitHub में commit नहीं करने
Play Console में Play App Signing enable करना
Upload और Play App Signing certificate के SHA-1/SHA-256 Firebase Prod में register करना
Keystore/password chat में भेजने की जरूरत नहीं है. Google Play नए apps के लिए AAB और Play App Signing workflow इस्तेमाल करता है: Play App Signing.

2. Final version set करना
Current:

version: 0.1.0+1
First public release के लिए recommended:

version: 1.0.0+1
versionCode हर subsequent Play upload पर बढ़ाना होगा: +2, +3, etc.

3. Signed production AAB बनाना
अभी केवल APK artifact मौजूद है; Play listing के लिए signed AAB चाहिए:

flutter build appbundle --flavor prod -t lib/main_prod.dart --release
Expected output:

apps/mobile/build/app/outputs/bundle/prodRelease/app-prod-release.aab
Upload से पहले verify करना होगा:

Correct package: app.dhammapath
Release/debug signature नहीं
Bundle size
16 KB page-size compatibility
Merged manifest permissions
Prod Firebase connectivity
Google Play नए apps के लिए Android App Bundle मांगता है: App bundle guidance.

4. Restricted permissions review
Manifest में policy-sensitive permissions हैं:

USE_EXACT_ALARM
SCHEDULE_EXACT_ALARM
USE_FULL_SCREEN_INTENT
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
WRITE_SETTINGS
Foreground media playback
Upload से पहले करना होगा:

USE_EXACT_ALARM और SCHEDULE_EXACT_ALARM दोनों रखने की जरूरत review करना
संभवतः redundant/broad permission हटाना
Exact-alarm special-access UX जोड़ना/verify करना
Full-screen alarm eligibility और declaration पूरा करना
Foreground service/media playback declaration देना
Battery optimization exemption genuinely जरूरी नहीं हो तो हटाना
Play reviewer के लिए explain करना कि ये permissions Daily Prarthana alarm/ringtone/audio के लिए हैं
ये permission section rejection risk है, इसलिए AAB upload से पहले code review जरूरी है.

5. Final licensed content
Play minimum item count नहीं मांगता, लेकिन app empty/broken या copyright-risk वाला नहीं होना चाहिए.

हर published item में verify करो:

Valid media और thumbnail
English/Hindi/Marathi titles
Correct teacher/category
Source और licence proof
Copyright/takedown contact
कोई seed/demo content Prod में नहीं
Wallpapers/audio/text के actual usage rights
Play Console में manually करना होगा
6. App create और first setup
Play Console में:

App name: Dhamma Path
Default language
App/Game: App
Free/Paid: Free
Package ID final confirm: app.dhammapath
Play App Signing स्वीकार करना
Package ID first upload के बाद practically permanent होगा.

7. Store listing assets
बनाने/अपलोड करने होंगे:

512×512 Play Store icon
1024×500 feature graphic
कम से कम phone screenshots
बेहतर होगा English, Hindi और Marathi screenshots
Short description
Full description
Support email
App category
Localized release notes
Adaptive Android launcher icon और dedicated notification icon भी verify करना बाकी है.

8. App Content forms
Play Console → Policy and programs → App content में:

Privacy Policy URL
https://dhamma-path-prod-public.web.app/privacy/
Account Deletion URL
https://dhamma-path-prod-public.web.app/delete-account/
Ads declaration: current release में No ads
Content rating questionnaire
Target audience and age group
App access instructions क्योंकि login mandatory है
Google reviewer के लिए working test account/OTP process
Exact alarm declaration
Full-screen intent declaration
Foreground service declaration
Government/news/health/financial declarations जहाँ applicable हों
9. Data Safety form
Actual app behavior के अनुसार declare करना होगा:

Name
Email address
Phone number
User ID
Profile image/user files जहाँ applicable
App preferences
Contact/support messages
App interactions/Analytics
Device or app instance identifiers/FCM tokens
Important:

Status personalization photo current flow में device पर रहती है—उस feature के लिए cloud collection मत declare करना.
Firebase Analytics active है.
Crashlytics currently inactive है.
Data encrypted in transit: Yes
Account deletion available: Yes
Service providers के रूप में Google/Firebase का processing सही classify करना
Google Play Data Safety form mandatory है: Data Safety guidance. Account deletion answers public deletion page से match होने चाहिए: Account deletion requirements.

Testing before Production
10. Internal testing
Signed AAB पहले Internal Testing track पर upload करो और verify करो:

Phone OTP
Google Sign-In
Firebase Auth/Firestore/Storage
Play Integrity/App Check token
Wallpaper set
Ringtone set
Daily Prarthana alarm
Reboot और force-stop के बाद alarm
Notifications
Account deletion request
Prod content loading
Play pre-launch report के crashes, ANRs और permission warnings fix करने होंगे.

11. Closed testing requirement
अगर personal Play developer account 13 November 2023 के बाद बना है, तो minimum:

12 opted-in testers
लगातार 14 days closed testing
इसके बाद Production access apply कर सकते हो. Google का current rule: Personal account testing requirements.

Project plan में 50-user beta लिखा है; Google minimum से ज्यादा testing अच्छी है, लेकिन compulsory minimum account eligibility पर depend करता है.

Strongly recommended before public launch
ये Play submission के absolute blockers नहीं, लेकिन release safety के लिए जरूरी हैं:

Crashlytics वापस compatible version से enable करना या alternative crash reporting लगाना
App Check को पहले Internal Play build पर test करना, फिर Prod enforcement ON करना
Samsung, Xiaomi, Oppo और Pixel physical-device testing
Android 8/10/12/14/15/16 testing
Hindi/Marathi text-scale और accessibility QA
Prod budget alerts
Takedown drill
Admin deletion-request runbook
Signed AAB CI workflow
Best execution order
Restricted permissions review/fix
Version 1.0.0+1 lock
Upload keystore और release signing
Signed Prod AAB build
Firebase SHA fingerprints register
Internal Testing upload
Auth/alarm/ringtone/wallpaper testing
Data Safety + App Content forms
Store graphics/listing
Closed test, अगर account पर required है
Production access → staged rollout
सबसे पहला practical काम: release signing और restricted Android permissions ठीक करना. उसके बिना final AAB upload नहीं करना चाहिए.