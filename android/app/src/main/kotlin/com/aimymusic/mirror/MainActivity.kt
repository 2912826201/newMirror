package com.aimymusic.mirror

import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.widget.Toast
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.android.FlutterActivity



class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var isDebug: Boolean
        var channel: String
//        val isDebug: Boolean = try {
//            val info: ApplicationInfo = context.applicationInfo
//            (info.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
//        } catch (e: Exception) {
//            false
//        }
        try {
            val appInfo: ApplicationInfo = context.packageManager.getApplicationInfo(context.packageName,
                    PackageManager.GET_META_DATA)
            channel = appInfo.metaData.getInt("CHANNEL", 0).toString()
            isDebug = appInfo.metaData.getString("ENVIRONMENT", "") == "DEV"
        } catch (e: Exception) {
            channel = "0"
            isDebug = false
        }

        if (isDebug) {
            UMConfigure.init(this, "60acbb5bc9aacd3bd4e6d5c0", channel, UMConfigure.DEVICE_TYPE_PHONE, null)
        } else {
            UMConfigure.init(this, "60af52726c421a3d97cf3faf", channel, UMConfigure.DEVICE_TYPE_PHONE, null)
        }
        UMConfigure.setLogEnabled(true)
        com.umeng.umeng_common_sdk.UmengCommonSdkPlugin.setContext(this)
        Log.i("UMLog", "onCreate@MainActivity")
    }


    override fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
        Log.i("UMLog", "onPause@MainActivity")
    }

    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
        Log.i("UMLog", "onResume@MainActivity")
    }

}
