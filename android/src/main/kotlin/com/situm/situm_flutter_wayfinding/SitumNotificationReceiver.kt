package com.situm.situm_flutter_wayfinding

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import es.situm.sdk.SitumSdk

class SitumNotificationReceiver : BroadcastReceiver() {

    companion object {
        const val STOP_ACTION = "STOP_ACTION"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        // Stop receiving location updates on notification button click.
        SitumSdk.locationManager().removeUpdates()
    }
}