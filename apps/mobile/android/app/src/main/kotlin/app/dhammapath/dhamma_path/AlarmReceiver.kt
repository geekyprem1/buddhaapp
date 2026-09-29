package app.dhammapath.dhamma_path

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getStringExtra(AlarmScheduler.EXTRA_ID) ?: return
        val stored = AlarmStore.find(context, id)
        val path = intent.getStringExtra(AlarmScheduler.EXTRA_PATH)
            ?: stored?.optString("prarthanaLocalPath").orEmpty()
        val label = intent.getStringExtra(AlarmScheduler.EXTRA_LABEL)
            ?: stored?.optString("label", "Daily Prarthana")
            ?: "Daily Prarthana"
        val snooze = intent.getIntExtra(
            AlarmScheduler.EXTRA_SNOOZE,
            stored?.optInt("snoozeMinutes", 10) ?: 10,
        )
        val isSnooze = intent.getBooleanExtra(AlarmScheduler.EXTRA_IS_SNOOZE, false)

        if (!isSnooze && stored != null) {
            AlarmScheduler.scheduleNext(context, stored)
        }

        val service = Intent(context, AlarmService::class.java).apply {
            action = AlarmService.ACTION_START
            putExtra(AlarmScheduler.EXTRA_ID, id)
            putExtra(AlarmScheduler.EXTRA_PATH, path)
            putExtra(AlarmScheduler.EXTRA_LABEL, label)
            putExtra(AlarmScheduler.EXTRA_SNOOZE, snooze)
        }
        try {
            if (Build.VERSION.SDK_INT >= 26) {
                context.startForegroundService(service)
            } else {
                context.startService(service)
            }
        } catch (e: Throwable) {
            // Android 14+ ForegroundServiceStartNotAllowedException fallback.
            // Avoid crashing the application process; display alarm notification directly.
            try {
                val ring = Intent(context, AlarmRingActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    putExtra(AlarmScheduler.EXTRA_ID, id)
                    putExtra(AlarmScheduler.EXTRA_LABEL, label)
                    putExtra(AlarmScheduler.EXTRA_SNOOZE, snooze)
                }
                val pi = PendingIntent.getActivity(
                    context,
                    1,
                    ring,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                val notif = NotificationCompat.Builder(context, AlarmService.CHANNEL_ID)
                    .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                    .setContentTitle(label)
                    .setContentText("Daily Prarthana")
                    .setCategory(NotificationCompat.CATEGORY_ALARM)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setContentIntent(pi)
                    .setFullScreenIntent(pi, true)
                    .setAutoCancel(true)
                    .build()
                nm?.notify(AlarmService.NOTIFICATION_ID, notif)
            } catch (_: Throwable) {
            }
        }
    }
}
