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
 * Home-screen widget showing today's habits. Each row toggles completion via a
 * background broadcast to the home_widget plugin (which runs Dart code).
 */
class HabitsWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_habits)

            views.setTextViewText(R.id.widget_title, "Habits")

            val emptyReason = widgetData.getString("habits_empty_reason", "none")
            if (emptyReason == "logged_out") {
                views.setTextViewText(R.id.widget_empty, "Please log in")
            } else {
                views.setTextViewText(R.id.widget_empty, "No habits today")
            }

            val progress = widgetData.getInt("habits_progress", 0)
            views.setProgressBar(R.id.widget_progress, 100, progress, false)

            // Bind the scrollable list to its RemoteViewsService.
            val serviceIntent = Intent(context, HabitsRemoteViewsService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.widget_list, serviceIntent)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)

            // Template intent for row taps -> background receiver (Dart callback).
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
