package app.dhammapath.dhamma_path

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensurePushChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        WallpaperPlugin.register(this, flutterEngine)
        RingtonePlugin.register(this, flutterEngine)
        AlarmPlugin.register(this, flutterEngine)
    }

    private fun ensurePushChannel() {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(
                "dhamma_path_push",
                "Dhamma Path",
                NotificationManager.IMPORTANCE_HIGH,
            ),
        )
    }
}

