/// config
/// Created by yangjiayi on 2020/10/26.

//在这里配置各种环境参数
class AppConfig {
  //当前环境
  static const Env ENV = Env.DEV;
}

enum Env {
  DEV, //测试服
  MIRROR, //镜像服
  PROD //正式服
}
