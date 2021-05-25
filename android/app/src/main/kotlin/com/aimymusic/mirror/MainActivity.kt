package com.aimymusic.mirror

import android.os.Bundle
import android.util.Log
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.android.FlutterActivity


class MainActivity: FlutterActivity() {

    override protected fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UMConfigure.init(this, "60acbb5bc9aacd3bd4e6d5c0", "DEV", UMConfigure.DEVICE_TYPE_PHONE, null)
        UMConfigure.setLogEnabled(true)
        com.umeng.umeng_common_sdk.UmengCommonSdkPlugin.setContext(this)
        Log.i("UMLog", "onCreate@MainActivity")
    }

    override protected fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
        Log.i("UMLog", "onPause@MainActivity")
    }

    override protected fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
        Log.i("UMLog", "onResume@MainActivity")
    }
}
