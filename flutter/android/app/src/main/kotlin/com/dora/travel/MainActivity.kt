package com.dora.travel

import android.app.Activity
import android.content.Intent
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.Priority
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingLocationResolutionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_LOCATION_SETTINGS,
        ).setMethodCallHandler(::onLocationSettingsMethodCall)
    }

    private fun onLocationSettingsMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_PROMPT_ENABLE_LOCATION -> promptEnableLocation(result)
            else -> result.notImplemented()
        }
    }

    private fun promptEnableLocation(result: MethodChannel.Result) {
        if (pendingLocationResolutionResult != null) {
            result.error(
                "resolution_in_progress",
                "A location settings resolution is already in progress.",
                null,
            )
            return
        }

        val request = LocationSettingsRequest.Builder()
            .addLocationRequest(
                LocationRequest.Builder(
                    Priority.PRIORITY_HIGH_ACCURACY,
                    10_000L,
                ).setMinUpdateIntervalMillis(5_000L).build(),
            )
            .setAlwaysShow(true)
            .build()

        LocationServices.getSettingsClient(this)
            .checkLocationSettings(request)
            .addOnSuccessListener {
                result.success(true)
            }
            .addOnFailureListener { error ->
                val resolvable = error as? ResolvableApiException
                if (resolvable == null) {
                    result.success(false)
                    return@addOnFailureListener
                }
                pendingLocationResolutionResult = result
                try {
                    resolvable.startResolutionForResult(
                        this,
                        REQUEST_CODE_ENABLE_LOCATION,
                    )
                } catch (_: Exception) {
                    pendingLocationResolutionResult = null
                    result.success(false)
                }
            }
    }

    @Deprecated("Use Activity Result APIs where possible.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_CODE_ENABLE_LOCATION) {
            return
        }
        val pending = pendingLocationResolutionResult
        pendingLocationResolutionResult = null
        pending?.success(resultCode == Activity.RESULT_OK)
    }

    companion object {
        private const val CHANNEL_LOCATION_SETTINGS = "com.dora.travel/location_settings"
        private const val METHOD_PROMPT_ENABLE_LOCATION = "promptEnableLocation"
        private const val REQUEST_CODE_ENABLE_LOCATION = 9102
    }
}
