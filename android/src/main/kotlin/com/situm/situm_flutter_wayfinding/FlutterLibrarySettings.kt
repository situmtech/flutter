package com.situm.situm_flutter_wayfinding

import es.situm.wayfinding.LibrarySettings

data class FlutterLibrarySettings(
    private val map: Map<String, Any>
) {
    var librarySettings: LibrarySettings = LibrarySettings()
    val buildingIdentifier: String
    val lockCameraToBuilding: Boolean

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
        librarySettings.setUseDashboardTheme(map.mGet("useDashboardTheme", false) as Boolean)
        librarySettings.isShowPoiNames = map.mGet("showPoiNames", false) as Boolean
        librarySettings.setHasSearchView(map.mGet("hasSearchView", true) as Boolean)
        librarySettings.isUseRemoteConfig = map.mGet("useRemoteConfig", false) as Boolean
    }
}

fun Map<String, Any>.mGet(key: String, defaultValue: Any): Any {
    return if (containsKey(key)) {
        get(key)!!
    } else defaultValue
}
