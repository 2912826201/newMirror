package com.aimymusic.mirror.util;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.location.LocationManager;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

public class LocationServiceUtil {

    private Context context;

    @SuppressLint("StaticFieldLeak")
    private static LocationServiceUtil locationServiceUtil;

    public static LocationServiceUtil init(Context context){
        if(locationServiceUtil==null){
            locationServiceUtil = new LocationServiceUtil();
            locationServiceUtil.context = context;
        }
        return locationServiceUtil;
    }


    /**
     * 检查定位服务是否开启
     */
    public boolean checkLocationIsOpen() {
        return isLocationEnabled();
    }


    /**
     * 返回定位服务开启状态
     */
    private boolean isLocationEnabled() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // This is new method provided in API 28
            LocationManager lm = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
            return lm.isLocationEnabled();
        } else {
            // This is Deprecated in API 28
            int mode = Settings.Secure.getInt(context.getContentResolver(), Settings.Secure.LOCATION_MODE,
                    Settings.Secure.LOCATION_MODE_OFF);
            return (mode != Settings.Secure.LOCATION_MODE_OFF);
        }
    }
}
