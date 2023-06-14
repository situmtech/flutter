package com.situm.situm_flutter_wayfinding

import android.os.Looper
import es.situm.sdk.SitumSdk
import es.situm.sdk.directions.DirectionsRequest
import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationListener
import es.situm.sdk.location.LocationStatus
import es.situm.sdk.model.cartography.Building
import es.situm.sdk.model.directions.Route
import es.situm.sdk.model.location.Location
import es.situm.sdk.model.navigation.NavigationProgress
import es.situm.sdk.navigation.NavigationListener
import es.situm.sdk.navigation.NavigationRequest
import es.situm.sdk.utils.Handler
import io.flutter.plugin.common.MethodChannel

class Navigation private constructor(
    private val channel: MethodChannel,
) : LocationListener, NavigationListener {
    private var handler = android.os.Handler(Looper.getMainLooper())

    // Navigation will be a singleton so we can be sure that calls to
    // locationManager.addListener(this) always receive the same instance.
    companion object {
        private var instance: Navigation? = null

        fun init(channel: MethodChannel): Navigation {
            if (instance == null) {
                instance = Navigation(channel)
            }
            return instance!!
        }
    }

    fun requestDirections(
        buildingIdentifier: String,
        directionsOptionsArgs: Map<String, Any>,
        navigationOptionsArgs: Map<String, Any>?,
        result: MethodChannel.Result,
    ) {
        SitumSdk.navigationManager().removeUpdates()
        // Directions handler: receive the calculated route.
        val directionsHandler = object : Handler<Route> {
            override fun onSuccess(route: Route) {
                if (navigationOptionsArgs != null) {
                    // If requested, start navigation:
                    val navigationRequest = NavigationRequest.fromMap(navigationOptionsArgs)
                    navigationRequest.route = route
                    SitumSdk.navigationManager().requestNavigationUpdates(
                        navigationRequest, this@Navigation
                    )
                }
                // Both requestDirections and requestNavigation methods will return the calculated
                // route.
                result.success(route.toMap())
            }

            override fun onFailure(error: Error) {
                result.notifySitumSdkError(error)
            }
        }
        // Handler for fetchBuilding: DirectionsRequest mapper requires a Building object to create
        // indoor points so we start calling fetchBuilding().
        val buildingHandler = object : Handler<Building> {
            override fun onSuccess(building: Building) {
                val directionsRequest = DirectionsRequest.fromMap(directionsOptionsArgs)
                SitumSdk.directionsManager().requestDirections(directionsRequest, directionsHandler)
            }

            override fun onFailure(error: Error) {
                result.notifySitumSdkError(error)
            }
        }
        SitumSdk.communicationManager().fetchBuilding(buildingIdentifier, buildingHandler)
        // Add this class as location listener to keep navigationManager up to date:
        SitumSdk.locationManager().addLocationListener(this)
    }

    // Location listener:

    override fun onLocationChanged(location: Location) {
        if (SitumSdk.navigationManager().isRunning) {
            SitumSdk.navigationManager().updateWithLocation(location)
        }
    }

    override fun onStatusChanged(status: LocationStatus) {
        // TODO!
    }

    override fun onError(error: Error) {
        SitumSdk.navigationManager().removeUpdates()
    }

    // Navigation listener:

    override fun onDestinationReached() {
        handler.post {
            channel.invokeMethod("onNavigationFinished", null)
        }
    }

    override fun onProgress(progress: NavigationProgress) {
        handler.post {
            channel.invokeMethod("onNavigationProgress", progress.toMap())
        }
    }

    override fun onUserOutsideRoute() {
        handler.post {
            channel.invokeMethod("onUserOutsideRoute", null)
        }
    }
}