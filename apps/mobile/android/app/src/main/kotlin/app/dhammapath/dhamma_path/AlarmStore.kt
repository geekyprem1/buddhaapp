package app.dhammapath.dhamma_path

import android.content.Context
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

/** SharedPreferences snapshot the boot receiver can read without Flutter. */
object AlarmStore {
    private const val PREFS = "dhamma_alarms"
    private const val KEY = "alarms"

    private fun storageContext(context: Context): Context {
        return if (Build.VERSION.SDK_INT >= 24 && !context.isDeviceProtectedStorage) {
            try {
                context.createDeviceProtectedStorageContext()
            } catch (_: Exception) {
                context
            }
        } else {
            context
        }
    }

    fun load(context: Context): List<JSONObject> {
        val target = storageContext(context)
        var raw: String? = null
        try {
            raw = target.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
        } catch (_: Exception) {}

        if (raw == null && target != context) {
            try {
                raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
                if (raw != null) {
                    target.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                        .edit()
                        .putString(KEY, raw)
                        .apply()
                }
            } catch (_: Exception) {}
        }
        val array = JSONArray(raw ?: "[]")
        return List(array.length()) { array.getJSONObject(it) }
    }

    fun save(context: Context, alarms: List<JSONObject>) {
        val array = JSONArray()
        alarms.forEach { array.put(it) }
        val raw = array.toString()
        val target = storageContext(context)
        try {
            target.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY, raw)
                .apply()
        } catch (_: Exception) {}

        if (target != context) {
            try {
                context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    .edit()
                    .putString(KEY, raw)
                    .apply()
            } catch (_: Exception) {}
        }
    }

    fun find(context: Context, id: String): JSONObject? =
        load(context).firstOrNull { it.optString("id") == id }
}
