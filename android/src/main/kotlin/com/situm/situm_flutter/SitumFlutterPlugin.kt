package com.situm.situm_flutter

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import es.situm.sdk.SitumSdk
import es.situm.sdk.communication.CommunicationConfigImpl
import es.situm.sdk.configuration.network.NetworkOptionsImpl
import es.situm.sdk.error.Error
import es.situm.sdk.location.ExternalArData
import es.situm.sdk.location.GeofenceListener
import es.situm.sdk.location.LocationListener
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.location.LocationStatus
import es.situm.sdk.location.ExternalLocation
import es.situm.sdk.model.cartography.*
import es.situm.sdk.model.location.Location
import es.situm.sdk.utils.Handler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// SitumFlutterPlugin.
class SitumFlutterPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var navigation: Navigation
    private lateinit var viewerNavigation: ViewerNavigation
    private var locationListener: LocationListener? = null
    private var geofenceListener: GeofenceListener? = null
    private var context: Context? = null
    private var handler = android.os.Handler(Looper.getMainLooper())
    private var ttsManager: TextToSpeechManager? = null

    // Add this config to avoid preloading images. The default value for preloadImages is true but
    // this might cause performance issues.
    private val NO_PRELOAD_IMAGES_CONFIG = CommunicationConfigImpl(
        NetworkOptionsImpl.Builder().setPreloadImages(false).build()
    )

    companion object {
        private var initialized = false
        const val CHANNEL_ID_SDK = "situm.com/flutter_sdk"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("Situm", "Situm> SitumFlutterPlugin> onAttachedToEngine initialized=$initialized")
        // Firebase remote message issue:
        if (initialized) {
            return
        }
        initialized = true
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_ID_SDK)
        channel.setMethodCallHandler(this)
        navigation = Navigation.init(channel, handler)
        viewerNavigation = ViewerNavigation.init(channel, handler)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("Situm", "Situm> SitumFlutterPlugin> onDetachedFromEngine - initialized=$initialized")
        // onDetachedFromEngine should be called only when the app using this plugin is finalized,
        // but should not be related to the Firebase issue.
        if (initialized) {
            channel.setMethodCallHandler(null)
            initialized = false
        }
        // Avoid leaking this listener:
        locationListener?.let {
            SitumSdk.locationManager().removeLocationListener(it)
        }
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        val arguments = (methodCall.arguments ?: emptyMap<String, Any>()) as Map<String, Any>
        when (methodCall.method) {
            "init" -> init(arguments, result)
            "initSdk" -> initSdk(result)
            "addExternalArData" -> addExternalArData(arguments, result)
            "setDashboardURL" -> setDashboardURL(arguments, result)
            "setApiKey" -> setApiKey(arguments, result)
            "setUserPass" -> setUserPass(arguments, result)
            "logout" -> logout(result)
            "setConfiguration" -> setConfiguration(arguments, result)
            "requestLocationUpdates" -> requestLocationUpdates(arguments, result)
            "removeUpdates" -> removeUpdates(result)
            "addExternalLocation" -> addExternalLocation(arguments, result)
            "prefetchPositioningInfo" -> prefetchPositioningInfo(arguments, result)
            "geofenceCallbacksRequested" -> geofenceCallbacksRequested(result)
            "fetchPoisFromBuilding" -> fetchPoisFromBuilding(arguments, result)
            "fetchPoiFromBuilding" -> fetchPoiFromBuilding(arguments, result)
            "fetchCategories" -> fetchCategories(result)
            "clearCache" -> clearCache(result)
            "fetchBuildingInfo" -> fetchBuildingInfo(arguments, result)
            "fetchBuildings" -> fetchBuildings(result)
            "getDeviceId" -> getDeviceId(result)
            "requestDirections" -> requestDirections(arguments, result)
            "requestNavigation" -> requestNavigation(arguments, result)
            "stopNavigation" -> stopNavigation(result)
            "openUrlInDefaultBrowser" -> openUrlInDefaultBrowser(arguments, result)
            "updateNavigationState" -> updateNavigationState(arguments, result)
            "requestAutoStop" -> requestAutoStop(arguments, result)
            "removeAutoStop" -> removeAutoStop(result)
            "speakAloudText" -> speakAloudText(arguments, result)
            else -> result.notImplemented()
        }
    }

    // Private methods:

    // Start listening location updates, regardless of whether the positioning has been initiated or not.
    private fun startListeningLocationUpdates() {
        locationListener?.let {
            SitumSdk.locationManager().removeLocationListener(it)
        }

        locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                handler.post { channel.invokeMethod("onLocationChanged", location.toMap()) }
            }

            override fun onStatusChanged(status: LocationStatus) {
                handler.post {
                    channel.invokeMethod("onStatusChanged", status.toMap())
                }
            }

            override fun onError(error: Error) {
                handler.post {
                    channel.invokeMethod("onError", error.toDartError())
                }
            }
        }
        SitumSdk.locationManager().addLocationListener(locationListener!!)
    }

    private fun onSdkInitialized() {
        startListeningLocationUpdates()
        SitumSdk.navigationManager().addNavigationListener(navigation)
    }

    // Public methods (impl):

    private fun init(arguments: Map<String, Any>, result: MethodChannel.Result) {
        SitumSdk.init(context)
        SitumSdk.configuration()
            .setApiKey(arguments["situmUser"] as String, arguments["situmApiKey"] as String)
        onSdkInitialized()
        result.success("DONE")
    }

    private fun addExternalArData(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val externalArData = ExternalArData.Builder().rawJsonString(arguments.toString()).build()
        SitumSdk.locationManager().addExternalArData(externalArData)
        result.success("DONE")
    }


    private fun initSdk(result: MethodChannel.Result) {
        SitumSdk.init(context)
        onSdkInitialized()
        result.success("DONE")
    }

    private fun setDashboardURL(arguments: Map<String, Any>, result: MethodChannel.Result) {
        if (arguments.containsKey("url")) {
            SitumSdk.configuration().setDashboardURL(arguments["url"] as String)
        }
        result.success("DONE")
    }

    private fun setApiKey(arguments: Map<String, Any>, result: MethodChannel.Result) {
        SitumSdk.configuration()
            .setApiKey(arguments["situmUser"] as String, arguments["situmApiKey"] as String)
        result.success("DONE")
    }

    private fun setUserPass(arguments: Map<String, Any>, result: MethodChannel.Result) {
        SitumSdk.configuration()
            .setUserPass(arguments["situmUser"] as String, arguments["situmPass"] as String)
        result.success("DONE")
    }

    private fun logout(result: MethodChannel.Result) {
        SitumSdk.communicationManager().logout(object : Handler<Any> {
            override fun onSuccess(o: Any?) {
                result.success("DONE")
            }

            override fun onFailure(error: Error) {
                result.notifySitumSdkError(error)
            }
        });
    }

    private fun setConfiguration(arguments: Map<String, Any>, result: MethodChannel.Result) {
        if (arguments.containsKey("useRemoteConfig")) {
            SitumSdk.configuration().isUseRemoteConfig = arguments["useRemoteConfig"] as Boolean
        }
        if (arguments.containsKey("useExternalLocations")) {
            SitumSdk.configuration().useExternalLocations(arguments["useExternalLocations"] as Boolean)
        }
        result.success("DONE")
    }

    private fun fetchBuildings(result: MethodChannel.Result) {
        SitumSdk.communicationManager().fetchBuildings(object : Handler<Collection<Building>> {
            override fun onSuccess(buildings: Collection<Building>) {
                result.success(buildings.toMap())
            }

            override fun onFailure(error: Error) {
                result.notifySitumSdkError(error)
            }

        })
    }

    private fun fetchBuildingInfo(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val buildingIdentifier = arguments["buildingIdentifier"] as String
        SitumSdk.communicationManager()
            .fetchBuildingInfo(buildingIdentifier, object : Handler<BuildingInfo> {
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
        val buildingIdentifier = arguments["buildingIdentifier"] as String
        SitumSdk.communicationManager().fetchIndoorPOIsFromBuilding(
            buildingIdentifier, NO_PRELOAD_IMAGES_CONFIG, object : Handler<Collection<Poi>> {
                override fun onSuccess(pois: Collection<Poi>) {
                    result.success(pois.toMap())
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                }
            })
    }

    private fun fetchPoiFromBuilding(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val buildingIdentifier = arguments["buildingIdentifier"] as String
        val poiIdentifier = arguments["poiIdentifier"] as String
        SitumSdk.communicationManager().fetchIndoorPOIFromBuilding(
            poiIdentifier, buildingIdentifier, NO_PRELOAD_IMAGES_CONFIG, object : Handler<Poi> {
                override fun onSuccess(poi: Poi) {
                    result.success(poi.toMap())
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                }
            })
    }

    private fun requestLocationUpdates(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val locationRequest = LocationRequest.Builder().fromArguments(arguments).build()
        SitumSdk.locationManager().requestLocationUpdates(locationRequest)
        result.success("DONE")
    }

    private fun removeUpdates(result: MethodChannel.Result?) {
        SitumSdk.locationManager().removeUpdates()
        result?.success("DONE")
    }

    private fun addExternalLocation(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val updatedArguments = arguments.toMutableMap()
        val accuracyConverted = (updatedArguments["accuracy"] as? Double)?.toFloat() ?: 0f
        updatedArguments["accuracy"] = accuracyConverted
        SitumSdk.locationManager().addExternalLocation(ExternalLocation.fromMap(updatedArguments))
        result.success("DONE")
    }

    private fun requestDirections(arguments: Map<String, Any>, result: MethodChannel.Result) {
        navigation.requestDirections(arguments, result)
    }

    private fun requestNavigation(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val directionsRequestArgs = arguments["directionsRequest"] as Map<String, Any>
        val navigationRequestArgs = arguments["navigationRequest"] as Map<String, Any>
        navigation.requestNavigation(
            directionsRequestArgs, navigationRequestArgs, result
        )
    }

    private fun stopNavigation(result: MethodChannel.Result) {
        SitumSdk.navigationManager().removeUpdates()
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

    private fun openUrlInDefaultBrowser(arguments: Map<String, Any>, result: MethodChannel.Result) {
        if (!arguments.containsKey("url")) {
            result.success(false)
            return
        }
        if (context == null || context !is Activity) {
            result.success(false)
            return
        }
        val url = arguments["url"] as String

        val activity = context as Activity
        val launchIntent: Intent = Intent(Intent.ACTION_VIEW)

        if (url.endsWith(".pdf")) {
            launchIntent.setDataAndType(Uri.parse(url), "application/pdf")
        } else {
            launchIntent.setData(Uri.parse(url))
        }
            
        try {
            activity.startActivity(launchIntent)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
        result.success(true)
    }

    private fun updateNavigationState(arguments: Map<String, Any>, result: MethodChannel.Result) {
        viewerNavigation.updateNavigationState(arguments, result)
    }

    private fun requestAutoStop(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val criteria = AutoStopCriteria.Builder().fromMap(arguments).build()
        AutoStop.autoStopUnderCriteria(criteria)
        result.success("DONE")
    }

    private fun speakAloudText(arguments: Map<String, Any>, result: MethodChannel.Result) {
        context?.let {
            if (ttsManager == null) {
                ttsManager = TextToSpeechManager(it)
            }
            ttsManager?.speak(
                text = arguments["text"] as String,
                lang = arguments["lang"] as String,
                pitch = (arguments["pitch"] as Double).toFloat(),
                rate = (arguments["rate"] as Double).toFloat(),
            )
        }
        result.success("DONE")
    }

    private fun removeAutoStop(result: MethodChannel.Result) {
        AutoStop.disable()
        result.success("DONE")
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
        ttsManager?.stop()
        ttsManager = null
    }
}
