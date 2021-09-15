package com.aimymusic.mirror.util;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

public class LocationServiceUtil {

    private ContentResolver contentResolver;
    private Context context;

    @SuppressLint("StaticFieldLeak")
    private static LocationServiceUtil locationServiceUtil;

    public static LocationServiceUtil init(Context context){
        if(locationServiceUtil==null){
            locationServiceUtil = new LocationServiceUtil();
            locationServiceUtil.context = context;
            locationServiceUtil.contentResolver = locationServiceUtil.context.getApplicationContext().getContentResolver();
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
        int locationMode;
        String locationProviders;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            try {
                locationMode = Settings.Secure.getInt(contentResolver,Settings.Secure.LOCATION_MODE);
            } catch (Settings.SettingNotFoundException e) {
                e.printStackTrace();
                return false;
            }
            return locationMode != Settings.Secure.LOCATION_MODE_OFF;
        } else {
            locationProviders = Settings.Secure.getString(contentResolver, Settings.Secure.LOCATION_PROVIDERS_ALLOWED);
            return !TextUtils.isEmpty(locationProviders);
        }
    }
}
