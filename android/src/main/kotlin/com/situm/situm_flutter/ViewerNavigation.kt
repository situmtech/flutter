package com.situm.situm_flutter

import es.situm.sdk.SitumSdk
import es.situm.sdk.navigation.ExternalNavigation
import io.flutter.plugin.common.MethodChannel

class ViewerNavigation private constructor() {

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
            arguments: Map<String, Any>,
            result: MethodChannel.Result
    ) {
        if (!arguments.containsKey("type") || !arguments.containsKey("payload")) {
            result.success(false)
            return
        }

        val messageTypes = mutableMapOf<String, ExternalNavigation.MessageType>()
        messageTypes["NAVIGATION_STARTED"] = ExternalNavigation.MessageType.NAVIGATION_STARTED
        messageTypes["PROGRESS"] = ExternalNavigation.MessageType.NAVIGATION_UPDATED
        messageTypes["DESTINATION_REACHED"] = ExternalNavigation.MessageType.DESTINATION_REACHED
        messageTypes["OUT_OF_ROUTE"] = ExternalNavigation.MessageType.OUTSIDE_ROUTE
        messageTypes["NAVIGATION_CANCELLED"] = ExternalNavigation.MessageType.NAVIGATION_CANCELLED

        val type = messageTypes[arguments["type"]]
        val payload = arguments["payload"] as Map<String, Any>

        if (type == null) {
            result.success(false)
            return
        }

        SitumSdk.navigationManager().updateNavigationState(
            ExternalNavigation(type, payload)
        )
        result.success(true)
    }
}