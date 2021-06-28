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


class AppBadgerMethodCallHandlerImpl(var context: Context) : MethodChannel.MethodCallHandler {


    companion object {
        var badgerChannel: String = "com.aimymusic.mirror/app_badger";
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "updateBadgeCount" -> {
                Log.d("aaaaa", "android 原生的updateBadgeCount${call.arguments}")
                if (call.arguments != null && call.arguments is Int) {
                    try {
                        val data = call.arguments.toString()
                        BadgeUtil.setBadgeCount(context, data.toInt(), R.mipmap.ic_launcher)
                    } catch (e: Exception) {
                    }
                    result.success(null)
                }
            }
            "removeBadge" -> {
                Log.d("aaaaa", "android 原生的removeBadge")
                BadgeUtil.resetBadgeCount(context, R.mipmap.ic_launcher)
            }
            "isAppBadgeSupported" -> {
                Log.d("aaaaa", "android 原生的isAppBadgeSupported")
//                result.success(ShortcutBadger.isBadgeCounterSupported(context))
            }
        }
    }
}


interface OnMethodCallListener {
    fun onMethodCall(callMethod: String, badgeCount: Int)
}