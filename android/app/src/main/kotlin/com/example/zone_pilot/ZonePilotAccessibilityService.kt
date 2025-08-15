package com.example.zone_pilot

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel

class ZonePilotAccessibilityService : AccessibilityService() {

    private var methodChannel: MethodChannel? = null

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
            val rootNode = rootInActiveWindow ?: return

            when (rootNode.packageName) {
                "com.ubercab.driver" -> {
                    val goOnlineButton = findNodeById(rootNode, "com.ubercab.driver:id/go_online_button")
                    if (goOnlineButton != null && goOnlineButton.isClickable) {
                        Log.d("ZonePilotService", "Found Uber 'Go Online' button by ID. Clicking it.")
                        goOnlineButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                        goOnlineButton.recycle()
                    }
                }
                "com.doordash.driverapp" -> {
                    val dashNowButton = findClickableParentByChildText(rootNode, "Dash Now")
                    if (dashNowButton != null) {
                        Log.d("ZonePilotService", "Found DoorDash 'Dash Now' button by text. Clicking it.")
                        dashNowButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                        dashNowButton.recycle()
                    }
                }
            }
        }
    }

    private fun swipeUpAndClickOffline() {
        val rootNode = rootInActiveWindow ?: return

        val bottomDrawer = findNodeById(rootNode, "com.ubercab.driver:id/status_assistant")
        
        if (bottomDrawer != null) {
            Log.d("ZonePilotService", "Found bottom drawer. Performing targeted swipe.")

            val rect = Rect()
            bottomDrawer.getBoundsInScreen(rect)

            // NEW: Log the coordinates of the drawer
            Log.d("ZonePilotService", "Drawer bounds: Left=${rect.left}, Top=${rect.top}, Right=${rect.right}, Bottom=${rect.bottom}")

            val startX = rect.centerX().toFloat()
            val startY = rect.centerY().toFloat() + rect.height() / 4f
            val endY = rect.centerY().toFloat() - rect.height() / 4f
            
            // NEW: Log the swipe path
            Log.d("ZonePilotService", "Attempting swipe from ($startX, $startY) to ($startX, $endY)")

            val path = Path()
            path.moveTo(startX, startY)
            path.lineTo(startX, endY)

            val gesture = GestureDescription.Builder()
                .addStroke(GestureDescription.StrokeDescription(path, 0, 250))
                .build()

            dispatchGesture(gesture, object : GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription) {
                    super.onCompleted(gestureDescription)
                    Log.d("ZonePilotService", "Targeted swipe completed.")
                    
                    Handler(Looper.getMainLooper()).postDelayed({
                        val currentRootNode = rootInActiveWindow
                        if (currentRootNode != null) {
                            val goOfflineButton = findNodeById(currentRootNode, "com.ubercab.driver:id/carbon_action_button")
                            if (goOfflineButton != null && goOfflineButton.isClickable) {
                                Log.d("ZonePilotService", "Found 'Go Offline' button. Clicking it.")
                                goOfflineButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                                goOfflineButton.recycle()
                            } else {
                                Log.d("ZonePilotService", "Could not find 'Go Offline' button after swipe.")
                            }
                        }
                    }, 500)
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    super.onCancelled(gestureDescription)
                    Log.e("ZonePilotService", "Swipe gesture was cancelled.")
                }
            }, null)

            bottomDrawer.recycle()
        } else {
            Log.d("ZonePilotService", "Could not find bottom drawer to swipe.")
        }
    }

    private fun findNodeById(rootNode: AccessibilityNodeInfo, viewId: String): AccessibilityNodeInfo? {
        val nodes = rootNode.findAccessibilityNodeInfosByViewId(viewId)
        if (nodes.isNullOrEmpty()) {
            return null
        }
        for (i in 1 until nodes.size) {
            nodes[i].recycle()
        }
        return nodes[0]
    }

    private fun findClickableParentByChildText(rootNode: AccessibilityNodeInfo, textToFind: String): AccessibilityNodeInfo? {
        val textNodes = rootNode.findAccessibilityNodeInfosByText(textToFind)
        if (textNodes.isNullOrEmpty()) {
            return null
        }
        for (textNode in textNodes) {
            var parent = textNode
            while (parent != null) {
                if (parent.isClickable) {
                    return parent
                }
                val nextParent = parent.parent
                if (parent != textNode) {
                    parent.recycle()
                }
                parent = nextParent
            }
            textNode.recycle()
        }
        return null
    }

    override fun onInterrupt() {}

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("ZonePilotService", "Accessibility Service Connected")

        methodChannel = MainActivity.methodChannel
        methodChannel?.invokeMethod("serviceConnected", null)

        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "goOffline") {
                swipeUpAndClickOffline()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        methodChannel?.invokeMethod("serviceDestroyed", null)
        super.onDestroy()
    }
}
