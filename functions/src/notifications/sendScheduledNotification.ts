import { onSchedule } from "firebase-functions/v2/scheduler";
import { dispatchDueCampaigns } from "./dispatch";

/**
 * Dispatch queued `notifications` whose `scheduledAt` has passed
 * (Architecture §8, AR-6.3). Runs every 5 minutes.
 */
export const sendScheduledNotification = onSchedule(
  {
    region: "asia-south1",
    schedule: "every 5 minutes",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    await dispatchDueCampaigns();
  },
);
