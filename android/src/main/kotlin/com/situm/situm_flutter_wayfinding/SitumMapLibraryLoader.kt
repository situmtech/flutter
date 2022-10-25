package com.situm.situm_flutter_wayfinding

import android.os.Looper
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import es.situm.wayfinding.SitumMapsLibrary
import es.situm.wayfinding.SitumMapsListener
import es.situm.wayfinding.actions.ActionsCallback

class SitumMapLibraryLoader private constructor(
    private var activity: AppCompatActivity,
) {

    companion object {
        const val TAG = "Situm>"

        var loaded = false
        private var library: SitumMapsLibrary? = null
        private var instance: SitumMapLibraryLoader? = null

        fun fromActivity(activity: AppCompatActivity): SitumMapLibraryLoader {
            instance = instance ?: SitumMapLibraryLoader(activity)
            instance!!.activity = activity
            return instance!!
        }
    }

    private val handler = android.os.Handler(Looper.getMainLooper())

    fun load(flutterLibrarySettings: FlutterLibrarySettings, callback: Callback) {
        Log.d(TAG, "PlatformView load called!")
        if (loaded) { // Manage this case, but it should not happen.
            Log.d(TAG, "\tAlready loaded, library = $library")
            library?.let {
                callback.onSuccess(it)
            }
            return
        }
        loaded = true // Set loaded=true as soon as possible to avoid multiple calls while loading.
        Log.d(TAG, "\tNot loaded yet.")
        // Avoid race conditions: native load will be called when the target view was available.
        // The SitumMapsLibrary instantiation must be done immediately so it can be passed as
        // parameter in the callback above while loading (when multiple calls to load() occur).
        library = SitumMapsLibrary(
            R.id.situm_flutter_map_view,
            activity,
            flutterLibrarySettings.librarySettings
        )
        runLoad {
            library?.apply {
                setSitumMapsListener(object : SitumMapsListener {
                    override fun onSuccess() {
                        Log.d(TAG, "\tNative load done.")
                        onLibraryLoaded(this@apply, flutterLibrarySettings, callback)
                    }

                    override fun onError(error: Int) {
                        loaded = false
                        callback.onError(
                            error, "Error loading SitumMapsLibrary, error code is: $error"
                        )
                    }
                })
                // Situm Maps Library load!
                load()
            }
        }
    }

    private fun runLoad(runnable: Runnable) {
        /* TODO: when using hybrid components with initExpensiveAndroidView the method loadLibrary
             is being called before the view was attached to the android hierarchy.
             loadLibrary is called through method channel at _onPlatformViewCreated, but that
             callback seems not to be working as expected.
             As a workaround, wait until the target view can be found in the activity. A better
             solution should be implemented.
         */
        handler.post(object : Runnable {
            override fun run() {
                val mapView = activity.findViewById<View>(R.id.situm_flutter_map_view)
                if (mapView != null) {
                    Log.d(TAG, "Target view found: ${R.id.situm_flutter_map_view}.")
                    handler.post(runnable)
                } else {
                    handler.postDelayed(this, 50)
                }
            }
        })
    }

    private fun onLibraryLoaded(
        library: SitumMapsLibrary,
        settings: FlutterLibrarySettings,
        result: Callback
    ) {
        if (settings.hasNavigationSettings) {
            settings.setNavigationRequestInterceptor(library)
        }
        if (!settings.showFloorSelector) { // Call only when explicitly wants to hide it.
            library.setFloorsListVisible(false)
        }
        val callback = object : ActionsCallback {
            override fun onActionConcluded() {
                result.onSuccess(library)
            }
        }
        if (settings.lockCameraToBuilding) {
            library.enableOneBuildingMode(settings.buildingIdentifier, callback);
        } else {
            library.centerBuilding(settings.buildingIdentifier, callback)
        }
    }

    fun unload() {
        if (loaded) {
            try {
                library?.unload()
            } catch (e: Exception) {
                Log.d(TAG, "Illegal call to unload(). This message can be ignored.", e)
            }
        }
        library = null
        loaded = false
    }

    interface Callback {
        fun onSuccess(obtained: SitumMapsLibrary)
        fun onError(code: Int, message: String)
    }
}