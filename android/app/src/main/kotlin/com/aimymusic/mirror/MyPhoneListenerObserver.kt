package com.aimymusic.mirror

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler
import io.flutter.plugin.common.BinaryMessenger.BinaryReply
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import java.nio.ByteBuffer
import java.util.*
/* Map<String, Object> resultMap = new HashMap<>();
    resultMap.put("message", "android 主动调用 flutter test 方法");
    resultMap.put("code", 200);
//主动向Flutter 中发送消息
    mMethodChannel.invokeMethod("test", resultMap);*/
class MyPhoneListenerObserver : BroadcastReceiver() {
    val TAG_PHONE = "Tel tag"
//    var messageChannel: BasicMessageChannel<Any>? = null
    var flutterView: BinaryMessenger = object : BinaryMessenger {
        override fun send(channel: String, message: ByteBuffer?) {
            println("-----------------------------send" + message.toString())
        }

        override fun send(channel: String, message: ByteBuffer?, callback: BinaryReply?) {
            println("-----------------------------send2" + message.toString())
        }

        override fun setMessageHandler(channel: String, handler: BinaryMessageHandler?) {
            println("-----------------------------setMessageHandler")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        var resultMap: MutableMap<String, Any> = HashMap()
        //主动向Flutter 中发送消息
         val  mMethodChannel = MethodChannel(flutterView,"PhoneStatusListener")
        val manager = context.getSystemService(Service.TELEPHONY_SERVICE) as TelephonyManager
       /* if (messageChannel == null) {
            messageChannel = BasicMessageChannel(flutterView, "messageChannel", StandardMessageCodec.INSTANCE)
        }*/
        when (manager.callState) {
            TelephonyManager.CALL_STATE_IDLE -> {
                Log.d(TAG_PHONE, "***空闲状态中****")
             /*   messageChannel!!.send("flutter***空闲状态中****")*/
                resultMap["PhoneStatus"] = TelephonyManager.CALL_STATE_IDLE
            }
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                Log.d(TAG_PHONE, "***通话中****")
               /* messageChannel!!.send("flutter***通话中****")*/
                resultMap["PhoneStatus"] = TelephonyManager.CALL_STATE_OFFHOOK
            }
            TelephonyManager.CALL_STATE_RINGING -> {
               /* messageChannel!!.send("***振铃中****")*/
                Log.d(TAG_PHONE, "flutter***振铃中****")
                resultMap["PhoneStatus"] = TelephonyManager.CALL_STATE_RINGING
            }
        }
        mMethodChannel.invokeMethod("phoneLitener",resultMap)
    }
}