package com.situm.situm_flutter_wayfinding

import android.annotation.SuppressLint
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import es.situm.sdk.model.cartography.Building
import es.situm.sdk.model.cartography.Floor
import es.situm.sdk.model.cartography.Poi
import es.situm.wayfinding.OnPoiSelectionListener
import es.situm.wayfinding.SitumMapsLibrary
import es.situm.wayfinding.actions.ActionsCallback
import es.situm.wayfinding.navigation.Navigation
import es.situm.wayfinding.navigation.NavigationError
import es.situm.wayfinding.navigation.OnNavigationListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView


class SitumMapPlatformView(
    private val activity: AppCompatActivity,
    messenger: BinaryMessenger,
    id: Int
) : PlatformView,
    MethodChannel.MethodCallHandler,
    DefaultLifecycleObserver {

    companion object {
        const val TAG = "Situm>"

        // Workaround to avoid WYF to be recreated with the flutter widget lifecycle.
        @SuppressLint("StaticFieldLeak")
        private var layout: View? = null

        // WYF:
        private var library: SitumMapsLibrary? = null
        private lateinit var libraryLoader: SitumMapLibraryLoader
        lateinit var loadSettings: FlutterLibrarySettings

        const val ERROR_LIBRARY_NOT_LOADED = "ERROR_LIBRARY_NOT_LOADED"
        const val ERROR_SELECT_POI = "ERROR_SELECT_POI"
    }

    private var methodChannel: MethodChannel

    init {
        libraryLoader = SitumMapLibraryLoader.fromActivity(activity)
        activity.lifecycle.addObserver(this)
        methodChannel = MethodChannel(messenger, "situm.com/flutter_wayfinding")
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View? {
        if (layout == null) {
            val inflater = LayoutInflater.from(activity)
            layout = inflater.inflate(R.layout.situm_flutter_map_view_layout, null, false)
        }
        return layout
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        val arguments = (methodCall.arguments ?: emptyMap<String, Any>()) as Map<String, Any>
        if (methodCall.method == "load") {
            load(arguments, result)
        } else {
            // Check that the library was successfully loaded.
            if (!verifyLibrary(result)) {
                return
            }
            when (methodCall.method) {
                // Add here all the library methods:
                "unload" -> unload(result)
                "selectPoi" -> selectPoi(arguments, result)
                "navigateToPoi" -> navigateToPoi(arguments, result)
                "startPositioning" -> startPositioning()
                "stopPositioning" -> stopPositioning()
                "stopNavigation" -> stopNavigation()
                "filterPoisBy" -> filterPoisBy(arguments, result)
                else -> result.notImplemented()
            }
        }
    }

    override fun dispose() {
        Log.d(TAG, "PlatformView dispose() called.")
        // TODO: this is causing problems with unload/load. A deeper analysis should be performed.
        // Why the method call handler is not being re-established?
        // methodChannel.setMethodCallHandler(null)
    }


    // Public methods (impl):

    // Load WYF into the target view.
    private fun load(arguments: Map<String, Any>, methodResult: MethodChannel.Result) {
        loadSettings = FlutterLibrarySettings(arguments)
        libraryLoader.load(loadSettings, object : SitumMapLibraryLoader.Callback {
            override fun onSuccess(obtained: SitumMapsLibrary) {
                library = obtained
                methodResult.success("SUCCESS")
                initCallbacks()
            }

            override fun onError(code: Int, message: String) {
                methodResult.error(code.toString(), message, null)
            }
        })
    }

    private fun unload(methodResult: MethodChannel.Result?) {
        Log.d(TAG, "PlatformView unload called!")
        libraryLoader.unload()
        // Ensure this layout does not have a parent:
        if (layout?.parent != null) {
            (layout?.parent as ViewGroup).removeView(layout)
        }
        layout = null
        methodResult?.success("DONE")
    }

    private fun startPositioning() {
        library?.startPositioning(loadSettings.buildingIdentifier)
    }

    private fun stopPositioning() {
        library?.stopPositioning()
    }

    private fun stopNavigation() {
        library?.stopNavigation()
    }

    // Select the given poi in the map.
    private fun selectPoi(arguments: Map<String, Any>, methodResult: MethodChannel.Result) {
        Log.d(TAG, "Android> Plugin selectPoi call.")
        val buildingId = arguments["buildingId"] as String
        val poiId = arguments["id"] as String
        FlutterCommunicationManager.fetchPoi(
            buildingId,
            poiId,
            object : FlutterCommunicationManager.Callback<Poi> {
                override fun onSuccess(result: Poi) {
                    Log.d(TAG, "Android> Library selectPoi call.")
                    library?.selectPoi(result, object : ActionsCallback {
                        override fun onActionConcluded() {
                            Log.d(TAG, "Android> selectPoi success.")
                            methodResult.success(poiId)
                        }
                    })
                }

                override fun onError(message: String) {
                    Log.e(TAG, "Android> Library selectPoi error: $message.")
                    methodResult.error(ERROR_SELECT_POI, message, null)
                }
            })
    }

    // Navigate to a given Situm poi
    private fun navigateToPoi(arguments: Map<String, Any>, methodResult: MethodChannel.Result) {
        Log.d(TAG, "Android> Plugin navigateToPoi call.")
        val buildingId = arguments["buildingId"] as String
        val poiId = arguments["id"] as String
        FlutterCommunicationManager.fetchPoi(
            buildingId,
            poiId,
            object : FlutterCommunicationManager.Callback<Poi> {
                override fun onSuccess(result: Poi) {
                    Log.d(TAG, "Android> Library selectPoi call.")
                    library?.findRouteToPoi(result)
                }

                override fun onError(message: String) {
                    Log.e(TAG, "Android> Library selectPoi error: $message.")
                    methodResult.error(ERROR_SELECT_POI, message, null)
                }
            })
    }

    // Filter poi categories
    private fun filterPoisBy(arguments: Map<String, Any>, result: MethodChannel.Result) {
        val categoryIdsFilter = arguments["categoryIdsFilter"] as List<String>
        library?.filterPoisBy(categoryIdsFilter)
        result.success("DONE")
    }

    // Callbacks

    fun initCallbacks() {
        // Listen for POI selection/deselection events.
        library?.setOnPoiSelectionListener(object : OnPoiSelectionListener {
            override fun onPoiSelected(poi: Poi, floor: Floor, building: Building) {
                val arguments = mutableMapOf<String, String>(
                    "buildingId" to building.identifier,
                    "buildingName" to building.name,
                    "floorId" to floor.identifier,
                    "floorName" to floor.name,
                    "poiId" to poi.identifier,
                    "poiName" to poi.name,
                    "poiInfoHtml" to poi.infoHtml,
                )
                methodChannel.invokeMethod("onPoiSelected", arguments)
            }

            override fun onPoiDeselected(building: Building) {
                val arguments = mutableMapOf(
                    "buildingId" to building.identifier,
                    "buildingName" to building.name,
                )
                methodChannel.invokeMethod("onPoiDeselected", arguments)
            }
        })

        library?.setOnNavigationListener(object : OnNavigationListener {
            override fun onNavigationError(navigation: Navigation, error: NavigationError) {
                val arguments = mutableMapOf(
                    "error" to error.message,
                    "destinationId" to navigation.destination.identifier,
                )
                methodChannel.invokeMethod("onNavigationError", arguments)
            }

            override fun onNavigationFinished(navigation: Navigation) {
                val arguments = mutableMapOf(
                    "destinationId" to navigation.destination.identifier,
                )
                methodChannel.invokeMethod("onNavigationFinished", arguments)
            }

            override fun onNavigationRequested(navigation: Navigation) {
                val arguments = mutableMapOf(
                    "destinationId" to navigation.destination.identifier,
                )
                methodChannel.invokeMethod("onNavigationRequested", arguments)
            }

            override fun onNavigationStarted(navigation: Navigation) {
                val arguments = mutableMapOf<String, Any?>(
                    "destinationId" to navigation.destination.identifier,
                )
                navigation.route?.let {
                    arguments += mutableMapOf<String, Any?>(
                        "routeDistance" to it.distance
                    )
                }
                methodChannel.invokeMethod("onNavigationStarted", arguments)
            }
        })
    }

    // Utils

    private fun verifyLibrary(result: MethodChannel.Result): Boolean {
        if (library == null) {
            result.error(
                ERROR_LIBRARY_NOT_LOADED, "SitumMapsLibrary not loaded.", null
            )
            return false
        }
        return true
    }

    // DefaultLifecycleObserver

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        owner.lifecycle.removeObserver(this)
        unload(null)
    }
}