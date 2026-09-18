# R8 / ProGuard rules for Dhamma Path (release builds).
#
# Code shrinking is always on in Flutter release builds, so these rules apply
# to every `--release` APK/AAB.

# ---------------------------------------------------------------------------
# Firebase component discovery  (FIXES: user logged out after app restart)
# ---------------------------------------------------------------------------
# At startup `FirebaseInitProvider` -> `FirebaseApp.<init>` -> ComponentDiscovery
# reads the `com.google.firebase.components` <meta-data> entries merged into
# AndroidManifest.xml and instantiates each named ComponentRegistrar with
# `getDeclaredConstructor().newInstance()`.
#
# Because those classes are only ever referenced as *strings* in the manifest,
# R8 keeps the class but treats its no-argument constructor as unused and
# removes it. Discovery then fails with:
#
#   W/ComponentDiscovery: Invalid component registrar.
#   Could not instantiate com.google.firebase.<x>Registrar
#   Caused by: java.lang.NoSuchMethodException: ...Registrar.<init> []
#
# The component is then silently absent, which we observed causing:
#   * DefaultFirebaseAppCheck to be null -> FirebaseAppCheck.activate() and
#     getToken() throw NPEs, so App Check never works in release.
#   * The firebase_auth plugin's auth-state EventChannel setup to throw
#     PlatformException (NPE on a null object), so the auth state listener is
#     never registered. The restored session never reaches Dart,
#     FirebaseAuth.instance.currentUser stays null, and the router's auth gate
#     sends a signed-in user to /login on every cold start.
#   * Firestore requests to go out unauthenticated (PERMISSION_DENIED).
#
# Which registrars R8 strips varies between builds, which is why this bug
# appeared on the Play build but not on a locally built APK of the same commit.
# Keeping the no-arg constructor makes discovery deterministic.
-keep class com.google.firebase.components.ComponentRegistrar
-keep class * implements com.google.firebase.components.ComponentRegistrar {
    public <init>();
}

# Firebase's reflective initialization entry point, named in the manifest.
-keep class com.google.firebase.provider.FirebaseInitProvider { *; }

# ---------------------------------------------------------------------------
# Firebase Auth session persistence  (FIXES: store file exists but currentUser
# is null on every cold start of a release build)
# ---------------------------------------------------------------------------
# Firebase Auth persists the signed-in user as JSON in
# shared_prefs/com.google.firebase.auth.api.Store.<persistenceKey>.xml and
# restores it with a plain disk read at startup. That blob embeds the *concrete
# class name* of the user implementation (com.google.firebase.auth.internal.zzaf
# in firebase-auth 23.2.1) so the SDK can rebuild the right type, and it maps
# onto that class's fields.
#
# R8 renames both. Verified in this project's own mapping.txt:
#     com.google.firebase.auth.internal.zzaf -> y7.f
#         com.google.firebase.auth.zzc zzk -> A
#         java.util.List zzm -> C
#
# Those names are not stable across R8 runs, so a session written by one build
# stops matching the names a later build looks for. The file stays on disk at
# full size, but restoration silently yields no user: the app then starts
# signed out and the router sends the user to the login screen. Debug builds are
# unaffected because R8 does not run there.
#
# Keeping these packages verbatim makes the persisted type name and field names
# stable, so a stored session stays readable across builds and upgrades.
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.internal.firebase-auth-api.** { *; }
