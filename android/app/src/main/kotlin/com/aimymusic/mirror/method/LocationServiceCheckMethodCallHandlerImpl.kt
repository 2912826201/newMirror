package com.aimymusic.mirror.method

import android.content.Context
import com.aimymusic.mirror.util.LocationServiceUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.Log


class LocationServiceCheckMethodCallHandlerImpl(var context: Context) : MethodChannel.MethodCallHandler {


    companion object {
        var badgerChannel: String = "com.aimymusic.mirror/location_service_check";
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("location_service_check", "判断手机")
        when (call.method) {
            "checkLocationIsOpen" -> {
                Log.d("location_service_check", "判断手机是否打开了定位服务")
                result.success(LocationServiceUtil.init(context).checkLocationIsOpen())
            }
        }
    }
}
