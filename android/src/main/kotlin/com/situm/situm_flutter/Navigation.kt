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

    fun requestNavigation(
        directionsRequestArgs: Map<String, Any>,
        navigationRequestArgs: Map<String, Any>,
        result: MethodChannel.Result,
    ) {
        val navigationRequest = NavigationRequest.fromMap(navigationRequestArgs)
        val directionsRequest = DirectionsRequest.fromMap(directionsRequestArgs)
        SitumSdk.navigationManager().addNavigationListener(this)
        SitumSdk.navigationManager().requestNavigationUpdates(
            navigationRequest,
            directionsRequest,
            CommonHandler(result) { SitumSdk.navigationManager().removeNavigationListener(this) }
        )
    }

    fun requestDirections(
        directionsRequestArgs: Map<String, Any>,
        result: MethodChannel.Result,
    ) {
        val directionsRequest = DirectionsRequest.fromMap(directionsRequestArgs)
        SitumSdk.directionsManager().requestDirections(
            directionsRequest, CommonHandler(result, null)
        )
    }

    // Common handler:

    private class CommonHandler(
        private val result: MethodChannel.Result,
        private val onError: (() -> Unit)?
    ) : Handler<Route> {
        override fun onSuccess(route: Route) {
            result.success(route.toMap())
        }

        override fun onFailure(error: Error) {
            result.notifySitumSdkError(error)
            onError?.invoke()
        }
    }

    // Navigation listener:

    override fun onStart(route: Route) {
        channel.invokeMethod("onNavigationStart", route.toMap())
    }

    override fun onCancellation() {
        channel.invokeMethod("onNavigationCancellation", null)
    }

    override fun onDestinationReached() {

    }

    override fun onProgress(progress: NavigationProgress) {
        channel.invokeMethod("onNavigationProgress", progress.toMap())
    }

    override fun onDestinationReached(route: Route) {
        channel.invokeMethod("onNavigationDestinationReached", route.toMap())
    }

    override fun onUserOutsideRoute() {
        channel.invokeMethod("onUserOutsideRoute", null)
    }
}