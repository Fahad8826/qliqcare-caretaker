package com.caretaker.qlickcare

import android.app.*
import android.content.Intent
import android.os.IBinder
import android.os.Build
import android.util.Log
import com.google.android.gms.location.*
import androidx.core.app.NotificationCompat
import java.util.*

class LocationForegroundService : Service() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback

    companion object {
        private const val CHANNEL_ID = "location_tracking_channel"
        private const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("BG_LOCATION", "🚀 Foreground Service CREATED")

        // Create notification channel first
        createNotificationChannel()

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (location in result.locations) {
                    sendLocationToFlutter(location.latitude, location.longitude)
                }
            }
        }

        startForeground(NOTIFICATION_ID, createNotification())
        startLocationUpdates()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Location Tracking Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows when QlickCare is tracking your location"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
            
            Log.d("BG_LOCATION", "✅ Notification channel created")
        }
    }

    private fun startLocationUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            // 15000L // 15 seconds
            900_000L  //15 minutes
        )
            .setMinUpdateDistanceMeters(0f)
            .setWaitForAccurateLocation(true)
            .build()

        try {
            fusedLocationClient.requestLocationUpdates(
                request,
                locationCallback,
                mainLooper
            )
            Log.d("BG_LOCATION", "📡 Location updates requested every 15s")
        } catch (e: SecurityException) {
            Log.e("BG_LOCATION", "❌ Location permission not granted: $e")
        }
    }

    
    private fun sendLocationToFlutter(lat: Double, lng: Double) {
    try {
        // Send as Double, NOT String! ✅
        MainActivity.channel?.invokeMethod("locationUpdate", mapOf(
            "latitude" to lat,   // Remove String.format
            "longitude" to lng   // Remove String.format
        ))
        Log.d("BG_LOCATION", "📍 Location sent: $lat, $lng")
    } catch (e: Exception) {
        Log.e("BG_LOCATION", "❌ Error sending location to Flutter: $e")
    }
}

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("QlickCare Location Service")
            .setContentText("Tracking your location in the background")
            .setSmallIcon(R.mipmap.ic_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    override fun onDestroy() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
        Log.d("BG_LOCATION", "🛑 Foreground Service DESTROYED")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}