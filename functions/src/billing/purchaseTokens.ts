import { createHash } from "node:crypto";
import { getFirestore } from "firebase-admin/firestore";

/**
 * Purchase-token ownership (N7). One Play purchase token grants exactly one
 * app account; the claim lives in the Function-only `purchaseTokens`
 * collection (Firestore rules deny all client access).
 *
 * Two lookup layers exist because the record format evolved:
 *  1. Canonical record: doc ID `sha256(token)`. Deterministic IDs make
 *     concurrent claims contend on ONE document, so exactly one claimant can
 *     win a Firestore transaction race.
 *  2. Pre-ownership auto-ID records (`{token, uid}` from earlier releases).
 * Legacy `users.premiumToken` grants are checked separately at claim time in
 * `verifyPurchase`, since they live on the user doc itself.
 */
export const PURCHASE_TOKENS_COLLECTION = "purchaseTokens";

/** Deterministic ownership doc ID for a purchase token. */
export function purchaseTokenDocId(purchaseToken: string): string {
  return createHash("sha256").update(purchaseToken, "utf8").digest("hex");
}

/**
 * Owner uid for a token via ownership records (canonical, then legacy
 * auto-ID). Returns null when no record exists. Legacy `users.premiumToken`
 * grants are NOT covered here — see `verifyPurchase`.
 */
export async function findTokenOwnerUid(
  purchaseToken: string,
): Promise<string | null> {
  const db = getFirestore();
  const direct = await db
    .collection(PURCHASE_TOKENS_COLLECTION)
    .doc(purchaseTokenDocId(purchaseToken))
    .get();
  const directUid = direct.data()?.uid;
  if (typeof directUid === "string" && directUid.length > 0) return directUid;

  const legacy = await db
    .collection(PURCHASE_TOKENS_COLLECTION)
    .where("token", "==", purchaseToken)
    .limit(1)
    .get();
  const legacyUid = legacy.docs[0]?.data()?.uid;
  return typeof legacyUid === "string" && legacyUid.length > 0
    ? legacyUid
    : null;
}
