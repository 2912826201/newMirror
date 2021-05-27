import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// config
/// Created by yangjiayi on 2020/10/26.

//在这里配置各种环境参数
class AppConfig {
  //当前环境 镜像服还需扩展开发
  static const Env env = kReleaseMode ? Env.PROD : Env.DEV;

  //当前渠道
  static const String channel = String.fromEnvironment("APP_CHANNEL", defaultValue: "");

  static String get channelCode {
    switch (channel) {
      case "common":
        return "10000";
      default:
        return "0";
    }
  }

  //版本号
  //在App启动时需要被重新赋值
  static String version = "0.0.1";
  static String buildNumber = "1";

  ///切换训练相关布局
  static bool needShowTraining = false;

  //各环境api请求基础路径
  // static const String _DEV_HOST = "http://ifdev.i-fitness.cn";
  // static const String _MIRROR_HOST = "http://ifdev.i-fitness.cn";
  // static const String _PROD_HOST = "http://ifdev.i-fitness.cn";
  static const String _DEV_HOST =
      // "http://14.119.109.139:18940";
      "http://ifdev2.aimymusic.com:18940";
  static const String _MIRROR_HOST = "http://ifdev.aimymusic.com";
  static const String _PROD_HOST = "http://ifdev.aimymusic.com";

  //各环境业务二维码基础路径
  static const String _DEV_QRCODE_HOST = "http://codedev.i-fitness.cn";
  static const String _MIRROR_QRCODE_HOST = "http://codedev.i-fitness.cn";
  static const String _PROD_QRCODE_HOST = "http://codedev.i-fitness.cn";

  //根据环境获取api的host地址
  static String getApiHost() {
    switch (AppConfig.env) {
      case Env.DEV:
        return _DEV_HOST;
      case Env.MIRROR:
        return _MIRROR_HOST;
      case Env.PROD:
        return _PROD_HOST;
      default:
        return "";
    }
  }

  //根据环境获取业务二维码基础路径
  static String getQrcodeHost() {
    switch (AppConfig.env) {
      case Env.DEV:
        return _DEV_QRCODE_HOST;
      case Env.MIRROR:
        return _MIRROR_QRCODE_HOST;
      case Env.PROD:
        return _PROD_QRCODE_HOST;
      default:
        return "";
    }
  }

  //各环境融云appkey
  static const String _DEV_RCAPPKEY = "pwe86ga5psfi6";
  static const String _MIRROR_RCAPPKEY = "pwe86ga5psfi6";
  static const String _PROD_RCAPPKEY = "pwe86ga5psfi6";

  //根据环境获取融云appkey
  static String getRCAppKey() {
    switch (AppConfig.env) {
      case Env.DEV:
        return _DEV_RCAPPKEY;
      case Env.MIRROR:
        return _MIRROR_RCAPPKEY;
      case Env.PROD:
        return _PROD_RCAPPKEY;
      default:
        return "";
    }
  }

  //app的文件根目录
  static String _appDir = "";

  //创建app用到的路径
  static void createAppDir() async {
    Directory extDir = await getApplicationDocumentsDirectory();
    _appDir = "${extDir.path}/if";
    print(_appDir);

    await Directory(_appDir).create(recursive: true);
    await Directory(getAppPicDir()).create(recursive: true);
    await Directory(getAppChatImageDir()).create(recursive: true);
    await Directory(getAppVideoDir()).create(recursive: true);
    await Directory(getAppVoiceDir()).create(recursive: true);
    await Directory(getAppDownloadDir()).create(recursive: true);
    await Directory(getAppCourseDir()).create(recursive: true);
    await Directory(getAppPublishDir()).create(recursive: true);
  }

  //获取图片文件的路径
  static String getAppPicDir() {
    return "$_appDir/pic";
  }

  //获取聊天界面图片文件的路径
  static String getAppChatImageDir() {
    return "$_appDir/chat_img";
  }

  //获取视频文件的路径
  static String getAppVideoDir() {
    return "$_appDir/video";
  }

  //获取语音文件的路径
  static String getAppVoiceDir() {
    return "$_appDir/voice";
  }

  static String getAppVoiceFilePath() {
    return "${getAppVoiceDir()}/record_${new DateTime.now().millisecondsSinceEpoch}.aac";
  }

  //获取内部下载文件的路径
  static String getAppDownloadDir() {
    return "$_appDir/download";
  }

  //获取课程文件的路径
  static String getAppCourseDir() {
    return "$_appDir/course";
  }

  //获取发布文件的路径
  static String getAppPublishDir() {
    return "$_appDir/publish";
  }

  // 高德ioskey
  static String amapIOSKey = "ac34e91ffcc967d7dca12f5f8d4bd038";

  // 高德安卓key
  static String amapAndroidKey = "18ddc6ba8332f5f7fab942b4fdf3ad9c";

  // 高德服务端key
  static String amapServerKey = "836c55dba7d3a44793ec9ae1e1dc2e82";

  // 获取当前系统的高德key
  static String getAmapKey() {
    if (Platform.isIOS) {
      return amapIOSKey;
    } else {
      return amapAndroidKey;
    }
  }
}

enum Env {
  DEV, //测试服
  MIRROR, //镜像服
  PROD //正式服
}
