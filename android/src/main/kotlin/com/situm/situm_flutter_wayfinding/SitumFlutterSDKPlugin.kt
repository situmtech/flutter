package com.situm.situm_flutter_wayfinding

import android.content.Context
import androidx.annotation.NonNull
import es.situm.sdk.SitumSdk
import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationListener
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.location.LocationStatus
import es.situm.sdk.model.location.Location
import es.situm.sdk.utils.Handler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// SitumFlutterSDKPlugin.
// Right now WYF does not have a plugin class (extending FlutterPlugin), it does require
// the view factory to be registered from the main activity.
// TODO: create a separated plugin for SitumSdk.
class SitumFlutterSDKPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var locationListener: LocationListener? = null
    private var context: Context? = null

    companion object {
        const val CHANNEL_ID_SDK = "situm.com/flutter_sdk"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_ID_SDK)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        val arguments = (methodCall.arguments ?: emptyMap<String, Any>()) as Map<String, Any>
        when (methodCall.method) {
            "init" -> init(arguments, result)
            "requestLocationUpdates" -> requestLocationUpdates(arguments, result)
            "removeUpdates" -> removeUpdates(result)
            "prefetchPositioningInfo" -> prefetchPositioningInfo(arguments, result)
            "geofenceCallbacksRequested" -> geofenceCallbacksRequested(arguments, result)
            else -> result.notImplemented()
        }
    }

    // Public methods:

    private fun init(arguments: Map<String, Any>, result: MethodChannel.Result) {
        SitumSdk.init(context)
        SitumSdk.configuration()
            .setApiKey(arguments["situmUser"] as String, arguments["situmApiKey"] as String)
        result.success("DONE")
    }

    private fun requestLocationUpdates(arguments: Map<String, Any>, result: MethodChannel.Result) {
        locationListener?.let {
            SitumSdk.locationManager().removeUpdates(it)
        }
        val locationRequest = LocationRequest.Builder().build()
        // TODO: fromArguments(arguments)
        locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                val callbackArgs = mutableMapOf<String, String>(
                    "buildingId" to location.buildingIdentifier
                )
                channel.invokeMethod("onLocationChanged", callbackArgs)
            }

            override fun onStatusChanged(status: LocationStatus) {
                val callbackArgs = mutableMapOf<String, String>(
                    "status" to status.name
                )
                channel.invokeMethod("onStatusChanged", callbackArgs)
            }

            override fun onError(error: Error) {
                val callbackArgs = mutableMapOf<String, Any>(
                    "code" to error.code,
                    "message" to error.message
                )
                channel.invokeMethod("onError", callbackArgs)
            }
        }
        SitumSdk.locationManager().requestLocationUpdates(locationRequest, locationListener!!)
        result.success("DONE")
    }

    private fun removeUpdates(result: MethodChannel.Result) {
        locationListener?.let {
            SitumSdk.locationManager().removeUpdates(it)
        }
        result.success("DONE")
    }

    private fun prefetchPositioningInfo(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val buildingIdentifiers = arguments["buildingIdentifiers"] as List<String>
        SitumSdk.communicationManager()
            .prefetchPositioningInfo(buildingIdentifiers, object : Handler<String> {
                override fun onSuccess(s: String) {
                    result.success("DONE")
                }

                override fun onFailure(error: Error) {
                    result.error(error.code.toString(), error.message, null)
                }

            })
    }

    private fun geofenceCallbacksRequested(
        arguments: Map<String, Any>,
        result: MethodChannel.Result
    ) {
        // TODO: waiting for SDK to be released.
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        context = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        context = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        context = binding.activity
    }

    override fun onDetachedFromActivity() {
        context = null
    }
}
