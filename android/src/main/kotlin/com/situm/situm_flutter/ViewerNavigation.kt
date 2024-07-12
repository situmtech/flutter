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
       
        SitumSdk.navigationManager().updateNavigationState(
            ExternalNavigation.fromMap(arguments)
        )
        result.success(true)
    }
}