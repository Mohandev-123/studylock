package com.studylock.app

import android.app.Activity
import android.os.Bundle
import android.os.CountDownTimer
import android.view.Gravity
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Button
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.ViewGroup

class LockScreenActivity : Activity() {

    private var countDownTimer: CountDownTimer? = null
    private lateinit var timerText: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make it appear over lock screen and other apps
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        val remainingMs = intent.getLongExtra("remaining_ms", 0)
        val blockedPackage = intent.getStringExtra("blocked_package") ?: ""

        setupUI(remainingMs, blockedPackage)
    }

    private fun setupUI(remainingMs: Long, blockedPackage: String) {
        // Dark gradient background
        val background = GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            intArrayOf(Color.parseColor("#0A0E21"), Color.parseColor("#070B1A"))
        )

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            this.background = background
            setPadding(64, 128, 64, 128)
        }

        // Lock icon (emoji as simple solution)
        val lockIcon = TextView(this).apply {
            text = "🔒"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 72f)
            gravity = Gravity.CENTER
        }
        layout.addView(lockIcon, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply { bottomMargin = 48 })

        // Title
        val title = TextView(this).apply {
            text = "App Locked"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 32f)
            gravity = Gravity.CENTER
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }
        layout.addView(title, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply { bottomMargin = 16 })

        // Subtitle
        val subtitle = TextView(this).apply {
            text = "Stay focused. You got this!"
            setTextColor(Color.parseColor("#8888AA"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            gravity = Gravity.CENTER
        }
        layout.addView(subtitle, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply { bottomMargin = 64 })

        // Timer text
        timerText = TextView(this).apply {
            text = formatTime(remainingMs)
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 48f)
            gravity = Gravity.CENTER
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }
        layout.addView(timerText, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply { bottomMargin = 16 })

        val remainingLabel = TextView(this).apply {
            text = "remaining"
            setTextColor(Color.parseColor("#8888AA"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            gravity = Gravity.CENTER
        }
        layout.addView(remainingLabel, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply { bottomMargin = 96 })

        // Go Back button
        val buttonBg = GradientDrawable().apply {
            setColor(Color.parseColor("#2244FF"))
            cornerRadius = 48f
        }
        val goBackButton = Button(this).apply {
            text = "Go Back"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            this.background = buttonBg
            isAllCaps = false
            setPadding(64, 32, 64, 32)
            setOnClickListener { goHome() }
        }
        layout.addView(goBackButton, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            leftMargin = 48
            rightMargin = 48
        })

        setContentView(layout)

        // Start countdown
        startCountdown(remainingMs)
    }

    private fun startCountdown(remainingMs: Long) {
        countDownTimer = object : CountDownTimer(remainingMs, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                timerText.text = formatTime(millisUntilFinished)
            }

            override fun onFinish() {
                timerText.text = "00:00:00"
                // Timer expired, close lock screen
                finish()
            }
        }.start()
    }

    private fun formatTime(ms: Long): String {
        val totalSeconds = ms / 1000
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60
        return String.format("%02d:%02d:%02d", hours, minutes, seconds)
    }

    private fun goHome() {
        // Navigate back to TimeLock app
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP)
            startActivity(intent)
        } else {
            // Fallback to home screen
            val homeIntent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
                addCategory(android.content.Intent.CATEGORY_HOME)
                flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(homeIntent)
        }
        finish()
    }

    override fun onBackPressed() {
        // Prevent back navigation — go home instead
        goHome()
    }

    override fun onDestroy() {
        countDownTimer?.cancel()
        super.onDestroy()
    }
}
