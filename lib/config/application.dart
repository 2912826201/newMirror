import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/im/rongcloud.dart';

/// application
/// Created by yangjiayi on 2020/11/14.

class Application {
  //融云
  static RongCloud rongCloud;

  //页面路由
  static FluroRouter router;

  //当前token
  static TokenDto token;

  //临时token 在用户需要绑定手机号或完善用户资料时该用户的token无法用在其他场景 暂存在这里
  static TokenModel tempToken;

  //当前用户的信息
  static ProfileDto profile;

  //视频课程的tag
  static VideoTagModel videoTagModel;

  //TODO 评论输入框等提示语 需要考量是否有更合适的方式管理
  static String hintText = "";

  //相机列表
  static List<CameraDescription> cameras;

  // 动态model
  static HomeFeedModel feedModel;

  // 是否唤起键盘上方输入框
  static bool isArouse = false;

  // 评论类型
  static CommentTypes commentTypes = CommentTypes.commentFeed;

  // 动态主评论
  static CommentDtoModel commentDtoModel;

  // 动态子评论
  static CommentDtoModel replysModel;

  // 用于传递所选图片视频内容，用完后需要删除
  static SelectedMediaFiles selectedMediaFiles;

  // 用于记录登录页之前页面的路由名称，以便完成登录后回退到该页完成页面返回
  static String loginPopRouteName;

  //发送验证码的全局计时
  static int smsCodeSendTime ;

  //全局的记录发送验证码的手机号
  static String sendSmsPhoneNum;

  //键盘的高度
  static double keyboardHeight = 0;
}