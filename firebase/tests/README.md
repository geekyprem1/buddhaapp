# Firestore rules tests (T0.7)

Covers the Architecture §7 paths: anonymous / signed-in user / content
manager / super admin against the rules in `firebase/firestore.rules`.

```powershell
npm --prefix firebase/tests install
firebase emulators:exec --only firestore "npm --prefix firebase/tests test"
```

Java 21+ is required (same as the rest of the emulator suite).
