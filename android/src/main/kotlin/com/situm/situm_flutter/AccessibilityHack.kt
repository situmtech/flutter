package com.situm.situm_flutter

import android.app.Activity
import android.os.Build
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.accessibility.AccessibilityEvent
import android.webkit.WebView

object AccessibilityHack {

    /**
     * Iterates through all active WebViews in the current context and applies
     * accessibility adjustments required for TalkBack to properly recognize
     * the Situm WebView content.
     *
     * This method ensures that accessibility modifications are scoped only
     * to the Situm WebView (matching the configured viewerDomain) and do not
     * interfere with other WebViews present in the app.
     */
    fun enableWebViewAccessibility(activity: Activity?, viewerDomain: String? = null) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        val root = activity?.window?.decorView?.rootView as? ViewGroup ?: return

        // TODO: remove logs!
        Log.d("ATAG", "Call to enableWebViewAccessibility, viewerDomain=$viewerDomain")
        findWebViews(root).forEach { webView ->
            val url = webView.url
            Log.d("ATAG", "Found WebView with url=$url")

            // Skip if viewerDomain is set and url does not match
            if (viewerDomain != null && (url == null || !url.contains(viewerDomain))) {
                return@forEach
            }

            Log.d("ATAG", "Applying accessibility hack to $url")

            webView.apply {
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
                if (contentDescription.isNullOrEmpty()) {
                    contentDescription = "Map screen"
                }
                sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED)
            }

            // Fix parent flags
            var parent = webView.parent
            while (parent is View) {
                if (parent.importantForAccessibility == View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS) {
                    Log.d("ATAG", "Fixing parent with NO_HIDE_DESCENDANTS")
                    parent.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_AUTO
                }
                parent = parent.parent
            }
        }
    }

    private fun findWebViews(root: View): List<WebView> {
        val result = mutableListOf<WebView>()
        fun traverse(view: View) {
            when (view) {
                is WebView -> result.add(view)
                is ViewGroup -> (0 until view.childCount).forEach { traverse(view.getChildAt(it)) }
            }
        }
        traverse(root)
        return result
    }
}
