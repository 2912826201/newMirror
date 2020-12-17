import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// config
/// Created by yangjiayi on 2020/10/26.

//在这里配置各种环境参数
class AppConfig {
  //当前环境
  static const Env ENV = Env.DEV;

  //版本号
  //TODO 暂时先写在这 之后需要和打包配置联动
  static const String VER = "0.0.1";

  //各环境api请求基础路径
  // static const String _DEV_HOST = "http://ifdev.i-fitness.cn";
  // static const String _MIRROR_HOST = "http://ifdev.i-fitness.cn";
  // static const String _PROD_HOST = "http://ifdev.i-fitness.cn";
  static const String _DEV_HOST = "http://ifdev.aimymusic.com";
  static const String _MIRROR_HOST = "http://ifdev.aimymusic.com";
  static const String _PROD_HOST = "http://ifdev.aimymusic.com";
  //各环境业务二维码基础路径
  static const String _DEV_QRCODE_HOST = "http://codedev.i-fitness.cn";
  static const String _MIRROR_QRCODE_HOST = "http://codedev.i-fitness.cn";
  static const String _PROD_QRCODE_HOST = "http://codedev.i-fitness.cn";

  //根据环境获取api的host地址
  static String getApiHost() {
    switch (AppConfig.ENV) {
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
    switch (AppConfig.ENV) {
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
    switch (AppConfig.ENV) {
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
  }

  //获取图片文件的路径
  static String getAppPicDir() {
    return "$_appDir/pic";
  }
}

enum Env {
  DEV, //测试服
  MIRROR, //镜像服
  PROD //正式服
}
