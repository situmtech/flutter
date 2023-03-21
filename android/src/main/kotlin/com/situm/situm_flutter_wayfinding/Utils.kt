package com.situm.situm_flutter_wayfinding

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import android.util.Log

object Utils {

    const val TAG = "Situm>"

    fun decodeBitMapFromBase64(encodedBitmap: String?): Bitmap? {
        if (encodedBitmap == null) {
            return null;
        }
        try{
            val bytes = Base64.decode(encodedBitmap, Base64.DEFAULT)
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        } catch (e: IllegalArgumentException) {
            Log.d(TAG, "Android> Could not decode bitmap from base 64 string.")
            return null
        }
    }
}