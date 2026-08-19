package app.dhammapath.dhamma_path

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

object AlarmScheduler {
    const val EXTRA_ID = "alarm_id"
    const val EXTRA_PATH = "alarm_path"
    const val EXTRA_LABEL = "alarm_label"
    const val EXTRA_SNOOZE = "alarm_snooze"
    const val EXTRA_IS_SNOOZE = "alarm_is_snooze"

    fun syncAll(context: Context, alarms: List<JSONObject>) {
        val previous = AlarmStore.load(context)
        val newIds = alarms.map { it.optString("id") }.toSet()
        previous.forEach { old ->
            val id = old.optString("id")
            if (id.isNotEmpty() && id !in newIds) cancel(context, id)
        }
        AlarmStore.save(context, alarms)
        alarms.forEach { scheduleNext(context, it) }
    }

    fun cancel(context: Context, id: String) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(pending(context, id, requestCode(id)))
        am.cancel(pending(context, id, snoozeCode(id)))
    }

    fun scheduleNext(context: Context, alarm: JSONObject) {
        if (!alarm.optBoolean("isEnabled", true)) {
            cancel(context, alarm.optString("id"))
            return
        }
        val whenMs = nextTriggerMillis(alarm)
        if (whenMs == null) {
            cancel(context, alarm.optString("id"))
            return
        }
        setExact(context, alarm, whenMs, requestCode(alarm.optString("id")), isSnooze = false)
    }

    fun scheduleSnooze(context: Context, alarm: JSONObject, minutes: Int) {
        val whenMs = System.currentTimeMillis() + minutes * 60_000L
        setExact(context, alarm, whenMs, snoozeCode(alarm.optString("id")), isSnooze = true)
    }

    fun scheduleIn(context: Context, alarm: JSONObject, seconds: Int) {
        val whenMs = System.currentTimeMillis() + seconds * 1000L
        setExact(context, alarm, whenMs, requestCode(alarm.optString("id")), isSnooze = false)
    }

    private fun setExact(
        context: Context,
        alarm: JSONObject,
        whenMs: Long,
        code: Int,
        isSnooze: Boolean,
    ) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = pending(context, alarm.optString("id"), code, alarm, isSnooze)
        if (Build.VERSION.SDK_INT >= 31 && !am.canScheduleExactAlarms()) {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, whenMs, pi)
            return
        }
        am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, whenMs, pi)
    }

    fun nextTriggerMillis(alarm: JSONObject, nowMs: Long = System.currentTimeMillis()): Long? {
        if (!alarm.optBoolean("isEnabled", true)) return null
        val hour = alarm.optInt("timeHour", 6)
        val minute = alarm.optInt("timeMinute", 0)
        val everyday = alarm.optBoolean("isEveryday", true)
        val days = mutableSetOf<Int>()
        val raw = alarm.optJSONArray("repeatDays") ?: JSONArray()
        for (i in 0 until raw.length()) days.add(raw.optInt(i))
        if (everyday || days.isEmpty()) {
            days.clear()
            days.addAll(1..7)
        }
        val now = Calendar.getInstance().apply { timeInMillis = nowMs }
        val cal = Calendar.getInstance().apply {
            timeInMillis = nowMs
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        repeat(8) {
            if (cal.timeInMillis > now.timeInMillis && isoWeekday(cal) in days) {
                return cal.timeInMillis
            }
            cal.add(Calendar.DAY_OF_MONTH, 1)
            cal.set(Calendar.HOUR_OF_DAY, hour)
            cal.set(Calendar.MINUTE, minute)
        }
        return null
    }

    private fun isoWeekday(cal: Calendar): Int = when (cal.get(Calendar.DAY_OF_WEEK)) {
        Calendar.MONDAY -> 1
        Calendar.TUESDAY -> 2
        Calendar.WEDNESDAY -> 3
        Calendar.THURSDAY -> 4
        Calendar.FRIDAY -> 5
        Calendar.SATURDAY -> 6
        else -> 7
    }

    private fun pending(
        context: Context,
        id: String,
        code: Int,
        alarm: JSONObject? = null,
        isSnooze: Boolean = false,
    ): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "app.dhammapath.ALARM"
            putExtra(EXTRA_ID, id)
            if (alarm != null) {
                putExtra(EXTRA_PATH, alarm.optString("prarthanaLocalPath"))
                putExtra(EXTRA_LABEL, alarm.optString("label", "Daily Prarthana"))
                putExtra(EXTRA_SNOOZE, alarm.optInt("snoozeMinutes", 10))
            }
            putExtra(EXTRA_IS_SNOOZE, isSnooze)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, code, intent, flags)
    }

    fun requestCode(id: String): Int = id.hashCode() and 0x7fffffff

    fun snoozeCode(id: String): Int = (id.hashCode() xor 0x5A5A5A5A) and 0x7fffffff
}
