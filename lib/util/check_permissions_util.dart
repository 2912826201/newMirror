import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/widget/loading.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermissionsUtil {
  static CheckPermissionsUtil _util;

  BuildContext _context;

  //获取权限失败-报错信息
  Function(String errorMessage) _errorMessageListener;

  //打开设置定位功能的界面-打开定位---ios只有这个返回
  Function() _openLocationSettingsListener;

  //打开app设置界面-设置权限-的返回方法---ios没有这个返回
  Function() _openAppSettingsListener;

  //获取有权限时 的返回方法
  Function() _successListener;

  //网络异常时--返回方法
  Function(String errorMessage) _networkErrorListener;

  BuildContext get context => _context;

  static CheckPermissionsUtil init(BuildContext context) {
    if (_util == null) {
      _util = CheckPermissionsUtil();
    }
    _util._context = context;
    _util._checkPermissions();
    return _util;
  }

  //检查有没有权限
  _checkPermissions() async {
    //检查有没有网络
    if (!(await isHaveNetwork())) {
      _analyzeErrorMessage("未连接到网络");
      return;
    }

    //开始获取定位
    Loading.showLoading(context);
    try {
      await AmapLocation.fetch();
      Loading.hideLoading(context);
      if (_successListener != null) {
        _successListener();
      }
    } catch (e) {
      Loading.hideLoading(context);
      _analyzeErrorMessage(e.toString());
    }
  }

  ///获取权限失败-报错信息
  CheckPermissionsUtil errorMessageListener(Function(String errorMessage) errorMessageListener) {
    this._errorMessageListener = errorMessageListener;
    return _util;
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

  ///网络异常时--返回方法
  CheckPermissionsUtil networkErrorListener(Function(String errorMessage) networkErrorListener) {
    this._networkErrorListener = networkErrorListener;
    return _util;
  }

  //解析错误信息
  //https://lbs.amap.com/api/android-location-sdk/guide/utilities/errorcode
  _analyzeErrorMessage(String message) async {
    print("_analyzeErrorMessage:${message?.toString()}");
    String alert = "获取定位权限失败";
    bool isNetworkError = false;
    if (message == null) {
      alert = "获取定位权限失败";
    } else if (message.contains("一些重要参数为空")) {
      alert = "请对定位传递的参数进行非空判断。";
    } else if (message.contains("没有基站信息")) {
      alert = "请重新尝试";
    } else if (message.contains("获取过程中出现异常")) {
      alert = "请对所连接网络进行全面检查，请求可能被篡改。";
      isNetworkError = true;
    } else if (message.contains("请求服务器过程中的异常")) {
      alert = "请检查设备网络是否通畅，检查通过接口设置的网络访问超时时间，建议采用默认的30秒。";
      isNetworkError = true;
    } else if (message.contains("定位结果解析失败")) {
      alert = "您可以稍后再试，或检查网络链路是否存在异常。";
      isNetworkError = true;
    } else if (message.contains("定位服务返回定位失败")) {
      alert = "请获取errorDetail（通过getLocationDetail()方法获取）信息并参考定位常见问题进行解决。";
    } else if (message.contains("KEY鉴权失败")) {
      alert = "请仔细检查key绑定的sha1值与apk签名sha1值是否对应，或通过高频问题查找相关解决办法。";
    } else if (message.contains("exception常规错误")) {
      alert = "请将errordetail（通过getLocationDetail()方法获取）信息通过工单系统反馈给我们。";
    } else if (message.contains("定位初始化时出现异常")) {
      alert = "请重新启动定位";
    } else if (message.contains("定位客户端启动失败")) {
      alert = "请检查AndroidManifest.xml文件是否配置了APSService定位服务";
    } else if (message.contains("定位时的基站信息错误")) {
      alert = "请检查是否安装SIM卡，设备很有可能连入了伪基站网络。";
      isNetworkError = true;
    } else if (message.contains("GPS当前不可用")) {
      alert = "建议开启设备的WIFI模块，并将设备中插入一张可以正常工作的SIM卡，"
          "或者检查GPS是否开启；如果以上都内容都确认无误，请您检查App是否被授予定位权限。";
    } else if (message.contains("GPS 状态差")) {
      alert = "建议持设备到相对开阔的露天场所再次尝试。";
    } else if (message.contains("定位结果被模拟导致定位失败")) {
      alert = "如果您希望位置被模拟，请通过setMockEnable(true);方法开启允许位置模拟";
    } else if (message.contains("无可用地理围栏")) {
      alert = "建议调整检索条件后重新尝试，例如调整POI关键字，调整POI类型，调整周边搜区域，调整行政区关键字等。";
    } else if (message.contains("由于手机WIFI功能被关闭同时设置为飞行模式")) {
      alert = "建议手机关闭飞行模式，并打开WIFI开关";
      isNetworkError = true;
    } else if (message.contains("由于手机没插sim卡且WIFI功能被关闭")) {
      alert = "建议手机插上sim卡，打开WIFI开关";
      isNetworkError = true;
    } else if (message.contains("定位服务没有开启")) {
      alert = "请在设置中打开定位服务开关";
      if (_openLocationSettingsListener != null) {
        _openLocationSettingsListener();
      }
    } else if (message.contains("定位权限被禁用")) {
      alert = "请授予应用定位权限";

      await _getPermissionStatus();
    } else if (message.contains("未连接到网络")) {
      alert = "网络异常，未连接到网络";
      isNetworkError = true;
    } else {
      alert = "获取定位权限失败...........";
    }

    if (isNetworkError) {
      if (_networkErrorListener != null) {
        _networkErrorListener(alert);
      }
    }

    if (_errorMessageListener != null) {
      _errorMessageListener(alert);
    }
    print("_analyzeErrorMessage:$alert");
  }

  //当没有权限时-获取权限
  _getPermissionStatus() async {
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

  //是否有网络
  Future<bool> isHaveNetwork() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}
