package com.aimymusic.mirror.method

import android.content.Context
import com.aimymusic.mirror.R
import com.aimymusic.mirror.util.BadgeUtil
import com.aimymusic.mirror.util.RomUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import me.leolin.shortcutbadger.ShortcutBadger
import java.lang.Exception
import io.flutter.Log


class SystemMethodCallHandlerImpl(var context: Context) : MethodChannel.MethodCallHandler {


    companion object {
        var badgerChannel: String = "com.aimymusic.mirror/phone_system";
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPhoneSystem" -> {
                Log.d("aaaaa", "获取手机系统的厂商")
                result.success(RomUtil.getDeviceBrand())
            }
        }
    }
}
