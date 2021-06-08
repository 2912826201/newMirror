package com.aimymusic.mirror;


import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.telephony.TelephonyManager;
import android.util.Log;



import java.lang.ref.WeakReference;



public class MyPhoneObServer {
    private  static String TAG_PHONE = "system.phoneListener.print";
    private   PhoneStatusChangeListener mPhoneStatusChangeListener;
    private PhoneListenerObserver mPhoneListenerObserver;
    private static final String PHONE_STATUS_ACTION = "android.phone.phoneStatus_action";
    private  Context mContext;
    public MyPhoneObServer(Context context){mContext = context;}
    public interface PhoneStatusChangeListener {
        void onPhoneStatusChange(int phoneStatus);
    }

    public PhoneStatusChangeListener getPhoneStatusChangeListener() {
        return mPhoneStatusChangeListener;
    }

    public void setPhoneStatusListener(PhoneStatusChangeListener phoneStatusChangeListener) {
        this.mPhoneStatusChangeListener = phoneStatusChangeListener;
    }
    public void registerReceiver() {
        mPhoneListenerObserver = new PhoneListenerObserver(this);
        IntentFilter filter = new IntentFilter();
        filter.addAction(PHONE_STATUS_ACTION);
        mContext.registerReceiver(mPhoneListenerObserver, filter);
    }
    public void unregisterReceiver() {
            try {
                mContext.unregisterReceiver(mPhoneListenerObserver);
                mPhoneStatusChangeListener = null;
            } catch (Exception e) {
                Log.e(TAG_PHONE, "unregisterReceiver: ", e);
            }

    }

    private static class PhoneListenerObserver extends BroadcastReceiver {
        private WeakReference<MyPhoneObServer> mObserverWeakReference;

        public PhoneListenerObserver(MyPhoneObServer myPhoneObServer) {
            mObserverWeakReference = new WeakReference<>(myPhoneObServer);
        }
        @Override
        public void onReceive(Context context, Intent intent) {
            MyPhoneObServer myPhoneObServer = mObserverWeakReference.get();
            PhoneStatusChangeListener listener = myPhoneObServer.getPhoneStatusChangeListener();
            TelephonyManager manager = (TelephonyManager) context.getSystemService(Service.TELEPHONY_SERVICE);
            switch (manager.getCallState()) {
                case TelephonyManager.CALL_STATE_IDLE:
                    Log.d(TAG_PHONE, "***空闲状态中****");
                    if (listener!=null){
                        listener.onPhoneStatusChange(TelephonyManager.CALL_STATE_IDLE);
                    }
                    break;
                case TelephonyManager.CALL_STATE_OFFHOOK:
                    Log.d(TAG_PHONE, "***振铃中****");
                    if (listener!=null){
                        listener.onPhoneStatusChange(TelephonyManager.CALL_STATE_OFFHOOK);
                    }
                    break;
                case TelephonyManager.CALL_STATE_RINGING:
                    Log.d(TAG_PHONE, "***通话中****");
                    if (listener!=null){
                        listener.onPhoneStatusChange(TelephonyManager.CALL_STATE_RINGING);
                    }
                    break;
            }

        }
    }
}

