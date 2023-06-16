package com.situm.situm_flutter_wayfinding

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Base64
import android.util.Log
import androidx.core.app.NotificationCompat

object Utils {

    const val TAG = "Situm>"

    fun decodeBitMapFromBase64(encodedBitmap: String?): Bitmap? {
        if (encodedBitmap == null) {
            return null;
        }
        try {
            val bytes = Base64.decode(encodedBitmap, Base64.DEFAULT)
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        } catch (e: IllegalArgumentException) {
            Log.d(TAG, "Android> Could not decode bitmap from base 64 string.")
            return null
        }
    }

    fun createNotification(actionText: String, context: Context): Notification {
        val channelId = context.getString(R.string.situm_sdk_foreground)
        if (Build.VERSION.SDK_INT >= 26) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val name = context.getString(R.string.app_background)
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(channelId, name, importance)
            notificationManager.createNotificationChannel(channel)
        }
        val builder = NotificationCompat.Builder(context, channelId)
        val stopIntent = Intent(context, SitumNotificationReceiver::class.java)
        stopIntent.action = SitumNotificationReceiver.STOP_ACTION
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            context, 0, stopIntent, flags
        )
        builder.apply {
            setContentTitle(context.getString(R.string.situm_notification_title))
            setSmallIcon(R.drawable.situm_ic_notification)
            addAction(R.drawable.situm_ic_notification, actionText, stopPendingIntent)
        }
        return builder.build()
    }
}