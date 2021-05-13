import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/profile/fitness_entry_model.dart';
import 'package:mirror/data/model/topic/topic_background_config.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_page.dart';
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
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/im/message_manager.dart';
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

  //记录路由名称
  static List<String> pagePopRouterName;

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

  //IfPage的TabController
  static TabController ifPageController;

  static Connectivity connectivity;

  //相机列表
  static List<CameraDescription> cameras;
  static bool isCameraInUse = false;

  // 动态model
  static HomeFeedModel feedModel;

  // 是否唤起键盘上方输入框
  static bool isArouse = false;

  //健身照片详情页返回内容
  static TrainingGalleryResult galleryResult;
  // 评论类型
  static CommentTypes commentTypes = CommentTypes.commentFeed;

  // 动态主评论
  static CommentDtoModel commentDtoModel;

  // 动态子评论
  static CommentDtoModel replysModel;

  //对比图是否保存分享
  static bool imageIsSaveOrShared = false;
  //互动通知未读数时间戳
  static int unreadNoticeTimeStamp;
  // 用于传递所选图片视频内容，用完后需要删除
  static SelectedMediaFiles selectedMediaFiles;

  // 用于记录登录页之前页面的路由名称，以便完成登录后回退到该页完成页面返回
  static String loginPopRouteName;

  //发送验证码的全局计时
  static int smsCodeSendTime;

  static Dio dio;

  //全局的记录发送验证码的手机号
  static String sendSmsPhoneNum;

  //键盘的高度
  static double keyboardHeightIfPage = 0;
  static double keyboardHeightChatPage = 0;

  //用户分享的消息
  static Message shareMessage;

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

  //系统平台 0-android 1-ios
  static int platform;

  //用户所登录的机器
  static MachineModel machine;

  //聊天群的群成员信息
  static Map<String, Map<String, dynamic>> chatGroupUserInformationMap = Map();

  //发送消息的临时列表
  //key是:用户id_会话id_会话类型
  static Map<String, List<ChatDataModel>> postChatDataModelList = Map();

  //进入聊天界面前先获取的消息列表
  static List<ChatDataModel> chatDataList = <ChatDataModel>[];

  //群组at的列表
  static AtMesGroupModel atMesGroupModel = AtMesGroupModel();

  //那些消息是置顶的no_prompt_uid_model
  static List<TopChatModel> topChatModelList = [];

  //那些消息是免打扰的
  static List<NoPromptUidModel> queryNoPromptUidList = [];

  // 定位所在城市Id
  static String cityId = "targetCityId";

  // 发布中临时插入的动态Id
  // static final int insertFeedId = -2;

  // 话题model的map
  static Map<int, TopicDtoModel> topicMap = {};

  //未读数-消息
  static int unreadMessageNumber = 0;

  //未读数-通知
  static int unreadNoticeNumber = 0;

  //是否显示新用户的dialog
  static bool isShowNewUserDialog = false;

  //发布失败动态key
  static String postFailurekey = "postFailureFeed";
  static FitnessEntryModel fitnessEntryModel = FitnessEntryModel();
  // 话题详情页背景图配置表
  static List<TopicBackgroundConfigModel> topicBackgroundConfig = [];
  //公共登出方法
  static appLogout({BuildContext context,bool isKicked = false}) async {
    if(context!=null){
      Loading.showLoading(context,infoText: "正在登出...");
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
        _clearUserRuntimeCache();
        //跳转页面 移除所有页面 重新打开首页
        if(Application.pagePopRouterName==null){
          Application.pagePopRouterName=[];
        }else {
          Application.pagePopRouterName.clear();
        }
        if(context!=null){
          Loading.hideLoading(context);
        }
        navigatorKey.currentState.pushNamedAndRemoveUntil("/", (route) => false);
        //TODO 这个弹窗待定
        if (isKicked) {
          Future.delayed(Duration(seconds: 1)).then((value) {
            showAppDialog(navigatorKey.currentState.overlay.context,
                title: "你被踢下线了",
                info: "可能在其他设备登录",
                confirm: AppDialogButton("我知道了", () {
                  return true;
                }));
          });
        }
      } else {
        if(context!=null){
          Loading.hideLoading(context);
        }
        print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫进入了匿名用户登出流程🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
        //如果本来就是匿名token那么换个token就行 不用清任何东西也不用跳转页面
        await TokenDBHelper().insertToken(tokenDto);
        appContext.read<TokenNotifier>().setToken(tokenDto);
      }
    } else {
      if(context!=null){
        Loading.hideLoading(context);
      }
      if(context!=null){
        ToastShow.show(msg: "退出登录失败", context: context);
      }
      //失败的情况下 登出将无token可用 所以不能继续登出
      print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫登出流程获取token失败🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
    }
  }

  static _clearUserRuntimeCache() {
    appContext.read<MachineNotifier>().setMachine(null);
    appContext.read<UserInteractiveNotifier>().clearProfileUiChangeModel();
    //TODO 其他的provider还需整理出来清掉
    atMesGroupModel?.atMsgMap?.clear();
    topChatModelList.clear();
    chatDataList.clear();
    postChatDataModelList.clear();
    queryNoPromptUidList.clear();
    chatGroupUserInformationMap.clear();
    postChatDataModelList.clear();
    unreadMessageNumber = 0;
    unreadNoticeNumber = 0;
    isShowNewUserDialog =false;
  }
}
