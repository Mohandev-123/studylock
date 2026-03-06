package com.example.study_lock

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppMonitorService : AccessibilityService() {

    companion object {
        const val TAG = "AppMonitorService"
        const val PREFS_NAME = "timelock_prefs"
        const val KEY_BLOCKED_PACKAGES = "blocked_packages"
        const val KEY_TIMER_END = "timer_end_time"
        const val KEY_IS_ACTIVE = "is_session_active"

        var instance: AppMonitorService? = null
            private set
    }

    private var blockedPackages: Set<String> = emptySet()
    private var timerEndTime: Long = 0
    private var isSessionActive: Boolean = false
    private var lastDetectedPackage: String = ""
    private var lastTriggerTime: Long = 0

    private val prefs: SharedPreferences by lazy {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            notificationTimeout = 300
        }
        serviceInfo = info

        // Restore state from SharedPreferences
        loadState()

        Log.d(TAG, "AppMonitorService connected. Blocked: ${blockedPackages.size} apps")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        // Skip our own app and system UI
        if (packageName == applicationContext.packageName) return
        if (packageName == "com.android.systemui") return
        if (packageName == "com.android.launcher3") return
        if (packageName == "com.google.android.apps.nexuslauncher") return

        if (!isSessionActive) return

        // Check if timer has expired
        if (System.currentTimeMillis() > timerEndTime) {
            Log.d(TAG, "Timer expired, stopping session")
            stopSession()
            return
        }

        // Check if this is a blocked app
        if (blockedPackages.contains(packageName)) {
            // Debounce to prevent rapid re-triggering
            val now = System.currentTimeMillis()
            if (packageName == lastDetectedPackage && (now - lastTriggerTime) < 2000) {
                return
            }
            lastDetectedPackage = packageName
            lastTriggerTime = now

            Log.d(TAG, "Blocked app detected: $packageName")
            showLockScreen(packageName)
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "AppMonitorService interrupted")
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    // ─── Public API ─────────────────────────────────────────────────

    fun startSession(packages: List<String>, durationMinutes: Int) {
        blockedPackages = packages.toSet()
        timerEndTime = System.currentTimeMillis() + (durationMinutes * 60 * 1000L)
        isSessionActive = true
        saveState()
        Log.d(TAG, "Session started: ${packages.size} apps blocked for ${durationMinutes}m")
    }

    fun stopSession() {
        isSessionActive = false
        blockedPackages = emptySet()
        timerEndTime = 0
        saveState()
        Log.d(TAG, "Session stopped")
    }

    fun updateBlockedPackages(packages: List<String>) {
        blockedPackages = packages.toSet()
        saveState()
    }

    fun isActive(): Boolean = isSessionActive && System.currentTimeMillis() < timerEndTime

    fun getRemainingTimeMs(): Long {
        if (!isSessionActive) return 0
        val remaining = timerEndTime - System.currentTimeMillis()
        return if (remaining > 0) remaining else 0
    }

    // ─── Private ────────────────────────────────────────────────────

    private fun showLockScreen(packageName: String) {
        val intent = Intent(this, LockScreenActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("blocked_package", packageName)
            putExtra("remaining_ms", getRemainingTimeMs())
        }
        startActivity(intent)
    }

    private fun saveState() {
        prefs.edit().apply {
            putStringSet(KEY_BLOCKED_PACKAGES, blockedPackages)
            putLong(KEY_TIMER_END, timerEndTime)
            putBoolean(KEY_IS_ACTIVE, isSessionActive)
            apply()
        }
    }

    private fun loadState() {
        blockedPackages = prefs.getStringSet(KEY_BLOCKED_PACKAGES, emptySet()) ?: emptySet()
        timerEndTime = prefs.getLong(KEY_TIMER_END, 0)
        isSessionActive = prefs.getBoolean(KEY_IS_ACTIVE, false)

        // Check if timer has expired while service was off
        if (isSessionActive && System.currentTimeMillis() > timerEndTime) {
            stopSession()
        }
    }
}
