package com.situm.situm_flutter_wayfinding.adapter

import com.situm.situm_flutter_wayfinding.FlutterCommunicationManager
import com.situm.situm_flutter_wayfinding.createCircle
import es.situm.sdk.model.cartography.BuildingInfo
import es.situm.sdk.model.cartography.Circle

class DirectionsRequestData {
    val exclusions: ArrayList<Circle> = ArrayList()
    var minimizeFloorChanges: Boolean? = null

    fun populateFromArguments(
        args: Map<String, Any>,
        callback: Callback
    ) {
        if (args.containsKey("minimizeFloorChanges")) {
            minimizeFloorChanges = args["minimizeFloorChanges"] as Boolean
        }

        // Get exclusions (depends on asynchronous call to fetchBuildingInfo):
        exclusions.clear()
        if (args.containsKey("exclusions")) {
            populateExclusions(args["exclusions"] as List<Map<String, Any>>, callback)
        } else {
            callback.onSuccess()
        }
    }

    private fun populateExclusions(
        exclusionsArgs: List<Map<String, Any>>,
        callback: Callback
    ) {
        if (exclusionsArgs.isEmpty()) {
            callback.onSuccess()
            return
        }
        // Exclusion circles depends on Building, which we must obtain asynchronously.
        // Get the buildingId from the very first exclusion area:
        val firstCenter = exclusionsArgs.first()["center"] as Map<String, Any>
        val buildingId = firstCenter["buildingId"] as String
        // Get the Building for the given buildingId and populate exclusions:
        FlutterCommunicationManager.fetchBuildingInfo(
            buildingId,
            object : FlutterCommunicationManager.Callback<BuildingInfo> {
                // Got building!
                override fun onSuccess(result: BuildingInfo) {
                    exclusionsArgs.forEach {
                        val centerMap = it["center"] as Map<String, Any>
                        exclusions.add(
                            result.building.createCircle(
                                centerMap["floorId"] as String,
                                centerMap["latitude"] as Double,
                                centerMap["longitude"] as Double,
                                it["radius"] as Double,
                            )
                        )
                    }
                }

                override fun onError(message: String) {
                    callback.onError(message)
                }
            })
    }

    interface Callback {
        fun onSuccess()
        fun onError(message: String)
    }
}