package com.situm.situm_flutter_wayfinding

import es.situm.sdk.error.Error
import es.situm.sdk.model.cartography.Geofence
import es.situm.sdk.model.cartography.Poi
import es.situm.sdk.model.cartography.PoiCategory
import io.flutter.plugin.common.MethodChannel

fun List<Geofence>.toGeofencesMap(): List<Map<String, String>> {
    return map {
        mapOf( // Create a map for each Geofence.
            "id" to it.identifier,
            "name" to it.name
        )
    }
}

fun Collection<Poi>.toPoisMap(): List<Map<String, String>> {
    return map {
        mapOf( // Create a map for each Geofence.
            "id" to it.identifier,
            "name" to it.name,
            "buildingId" to it.buildingIdentifier
        )
    }
}

fun Collection<PoiCategory>.toCategoriesMap(): List<Map<String, String>> {
    return map {
        mapOf( // Create a map for each Geofence.
            "id" to it.identifier,
            "name" to it.name
        )
    }
}

fun Error.toDartError(): MutableMap<String, Any> {
    return mutableMapOf(
        "code" to code.toString(),
        "message" to message
    )
}

fun MethodChannel.Result.notifySitumSdkError(error: Error) {
    error(error.code.toString(), error.message, null)
}