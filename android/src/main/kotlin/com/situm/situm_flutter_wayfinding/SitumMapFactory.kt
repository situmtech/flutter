package com.situm.situm_flutter_wayfinding

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SitumMapFactory(
    private val messenger: BinaryMessenger,
    private val activity: AppCompatActivity
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        const val CHANNEL_ID = "situm.com/flutter_wayfinding"
    }

    override fun create(context: Context?, id: Int, o: Any?): PlatformView {
        return SitumMapPlatformView(activity, messenger, id)
    }
}