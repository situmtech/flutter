package com.situm.situm_flutter

import es.situm.sdk.SitumSdk
import es.situm.sdk.error.Error
import es.situm.sdk.location.LocationListener
import es.situm.sdk.location.LocationStatus
import es.situm.sdk.model.location.Location

object AutoStop : LocationListener {

    private lateinit var autoStopCriteria: AutoStopCriteria
    private var consecutiveOOBTracker: TimeTracker? = null

    fun autoStopUnderCriteria(autoStopCriteria: AutoStopCriteria) {
        this.autoStopCriteria = autoStopCriteria
        if (autoStopCriteria.checkConsecutiveOutOfBuildingTimeout()) {
            consecutiveOOBTracker = null
            SitumSdk.locationManager().addLocationListener(this)
        }
    }

    fun disable() {
        SitumSdk.locationManager().removeLocationListener(this)
        consecutiveOOBTracker = null
    }

    override fun onLocationChanged(location: Location) {
        // Any location received will reset the OOB TimeTracker.
        consecutiveOOBTracker = null
    }

    override fun onStatusChanged(status: LocationStatus) {
        if (autoStopCriteria.checkConsecutiveOutOfBuildingTimeout() && status == LocationStatus.USER_NOT_IN_BUILDING) {
            if (consecutiveOOBTracker == null) {
                consecutiveOOBTracker = TimeTracker()
            }
            if (consecutiveOOBTracker?.hasElapsedSeconds(autoStopCriteria.consecutiveOOBTimeout) == true) {
                SitumSdk.locationManager().removeUpdates()
                disable()
            }
        }
    }

    override fun onError(error: Error) {
        // Do nothing.
    }

}

class AutoStopCriteria private constructor(
    internal val consecutiveOOBTimeout: Long
) {
    fun checkConsecutiveOutOfBuildingTimeout(): Boolean {
        return consecutiveOOBTimeout > 0
    }

    class Builder {
        private var consecutiveOOBTimeout: Long = -1

        /**
         * Seconds elapsed receiving consecutive LocationStatus#USER_NOT_IN_BUILDING statuses after
         * which positioning will stop.
         */
        fun setConsecutiveOutOfBuildingTimeout(timeoutInSeconds: Long): Builder = apply {
            this.consecutiveOOBTimeout = timeoutInSeconds
        }

        fun build(): AutoStopCriteria {
            return AutoStopCriteria(consecutiveOOBTimeout)
        }

        fun fromMap(map: Map<String, Any?>): Builder {
            val timeout = map["consecutiveOutOfBuildingTimeout"] as Int?
            timeout?.let { setConsecutiveOutOfBuildingTimeout(it.toLong()) }
            return this
        }
    }
}


class TimeTracker {
    private var referenceTime: Long = System.currentTimeMillis()

    init {
        referenceTime = System.currentTimeMillis()
    }

    fun hasElapsedSeconds(seconds: Long): Boolean {
        val currentTime = System.currentTimeMillis()
        return (currentTime - referenceTime) >= seconds * 1000
    }
}


