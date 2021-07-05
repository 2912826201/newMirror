package com.aimymusic.mirror.util

import android.os.Build
import android.text.TextUtils
import io.flutter.Log
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader


object RomUtil {
    private val TAG = "Rom"

    //小米
    val rom_xiaomi = "xiaomi"

    //索尼
    val rom_sony = "sony"

    //三星
    val rom_samsung = "samsung"
    val rom_lg = "lg"

    //htc
    val rom_htc = "htc"

    //oppo
    val rom_oppo = "OPPO"

    //乐视
    val rom_lemobile = "LeMobile"
    val rom_letv = "letv"

    //vivo
    val rom_vivo = "vivo"

    //华为
    val rom_huawei1 = "HUAWEI"
    val rom_huawei2 = "Huawei"

    //华为-nova
    val rom_nova = "nova"

    //荣耀
    val rom_honor = "HONOR"

    //魅族
    val rom_meizu = "Meizu"

    //魅族
    val rom_oneplus = "OnePlus"

    //三星
    val rom_smartisan = "smartisan"

    //联想
    val rom_lenovo = "lenovo"


    /**
     * 获取手机厂商
     *
     * @return  手机厂商
     */
    fun getDeviceBrand(): String? {
        return Build.BRAND
    }


}