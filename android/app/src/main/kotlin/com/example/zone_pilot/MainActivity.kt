package com.example.zone_pilot

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // This companion object will hold our communication channel
    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create the MethodChannel here, where we have proper access
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.zonepilot/accessibility")
    }
}
