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
  static const String _DEV_HOST = "http://ifdev.aimymusic.com";
  static const String _MIRROR_HOST = "https://ifdev.aimymusic.com";
  static const String _PROD_HOST = "https://ifdev.aimymusic.com";

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
}

enum Env {
  DEV, //测试服
  MIRROR, //镜像服
  PROD //正式服
}
