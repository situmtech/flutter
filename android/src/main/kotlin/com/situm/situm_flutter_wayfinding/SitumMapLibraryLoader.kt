package com.situm.situm_flutter_wayfinding

import android.os.Looper
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import es.situm.sdk.SitumSdk
import es.situm.sdk.error.Error
import es.situm.sdk.model.cartography.BuildingInfo
import es.situm.sdk.utils.Handler
import es.situm.wayfinding.SitumMapsLibrary
import es.situm.wayfinding.SitumMapsListener
import es.situm.wayfinding.actions.ActionsCallback

class SitumMapLibraryLoader(
    private val activity: AppCompatActivity,
) {

    companion object {
        var loaded = false
        private var library: SitumMapsLibrary? = null
    }

    private val handler = android.os.Handler(Looper.getMainLooper())

    fun load(flutterLibrarySettings: FlutterLibrarySettings, callback: Callback) {
        if (loaded) {
            library?.let {
                callback.onSuccess(it)
            }
            return
        }

        Log.d("ATAG", "PlatformView load called!")
        runLoad {
            library = SitumMapsLibrary(
                R.id.situm_flutter_map_view,
                activity,
                flutterLibrarySettings.librarySettings
            ).apply {
                setSitumMapsListener(object : SitumMapsListener {
                    override fun onSuccess() {
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
            loaded = true
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
                    Log.d("ATAG", "Target view found: ${R.id.situm_flutter_map_view}.")
                    handler.post(runnable)
                } else {
                    Log.d("ATAG", "No target view available, waiting.")
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
        SitumSdk.communicationManager().fetchBuildingInfo(
            settings.buildingIdentifier,
            object : Handler<BuildingInfo> {
                override fun onSuccess(buildingInfo: BuildingInfo) {
                    if (settings.lockCameraToBuilding) {
                        library.enableOneBuildingMode(settings.buildingIdentifier);
                    }
                    library.centerBuilding(
                        buildingInfo.building,
                        object : ActionsCallback {
                            override fun onActionConcluded() {
                                result.onSuccess(library)
                            }
                        })
                }

                override fun onFailure(error: Error) {
                    result.onError(
                        error.code,
                        "Error loading SitumMapsLibrary, error is: $error"
                    )
                }
            })
    }

    fun unload() {
        loaded = false
        // TODO: library.unload() crashes here.
        library = null
    }

    interface Callback {
        fun onSuccess(obtained: SitumMapsLibrary)
        fun onError(code: Int, message: String)
    }
}