package app.dhammapath.dhamma_path

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

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
        if (Build.VERSION.SDK_INT >= 26) {
            context.startForegroundService(service)
        } else {
            context.startService(service)
        }
    }
}
