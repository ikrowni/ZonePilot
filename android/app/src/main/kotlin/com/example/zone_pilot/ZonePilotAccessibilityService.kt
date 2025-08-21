package com.example.zone_pilot

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Intent
import android.graphics.Path
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.plugin.common.MethodChannel

class ZonePilotAccessibilityService : AccessibilityService() {

    private val TAG = "ZonePilotService"
    private var methodChannel: MethodChannel? = null

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
            val clickedNode: AccessibilityNodeInfo? = event.source
            if (clickedNode != null) {
                Log.d(TAG, "================ TAPPED ELEMENT ================")
                val nodeInfo = """
                    className: ${clickedNode.className},
                    text: '${clickedNode.text}',
                    contentDescription: '${clickedNode.contentDescription}',
                    viewId: '${clickedNode.viewIdResourceName}'
                """.trimIndent()
                Log.d(TAG, nodeInfo)
                Log.d(TAG, "==============================================")
                clickedNode.recycle()
            }
        }
    }

    private fun goOnline() {
        val rootNode = rootInActiveWindow ?: return
        val goOnlineButton = findNodeById(rootNode, "com.ubercab.driver:id/go_online_button")
        if (goOnlineButton != null && goOnlineButton.isClickable) {
            Log.d(TAG, "Found 'Go Online' button. Using ACTION_CLICK.")
            goOnlineButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            goOnlineButton.recycle()
            Handler(Looper.getMainLooper()).postDelayed({
                bringZonePilotToFront()
            }, 3000)
        } else {
            Log.e(TAG, "Could not find 'Go Online' button.")
            bringZonePilotToFront()
        }
    }

    private fun goOffline() {
        val rootNode = rootInActiveWindow ?: return
        val bottomDrawer = findNodeById(rootNode, "com.ubercab.driver:id/status_assistant")

        if (bottomDrawer != null) {
            Log.d(TAG, "Found bottom drawer. Using ACTION_CLICK to open.")
            bottomDrawer.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            bottomDrawer.recycle()

            Handler(Looper.getMainLooper()).postDelayed({
                Log.d(TAG, "Starting search for the 'go_offline_view' container.")
                val currentRootNode = rootInActiveWindow ?: return@postDelayed
                val goOfflineContainer = findNodeById(currentRootNode, "com.ubercab.driver:id/go_offline_view")

                if (goOfflineContainer != null) {
                    val clickableButton = findFirstClickableChild(goOfflineContainer)
                    if (clickableButton != null) {
                        Log.d(TAG, "Found clickable button inside container. Performing ACTION_CLICK.")
                        clickableButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                        clickableButton.recycle()
                    } else {
                        Log.e(TAG, "Could not find a clickable child in the 'go_offline_view' container.")
                    }
                    goOfflineContainer.recycle()
                } else {
                    Log.e(TAG, "Could not find the 'go_offline_view' container.")
                }

                Handler(Looper.getMainLooper()).postDelayed({
                    bringZonePilotToFront()
                }, 1000)
            }, 2000)

        } else {
            Log.d(TAG, "Could not find bottom drawer to tap.")
            bringZonePilotToFront()
        }
    }
    
    private fun findFirstClickableChild(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.isClickable) {
            return node
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            val clickableChild = findFirstClickableChild(child)
            if (clickableChild != null) {
                return clickableChild
            }
        }
        return null
    }

    private fun bringZonePilotToFront() {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            Log.d(TAG, "Brought ZonePilot to the front.")
        } else {
            Log.e(TAG, "Could not get launch intent for ZonePilot.")
        }
    }

    private fun logViewHierarchy(node: AccessibilityNodeInfo?, depth: Int) {
        if (node == null) return
        val indent = " ".repeat(depth * 4)
        if (node.viewIdResourceName != null || node.text != null || node.contentDescription != null) {
            val nodeInfo = """
                ${indent}className: ${node.className},
                ${indent}text: '${node.text}',
                ${indent}contentDescription: '${node.contentDescription}',
                ${indent}viewId: '${node.viewIdResourceName}',
                ${indent}isClickable: ${node.isClickable}
            """.trimIndent()
            Log.d(TAG, nodeInfo)
        }
        for (i in 0 until node.childCount) {
            logViewHierarchy(node.getChild(i), depth + 1)
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
    
    // --- THIS FUNCTION WAS RESTORED ---
    private fun findClickableParentByChildText(rootNode: AccessibilityNodeInfo, textToFind: String): AccessibilityNodeInfo? {
        val textNodes = rootNode.findAccessibilityNodeInfosByText(textToFind)
        if (textNodes.isNullOrEmpty()) {
            return null
        }
        for (textNode in textNodes) {
            var parent: AccessibilityNodeInfo? = textNode
            while (parent != null) {
                if (parent.isClickable) {
                    return parent
                }
                parent = parent.parent
            }
        }
        return null
    }

    override fun onInterrupt() {
         Log.d(TAG, "Accessibility Service Interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service Connected")
        
        methodChannel = MainActivity.methodChannel
        methodChannel?.invokeMethod("serviceConnected", null)

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "goOnline" -> {
                    goOnline()
                    result.success("Go Online action initiated.")
                }
                "goOffline" -> {
                    goOffline()
                    result.success("Go Offline action initiated.")
                }
                "dumpLayout" -> {
                    Log.d(TAG, "--- MANUAL LAYOUT DUMP TRIGGERED ---")
                    val rootNode = rootInActiveWindow
                    if (rootNode != null) {
                        logViewHierarchy(rootNode, 0)
                        result.success("Layout dumped to Logcat.")
                    } else {
                        result.error("NULL_ROOT", "Root node is null.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        methodChannel?.invokeMethod("serviceDestroyed", null)
        super.onDestroy()
    }
}