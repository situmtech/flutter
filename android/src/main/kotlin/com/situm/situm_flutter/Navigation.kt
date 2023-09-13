package com.situm.situm_flutter

import es.situm.sdk.SitumSdk
import es.situm.sdk.directions.DirectionsRequest
import es.situm.sdk.error.Error
import es.situm.sdk.model.directions.Route
import es.situm.sdk.model.navigation.NavigationProgress
import es.situm.sdk.navigation.NavigationListener
import es.situm.sdk.navigation.NavigationRequest
import es.situm.sdk.utils.Handler
import io.flutter.plugin.common.MethodChannel

class Navigation private constructor() : NavigationListener {

    private lateinit var channel: MethodChannel
    private lateinit var osHandler: android.os.Handler

    // Navigation will be a singleton so we can be sure that calls to
    // locationManager.addListener(this) always receive the same instance.
    companion object {
        private var instance: Navigation? = null

        fun init(channel: MethodChannel, handler: android.os.Handler): Navigation {
            if (instance == null) {
                instance = Navigation()
            }
            instance?.let {
                it.channel = channel
                it.osHandler = handler
            }
            return instance!!
        }
    }

    fun request(
        directionsRequestArgs: Map<String, Any>,
        navigationRequestArgs: Map<String, Any>?,
        result: MethodChannel.Result,
    ) {
        val navigationRequest = navigationRequestArgs?.let { NavigationRequest.fromMap(it) }
        val directionsRequest = DirectionsRequest.fromMap(directionsRequestArgs)
        SitumSdk.navigationManager().addNavigationListener(this)
        SitumSdk.navigationManager().requestNavigationUpdates(
            navigationRequest,
            directionsRequest,
            object : Handler<Route> {
                override fun onSuccess(route: Route) {
                    // Both requestDirections and requestNavigation methods will return the
                    // calculated route.
                    result.success(route.toMap())
                }

                override fun onFailure(error: Error) {
                    result.notifySitumSdkError(error)
                    SitumSdk.navigationManager().removeNavigationListener(this@Navigation)
                }
            })
    }

    // Navigation listener:

    override fun onStart(route: Route) {
        channel.invokeMethod("onNavigationStart", route.toMap())
    }

    override fun onCancellation() {
        channel.invokeMethod("onNavigationCancellation", null)
    }

    override fun onDestinationReached() {
        channel.invokeMethod("onNavigationDestinationReached", null)
    }

    override fun onProgress(progress: NavigationProgress) {
        channel.invokeMethod("onNavigationProgress", progress.toMap())
    }

    override fun onUserOutsideRoute() {
        channel.invokeMethod("onUserOutsideRoute", null)
    }
}