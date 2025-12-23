package com.caretaker.qlickcare

import android.content.Intent
import android.annotation.SuppressLint
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.location.*

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.qliq/location"
        var channel: MethodChannel? = null // Make it static and nullable
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the static channel
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        channel?.setMethodCallHandler { call, result ->

            when (call.method) {

                "getLocation" -> getSingleLocation(result)

                "startLocationService" -> {
                    startService(
                        Intent(this, LocationForegroundService::class.java)
                    )
                    result.success(null)
                }

                "stopLocationService" -> {
                    stopService(
                        Intent(this, LocationForegroundService::class.java)
                    )
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }


    @SuppressLint("MissingPermission")
    private fun getSingleLocation(result: MethodChannel.Result) {
        val client = LocationServices.getFusedLocationProviderClient(this)

        // Request ONE fresh location
        client.getCurrentLocation(
            Priority.PRIORITY_HIGH_ACCURACY,
            null
        ).addOnSuccessListener { location ->
            if (location != null) {
                // Send as Double, NOT String! ✅
                result.success(
                    mapOf(
                        "latitude" to location.latitude,   // Remove String.format
                        "longitude" to location.longitude  // Remove String.format
                    )
                )
            } else {
                result.error("NO_LOCATION", "Location is null", null)
            }
        }.addOnFailureListener { e ->
            result.error("LOCATION_ERROR", e.message, null)
        }
    }
}