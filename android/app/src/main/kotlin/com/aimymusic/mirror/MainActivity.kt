package com.aimymusic.mirror

import android.Manifest
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler
import io.flutter.plugin.common.BinaryMessenger.BinaryReply
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import java.nio.ByteBuffer
import java.util.*


@Suppress("DEPRECATED_IDENTITY_EQUALS")
class MainActivity : FlutterActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        requestPermission()
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
//        myPhoneListener.unregisterReceiver()
        Log.i("UMLog", "onPause@MainActivity")
    }
    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
//        myPhoneListener.registerReceiver()
        Log.i("UMLog", "onResume@MainActivity")
    }
    fun getFlutterView(): BinaryMessenger? {
        return flutterEngine!!.dartExecutor.binaryMessenger
    }

    fun requestPermission() {
        if (ContextCompat.checkSelfPermission(this,
                        Manifest.permission.CALL_PHONE) !== PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                        Manifest.permission.READ_PHONE_STATE) !== PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                        Manifest.permission.MODIFY_PHONE_STATE) !== PackageManager.PERMISSION_GRANTED) { //表示未授权时
            //进行授权
            ActivityCompat.requestPermissions(this, arrayOf<String>(Manifest.permission.CALL_PHONE, Manifest
                    .permission.READ_PHONE_STATE, Manifest.permission.MODIFY_PHONE_STATE), 1)
        }
    }

}
