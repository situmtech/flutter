package com.situm.situm_flutter_wayfinding

import android.util.Log
import es.situm.sdk.communication.CommunicationManager
import es.situm.sdk.directions.DirectionsRequest
import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.model.MapperInterface
import es.situm.sdk.model.cartography.Building
import es.situm.sdk.model.cartography.Point
import es.situm.sdk.model.location.Angle
import es.situm.sdk.model.location.Coordinate
import es.situm.sdk.navigation.NavigationRequest
import es.situm.sdk.utils.Handler
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
            Log.d("SDK>", "Set buildingIdentifier: $buildingIdentifier")
            buildingIdentifier(buildingIdentifier)
        }
    }
    if (args.containsKey("useDeadReckoning")) {
        Log.d("SDK>", "Set useDeadReckoning: ${args["useDeadReckoning"]}")
        useDeadReckoning(args["useDeadReckoning"] as Boolean)
    }
    return this
}

fun DirectionsRequest.Builder.fromArguments(
    building: Building,
    args: Map<String, Any>
): DirectionsRequest.Builder {
    if (args.containsKey("from")) {
        @Suppress("UNCHECKED_CAST")
        val from = args["from"] as Map<String, Any>
        val bearingFrom = "${args["bearingFrom"] ?: 0}".toDouble()
        from(pointFromArguments(building, from), Angle.fromDegrees(bearingFrom))
    }
    if (args.containsKey("to")) {
        @Suppress("UNCHECKED_CAST")
        val to = args["to"] as Map<String, Any>
        to(pointFromArguments(building, to))
    }
    if (args.containsKey("minimizeFloorChanges")) {
        minimizeFloorChanges(args["minimizeFloorChanges"] as Boolean)
    }
    return this
}

fun NavigationRequest.Builder.fromArguments(
    args: Map<String, Any>
): NavigationRequest.Builder {
    if (args.containsKey("outsideRouteThreshold")) {
        val outsideRoute = "${args["outsideRouteThreshold"]}".toDouble()
        if (outsideRoute > 0) {
            outsideRouteThreshold(outsideRoute)
        }
    }
    if (args.containsKey("distanceToGoalThreshold")) {
        val distanceToGoal = "${args["distanceToGoalThreshold"]}".toDouble()
        if (distanceToGoal > 0) {
            distanceToGoalThreshold(distanceToGoal)
        }
    }
    return this
}

fun pointFromArguments(
    building: Building,
    args: Map<String, Any>
): Point {
    return Point(
        building,
        args["floorIdentifier"] as String,
        // Dart Point class differs from native and does not have a Coordinate field; instead it
        // has latitude and longitude objects directly so we pass the same args map.
        coordinateFromArguments(args)
    )
}

fun coordinateFromArguments(args: Map<String, Any>): Coordinate {
    return Coordinate(
        args["latitude"] as Double,
        args["longitude"] as Double
    )
}

fun CommunicationManager.fetchBuilding(buildingId: String, handler: Handler<Building>) {
    fetchBuildings(object : Handler<Collection<Building>> {
        override fun onSuccess(buildings: Collection<Building>) {
            buildings.forEach {
                if (buildingId == it.identifier) {
                    handler.onSuccess(it)
                    return
                }
            }
        }

        override fun onFailure(error: Error) {
            handler.onFailure(error)
        }

    })
}