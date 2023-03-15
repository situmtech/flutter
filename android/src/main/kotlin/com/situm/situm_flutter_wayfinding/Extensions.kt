package com.situm.situm_flutter_wayfinding

import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.model.MapperInterface
import es.situm.sdk.model.cartography.*
import es.situm.sdk.model.location.Coordinate
import io.flutter.plugin.common.MethodChannel

fun Collection<MapperInterface>.toMap(): List<Map<String, Any>> {
    return map {
        it.toMap()
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
        val buildingIdentifier = args["buildingIdentifier"] as String
        if (buildingIdentifier.isNotBlank()) {
            buildingIdentifier(buildingIdentifier)
        }
    }
    return this
}

fun Building.createPoint(
    floorId: String,
    latitude: Double,
    longitude: Double
): Point {
    val coordinate = Coordinate(latitude, longitude)
    return Point(this, floorId, coordinate)
}

fun Building.createCircle(
    floorId: String,
    latitude: Double,
    longitude: Double,
    radius: Double
): Circle {
    val point = createPoint(floorId, latitude, longitude)
    return Circle(point, radius.toFloat())
}
