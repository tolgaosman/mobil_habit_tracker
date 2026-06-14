package com.example.mobil_habit_tracker.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import com.example.mobil_habit_tracker.R
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget showing today's random side quests (easy/medium/hard).
 */
class QuestsWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quests)

            views.setTextViewText(R.id.widget_title, "Daily Quests")

            val emptyReason = widgetData.getString("quests_empty_reason", "none")
            if (emptyReason == "logged_out") {
                views.setTextViewText(R.id.widget_empty, "Please log in")
            } else {
                views.setTextViewText(R.id.widget_empty, "No quests today")
            }

            val progress = widgetData.getInt("quests_progress", 0)
            views.setProgressBar(R.id.widget_progress, 100, progress, false)

            val serviceIntent = Intent(context, QuestsRemoteViewsService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.widget_list, serviceIntent)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)

            val toggleIntent = Intent().apply {
                action = WidgetConstants.BACKGROUND_ACTION
                component = ComponentName(
                    context,
                    "es.antonborri.home_widget.HomeWidgetBackgroundReceiver"
                )
            }
            var flags = PendingIntent.FLAG_UPDATE_CURRENT
            if (Build.VERSION.SDK_INT >= 31) {
                flags = flags or PendingIntent.FLAG_MUTABLE
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, widgetId, toggleIntent, flags
            )
            views.setPendingIntentTemplate(R.id.widget_list, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list)
        }
    }
}
