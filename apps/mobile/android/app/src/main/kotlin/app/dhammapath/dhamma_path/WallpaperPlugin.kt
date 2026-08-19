package app.dhammapath.dhamma_path

import android.app.Activity
import android.app.WallpaperManager
import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * Native wallpaper set + gallery save (T2.23).
 * Dart talks to this over [CHANNEL]; Android 8–15 differences stay here.
 */
class WallpaperPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "app.dhammapath/wallpaper"

        fun register(activity: Activity, engine: FlutterEngine) {
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler(WallpaperPlugin(activity))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setWallpaper" -> {
                val path = call.argument<String>("path")
                val target = call.argument<String>("target")
                if (path.isNullOrEmpty() || target.isNullOrEmpty()) {
                    result.error("bad_args", "path and target are required", null)
                    return
                }
                try {
                    setWallpaper(path, target)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("set_failed", e.message, null)
                }
            }
            "saveToGallery" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("bad_args", "path is required", null)
                    return
                }
                try {
                    val uri = saveToGallery(path)
                    result.success(uri)
                } catch (e: Exception) {
                    result.error("save_failed", e.message, null)
                }
            }
            "shareWhatsApp" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("bad_args", "path is required", null)
                    return
                }
                try {
                    shareWhatsApp(path)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("share_failed", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun setWallpaper(path: String, target: String) {
        val bitmap = decodeSampled(path)
        try {
            val wm = WallpaperManager.getInstance(activity)
            val flags = when (target) {
                "home" -> WallpaperManager.FLAG_SYSTEM
                "lock" -> WallpaperManager.FLAG_LOCK
                else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
            }
            wm.setBitmap(bitmap, null, true, flags)
        } finally {
            bitmap.recycle()
        }
    }

    private fun saveToGallery(path: String): String {
        val source = File(path)
        val ext = source.extension.ifEmpty { "jpg" }
        val mime = mimeFor(ext)
        val name = "dhamma_${System.currentTimeMillis()}.$ext"

        if (Build.VERSION.SDK_INT >= 29) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, name)
                put(MediaStore.Images.Media.MIME_TYPE, mime)
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Dhamma Path")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val resolver = activity.contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("MediaStore insert returned null")
            resolver.openOutputStream(uri).use { out ->
                if (out == null) throw IllegalStateException("Could not open gallery stream")
                FileInputStream(source).use { it.copyTo(out) }
            }
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return uri.toString()
        }

        @Suppress("DEPRECATION")
        val dir = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
            "Dhamma Path",
        )
        if (!dir.exists() && !dir.mkdirs()) {
            throw IllegalStateException("Could not create Pictures/Dhamma Path")
        }
        val dest = File(dir, name)
        FileInputStream(source).use { input ->
            FileOutputStream(dest).use { input.copyTo(it) }
        }
        MediaScannerConnection.scanFile(
            activity,
            arrayOf(dest.absolutePath),
            arrayOf(mime),
            null,
        )
        return dest.absolutePath
    }

    private fun decodeSampled(path: String, maxDim: Int = 2048): Bitmap {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        var sample = 1
        val w = bounds.outWidth
        val h = bounds.outHeight
        while (w / sample > maxDim || h / sample > maxDim) {
            sample *= 2
        }
        val opts = BitmapFactory.Options().apply { inSampleSize = sample }
        return BitmapFactory.decodeFile(path, opts)
            ?: throw IllegalStateException("Could not decode image")
    }

    private fun shareWhatsApp(path: String) {
        val file = File(path)
        val uri = FileProvider.getUriForFile(
            activity,
            "${activity.packageName}.flutter.share_provider",
            file,
        )
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "image/png"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val packages = listOf("com.whatsapp", "com.whatsapp.w4b")
        var last: Exception? = null
        for (pkg in packages) {
            try {
                activity.grantUriPermission(pkg, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                send.setPackage(pkg)
                activity.startActivity(send)
                return
            } catch (e: ActivityNotFoundException) {
                last = e
            }
        }
        throw last ?: ActivityNotFoundException("WhatsApp not installed")
    }

    private fun mimeFor(ext: String): String = when (ext.lowercase()) {
        "png" -> "image/png"
        "webp" -> "image/webp"
        "jpg", "jpeg" -> "image/jpeg"
        else -> "image/jpeg"
    }
}
