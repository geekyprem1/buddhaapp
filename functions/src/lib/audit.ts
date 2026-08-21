import { getFirestore, FieldValue } from "firebase-admin/firestore";

export interface AuditEntry {
  actorUid: string;
  actorEmail?: string | null;
  action: string;
  entityType: string;
  entityId: string;
  before?: Record<string, unknown> | null;
  after?: Record<string, unknown> | null;
}

/** Client writes to `auditLogs` are denied; only the Admin SDK can insert. */
export async function writeAuditLog(entry: AuditEntry): Promise<void> {
  await getFirestore()
    .collection("auditLogs")
    .add({
      actorUid: entry.actorUid,
      actorEmail: entry.actorEmail ?? null,
      action: entry.action,
      entityType: entry.entityType,
      entityId: entry.entityId,
      before: entry.before ?? null,
      after: entry.after ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });
}
