import { initializeApp } from "firebase-admin/app";

initializeApp();

export { setAdminRole } from "./admin/setAdminRole";
export { sendNotification } from "./notifications/sendNotification";
export { sendScheduledNotification } from "./notifications/sendScheduledNotification";

// Content pipeline (M1)
export { onMediaUpload } from "./media/onMediaUpload";
export {
  onWallpaperWrite,
  onRingtoneWrite,
  onSongWrite,
  onMeditationWrite,
  onStatusWrite,
  onPrarthanaWrite,
} from "./content/onContentWrite";
export { publishScheduled } from "./content/publishScheduled";
export { aggregateEvents } from "./counters/aggregateEvents";
export { cleanupOrphans } from "./maintenance/cleanupOrphans";
