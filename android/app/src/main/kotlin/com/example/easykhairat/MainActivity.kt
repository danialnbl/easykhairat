package com.example.easykhairat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.easykhairat.app/browser"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "closeExternalBrowser" -> {
                        // Bring the app to foreground and close custom tabs
                        // The Chrome Custom Tab will automatically close when we bring our app to foreground
                        try {
                            // This brings our app to the foreground
                            // The custom tab will close automatically as it's a temporary overlay
                            moveTaskToBack(false)
                            moveTaskToBack(true)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Could not close browser: ${e.message}", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

