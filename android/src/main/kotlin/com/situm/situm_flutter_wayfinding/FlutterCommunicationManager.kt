package com.situm.situm_flutter_wayfinding

import android.util.Log
import es.situm.sdk.SitumSdk
import es.situm.sdk.error.Error
import es.situm.sdk.model.cartography.BuildingInfo
import es.situm.sdk.model.cartography.Poi
import es.situm.sdk.utils.Handler


class FlutterCommunicationManager {

    companion object {
        const val TAG = "Situm>"

        /**
         * Get a Poi using both Building and Poi identifiers.
         * @param buildingId The building id.
         * @param poiId The POI id.
         * @param callback Callback to handle success/failure.
         */
        fun fetchPoi(buildingId: String, poiId: String, callback: Callback<Poi>) {
            SitumSdk.communicationManager()
                .fetchIndoorPOIsFromBuilding(buildingId, object : Handler<Collection<Poi>> {
                    override fun onSuccess(pois: Collection<Poi>) {
                        Log.d(TAG, "Getting POI $poiId.")
                        for (poi in pois) {
                            if (poiId == poi.identifier) {
                                Log.d(TAG, "Found POI $poiId.")
                                callback.onSuccess(poi)
                                return
                            }
                        }
                        Log.d(TAG, "POI $poiId not found.")
                        callback.onError("Poi with id=$poiId not found for building with id=$buildingId")
                    }

                    override fun onFailure(error: Error) {
                        Log.e(TAG, "Error getting POI $poiId.")
                        callback.onError(error.message)
                    }
                })
        }

        /**
         * Get a BuildingInfo instance object.
         */
        fun fetchBuildingInfo(buildingId: String, callback: Callback<BuildingInfo>) {
            SitumSdk.communicationManager()
                .fetchBuildingInfo(buildingId, object : Handler<BuildingInfo> {
                    override fun onSuccess(buildingInfo: BuildingInfo) {
                        callback.onSuccess(buildingInfo)
                    }

                    override fun onFailure(error: Error) {
                        Log.e(TAG, "Error getting building info for $buildingId.")
                        callback.onError(error.message)
                    }
                })
        }
    }

    interface Callback<T> {
        fun onSuccess(result: T)
        fun onError(message: String)
    }
}