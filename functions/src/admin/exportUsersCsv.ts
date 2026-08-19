import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { writeAuditLog } from "../lib/audit";
import { isSuperAdmin } from "./roles";

const FIELDS = [
  "uid",
  "name",
  "phone",
  "email",
  "language",
  "authMethod",
  "platform",
  "appVersion",
  "isBlocked",
  "selectedTeachers",
  "createdAt",
  "lastActiveAt",
] as const;

function csvCell(value: unknown): string {
  if (value == null) return "";
  let text: string;
  if (Array.isArray(value)) {
    text = value.join("|");
  } else if (
    typeof value === "object" &&
    "toDate" in (value as Record<string, unknown>)
  ) {
    text = (value as { toDate: () => Date }).toDate().toISOString();
  } else {
    text = String(value);
  }
  if (/[",\n]/.test(text)) {
    text = `"${text.replace(/"/g, '""')}"`;
  }
  return text;
}

/**
 * `exportUsersCsv` (Architecture §8, T1.24, AR-5.4). Super-admin only,
 * audit-logged with a PII-access flag. Launch volumes (a few hundred users)
 * fit comfortably in a single callable response — no Storage/signed-URL
 * round trip needed.
 */
export const exportUsersCsv = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    if (!isSuperAdmin(request.auth.token.role)) {
      throw new HttpsError(
        "permission-denied",
        "Only a Super Admin can export user data.",
      );
    }

    const snap = await getFirestore().collection("users").get();
    const rows = [FIELDS.join(",")];
    for (const doc of snap.docs) {
      const data = doc.data();
      rows.push(
        FIELDS.map((f) =>
          csvCell(f === "uid" ? doc.id : data[f]),
        ).join(","),
      );
    }
    const csv = rows.join("\n");

    await writeAuditLog({
      actorUid: request.auth.uid,
      actorEmail: request.auth.token.email ?? null,
      action: "export_users_csv",
      entityType: "users",
      entityId: "all",
      after: { rowCount: snap.size, piiAccessed: true },
    });

    return { csv, rowCount: snap.size };
  },
);
