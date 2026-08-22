package app.dhammapath.dhamma_path

import android.app.Activity
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class AlarmPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "app.dhammapath/alarm"

        fun register(activity: Activity, engine: FlutterEngine) {
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler(AlarmPlugin(activity))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canScheduleExact" -> {
                val am = activity.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                result.success(
                    if (Build.VERSION.SDK_INT >= 31) am.canScheduleExactAlarms() else true,
                )
            }
            "openExactAlarmSettings" -> {
                if (Build.VERSION.SDK_INT >= 31) {
                    openSettings(
                        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                            data = Uri.parse("package:${activity.packageName}")
                        },
                    )
                }
                result.success(true)
            }
            "isIgnoringBatteryOptimizations" -> {
                val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
                result.success(pm.isIgnoringBatteryOptimizations(activity.packageName))
            }
            "openBatterySettings" -> {
                // App info only — do not use ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS.
                openSettings(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.parse("package:${activity.packageName}")
                    },
                )
                result.success(true)
            }
            "syncAlarms" -> {
                val raw = call.argument<List<Map<String, Any?>>>("alarms") ?: emptyList()
                val alarms = raw.map { toJson(it) }
                AlarmScheduler.syncAll(activity, alarms)
                result.success(true)
            }
            "cancelAlarm" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrEmpty()) {
                    result.error("bad_args", "id required", null)
                    return
                }
                AlarmScheduler.cancel(activity, id)
                result.success(true)
            }
            "scheduleTest" -> {
                val id = call.argument<String>("id")
                val seconds = call.argument<Int>("seconds") ?: 60
                if (id.isNullOrEmpty()) {
                    result.error("bad_args", "id required", null)
                    return
                }
                val alarm = AlarmStore.find(activity, id)
                if (alarm == null) {
                    result.error("not_found", "Alarm not synced", null)
                    return
                }
                AlarmScheduler.scheduleIn(activity, alarm, seconds)
                result.success(true)
            }
            "stopRinging" -> {
                activity.startService(
                    Intent(activity, AlarmService::class.java)
                        .setAction(AlarmService.ACTION_STOP),
                )
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun openSettings(intent: Intent) {
        try {
            activity.startActivity(intent)
        } catch (_: Exception) {
            activity.startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:${activity.packageName}")
                },
            )
        }
    }

    private fun toJson(map: Map<String, Any?>): JSONObject {
        val obj = JSONObject()
        obj.put("id", map["id"] ?: "")
        obj.put("timeHour", (map["timeHour"] as? Number)?.toInt() ?: 6)
        obj.put("timeMinute", (map["timeMinute"] as? Number)?.toInt() ?: 0)
        obj.put("isEveryday", map["isEveryday"] as? Boolean ?: true)
        obj.put("isEnabled", map["isEnabled"] as? Boolean ?: true)
        obj.put("prarthanaId", map["prarthanaId"] ?: "")
        obj.put("prarthanaLocalPath", map["prarthanaLocalPath"] ?: "")
        obj.put("label", map["label"] ?: "Daily Prarthana")
        obj.put("snoozeMinutes", (map["snoozeMinutes"] as? Number)?.toInt() ?: 10)
        val days = JSONArray()
        val rawDays = map["repeatDays"]
        if (rawDays is List<*>) {
            rawDays.forEach { if (it is Number) days.put(it.toInt()) }
        }
        obj.put("repeatDays", days)
        return obj
    }
}
