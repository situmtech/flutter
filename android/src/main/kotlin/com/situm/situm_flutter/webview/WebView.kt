package com.situm.situm_flutter.webview

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import es.situm.sdk.wayfinding.MapViewConfiguration
import es.situm.sdk.wayfinding.MapViewManager
import io.flutter.plugin.platform.PlatformView

class WebView(val context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    val view: FrameLayout

    init {
        view = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        // TODO: incluír inicialmente un "loading" e logo facer "load"?
        // TODO: pasar parámetros: MapViewConfiguration.fromMap() - creationParams?
        val mapViewConfiguration = MapViewConfiguration.Builder()
            .setBuildingIdentifier("7033") // Demo account
            .setProfile("demo")
            .setUseSdkCache(true)
            .build()
        MapViewManager.loadMapView(context, view, mapViewConfiguration) { loadResult ->
            loadResult.onSuccess { controller ->
                // TODO: fai falta o controller para postMessage.
            }.onFailure {
                // TODO: control de erros!
                Toast.makeText(context, "Error loading MapView", Toast.LENGTH_LONG).show()
            }
        }
    }

    override fun getView(): View? {
        return view
    }

    override fun dispose() {

    }
}