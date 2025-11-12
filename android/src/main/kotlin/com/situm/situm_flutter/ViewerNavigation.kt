package com.situm.situm_flutter

import es.situm.sdk.SitumSdk
import es.situm.sdk.navigation.ExternalNavigation
import io.flutter.plugin.common.MethodChannel

class ViewerNavigation private constructor() {

    private lateinit var channel: MethodChannel
    private lateinit var osHandler: android.os.Handler

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
        val externalNavigation = ExternalNavigation.fromMap(arguments)
        if (externalNavigation == null) {
            result.success(false)
            return
        }
        SitumSdk.navigationManager().updateNavigationState(externalNavigation)
        result.success(true)
    }
}