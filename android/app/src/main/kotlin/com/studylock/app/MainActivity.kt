package com.studylock.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "timelock_service"
        const val TAG = "TimeLockMainActivity"
        const val NOTIFICATION_CHANNEL_ID = "timelock_focus"
        const val NOTIFICATION_CHANNEL_NAME = "Focus Session"
    }

    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    Thread {
                        try {
                            val apps = getInstalledApps()
                            runOnUiThread { result.success(apps) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("ERROR", e.message, null) }
                        }
                    }.start()
                }

                "startFocusSession" -> {
                    val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                    val durationMinutes = call.argument<Int>("durationMinutes") ?: 0

                    val service = AppMonitorService.instance
                    if (service != null) {
                        service.startSession(packageNames, durationMinutes)
                        result.success(true)
                    } else {
                        // Service not running — save state to SharedPrefs for when it starts
                        val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, MODE_PRIVATE)
                        prefs.edit().apply {
                            putStringSet(AppMonitorService.KEY_BLOCKED_PACKAGES, packageNames.toSet())
                            putLong(AppMonitorService.KEY_TIMER_END,
                                System.currentTimeMillis() + (durationMinutes * 60 * 1000L))
                            putBoolean(AppMonitorService.KEY_IS_ACTIVE, true)
                            apply()
                        }
                        result.success(true)
                    }
                }

                "stopFocusSession" -> {
                    val service = AppMonitorService.instance
                    if (service != null) {
                        service.stopSession()
                    }
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, MODE_PRIVATE)
                    prefs.edit().apply {
                        putBoolean(AppMonitorService.KEY_IS_ACTIVE, false)
                        apply()
                    }
                    result.success(true)
                }

                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }

                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                }

                "isServiceRunning" -> {
                    result.success(AppMonitorService.instance != null)
                }

                "getBlockedPackages" -> {
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, MODE_PRIVATE)
                    val packages = prefs.getStringSet(AppMonitorService.KEY_BLOCKED_PACKAGES, emptySet())
                    result.success(packages?.toList() ?: emptyList<String>())
                }

                "saveBlockedPackages" -> {
                    val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, MODE_PRIVATE)
                    prefs.edit().apply {
                        putStringSet(AppMonitorService.KEY_BLOCKED_PACKAGES, packageNames.toSet())
                        apply()
                    }
                    val service = AppMonitorService.instance
                    service?.updateBlockedPackages(packageNames)
                    result.success(true)
                }

                "getRemainingTime" -> {
                    val service = AppMonitorService.instance
                    if (service != null) {
                        result.success(service.getRemainingTimeMs())
                    } else {
                        val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, MODE_PRIVATE)
                        val endTime = prefs.getLong(AppMonitorService.KEY_TIMER_END, 0)
                        val remaining = endTime - System.currentTimeMillis()
                        result.success(if (remaining > 0) remaining else 0L)
                    }
                }

                "showNotification" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        val title = call.argument<String>("title") ?: "TimeLock"
                        val body = call.argument<String>("body") ?: ""

                        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

                        // Create notification channel for Android 8+
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val channel = NotificationChannel(
                                NOTIFICATION_CHANNEL_ID,
                                NOTIFICATION_CHANNEL_NAME,
                                NotificationManager.IMPORTANCE_DEFAULT
                            ).apply {
                                description = "Notifications for focus session events"
                            }
                            notificationManager.createNotificationChannel(channel)
                        }

                        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
                            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
                            .setContentTitle(title)
                            .setContentText(body)
                            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                            .setAutoCancel(true)
                            .build()

                        notificationManager.notify(id, notification)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error showing notification", e)
                        result.error("NOTIFICATION_ERROR", e.message, null)
                    }
                }

                "cancelNotification" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        notificationManager.cancel(id)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error cancelling notification", e)
                        result.error("NOTIFICATION_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val apps = mutableListOf<Map<String, Any?>>()
        val systemExclusions = setOf(
            "com.android.settings",
            "com.android.phone",
            "com.android.emergency",
            "com.android.providers.contacts",
            "com.google.android.permissioncontroller",
            "com.google.android.packageinstaller",
            "com.android.systemui",
        )

        // Get all packages that have a launcher intent (appear in app drawer)
        val launchIntent = Intent(Intent.ACTION_MAIN, null)
        launchIntent.addCategory(Intent.CATEGORY_LAUNCHER)
        val launchableApps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(launchIntent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(launchIntent, 0)
        }

        for (resolveInfo in launchableApps) {
            val targetPackage = resolveInfo.activityInfo.packageName

            // Skip our own app and core system utilities users should not block.
            if (targetPackage == packageName) continue
            if (systemExclusions.contains(targetPackage)) continue

            try {
                val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    pm.getApplicationInfo(
                        targetPackage,
                        PackageManager.ApplicationInfoFlags.of(0),
                    )
                } else {
                    @Suppress("DEPRECATION")
                    pm.getApplicationInfo(targetPackage, 0)
                }
                val appName = pm.getApplicationLabel(appInfo).toString()
                val icon = pm.getApplicationIcon(appInfo)
                val iconBytes = drawableToBytes(icon)

                apps.add(mapOf(
                    "appName" to appName,
                    "packageName" to targetPackage,
                    "appIcon" to iconBytes,
                ))
            } catch (e: Exception) {
                Log.w(TAG, "Error loading app info for $targetPackage", e)
            }
        }

        return apps
            .distinctBy { it["packageName"] }
            .sortedBy { (it["appName"] as String).lowercase() }
    }

    private fun drawableToBytes(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        val scaled = Bitmap.createScaledBitmap(bitmap, 96, 96, true)
        val stream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponentName = ComponentName(this, AppMonitorService::class.java)
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServices)

        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledComponent = ComponentName.unflattenFromString(componentNameString)
            if (enabledComponent != null && enabledComponent == expectedComponentName) {
                return true
            }
        }
        return false
    }
}
