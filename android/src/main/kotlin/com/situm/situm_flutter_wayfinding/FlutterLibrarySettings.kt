package com.situm.situm_flutter_wayfinding

import es.situm.wayfinding.LibrarySettings

data class FlutterLibrarySettings(
    private val map: Map<String, Any>
) {
    var librarySettings: LibrarySettings = LibrarySettings()
    val buildingIdentifier: String
    val useHybridComponents: Boolean

    init {
        val email = map.mGet("situmUser", "NO-EMAIL") as String
        val apiKey = map.mGet("situmApiKey", "NO-API-KEY") as String
        buildingIdentifier = map.mGet("buildingIdentifier", "NO-BUILDING-IDENTIFIER") as String
        useHybridComponents = map.mGet("useHybridComponents", false) as Boolean
        librarySettings.setApiKey(email, apiKey)
        librarySettings.isEnablePoiClustering = map.mGet("enablePoiClustering", true) as Boolean
        librarySettings
    }
}

fun Map<String, Any>.mGet(key: String, defaultValue: Any): Any {
    return if (containsKey(key)) {
        get(key)!!
    } else defaultValue
}
