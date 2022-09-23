package com.situm.situm_flutter_wayfinding

import es.situm.sdk.SitumSdk
import es.situm.sdk.error.Error
import es.situm.sdk.model.cartography.Poi
import es.situm.sdk.utils.Handler


class FlutterCommunicationManager {

    companion object {
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
                        for (poi in pois) {
                            if (poiId == poi.identifier) {
                                callback.onSuccess(poi)
                                return
                            }
                        }
                        callback.onError("Poi with id=$poiId not found for building with id=$buildingId")
                    }

                    override fun onFailure(error: Error) {
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