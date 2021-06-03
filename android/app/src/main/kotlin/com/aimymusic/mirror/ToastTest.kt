package com.aimymusic.mirror

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterNativePlugin private constructor(private val activity: Activity) : MethodCallHandler {
    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) { // 分析 2
        if (methodCall.method == "isChinese") {
            val isChinese = true
            result.success(true) // 分析3
        } else {
            result.notImplemented()
        }
    }

    companion object {
        var CHANNEL = "com.test/name" // 分析1
        var channel: MethodChannel? = null
        fun registerWith(registrar: Registrar) {
            channel = MethodChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterNativePlugin(registrar.activity())
            channel!!.setMethodCallHandler(instance)
        }
    }

}