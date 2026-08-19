import * as functionsV1 from "firebase-functions/v1";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

/**
 * `onUserCreate` (Architecture §8, T2.9, FR-2.4). Auth user lifecycle events
 * are still v1-only in `firebase-functions`, hence the v1 builder here while
 * everything else in this codebase is v2.
 *
 * Seeds `users/{uid}` server-side as the source of truth. The mobile client
 * also calls `UserRepository.ensureUserDocument` on first sign-in as a
 * safety net against Function cold-start latency blocking onboarding — the
 * two are idempotent with each other (`merge: true`, first-write-wins on the
 * fields that matter), so having both never produces conflicting data.
 * Subscribes the new user to the `all` FCM topic so day-one broadcasts reach
 * them before they've picked a language or teacher.
 */
export const onUserCreate = functionsV1
  .region("asia-south1")
  .auth.user()
  .onCreate(async (user) => {
    const db = getFirestore();
    const ref = db.collection("users").doc(user.uid);
    const existing = await ref.get();

    const authMethod = user.providerData.some((p) => p.providerId === "google.com")
      ? "google"
      : "phone";

    await ref.set(
      {
        name: existing.data()?.name ?? user.displayName ?? "",
        phone: user.phoneNumber ?? existing.data()?.phone ?? null,
        email: user.email ?? existing.data()?.email ?? null,
        photoUrl: user.photoURL ?? existing.data()?.photoUrl ?? null,
        authMethod,
        onboardingStep: existing.data()?.onboardingStep ?? "language",
        language: existing.data()?.language ?? "en",
        selectedTeachers: existing.data()?.selectedTeachers ?? [],
        fcmTokens: existing.data()?.fcmTokens ?? [],
        isBlocked: existing.data()?.isBlocked ?? false,
        platform: existing.data()?.platform ?? "android",
        createdAt: existing.data()?.createdAt ?? FieldValue.serverTimestamp(),
        lastActiveAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    // Best-effort — a topic subscribe needs a device token, which a brand
    // new Auth user may not have registered yet. The mobile app re-subscribes
    // once it has one (T2.70), so failure here is not user-visible.
    const tokens: string[] = existing.data()?.fcmTokens ?? [];
    if (tokens.length > 0) {
      try {
        await getMessaging().subscribeToTopic(tokens, "all");
      } catch {
        // Ignored — client-side subscribe covers this.
      }
    }
  });
