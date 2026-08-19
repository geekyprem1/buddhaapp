export const ADMIN_ROLES = [
  "super_admin",
  "content_manager",
  "moderator",
] as const;

export type AdminRole = (typeof ADMIN_ROLES)[number];

export function isAdminRole(value: unknown): value is AdminRole {
  return typeof value === "string" && (ADMIN_ROLES as readonly string[]).includes(value);
}

export function isSuperAdmin(role: unknown): boolean {
  return role === "super_admin";
}

/** Compose / send push campaigns (AR-6, T1.25). */
export function canSendNotifications(role: unknown): boolean {
  return role === "super_admin" || role === "content_manager";
}
