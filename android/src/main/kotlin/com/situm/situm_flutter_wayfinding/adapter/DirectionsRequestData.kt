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
        exclusions.clear()
        // Exclusion circles depends on Building, which we must obtain asynchronously.
        if (exclusionsArgs.isNotEmpty()) {
            val buildingId = exclusionsArgs.first()["buildingId"] as String
            FlutterCommunicationManager.fetchBuildingInfo(
                buildingId,
                object : FlutterCommunicationManager.Callback<BuildingInfo> {
                    override fun onSuccess(result: BuildingInfo) {
                        exclusionsArgs.forEach {
                            exclusions.add(
                                result.building.createCircle(
                                    it["floorId"] as String,
                                    it["latitude"] as Double,
                                    it["longitude"] as Double,
                                    it["radius"] as Double,
                                )
                            )
                        }
                    }

                    override fun onError(message: String) {
                        callback.onError(message)
                    }
                })
        } else {
            callback.onSuccess()
        }
    }

    interface Callback {
        fun onSuccess()
        fun onError(message: String)
    }
}