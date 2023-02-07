package com.situm.situm_flutter_wayfinding

import android.util.Log
import es.situm.wayfinding.LibrarySettings
import es.situm.wayfinding.SitumMapsLibrary

data class FlutterLibrarySettings(
    private val map: Map<String, Any>
) {
    companion object {
        const val TAG = "Situm>"
        const val NO_VALUE = -1.0
    }

    var librarySettings: LibrarySettings = LibrarySettings()
    val buildingIdentifier: String
    val lockCameraToBuilding: Boolean
    val showFloorSelector: Boolean

    // Navigation settings:
    var hasNavigationSettings: Boolean = false
    var outsideRouteThreshold: Double = NO_VALUE
    var distanceToGoalThreshold: Double = NO_VALUE

    // Direction settings
    var hasDirectionsSettings: Boolean = false
    var minimizeFloorChanges: Boolean? = null

    init {
        val email = map.mGet("situmUser", "NO-EMAIL") as String
        val apiKey = map.mGet("situmApiKey", "NO-API-KEY") as String
        buildingIdentifier = map.mGet("buildingIdentifier", "NO-BUILDING-IDENTIFIER") as String
        lockCameraToBuilding = map.mGet("lockCameraToBuilding", false) as Boolean
        librarySettings.setApiKey(email, apiKey)
        librarySettings.isEnablePoiClustering = map.mGet("enablePoiClustering", true) as Boolean
        librarySettings.setSearchViewPlaceholder(
            map.mGet(
                "searchViewPlaceholder",
                "Situm Flutter Wayfinding"
            ) as String
        )
        librarySettings.setUseDashboardTheme(map.mGet("useDashboardTheme", true) as Boolean)
        librarySettings.isShowPoiNames = map.mGet("showPoiNames", true) as Boolean
        librarySettings.setHasSearchView(map.mGet("hasSearchView", true) as Boolean)
        librarySettings.isUseRemoteConfig = map.mGet("useRemoteConfig", true) as Boolean
        librarySettings.initialZoom = map.mGet("initialZoom", 18) as Int
        librarySettings.minZoom = map.mGet("minZoom", 15) as Int
        librarySettings.maxZoom = map.mGet("maxZoom", 21) as Int
        librarySettings.isShowNavigationIndications =
            map.mGet("showNavigationIndications", true) as Boolean
        showFloorSelector = map.mGet("showFloorSelector", true) as Boolean
        // Navigation settings:
        if (map.containsKey("navigationSettings")) {
            val navSettings: Map<String, Any>? = map["navigationSettings"] as Map<String, Any>?
            navSettings?.let {
                hasNavigationSettings = true
                outsideRouteThreshold = it.mGet("outsideRouteThreshold", NO_VALUE) as Double
                distanceToGoalThreshold = it.mGet("distanceToGoalThreshold", NO_VALUE) as Double
            }
        }
        // Direction settings:
        if (map.containsKey("directionsSettings")) {
            val dirSettings: Map<String, Any>? = map["directionsSettings"] as Map<String, Any>?
            dirSettings?.let {
                hasDirectionsSettings = true
                // minimizeFloorChanges = it.mGet("minimizeFloorChanges", null) as Boolean?
                if (it.containsKey("minimizeFloorChanges")){
                    minimizeFloorChanges = it["minimizeFloorChanges"] as Boolean
                }
            }
        }
    }

    fun setNavigationRequestInterceptor(library: SitumMapsLibrary) {
        if (hasNavigationSettings) {
            library.addNavigationRequestInterceptor { builder ->
                if (outsideRouteThreshold != NO_VALUE) {
                    Log.d(TAG, "outsideRouteThreshold set to $outsideRouteThreshold")
                    builder.outsideRouteThreshold(outsideRouteThreshold)
                }
                if (distanceToGoalThreshold != NO_VALUE) {
                    Log.d(TAG, "distanceToGoalThreshold set to $distanceToGoalThreshold")
                    builder.distanceToGoalThreshold(distanceToGoalThreshold)
                }
            }
        }
    }

    fun setDirectionsRequestInterceptor(library: SitumMapsLibrary) {
        if (hasDirectionsSettings) {
            library.addDirectionsRequestInterceptor { builder ->
                minimizeFloorChanges?.let {
                    builder.minimizeFloorChanges(it)
                }
            }
        }
    }
}

fun Map<String, Any>.mGet(key: String, defaultValue: Any): Any {
    return if (containsKey(key)) {
        get(key)!!
    } else defaultValue
}
