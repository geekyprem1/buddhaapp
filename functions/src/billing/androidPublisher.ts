import { google, androidpublisher_v3 } from "googleapis";

/// The Play Store package name (prod applicationId).
export const PACKAGE_NAME = "app.dhammapath";

/// The single subscription product id (matches the mobile app + Play Console).
export const PREMIUM_PRODUCT_ID = "dhamma_premium_monthly";

let _client: androidpublisher_v3.Androidpublisher | null = null;

/// Lazily builds an authenticated Android Publisher client.
///
/// Uses Application Default Credentials — on Cloud Functions this is the
/// function's service account. That service account must be granted access in
/// Play Console → API access (see setup steps), otherwise calls 401/403.
async function client(): Promise<androidpublisher_v3.Androidpublisher> {
  if (_client) return _client;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  _client = google.androidpublisher({ version: "v3", auth });
  return _client;
}

export interface SubscriptionStatus {
  /// Epoch millis the entitlement is valid until (0 if none/expired).
  premiumUntil: number;
  /// Raw Play state, e.g. SUBSCRIPTION_STATE_ACTIVE / _CANCELED / _EXPIRED.
  state: string | null;
  /// True when the user should currently have access.
  active: boolean;
}

/// Reads a subscription purchase from Play and derives entitlement.
///
/// Uses subscriptionsv2 which is product-agnostic (only needs the token) and
/// returns the authoritative expiry. Access is granted while the current
/// billing period hasn't ended — this correctly keeps a cancelled-but-paid
/// user until their period ends, and drops an expired one immediately.
export async function fetchSubscriptionStatus(
  purchaseToken: string,
): Promise<SubscriptionStatus> {
  const api = await client();
  const res = await api.purchases.subscriptionsv2.get({
    packageName: PACKAGE_NAME,
    token: purchaseToken,
  });
  const data = res.data;
  const state = data.subscriptionState ?? null;

  // The latest line item's expiry is the entitlement end.
  let expiryMs = 0;
  for (const item of data.lineItems ?? []) {
    if (item.expiryTime) {
      const t = Date.parse(item.expiryTime);
      if (!Number.isNaN(t) && t > expiryMs) expiryMs = t;
    }
  }

  const grantingStates = new Set([
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_CANCELED", // cancelled but still within paid period
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  ]);
  const active =
    (state === null || grantingStates.has(state)) && expiryMs > Date.now();

  return { premiumUntil: active ? expiryMs : 0, state, active };
}

/// Acknowledges a purchase so Play doesn't auto-refund after 3 days. Safe to
/// call repeatedly; ignores "already acknowledged" style errors.
export async function acknowledgeSubscription(
  purchaseToken: string,
): Promise<void> {
  try {
    const api = await client();
    await api.purchases.subscriptions.acknowledge({
      packageName: PACKAGE_NAME,
      subscriptionId: PREMIUM_PRODUCT_ID,
      token: purchaseToken,
      requestBody: {},
    });
  } catch {
    // Already acknowledged / not required — non-fatal.
  }
}
