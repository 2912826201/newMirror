import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermissionsUtil {
  static CheckPermissionsUtil _util;

  static final String _badgerChannel = "com.aimymusic.mirror/location_service_check";

  static MethodChannel _channel;

  BuildContext _context;

  //打开设置定位功能的界面-打开定位---ios只有这个返回
  Function() _openLocationSettingsListener;

  //打开app设置界面-设置权限-的返回方法---ios没有这个返回
  Function() _openAppSettingsListener;

  //获取有权限时 的返回方法
  Function() _successListener;


  BuildContext get context => _context;

  static CheckPermissionsUtil init(BuildContext context) {
    if (_util == null) {
      _util = CheckPermissionsUtil();
    }
    if (_channel == null) {
      _channel = MethodChannel(_badgerChannel);
    }
    _util._context = context;
    _util._checkPermissions();
    return _util;
  }

  //检查权限
  //这里只检测android手机是否打开定位服务
  //ios 不检测
  _checkPermissions() async {
    if (CheckPhoneSystemUtil.init().isAndroid()) {
      bool checkLocationIsOpen = await _channel.invokeMethod('checkLocationIsOpen');
      if (checkLocationIsOpen) {
        _isHavePermissions();
      } else {
        //android 没有打开定位服务
        if (_openLocationSettingsListener != null) {
          _openLocationSettingsListener();
        }
      }
    } else {
      _isHavePermissions();
    }
  }

  //检查有没有权限
  _isHavePermissions() async {
    PermissionStatus permissions = await Permission.locationWhenInUse.status;

    if (permissions.isDenied) {
      permissions = await Permission.locationWhenInUse.request();
    }

    if (permissions.isGranted) {
      if (_successListener != null) {
        _successListener();
      }
    } else if (permissions.isPermanentlyDenied) {
      if (!AppPrefs.isFirstLocationPermissionDenied()) {
        if (CheckPhoneSystemUtil.init().isAndroid()) {
          if (_openAppSettingsListener != null) {
            _openAppSettingsListener();
          }
        } else {
          if (_openLocationSettingsListener != null) {
            _openLocationSettingsListener();
          }
        }
      } else {
        AppPrefs.setIsFirstLocationPermissionDenied(false);
      }
    } else if (permissions.isDenied) {
      AppPrefs.removeLocationPermissionDenied();
    }
  }


  ///打开设置定位功能的界面-打开定位---ios只有这个返回
  CheckPermissionsUtil openLocationSettingsListener(Function() openLocationSettingsListener) {
    this._openLocationSettingsListener = openLocationSettingsListener;
    return _util;
  }

  ///打开app设置界面-设置权限-的返回方法---ios没有这个返回
  CheckPermissionsUtil openAppSettingsListener(Function() openAppSettingsListener) {
    this._openAppSettingsListener = openAppSettingsListener;
    return _util;
  }

  ///获取有权限时 的返回方法
  CheckPermissionsUtil successListener(Function() successListener) {
    this._successListener = successListener;
    return _util;
  }

}

// 获取定位权限
locationPermissions1(BuildContext context) async {
  CheckPermissionsUtil.init(context).openAppSettingsListener(() {
    showAppDialog(context,
        title: "位置信息",
        info: "你没有开通位置权限，您可以通过系统\"设置\"进行权限管理",
        confirmColor: AppColor.white,
        cancel: AppDialogButton("返回", () {
          return true;
        }),
        confirm: AppDialogButton("去设置", () {
          AppSettings.openAppSettings();
          return true;
        }));
  }).openLocationSettingsListener(() {
    showAppDialog(context,
        title: "位置信息",
        info: "你没有打开定位功能,请打开定位功能",
        confirmColor: AppColor.white,
        cancel: AppDialogButton("返回", () {
          return true;
        }),
        confirm: AppDialogButton("去设置", () {
          AppSettings.openLocationSettings();
          return true;
        }));
  }).successListener(() {
    //有权限时
    ToastShow.show(msg: "权限没有问题", context: context);
  });
}
