package com.example.mobil_habit_tracker.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.example.mobil_habit_tracker.R
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class QuestsRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        QuestsRemoteViewsFactory(applicationContext)
}

class QuestsRemoteViewsFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private var items: JSONArray = JSONArray()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = HomeWidgetPlugin.getData(context)
        val json = prefs.getString("quests_json", "[]") ?: "[]"
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
        val views = RemoteViews(context.packageName, R.layout.widget_row_quest)
        val item = items.optJSONObject(position) ?: return views

        val id = item.optString("id")
        val title = item.optString("title")
        val difficulty = item.optString("difficulty", "easy")
        val completed = item.optBoolean("completed", false)

        views.setTextViewText(R.id.row_title, title)
        views.setImageViewResource(
            R.id.row_dot,
            when (difficulty) {
                "hard" -> R.drawable.widget_dot_hard
                "medium" -> R.drawable.widget_dot_medium
                else -> R.drawable.widget_dot_easy
            }
        )
        views.setImageViewResource(
            R.id.row_check,
            if (completed) R.drawable.widget_check_on else R.drawable.widget_check_off
        )

        val uri = Uri.parse("habitwidget://toggle?type=quest&id=$id")
        val fillIn = Intent().apply { data = uri }
        views.setOnClickFillInIntent(R.id.row_root, fillIn)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long =
        items.optJSONObject(position)?.optString("id")?.hashCode()?.toLong() ?: position.toLong()

    override fun hasStableIds(): Boolean = true
}
