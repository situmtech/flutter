package com.situm.situm_flutter_wayfinding

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import es.situm.sdk.model.cartography.Building
import es.situm.sdk.model.cartography.Floor
import es.situm.sdk.model.cartography.Poi
import es.situm.wayfinding.OnPoiSelectionListener
import es.situm.wayfinding.SitumMapsLibrary
import es.situm.wayfinding.actions.ActionsCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import android.os.Build
import java.util.*


class SitumMapPlatformView(
    private val activity: AppCompatActivity,
    messenger: BinaryMessenger,
    id: Int
) : PlatformView,
    MethodChannel.MethodCallHandler,
    DefaultLifecycleObserver {

    companion object {
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
        libraryLoader = SitumMapLibraryLoader(activity)
        activity.lifecycle.addObserver(this)
        methodChannel = MethodChannel(messenger, "situm.com/flutter_wayfinding_$id")
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
                "unload" -> unload()
                "selectPoi" -> selectPoi(arguments, result)
                "startPositioning" -> startPositioning()
                "stopPositioning" -> stopPositioning()
                else -> result.notImplemented()
            }
        }
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    private fun setLanguage(arguments: Map<String, Any>) {
        var language = arguments["language"] as String?
        if (language.isNullOrEmpty()) {
            return
        }
        val locale = Locale(language)
        val resources = activity.resources
        val configuration = resources.configuration
        configuration.setLocale(locale)
        resources.updateConfiguration(configuration, resources.displayMetrics)
    }


    // Public methods (impl):

    // Load WYF into the target view.
    private fun load(arguments: Map<String, Any>, methodResult: MethodChannel.Result) {
        loadSettings = FlutterLibrarySettings(arguments)
        setLanguage(arguments)
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

    private fun unload() {
        layout = null
        libraryLoader.unload()
    }

    private fun startPositioning() {
        library?.startPositioning(loadSettings.buildingIdentifier)
    }

    private fun stopPositioning() {
        library?.stopPositioning()
    }

    // Select the given poi in the map.
    private fun selectPoi(arguments: Map<String, Any>, methodResult: MethodChannel.Result) {
        val buildingId = arguments["buildingId"] as String
        val poiId = arguments["id"] as String
        FlutterCommunicationManager.fetchPoi(
            buildingId,
            poiId,
            object : FlutterCommunicationManager.Callback<Poi> {
                override fun onSuccess(result: Poi) {
                    library?.selectPoi(result, object : ActionsCallback {
                        override fun onActionConcluded() {
                            methodResult.success(poiId)
                        }
                    })
                }

                override fun onError(message: String) {
                    methodResult.error(ERROR_SELECT_POI, message, null)
                }
            })
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
                )
                methodChannel.invokeMethod("onPoiSelected", arguments)
            }

            override fun onPoiDeselected(building: Building) {
                val arguments = mutableMapOf<String, String>(
                    "buildingId" to building.identifier,
                    "buildingName" to building.name,
                )
                methodChannel.invokeMethod("onPoiDeselected", arguments)
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
        unload()
    }
}