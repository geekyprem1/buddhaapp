import { initializeApp } from "firebase-admin/app";

initializeApp();

export { setAdminRole } from "./admin/setAdminRole";
export { exportUsersCsv } from "./admin/exportUsersCsv";
export { processDeletionRequest } from "./admin/processDeletionRequest";
export { sendNotification } from "./notifications/sendNotification";
export { sendScheduledNotification } from "./notifications/sendScheduledNotification";

// Auth lifecycle (M2, T2.9)
export { onUserCreate } from "./users/onUserCreate";
export { onUserDelete } from "./users/onUserDelete";

// Auth abuse guard (M2, T2.11)
export { guardOtpAbuse } from "./auth/guardOtpAbuse";

// Content pipeline (M1)
export { onMediaUpload } from "./media/onMediaUpload";
export {
  onWallpaperWrite,
  onRingtoneWrite,
  onSongWrite,
  onVandanaWrite,
  onMeditationWrite,
  onChantingWrite,
  onStatusWrite,
  onPrarthanaWrite,
} from "./content/onContentWrite";
export { publishScheduled } from "./content/publishScheduled";
export { aggregateEvents } from "./counters/aggregateEvents";
export { cleanupOrphans } from "./maintenance/cleanupOrphans";
