package com.example.mobil_habit_tracker.widget

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.example.mobil_habit_tracker.R
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class HabitsRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        HabitsRemoteViewsFactory(applicationContext)
}

class HabitsRemoteViewsFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private var items: JSONArray = JSONArray()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = HomeWidgetPlugin.getData(context)
        val json = prefs.getString("habits_json", "[]") ?: "[]"
        items = try {
            JSONArray(json)
        } catch (e: Exception) {
            JSONArray()
        }
    }

    override fun onDestroy() {
        items = JSONArray()
    }

    override fun getCount(): Int = items.length()

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_row_habit)
        val item = items.optJSONObject(position) ?: return views

        val id = item.optString("id")
        val name = item.optString("name")
        val completed = item.optBoolean("completed", false)
        val accent = parseHabitColor(item.optString("colorHex"))

        views.setTextViewText(R.id.row_title, name)
        // Tint the per-row accent dot with the habit's own color.
        views.setInt(R.id.row_icon, "setColorFilter", accent)
        views.setImageViewResource(
            R.id.row_check,
            if (completed) R.drawable.widget_check_on else R.drawable.widget_check_off
        )

        // Per-row fill-in intent: carries the type and id as extras + unique data URI.
        val fillIn = Intent().apply {
            putExtra(WidgetClickReceiver.EXTRA_TYPE, "habit")
            putExtra(WidgetClickReceiver.EXTRA_ID, id)
            // Unique data URI is critical so Android doesn't deduplicate PendingIntents.
            data = Uri.parse("habitwidget://toggle?type=habit&id=$id")
        }
        views.setOnClickFillInIntent(R.id.row_root, fillIn)

        return views
    }

    /** Habit colorHex is stored as "AARRGGBB" or "RRGGBB" (no leading #). */
    private fun parseHabitColor(hex: String): Int {
        return try {
            var clean = hex.trim().removePrefix("#")
            if (clean.length == 6) clean = "FF$clean"
            Color.parseColor("#$clean")
        } catch (e: Exception) {
            Color.parseColor("#5B7C6A") // sage fallback (= widget_teal)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long =
        items.optJSONObject(position)?.optString("id")?.hashCode()?.toLong() ?: position.toLong()

    override fun hasStableIds(): Boolean = true
}
