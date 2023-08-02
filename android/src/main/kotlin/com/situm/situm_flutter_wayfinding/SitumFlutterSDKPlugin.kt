package com.situm.situm_flutter_wayfinding

import android.app.Notification
import android.content.Context
import android.os.Looper
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import es.situm.sdk.SitumSdk
import es.situm.sdk.communication.CommunicationConfigImpl
import es.situm.sdk.configuration.network.NetworkOptionsImpl
import es.situm.sdk.error.Error
import es.situm.sdk.location.GeofenceListener
import es.situm.sdk.location.LocationListener
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.location.LocationStatus
import es.situm.sdk.model.cartography.Building;
import es.situm.sdk.model.cartography.BuildingInfo;
import es.situm.sdk.model.cartography.Poi;
import es.situm.sdk.model.cartography.PoiCategory;
import es.situm.sdk.model.cartography.Geofence;
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
    private var geofenceListener: GeofenceListener? = null
    private var context: Context? = null
    private var handler = android.os.Handler(Looper.getMainLooper())

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
            "setConfiguration" -> setConfiguration(arguments, result)
            "requestLocationUpdates" -> requestLocationUpdates(arguments, result)
            "removeUpdates" -> removeUpdates(result)
            "prefetchPositioningInfo" -> prefetchPositioningInfo(arguments, result)
            "geofenceCallbacksRequested" -> geofenceCallbacksRequested(result)
            "fetchPoisFromBuilding" -> fetchPoisFromBuilding(arguments, result)
            "fetchCategories" -> fetchCategories(result)
            "clearCache" -> clearCache(result)
            "fetchBuildingInfo" -> fetchBuildingInfo(arguments, result)
            "fetchBuildings" -> fetchBuildings(result)
            "getDeviceId" -> getDeviceId(result)
            else -> result.notImplemented()
        }
    }

    // Public methods (impl):

    private fun setConfiguration(arguments: Map<String, Any>, result: MethodChannel.Result) {
        if (arguments.containsKey("useRemoteConfig")) {
            SitumSdk.configuration().isUseRemoteConfig = arguments["useRemoteConfig"] as Boolean
        }
        result.success("DONE")
    }

    private fun fetchBuildings(result: MethodChannel.Result) {
        SitumSdk.communicationManager().fetchBuildings(object: Handler<Collection<Building>> {
            override fun onSuccess(buildings: Collection<Building>) {
                result.success(buildings.toMap())
            }

            override fun onFailure(error: Error) {
                result.notifySitumSdkError(error)
            }

        })
    }

    private fun fetchBuildingInfo(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val buildingId = arguments["buildingId"] as String
        SitumSdk.communicationManager()
            .fetchBuildingInfo(buildingId, object : Handler<BuildingInfo> {
                override fun onSuccess(buildingInfo: BuildingInfo) {
                    result.success(buildingInfo.toMap())
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                }
            })
    }

    private fun fetchCategories(result: MethodChannel.Result) {
        SitumSdk.communicationManager()
            .fetchPoiCategories(object : Handler<Collection<PoiCategory>> {
                override fun onSuccess(categories: Collection<PoiCategory>) {
                    result.success(categories.toMap())
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                }

            })
    }

    private fun fetchPoisFromBuilding(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val buildingId = arguments["buildingId"] as String
        SitumSdk.communicationManager()
            .fetchIndoorPOIsFromBuilding(buildingId, object : Handler<Collection<Poi>> {
                override fun onSuccess(pois: Collection<Poi>) {
                    result.success(pois.toMap())
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                }
            })
    }

    private fun init(arguments: Map<String, Any>, result: MethodChannel.Result) {
        SitumSdk.init(context)
        SitumSdk.configuration()
            .setApiKey(arguments["situmUser"] as String, arguments["situmApiKey"] as String)
        result.success("DONE")
    }

    private fun requestLocationUpdates(arguments: Map<String, Any>, result: MethodChannel.Result) {
        locationListener?.let {
            SitumSdk.locationManager().removeLocationListener(it)
        }
        val locationRequest = LocationRequest.Builder()
            .fromArguments(arguments)
            .foregroundServiceNotification(Utils.createNotification("Stop", context!!))
            .build()
        locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                val callbackArgs = mutableMapOf<String, String>(
                    "buildingId" to location.buildingIdentifier
                )
                handler.post { channel.invokeMethod("onLocationChanged", callbackArgs) }
            }

            override fun onStatusChanged(status: LocationStatus) {
                val callbackArgs = mutableMapOf<String, String>(
                    "status" to status.name
                )
                handler.post {
                    channel.invokeMethod("onStatusChanged", callbackArgs)
                }
            }

            override fun onError(error: Error) {
                handler.post {
                    channel.invokeMethod("onError", error.toDartError())
                }
            }
        }
        SitumSdk.locationManager().addLocationListener(locationListener!!)
        SitumSdk.locationManager().requestLocationUpdates(locationRequest)
        result.success("DONE")
    }

    private fun removeUpdates(result: MethodChannel.Result) {
        SitumSdk.locationManager().let { manager ->
            manager.removeUpdates()
            locationListener?.let {
                manager.removeLocationListener(it)
            }
        }
        result.success("DONE")
    }

    private fun prefetchPositioningInfo(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val buildingIdentifiers = arguments["buildingIdentifiers"] as List<String>
        val optionsBuilder = NetworkOptionsImpl.Builder()
        val optionsMap = (arguments["optionsMap"] ?: emptyMap<String, Any>()) as Map<String, Any>
        if (optionsMap.containsKey("preloadImages")) {
            optionsBuilder.setPreloadImages(optionsMap["preloadImages"] as Boolean)
        }
        val config = CommunicationConfigImpl(optionsBuilder.build())
        SitumSdk.communicationManager()
            .prefetchPositioningInfo(buildingIdentifiers, config, object : Handler<String> {
                override fun onSuccess(s: String) {
                    result.success("DONE")
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                }
            })
    }

    private fun geofenceCallbacksRequested(
        result: MethodChannel.Result
    ) {
        geofenceListener = object : GeofenceListener {
            override fun onEnteredGeofences(enteredGeofences: List<Geofence>) {
                val geofencesMap = enteredGeofences.toMap()
                channel.invokeMethod("onEnteredGeofences", geofencesMap)
            }

            override fun onExitedGeofences(exitedGeofences: List<Geofence>) {
                val geofencesMap = exitedGeofences.toMap()
                channel.invokeMethod("onExitedGeofences", geofencesMap)
            }
        }
        SitumSdk.locationManager().setGeofenceListener(geofenceListener)
        result.success("DONE")
    }

    private fun clearCache(result: MethodChannel.Result) {
        SitumSdk.communicationManager().invalidateCache()
        result.success("DONE")
    }

    private fun getDeviceId(result: MethodChannel.Result) {
        val deivceId = SitumSdk.getDeviceID()
        result.success(deivceId.toString())
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
