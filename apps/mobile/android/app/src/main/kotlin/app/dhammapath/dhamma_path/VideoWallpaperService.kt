package app.dhammapath.dhamma_path

import android.net.Uri
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import java.io.File

/**
 * Renders a looping, muted mp4 as the device's live wallpaper via ExoPlayer.
 * The video path is written by [WallpaperPlugin.setLiveWallpaper] into
 * SharedPreferences + the app's filesDir. One ExoPlayer per wallpaper engine
 * (Android may create a preview engine + a real one).
 */
class VideoWallpaperService : WallpaperService() {

    companion object {
        const val PREFS = "live_wallpaper_prefs"
        const val KEY_PATH = "video_path"
        const val WALLPAPER_FILE = "live_wallpaper.mp4"
    }

    override fun onCreateEngine(): Engine = VideoEngine()

    inner class VideoEngine : Engine() {
        private var player: ExoPlayer? = null

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            startPlayer(holder)
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            // Pause when the wallpaper isn't visible to save battery.
            player?.playWhenReady = visible
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            releasePlayer()
        }

        override fun onDestroy() {
            super.onDestroy()
            releasePlayer()
        }

        private fun startPlayer(holder: SurfaceHolder) {
            val path = applicationContext
                .getSharedPreferences(PREFS, MODE_PRIVATE)
                .getString(KEY_PATH, null)
                ?: File(applicationContext.filesDir, WALLPAPER_FILE).absolutePath
            val file = File(path)
            if (!file.exists()) return

            releasePlayer()
            player = ExoPlayer.Builder(applicationContext).build().apply {
                setVideoSurface(holder.surface)
                videoScalingMode = C.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING
                repeatMode = Player.REPEAT_MODE_ALL
                volume = 0f
                setMediaItem(MediaItem.fromUri(Uri.fromFile(file)))
                prepare()
                playWhenReady = true
            }
        }

        private fun releasePlayer() {
            player?.release()
            player = null
        }
    }
}
