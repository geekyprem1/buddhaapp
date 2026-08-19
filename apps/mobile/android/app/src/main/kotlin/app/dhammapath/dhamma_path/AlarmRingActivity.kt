package app.dhammapath.dhamma_path

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmRingActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 27) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        val label = intent.getStringExtra(AlarmScheduler.EXTRA_LABEL) ?: "Daily Prarthana"
        val cream = Color.parseColor("#FDF3E0")
        val maroon = Color.parseColor("#8B1A1A")
        val gold = Color.parseColor("#D4A24C")

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(cream)
            gravity = Gravity.CENTER
            setPadding(48, 48, 48, 48)
        }

        val time = TextView(this).apply {
            text = SimpleDateFormat("h:mm a", Locale.getDefault()).format(Date())
            textSize = 48f
            setTextColor(maroon)
            setTypeface(typeface, Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        val title = TextView(this).apply {
            text = label
            textSize = 22f
            setTextColor(Color.parseColor("#1F1F1F"))
            gravity = Gravity.CENTER
            setPadding(0, 24, 0, 64)
        }
        val stop = Button(this).apply {
            text = "Stop"
            setBackgroundColor(maroon)
            setTextColor(Color.WHITE)
            setOnClickListener { send(AlarmService.ACTION_STOP) }
        }
        val snooze = Button(this).apply {
            text = "Snooze 10 min"
            setBackgroundColor(gold)
            setTextColor(Color.parseColor("#1F1F1F"))
            setOnClickListener { send(AlarmService.ACTION_SNOOZE) }
        }

        val lp = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT,
        ).apply { bottomMargin = 24 }

        root.addView(time)
        root.addView(title)
        root.addView(stop, lp)
        root.addView(snooze, lp)
        setContentView(root)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Alarm must be dismissed via Stop / Snooze.
    }

    private fun send(action: String) {
        startService(Intent(this, AlarmService::class.java).setAction(action))
        finish()
    }
}
