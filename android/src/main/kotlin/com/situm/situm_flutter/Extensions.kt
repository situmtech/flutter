package com.situm.situm_flutter

import android.util.Log
import es.situm.sdk.communication.CommunicationManager
import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationRequest
import es.situm.sdk.model.MapperInterface
import es.situm.sdk.model.cartography.Building
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