import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// application
/// Created by yangjiayi on 2020/11/14.

//FIXME 需要整理出哪些是和用户相关的 在切换账号或登出时要清掉
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
  static bool isCameraInUse = false;

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
  static int smsCodeSendTime;

  //全局的记录发送验证码的手机号
  static String sendSmsPhoneNum;

  //键盘的高度
  static double keyboardHeight = 0;

  //用户分享的消息
  static Message shareMessage;

  //省级地区的数据
  static LinkedHashMap<int, RegionDto> provinceMap =
      LinkedHashMap<int, RegionDto>();

  //市级地区的数据
  static Map<int, List<RegionDto>> cityMap = Map<int, List<RegionDto>>();

  //播放音频组件
  static AudioPlayer audioPlayer;

  //main的上下文
  static BuildContext appContext;


  //群成员的id--群昵称
  static Map<String, String> chatGroupUserModelMap = Map();

  //群组at的列表
  static AtMesGroupModel atMesGroupModel = new AtMesGroupModel();

  //系统平台 0-android 1-ios
  static int platform;

  //那些消息是置顶的no_prompt_uid_model
  static List<TopChatModel> topChatModelList = [];

  //那些消息是免打扰的
  static List<NoPromptUidModel> queryNoPromptUidList = [];

  //用户所登录的机器
  static MachineModel machine;
  // 定位所在城市Id
  static String cityId = "targetCityId";
  // 高德ioskey
  static String iosKey = "836c55dba7d3a44793ec9ae1e1dc2e82";
  // 高德安卓key
  static String androidAMapKey = "fef4e35be05e2337119aeb3b4e57388d";
}