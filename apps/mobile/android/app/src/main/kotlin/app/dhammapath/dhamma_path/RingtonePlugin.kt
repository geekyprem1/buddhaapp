package app.dhammapath.dhamma_path

import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * Native ringtone / alarm / notification set (T2.37).
 * WRITE_SETTINGS is a special setting, not a runtime permission.
 */
class RingtonePlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "app.dhammapath/ringtone"

        fun register(activity: Activity, engine: FlutterEngine) {
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler(RingtonePlugin(activity))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canWriteSettings" -> result.success(Settings.System.canWrite(activity))
            "openWriteSettings" -> {
                val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
                    data = Uri.parse("package:${activity.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                activity.startActivity(intent)
                result.success(true)
            }
            "setTone" -> {
                val path = call.argument<String>("path")
                val kind = call.argument<String>("kind")
                if (path.isNullOrEmpty() || kind.isNullOrEmpty()) {
                    result.error("bad_args", "path and kind are required", null)
                    return
                }
                try {
                    if (!Settings.System.canWrite(activity)) {
                        result.error("write_settings_denied", "WRITE_SETTINGS not granted", null)
                        return
                    }
                    setTone(path, kind)
                    result.success(true)
                } catch (e: Exception) {
                    android.util.Log.e("RingtonePlugin", "setTone failed", e)
                    result.error("set_failed", e.message, null)
                }
            }
            "saveTone" -> {
                val path = call.argument<String>("path")
                val kind = call.argument<String>("kind") ?: "ringtone"
                if (path.isNullOrEmpty()) {
                    result.error("bad_args", "path is required", null)
                    return
                }
                try {
                    val uri = insertMediaStore(path, kind)
                    result.success(uri.toString())
                } catch (e: Exception) {
                    android.util.Log.e("RingtonePlugin", "saveTone failed", e)
                    result.error("save_failed", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun setTone(path: String, kind: String) {
        val type = when (kind) {
            "alarm" -> RingtoneManager.TYPE_ALARM
            "notification" -> RingtoneManager.TYPE_NOTIFICATION
            else -> RingtoneManager.TYPE_RINGTONE
        }
        val uri = insertMediaStore(path, kind)
        RingtoneManager.setActualDefaultRingtoneUri(activity, type, uri)
    }

    private fun insertMediaStore(path: String, kind: String): Uri {
        val source = File(path)
        if (!source.exists() || source.length() < 64L) {
            throw IllegalStateException("Audio file missing or empty")
        }
        val ext = source.extension.ifEmpty { "mp3" }
        val mime = when (ext.lowercase()) {
            "m4a", "mp4", "aac" -> "audio/mp4"
            "ogg" -> "audio/ogg"
            "wav" -> "audio/wav"
            else -> "audio/mpeg"
        }
        val name = "dhamma_${System.currentTimeMillis()}.$ext"
        val title = source.nameWithoutExtension.ifBlank { "Dhamma Path" }
        val isRingtone = if (kind == "ringtone") 1 else 0
        val isAlarm = if (kind == "alarm") 1 else 0
        val isNotif = if (kind == "notification") 1 else 0

        if (Build.VERSION.SDK_INT >= 29) {
            val relative = when (kind) {
                "alarm" -> "${Environment.DIRECTORY_ALARMS}/Dhamma Path"
                "notification" -> "${Environment.DIRECTORY_NOTIFICATIONS}/Dhamma Path"
                else -> "${Environment.DIRECTORY_RINGTONES}/Dhamma Path"
            }
            val values = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, name)
                put(MediaStore.Audio.Media.TITLE, title)
                put(MediaStore.Audio.Media.MIME_TYPE, mime)
                put(MediaStore.Audio.Media.IS_RINGTONE, isRingtone)
                put(MediaStore.Audio.Media.IS_ALARM, isAlarm)
                put(MediaStore.Audio.Media.IS_NOTIFICATION, isNotif)
                put(MediaStore.Audio.Media.IS_MUSIC, 0)
                put(MediaStore.Audio.Media.RELATIVE_PATH, relative)
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }
            val resolver = activity.contentResolver
            val uri = resolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("MediaStore insert returned null")
            resolver.openOutputStream(uri).use { out ->
                if (out == null) throw IllegalStateException("Could not open audio stream")
                FileInputStream(source).use { it.copyTo(out) }
            }
            values.clear()
            values.put(MediaStore.Audio.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return uri
        }

        @Suppress("DEPRECATION")
        val publicType = when (kind) {
            "alarm" -> Environment.DIRECTORY_ALARMS
            "notification" -> Environment.DIRECTORY_NOTIFICATIONS
            else -> Environment.DIRECTORY_RINGTONES
        }
        @Suppress("DEPRECATION")
        val dir = File(Environment.getExternalStoragePublicDirectory(publicType), "Dhamma Path")
        if (!dir.exists() && !dir.mkdirs()) {
            throw IllegalStateException("Could not create $publicType/Dhamma Path")
        }
        val dest = File(dir, name)
        FileInputStream(source).use { input ->
            FileOutputStream(dest).use { input.copyTo(it) }
        }
        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DATA, dest.absolutePath)
            put(MediaStore.Audio.Media.DISPLAY_NAME, name)
            put(MediaStore.Audio.Media.TITLE, title)
            put(MediaStore.Audio.Media.MIME_TYPE, mime)
            put(MediaStore.Audio.Media.IS_RINGTONE, isRingtone)
            put(MediaStore.Audio.Media.IS_ALARM, isAlarm)
            put(MediaStore.Audio.Media.IS_NOTIFICATION, isNotif)
            put(MediaStore.Audio.Media.IS_MUSIC, 0)
        }
        return activity.contentResolver.insert(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            values,
        ) ?: Uri.fromFile(dest)
    }
}
