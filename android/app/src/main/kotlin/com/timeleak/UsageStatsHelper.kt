package com.timeleak

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Process
import java.io.ByteArrayOutputStream
import java.util.Calendar

class UsageStatsHelper(private val context: Context) {

    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun getUsageStats(startTime: Long, endTime: Long): List<Map<String, Any>> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        // queryAndAggregateUsageStats can be unreliable on some devices/versions.
        // queryUsageStats with INTERVAL_DAILY is more robust.
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, 
            startTime, 
            endTime
        )
        
        if (stats == null || stats.isEmpty()) return emptyList()

        // Manually aggregate by packageName to ensure we don't miss entries
        val aggregatedStats = mutableMapOf<String, Map<String, Any>>()
        
        for (stat in stats) {
            if (stat.totalTimeInForeground <= 0) continue
            
            val pkg = stat.packageName
            val existing = aggregatedStats[pkg]
            
            if (existing == null) {
                aggregatedStats[pkg] = mapOf(
                    "packageName" to pkg,
                    "totalTimeInForeground" to stat.totalTimeInForeground,
                    "firstTimeStamp" to stat.firstTimeStamp,
                    "lastTimeStamp" to stat.lastTimeStamp
                )
            } else {
                // If there are multiple entries for the same package, sum the time
                val currentTotal = existing["totalTimeInForeground"] as Long
                aggregatedStats[pkg] = mapOf(
                    "packageName" to pkg,
                    "totalTimeInForeground" to currentTotal + stat.totalTimeInForeground,
                    "firstTimeStamp" to Math.min(existing["firstTimeStamp"] as Long, stat.firstTimeStamp),
                    "lastTimeStamp" to Math.max(existing["lastTimeStamp"] as Long, stat.lastTimeStamp)
                )
            }
        }
        
        return aggregatedStats.values.toList()
    }

    fun getAppSwitches(startTime: Long, endTime: Long): List<Map<String, Any>> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(startTime, endTime)
        
        val eventList = mutableListOf<Map<String, Any>>()
        val event = UsageEvents.Event()
        
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            // 1 = ACTIVITY_RESUMED, 2 = ACTIVITY_PAUSED, 18 = KEYGUARD_HIDDEN
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED || 
                event.eventType == UsageEvents.Event.ACTIVITY_PAUSED ||
                event.eventType == UsageEvents.Event.KEYGUARD_HIDDEN) {
                
                eventList.add(
                    mapOf(
                        "packageName" to event.packageName,
                        "timeStamp" to event.timeStamp,
                        "eventType" to event.eventType
                    )
                )
            }
        }
        
        return eventList
    }

    fun getAppLabel(packageName: String): String {
        return try {
            val pm = context.packageManager
            val info = pm.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            pm.getApplicationLabel(info).toString()
        } catch (e: Exception) {
            packageName
        }
    }

    fun getAppCategory(packageName: String): Int {
        return try {
            val pm = context.packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                info.category
            } else {
                -1 // CATEGORY_UNDEFINED
            }
        } catch (e: Exception) {
            -1
        }
    }

    fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val pm = context.packageManager
            val icon = pm.getApplicationIcon(packageName)
            val bitmap = drawableToBitmap(icon)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            if (drawable.bitmap != null) {
                return drawable.bitmap
            }
        }
        val bitmap = if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {
            Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        } else {
            Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        }
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
