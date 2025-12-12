package com.pomodorostudy.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PomodoroWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.pomodoro_widget).apply {
                
                // Get data from shared preferences
                val timerState = widgetData.getString("timer_state", "idle") ?: "idle"
                val remainingTime = widgetData.getInt("remaining_time", 0)
                val sessionType = widgetData.getString("session_type", "study") ?: "study"
                val themeName = widgetData.getString("theme_name", "Classic") ?: "Classic"
                val taskName = widgetData.getString("task_name", "") ?: ""
                val todayPomodoros = widgetData.getInt("today_pomodoros", 0)
                val todayMinutes = widgetData.getInt("today_minutes", 0)
                val currentStreak = widgetData.getInt("current_streak", 0)

                // Format time
                val minutes = remainingTime / 60
                val seconds = remainingTime % 60
                val timeText = String.format("%02d:%02d", minutes, seconds)

                // Update views
                setTextViewText(R.id.widget_time, timeText)
                setTextViewText(R.id.widget_session_type, 
                    if (sessionType == "study") "Học tập" else "Nghỉ giải lao"
                )
                setTextViewText(R.id.widget_theme_name, themeName)
                setTextViewText(R.id.widget_task_name, 
                    if (taskName.isNotEmpty()) "📝 $taskName" else ""
                )
                setTextViewText(R.id.widget_today_pomodoros, todayPomodoros.toString())
                setTextViewText(R.id.widget_streak, currentStreak.toString())
                setTextViewText(R.id.widget_today_minutes, todayMinutes.toString())

                // Set text color based on state
                val timeColor = when {
                    timerState == "idle" -> android.graphics.Color.parseColor("#757575")
                    sessionType == "study" -> android.graphics.Color.parseColor("#2E7D32")
                    else -> android.graphics.Color.parseColor("#1976D2")
                }
                setTextColor(R.id.widget_time, timeColor)

                // Set click intent to open app
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
