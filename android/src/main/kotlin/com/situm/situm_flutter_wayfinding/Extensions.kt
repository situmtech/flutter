package com.situm.situm_flutter_wayfinding

import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.model.MapperInterface
import es.situm.sdk.model.cartography.Poi
import es.situm.sdk.model.cartography.PoiCategory
import io.flutter.plugin.common.MethodChannel

fun List<MapperInterface>.toMap(): List<Map<String, Any>> {
    return map {
        it.toMap()
    }
}

fun Collection<Poi>.toPoisMap(): List<Map<String, Any>> {
    return map {
        mapOf(
            // Create a map for each Poi.
            // TODO: pending category identifier, then delete this method.
            "poiCategory" to it.category.ftToMap(),
        ) + it.toMap()
    }
}

fun PoiCategory.ftToMap(): Map<String, Any> {
    return mapOf(
        // Create a map for the current poi category.
        // TODO: fix SDK, add identifier, then delete this method.
        "id" to identifier,
    ) + toMap()
}

fun Collection<PoiCategory>.toCategoriesMap(): List<Map<String, Any>> {
    // TODO: pending category identifier, then delete this method.
    return map {
        it.ftToMap()
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

fun LocationRequest.Builder.fromArguments(args: Map<String, Any>): LocationRequest.Builder {
    if (args.containsKey("buildingIdentifier")) {
        buildingIdentifier(args["buildingIdentifier"] as String)
    }
    return this
}