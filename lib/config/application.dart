import 'package:fluro/fluro.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';

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
  //DateTime.now().millisecondsSinceEpoch的值，为unix时间戳
  //发送验证码的全局计时
  static int smsCodeSendTime ;
  //全局的记录发送验证码的手机号
  static String sendSmsPhoneNum;
}