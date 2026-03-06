package com.example.study_lock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receiver that triggers after device reboot.
 * The AccessibilityService will auto-restart if enabled in system settings,
 * but this receiver ensures we log the event and can take additional actions.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        const val TAG = "TimeLockBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {

            Log.d(TAG, "Boot completed — checking for active session")

            // The AccessibilityService will auto-restart if the user has enabled it.
            // We just need to check if there's an active session that should still be running.
            val prefs = context.getSharedPreferences(
                AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE
            )

            val isActive = prefs.getBoolean(AppMonitorService.KEY_IS_ACTIVE, false)
            val endTime = prefs.getLong(AppMonitorService.KEY_TIMER_END, 0)

            if (isActive && System.currentTimeMillis() < endTime) {
                Log.d(TAG, "Active session found — service will resume when accessibility starts")
            } else if (isActive) {
                // Timer expired during reboot
                Log.d(TAG, "Session expired during reboot — clearing state")
                prefs.edit().apply {
                    putBoolean(AppMonitorService.KEY_IS_ACTIVE, false)
                    apply()
                }
            }
        }
    }
}
