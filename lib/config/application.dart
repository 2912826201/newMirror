import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
/// application
/// Created by yangjiayi on 2020/11/14.

class Application {
  //页面路由
  static FluroRouter router;

  //当前token
  static TokenDto token;

  //临时token 在用户需要绑定手机号或完善用户资料时该用户的token无法用在其他场景 暂存在这里
  static TokenModel tempToken;

  //当前用户的信息
  static ProfileDto profile;

  //TODO 评论输入框等提示语 需要考量是否有更合适的方式管理
  static String hintText = "";
  //相机列表
  static List<CameraDescription> cameras;
  // 动态model
  static HomeFeedModel model;
  // 是否唤起键盘上方输入框
  static bool isArouse = false;
}