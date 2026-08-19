import { HttpsError, onCall } from "firebase-functions/v2/https";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { writeAuditLog } from "../lib/audit";
import { canSendNotifications } from "../admin/roles";
import { parseAudience } from "./audience";
import {
  markFailed,
  markSent,
  sendTestToToken,
  sendToAudience,
  writeCampaign,
  type CampaignContent,
} from "./dispatch";

interface SendNotificationRequest {
  campaignId?: string;
  title?: string;
  body?: string;
  imageUrl?: string | null;
  deepLink?: string | null;
  audience?: string;
  scheduledAt?: string | number | null;
  testToken?: string | null;
}

function requireText(value: unknown, field: string, max: number): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  const trimmed = value.trim();
  if (!trimmed) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  if (trimmed.length > max) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be at most ${max} characters.`,
    );
  }
  return trimmed;
}

function optionalText(value: unknown, field: string, max: number): string | null {
  if (value == null || value === "") return null;
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${field} must be a string.`);
  }
  const trimmed = value.trim();
  if (!trimmed) return null;
  if (trimmed.length > max) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be at most ${max} characters.`,
    );
  }
  return trimmed;
}

function parseScheduledAt(raw: unknown): Date | null {
  if (raw == null || raw === "") return null;
  if (typeof raw === "number" && Number.isFinite(raw)) {
    return new Date(raw < 1e12 ? raw * 1000 : raw);
  }
  if (typeof raw === "string") {
    const parsed = new Date(raw);
    if (Number.isNaN(parsed.getTime())) {
      throw new HttpsError("invalid-argument", "scheduledAt is not a valid date.");
    }
    return parsed;
  }
  throw new HttpsError("invalid-argument", "scheduledAt is not a valid date.");
}

/**
 * Compose and send (or queue) an FCM campaign (Architecture §8, AR-6).
 * Super Admin and Content Manager only. Test-token sends do not flip status.
 */
export const sendNotification = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    if (!canSendNotifications(request.auth.token.role)) {
      throw new HttpsError(
        "permission-denied",
        "Only a Super Admin or Content Manager can send notifications.",
      );
    }

    const data = (request.data ?? {}) as SendNotificationRequest;
    const title = requireText(data.title, "title", 200);
    const body = requireText(data.body, "body", 1000);
    const imageUrl = optionalText(data.imageUrl, "imageUrl", 2000);
    if (imageUrl && !/^https:\/\//i.test(imageUrl)) {
      throw new HttpsError("invalid-argument", "imageUrl must be an https URL.");
    }
    const deepLink = optionalText(data.deepLink, "deepLink", 500);
    const audience = optionalText(data.audience, "audience", 200) ?? "all";
    try {
      parseAudience(audience);
    } catch (err) {
      throw new HttpsError(
        "invalid-argument",
        err instanceof Error ? err.message : "Invalid audience.",
      );
    }

    const content: CampaignContent = {
      title,
      body,
      imageUrl,
      deepLink,
      audience,
    };

    const testToken = optionalText(data.testToken, "testToken", 4096);
    if (testToken) {
      const messageId = await sendTestToToken(
        testToken,
        content,
        data.campaignId?.trim() || "test",
      );
      await writeAuditLog({
        actorUid: request.auth.uid,
        actorEmail: request.auth.token.email ?? null,
        action: "notification_test",
        entityType: "notifications",
        entityId: data.campaignId?.trim() || "test",
        after: { audience, title, test: true },
      });
      return { status: "test", messageId, deliveredCount: 1 };
    }

    const scheduledAt = parseScheduledAt(data.scheduledAt);
    if (scheduledAt && scheduledAt.getTime() <= Date.now() - 15_000) {
      throw new HttpsError(
        "invalid-argument",
        "scheduledAt must be in the future.",
      );
    }

    const db = getFirestore();
    const col = db.collection("notifications");
    const campaignId = data.campaignId?.trim();
    const ref = campaignId ? col.doc(campaignId) : col.doc();
    const existing = await ref.get();
    if (existing.exists) {
      const status = existing.data()?.status;
      if (status === "sent" || status === "sending") {
        throw new HttpsError(
          "failed-precondition",
          "This campaign has already been sent.",
        );
      }
    }

    const createdFields = existing.exists
      ? {}
      : {
          createdBy: request.auth.uid,
          createdAt: FieldValue.serverTimestamp(),
        };

    if (scheduledAt) {
      await writeCampaign(ref, content, {
        status: "scheduled",
        scheduledAt: Timestamp.fromDate(scheduledAt),
        error: null,
        ...createdFields,
      });
      await writeAuditLog({
        actorUid: request.auth.uid,
        actorEmail: request.auth.token.email ?? null,
        action: "notification_schedule",
        entityType: "notifications",
        entityId: ref.id,
        after: { audience, title, scheduledAt: scheduledAt.toISOString() },
      });
      return {
        campaignId: ref.id,
        status: "scheduled",
        deliveredCount: 0,
      };
    }

    await writeCampaign(ref, content, {
      status: "sending",
      scheduledAt: FieldValue.delete(),
      error: null,
      ...createdFields,
    });

    try {
      const result = await sendToAudience(content, ref.id);
      await markSent(ref, result);
      await writeAuditLog({
        actorUid: request.auth.uid,
        actorEmail: request.auth.token.email ?? null,
        action: "notification_send",
        entityType: "notifications",
        entityId: ref.id,
        after: {
          audience,
          title,
          deliveredCount: result.deliveredCount,
          target: result.target,
        },
      });
      return {
        campaignId: ref.id,
        status: "sent",
        deliveredCount: result.deliveredCount,
        messageId: result.messageId ?? null,
      };
    } catch (err) {
      const message = err instanceof Error ? err.message : "Send failed.";
      await markFailed(ref, message);
      throw new HttpsError("internal", message);
    }
  },
);
