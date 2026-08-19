package app.dhammapath.dhamma_path

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import java.io.File

class AlarmService : Service() {
    companion object {
        const val ACTION_START = "app.dhammapath.ALARM_START"
        const val ACTION_STOP = "app.dhammapath.ALARM_STOP"
        const val ACTION_SNOOZE = "app.dhammapath.ALARM_SNOOZE"
        const val CHANNEL_ID = "prarthana_alarm"
        const val NOTIFICATION_ID = 7101
    }

    private var player: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var currentId: String? = null
    private var currentPath: String? = null
    private var currentLabel: String = "Daily Prarthana"
    private var snoozeMinutes: Int = 10

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "dhamma:prarthana")
        wakeLock?.acquire(15 * 60 * 1000L)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopEverything()
                return START_NOT_STICKY
            }
            ACTION_SNOOZE -> {
                val id = currentId ?: intent.getStringExtra(AlarmScheduler.EXTRA_ID)
                if (id != null) {
                    val stored = AlarmStore.find(this, id)
                    if (stored != null) {
                        AlarmScheduler.scheduleSnooze(this, stored, snoozeMinutes)
                    }
                }
                stopEverything()
                return START_NOT_STICKY
            }
            else -> {
                currentId = intent?.getStringExtra(AlarmScheduler.EXTRA_ID)
                currentPath = intent?.getStringExtra(AlarmScheduler.EXTRA_PATH)
                currentLabel = intent?.getStringExtra(AlarmScheduler.EXTRA_LABEL)
                    ?: "Daily Prarthana"
                snoozeMinutes = intent?.getIntExtra(AlarmScheduler.EXTRA_SNOOZE, 10) ?: 10
                startForeground(NOTIFICATION_ID, buildNotification())
                startPlayback()
                launchRingActivity()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        stopPlayback()
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        super.onDestroy()
    }

    private fun startPlayback() {
        stopPlayback()
        val player = MediaPlayer()
        try {
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build(),
            )
            val path = currentPath
            if (!path.isNullOrEmpty() && File(path).exists()) {
                player.setDataSource(path)
            } else {
                player.setDataSource(
                    this,
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM),
                )
            }
            player.isLooping = true
            player.prepare()
            player.start()
            this.player = player
        } catch (_: Exception) {
            player.release()
            this.player = null
        }
    }

    private fun stopPlayback() {
        try {
            player?.stop()
        } catch (_: Exception) {
        }
        player?.release()
        player = null
    }

    private fun stopEverything() {
        stopPlayback()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun launchRingActivity() {
        val ring = Intent(this, AlarmRingActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra(AlarmScheduler.EXTRA_ID, currentId)
            putExtra(AlarmScheduler.EXTRA_LABEL, currentLabel)
            putExtra(AlarmScheduler.EXTRA_SNOOZE, snoozeMinutes)
        }
        startActivity(ring)
    }

    private fun buildNotification(): Notification {
        val ring = Intent(this, AlarmRingActivity::class.java).apply {
            putExtra(AlarmScheduler.EXTRA_ID, currentId)
            putExtra(AlarmScheduler.EXTRA_LABEL, currentLabel)
            putExtra(AlarmScheduler.EXTRA_SNOOZE, snoozeMinutes)
        }
        val content = PendingIntent.getActivity(
            this,
            1,
            ring,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val stop = PendingIntent.getService(
            this,
            2,
            Intent(this, AlarmService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val snooze = PendingIntent.getService(
            this,
            3,
            Intent(this, AlarmService::class.java).setAction(ACTION_SNOOZE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(currentLabel)
            .setContentText("Daily Prarthana")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setSound(null)
            .setContentIntent(content)
            .setFullScreenIntent(content, true)
            .addAction(0, "Stop", stop)
            .addAction(0, "Snooze 10 min", snooze)
            .build()
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Daily Prarthana",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            setSound(null, null)
            enableVibration(true)
        }
        nm.createNotificationChannel(channel)
    }
}
