import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:better_player/better_player.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/fitness_entry_model.dart';
import 'package:mirror/data/model/topic/topic_background_config.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/loading.dart';
import 'package:provider/provider.dart';
import 'package:fluro/fluro.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'runtime_properties.dart';

/// application
/// Created by yangjiayi on 2020/11/14.

//FIXME 需要整理出哪些是和用户相关的 在切换账号或登出时要清掉
class Application {
  //融云
  static RongCloud rongCloud;

  //页面路由
  static FluroRouter router;

  //记录路由名称
  static List<String> pagePopRouterName;

  //当前token
  //NOTE 当网络不通或服务端异常时可能取不到token此值可能为null
  static TokenDto token;

  //临时token 在用户需要绑定手机号或完善用户资料时该用户的token无法用在其他场景 暂存在这里
  static TokenModel tempToken;

  //当前用户的信息
  static ProfileDto profile;

  //视频课程的tag
  static VideoTagModel videoTagModel;

  //IfPage的TabController
  static TabController ifPageController;

  static Connectivity connectivity;

  //相机列表
  static List<CameraDescription> cameras;
  static bool isCameraInUse = false;

  // 用于记录登录页之前页面的路由名称，以便完成登录后回退到该页完成页面返回
  static String loginPopRouteName;

  static Dio dio;

  static JPush jpush;

  //键盘的高度
  static double keyboardHeightIfPage = 0;
  static double keyboardHeightChatPage = 0;

  //省级地区的数据
  static LinkedHashMap<int, RegionDto> provinceMap = LinkedHashMap<int, RegionDto>();

  //市级地区的数据
  static Map<int, List<RegionDto>> cityMap = Map<int, List<RegionDto>>();

  //播放音频组件
  static AudioPlayer audioPlayer;

  //main的上下文
  static BuildContext appContext;

  //app的页面导航key
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static int openAppTime = 0;

  static bool isBackGround = false;

  static bool isShowWidget = false;

  //用户所登录的机器
  static MachineModel machine;

  // 定位所在城市Id
  static String cityId = "targetCityId";

  // 发布中临时插入的动态Id
  // static final int insertFeedId = -2;

  static bool dialogClose = true;
  //新版本的信息
  static VersionModel versionModel;

  //是否存在新版本
  static bool haveNewVersion = false;

  //发布失败动态key
  static String postFailurekey = "postFailureFeed";
  static FitnessEntryModel fitnessEntryModel = FitnessEntryModel();

  // 话题详情页背景图配置表
  static List<TopicBackgroundConfigModel> topicBackgroundConfig = [];

  // 搜索页tabBarIndex数组
  static List<int> tabBarIndexList = [];

  // 动态视频控制器
  static List<int> feedVideoControllerList = [];
  static List<BetterPlayerController> feedVideoControllerLists = [];
  // 轮播图切换
  static bool slideBanner2Dor3D = false;
  // 话题详情页贝塞尔曲线切换
  static bool slideTopicBezierCurve = false;
  // 动态点赞动画切换
  static bool slideFeedLike = false;
  // 点赞文字颜色动画切换
  static bool slideColorizeAnimatedText = false;
  // 话题详情页简介文字打字机效果切换
  static bool slideAnimatedTextTypewriter = false;
  // 发布动态周边信息滑动动画渐隐渐现动画
  static bool slideReleaseFeedFadeInAnimation = false;
  // 查看视频曝光的元素看时间最明显
  static List<String> feedVideoTimeList = [];
  //公共登出方法
  static appLogout({BuildContext context, bool isKicked = false}) async {
    if (context != null) {
      Loading.showLoading(context, infoText: "正在登出...");
    }
    //先取个匿名token
    BaseResponseModel responseModel = await login("anonymous", null, null, null);
    if (responseModel != null && responseModel.code == 200) {
      TokenModel tokenModel = TokenModel.fromJson(responseModel.data);
      TokenDto tokenDto = TokenDto.fromTokenModel(tokenModel);
      if (token != null && token.anonymous == 0) {
        print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫进入了登录用户登出流程🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
        bool result = await logout();
        //TODO 这里先不处理登出接口的结果
        //清用户token和用户资料 provider的context用appContext
        await TokenDBHelper().insertToken(tokenDto);
        appContext.read<TokenNotifier>().setToken(tokenDto);
        await ProfileDBHelper().clearProfile();
        appContext.read<ProfileNotifier>().setProfile(ProfileDto.fromUserModel(UserModel()));
        // 登出融云
        Application.rongCloud.disconnect();
        //TODO 处理登出后需要清掉的用户的其他数据
        MessageManager.clearUserMessage(appContext);
        RuntimeProperties.clearUserRuntimeProperties(appContext);
        EventBus.getDefault().post(msg: true, registerName: AGAIN_LOGIN_REPLACE_LAYOUT);
        //友盟上报登出
        UmengCommonSdk.onProfileSignOff();
        //跳转页面 移除所有页面 重新打开首页
        if (Application.pagePopRouterName == null) {
          Application.pagePopRouterName = [];
        } else {
          Application.pagePopRouterName.clear();
        }
        if (context != null) {
          Loading.hideLoading(context);
        }
        navigatorKey.currentState.pushNamedAndRemoveUntil("/", (route) => false);
        //TODO 这个弹窗待定
        if (isKicked) {
          dialogClose = false;
          Future.delayed(Duration(seconds: 1)).then((value) {
            showAppDialog(navigatorKey.currentState.overlay.context,
                title: "你被踢下线了",
                info: "可能在其他设备登录",
                confirm: AppDialogButton("我知道了", () {
                  dialogClose = true;
                  return true;
                }));
          });
        }
      } else {
        if (context != null) {
          Loading.hideLoading(context);
        }
        print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫进入了匿名用户登出流程🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
        //如果本来就是匿名token那么换个token就行 不用清任何东西也不用跳转页面
        await TokenDBHelper().insertToken(tokenDto);
        appContext.read<TokenNotifier>().setToken(tokenDto);
      }
    } else {
      if (context != null) {
        Loading.hideLoading(context);
      }
      if (context != null) {
        ToastShow.show(msg: "退出登录失败", context: context);
      }
      //失败的情况下 登出将无token可用 所以不能继续登出
      print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫登出流程获取token失败🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
    }
  }
}
