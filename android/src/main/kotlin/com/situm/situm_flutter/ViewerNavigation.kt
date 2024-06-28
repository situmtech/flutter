package com.situm.situm_flutter

import es.situm.sdk.SitumSdk
import es.situm.sdk.directions.DirectionsRequest
import es.situm.sdk.error.Error
import es.situm.sdk.model.directions.Route
import es.situm.sdk.model.navigation.NavigationProgress
import es.situm.sdk.navigation.ExternalNavigation
import es.situm.sdk.navigation.NavigationListener
import es.situm.sdk.navigation.NavigationRequest
import es.situm.sdk.utils.Handler
import io.flutter.plugin.common.MethodChannel

class ViewerNavigation private constructor() : NavigationListener {

    private lateinit var channel: MethodChannel
    private lateinit var osHandler: android.os.Handler

    // Navigation will be a singleton so we can be sure that calls to
    // locationManager.addListener(this) always receive the same instance.
    companion object {
        private var instance: ViewerNavigation? = null

        fun init(channel: MethodChannel, handler: android.os.Handler): ViewerNavigation {
            if (instance == null) {
                instance = ViewerNavigation()
            }
            instance?.let {
                it.channel = channel
                it.osHandler = handler
            }
            return instance!!
        }
    }

    fun updateNavigationState(
        externalNavigation: ExternalNavigation,
    ) {
        if (externalNavigation.messageType == ExternalNavigation.MessageType.NAVIGATION_STARTED) {
            SitumSdk.navigationManager().addNavigationListener(this)
        }
        SitumSdk.navigationManager().updateNavigationState(
            externalNavigation
        )
    }

    // Navigation listener:

    override fun onStart(route: Route) {
        channel.invokeMethod("onNavigationStart", route.toMap())
    }

    override fun onCancellation() {
        channel.invokeMethod("onNavigationCancellation", null)
        SitumSdk.navigationManager().removeNavigationListener(this)
    }

    override fun onDestinationReached() {

    }

    override fun onProgress(progress: NavigationProgress) {
        channel.invokeMethod("onNavigationProgress", progress.toMap())
    }

    override fun onDestinationReached(route: Route) {
        channel.invokeMethod("onNavigationDestinationReached", route.toMap())
        SitumSdk.navigationManager().removeNavigationListener(this)
    }

    override fun onUserOutsideRoute() {
        channel.invokeMethod("onUserOutsideRoute", null)
    }
}