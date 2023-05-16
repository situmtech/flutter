package com.situm.flutterWayfindingPlugin

import com.situm.situm_flutter_wayfinding.SitumMapFactory
import io.flutter.embedding.android.FlutterAppCompatActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : /*FlutterActivity()*/ FlutterAppCompatActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Automatically register plugins:
        super.configureFlutterEngine(flutterEngine)
        // Reguster WYF widget:
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                SitumMapFactory.CHANNEL_ID,
                SitumMapFactory(flutterEngine.dartExecutor.binaryMessenger, this)
            )
    }
}
