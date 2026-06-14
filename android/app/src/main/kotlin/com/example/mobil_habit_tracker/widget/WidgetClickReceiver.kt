package com.example.mobil_habit_tracker.widget

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetPlugin
import com.example.mobil_habit_tracker.R
import org.json.JSONArray

/**
 * BroadcastReceiver that handles widget row taps natively on the Android side.
 *
 * This toggles the completion status directly in SharedPreferences (the shared
 * store used by home_widget) and refreshes the widget. When the app is opened
 * next, the Dart background callback will reconcile the real Hive data.
 *
 * This approach is more reliable than relying on the Dart background isolate
 * for every tap, which can silently fail on some devices/OS versions.
 */
class WidgetClickReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_TOGGLE = "com.example.mobil_habit_tracker.WIDGET_TOGGLE"
        const val EXTRA_TYPE = "toggle_type"   // "habit" or "quest"
        const val EXTRA_ID = "toggle_id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TOGGLE) return

        val type = intent.getStringExtra(EXTRA_TYPE) ?: return
        val id = intent.getStringExtra(EXTRA_ID) ?: return

        val prefs = HomeWidgetPlugin.getData(context)

        when (type) {
            "habit" -> toggleHabit(context, prefs, id)
            "quest" -> toggleQuest(context, prefs, id)
        }

        // Also fire the home_widget background callback so Hive gets updated
        // when the Dart isolate can start.
        val bgIntent = Intent().apply {
            action = WidgetConstants.BACKGROUND_ACTION
            component = ComponentName(
                context,
                "es.antonborri.home_widget.HomeWidgetBackgroundReceiver"
            )
            data = Uri.parse("habitwidget://toggle?type=$type&id=$id")
        }
        context.sendBroadcast(bgIntent)
    }

    private fun toggleHabit(context: Context, prefs: android.content.SharedPreferences, id: String) {
        val json = prefs.getString("habits_json", "[]") ?: "[]"
        val arr = try { JSONArray(json) } catch (_: Exception) { return }

        var completedCount = 0
        for (i in 0 until arr.length()) {
            val obj = arr.optJSONObject(i) ?: continue
            if (obj.optString("id") == id) {
                val newVal = !obj.optBoolean("completed", false)
                obj.put("completed", newVal)
            }
            if (arr.optJSONObject(i)?.optBoolean("completed", false) == true) {
                completedCount++
            }
        }

        val progress = if (arr.length() == 0) 0 else ((completedCount.toFloat() / arr.length()) * 100).toInt()

        prefs.edit()
            .putString("habits_json", arr.toString())
            .putInt("habits_progress", progress)
            .apply()

        // Refresh the widget
        val manager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, HabitsWidgetProvider::class.java)
        val widgetIds = manager.getAppWidgetIds(component)
        manager.notifyAppWidgetViewDataChanged(widgetIds, R.id.widget_list)

        val updateIntent = Intent(context, HabitsWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
        }
        context.sendBroadcast(updateIntent)
    }

    private fun toggleQuest(context: Context, prefs: android.content.SharedPreferences, id: String) {
        val json = prefs.getString("quests_json", "[]") ?: "[]"
        val arr = try { JSONArray(json) } catch (_: Exception) { return }

        var completedCount = 0
        for (i in 0 until arr.length()) {
            val obj = arr.optJSONObject(i) ?: continue
            if (obj.optString("id") == id) {
                val newVal = !obj.optBoolean("completed", false)
                obj.put("completed", newVal)
            }
            if (arr.optJSONObject(i)?.optBoolean("completed", false) == true) {
                completedCount++
            }
        }

        val progress = if (arr.length() == 0) 0 else ((completedCount.toFloat() / arr.length()) * 100).toInt()

        prefs.edit()
            .putString("quests_json", arr.toString())
            .putInt("quests_progress", progress)
            .apply()

        val manager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, QuestsWidgetProvider::class.java)
        val widgetIds = manager.getAppWidgetIds(component)
        manager.notifyAppWidgetViewDataChanged(widgetIds, R.id.widget_list)

        val updateIntent = Intent(context, QuestsWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
        }
        context.sendBroadcast(updateIntent)
    }
}
