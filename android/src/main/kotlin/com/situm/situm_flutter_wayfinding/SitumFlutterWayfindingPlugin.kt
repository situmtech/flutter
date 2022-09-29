package com.situm.situm_flutter_wayfinding

import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

// SitumFlutterWayfindingPlugin
// Avoids the message "The plugin `situm_flutter_wayfinding` doesn't have a main class [...]".
// Right now WYF does not have a plugin class (extending FlutterPlugin).
// TODO: create a separated plugin for SitumSdk.
// TODO: register platform view here instead of MainActivity.
open class SitumFlutterWayfindingPlugin : FlutterPlugin, ActivityAware {

    private var activity: AppCompatActivity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Do nothing.
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Do nothing
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as AppCompatActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as AppCompatActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}