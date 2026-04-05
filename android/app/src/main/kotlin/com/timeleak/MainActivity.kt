package com.timeleak

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.timeleak/usage_stats"
    private lateinit var usageStatsHelper: UsageStatsHelper

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        usageStatsHelper = UsageStatsHelper(context)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    val hasPermission = usageStatsHelper.hasUsageStatsPermission()
                    result.success(hasPermission)
                }
                "requestPermission" -> {
                    // Start an intent to usage access settings
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                    result.success(true)
                }
                "getUsageStats" -> {
                    val startTime = call.argument<Long>("startTime") ?: 0L
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                    val stats = usageStatsHelper.getUsageStats(startTime, endTime)
                    result.success(stats)
                }
                "getAppSwitches" -> {
                    val startTime = call.argument<Long>("startTime") ?: 0L
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                    val events = usageStatsHelper.getAppSwitches(startTime, endTime)
                    result.success(events)
                }
                "getAppLabel" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val label = usageStatsHelper.getAppLabel(packageName)
                    result.success(label)
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val icon = usageStatsHelper.getAppIcon(packageName)
                    result.success(icon)
                }
                "getAppCategory" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val category = usageStatsHelper.getAppCategory(packageName)
                    result.success(category)
                }
                "startFocusMode" -> {
                    startLockTask()
                    result.success(true)
                }
                "stopFocusMode" -> {
                    try {
                        stopLockTask()
                    } catch (e: Exception) {
                        // ignore if not locked
                    }
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
