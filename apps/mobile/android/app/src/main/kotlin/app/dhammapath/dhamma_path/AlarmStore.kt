package app.dhammapath.dhamma_path

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** SharedPreferences snapshot the boot receiver can read without Flutter. */
object AlarmStore {
    private const val PREFS = "dhamma_alarms"
    private const val KEY = "alarms"

    fun load(context: Context): List<JSONObject> {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY, "[]") ?: "[]"
        val array = JSONArray(raw)
        return List(array.length()) { array.getJSONObject(it) }
    }

    fun save(context: Context, alarms: List<JSONObject>) {
        val array = JSONArray()
        alarms.forEach { array.put(it) }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY, array.toString())
            .apply()
    }

    fun find(context: Context, id: String): JSONObject? =
        load(context).firstOrNull { it.optString("id") == id }
}
