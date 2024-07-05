package com.situm.situm_flutter

import es.situm.sdk.SitumSdk
import es.situm.sdk.model.directions.Route
import es.situm.sdk.model.navigation.NavigationProgress
import es.situm.sdk.navigation.ExternalNavigation
import es.situm.sdk.navigation.NavigationListener
import es.situm.sdk.utils.Handler
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class ViewerNavigation private constructor() : NavigationListener {

    private lateinit var channel: MethodChannel
    private lateinit var osHandler: android.os.Handler

    private var navigationStarted: Boolean = false

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
            arguments: Map<String, Any>,
            result: MethodChannel.Result
    ) {
        if (!arguments.containsKey("messageType") || !arguments.containsKey("payload")) {
            result.success(false)
            return
        }

        val messageType = arguments["messageType"] as String
        val payload = arguments["payload"] as Map<String, Any>

        var type: ExternalNavigation.MessageType? = null

        when (messageType) {
            "NavigationStarted" -> {
                if (!navigationStarted) {
                    navigationStarted = true
                    SitumSdk.navigationManager().addNavigationListener(this)
                    Log.d("ViewerNavigation", "navigation has started, added navigation listener.");
                }
                type = ExternalNavigation.MessageType.NAVIGATION_STARTED
            }
            "NavigationUpdated" -> {
                type = ExternalNavigation.MessageType.NAVIGATION_UPDATED
            }
            "DestinationReached" -> {
                type = ExternalNavigation.MessageType.DESTINATION_REACHED
            }
            "OutsideRoute" -> {
                type = ExternalNavigation.MessageType.OUTSIDE_ROUTE
            }
            "NavigationCancelled" -> {
                type = ExternalNavigation.MessageType.NAVIGATION_CANCELLED
            }
        }

        if (type == null) {
            result.success(false)
            return
        }

        SitumSdk.navigationManager().updateNavigationState(
            ExternalNavigation(type, payload)
        )
        result.success(true)
    }

    // Navigation listener:

    override fun onStart(route: Route) {
        channel.invokeMethod("onNavigationStart", route.toMap())
    }

    override fun onCancellation() {
        channel.invokeMethod("onNavigationCancellation", null)
        SitumSdk.navigationManager().removeNavigationListener(this)
        navigationStarted = false
        Log.d("ViewerNavigation", "navigation was cancelled, navigation listener removed.");
    }

    override fun onDestinationReached() {

    }

    override fun onProgress(progress: NavigationProgress) {
        channel.invokeMethod("onNavigationProgress", progress.toMap())
    }

    override fun onDestinationReached(route: Route) {
        channel.invokeMethod("onNavigationDestinationReached", route.toMap())
        SitumSdk.navigationManager().removeNavigationListener(this)
        navigationStarted = false
        Log.d("ViewerNavigation", "destination was reached, navigation listener removed.");
    }

    override fun onUserOutsideRoute() {
        channel.invokeMethod("onUserOutsideRoute", null)
    }
}