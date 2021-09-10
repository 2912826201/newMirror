import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fps_monitor/util/collection_util.dart';
import 'package:fps_monitor/widget/custom_widget_inspector.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/api/version_api.dart';
import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/region_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/topic/topic_background_config.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/util/badger_util.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/jpush_analyze_code_util.dart';
import 'package:mirror/widget/globalization/localization_delegate.dart';
import 'package:mirror/widget/my_widgets_binding_observer.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'api/push_api.dart';
import 'api/training/course_api.dart';
import 'api/message_api.dart';
import 'api/user_api.dart';
import 'config/application.dart';
import 'config/config.dart';
import 'config/shared_preferences.dart';
import 'data/dto/profile_dto.dart';
import 'data/dto/token_dto.dart';
import 'data/model/data_response_model.dart';
import 'data/model/feed/feed_flow_data_notifier.dart';
import 'data/model/machine_model.dart';
import 'data/model/message/chat_enter_notifier.dart';
import 'generated/l10n.dart';
import 'data/model/message/chat_voice_setting.dart';
import 'data/model/message/group_user_model.dart';
import 'data/model/message/no_prompt_uid_model.dart';
import 'data/model/message/top_chat_model.dart';
import 'data/model/message/voice_alert_date_model.dart';
import 'data/model/token_model.dart';
import 'data/notifier/machine_notifier.dart';
import 'data/notifier/token_notifier.dart';
import 'data/notifier/profile_notifier.dart';
import 'data/notifier/unread_message_notifier.dart';
import 'data/notifier/user_interactive_notifier.dart';
import 'im/message_manager.dart';
import 'route/router.dart';

void main() {
  //设置状态栏透明
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  _initApp().then((value) => FlutterBugly.postCatchedException(() {
    // GestureBinding.instance.resamplingEnabled = true;
    runApp(
          MultiProvider(
            providers: [
              //当前用户的token信息 无论匿名用户还是登录用户都会有值
              ChangeNotifierProvider(create: (_) => TokenNotifier(Application.token)),
              //当前用户的用户信息 如果是匿名用户则uid为-1 无其他信息
              ChangeNotifierProvider(create: (_) => ProfileNotifier(Application.profile)),
              //当前用户所登录的机器终端信息 如果没有则为null
              ChangeNotifierProvider(create: (_) => MachineNotifier(Application.machine)),
              // ValueListenableProvider<FeedMapNotifier>(builder: (_) => {},)
              ChangeNotifierProvider(create: (_) => FeedMapNotifier(FeedMap({}))),
              //融云的连接状态 初始值为-1
              ChangeNotifierProvider(create: (_) => RongCloudStatusNotifier()),
              //用户的融云会话信息 登录后会从数据库查出来放到此provider中
              ChangeNotifierProvider(create: (_) => ConversationNotifier()),
              //聊天界面用户录音的提示文字
              ChangeNotifierProvider(create: (_) => VoiceAlertData()),
              //聊天界面用户用户录音的功能
              ChangeNotifierProvider(create: (_) => VoiceSettingNotifier()),
              //群聊界面的@用户功能
              ChangeNotifierProvider(create: (_) => ChatEnterNotifier()),
              //用户相关界面信息
              ChangeNotifierProvider(create: (_) => UserInteractiveNotifier(UserNotifierModel({}))),
              //群成员信息
              ChangeNotifierProvider(create: (_) => GroupUserProfileNotifier()),
              //记录未读消息数 目前只记录3种互动通知的数量 从接口获取更新数据
              ChangeNotifierProvider(create: (_) => UnreadMessageNotifier()),
              ChangeNotifierProvider(create: (_) => FeedFlowDataNotifier()),
            ],
            child: MyApp(),
          ),
        );
      }));
}

//初始化APP
Future _initApp() async {
  // 升级flutter版本1.10.2后，因为在main()方法中有异步操作，对一些插件做了初始化操作。
  //要先执行该方法 不然插件无法加载调用
  WidgetsFlutterBinding.ensureInitialized();
  // 添加内存不足的监听处理
  MyWidgetsBindingObserver observer = MyWidgetsBindingObserver();
  WidgetsBinding.instance.addObserver(observer);
  //缓存个数 100
  PaintingBinding.instance.imageCache.maximumSize = 100;
  //缓存大小 100m
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;
  // 强制竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  //根据环境初始化bugly
  if (AppConfig.env == Env.DEV) {
    FlutterBugly.init(androidAppId: "251c0d4588", iOSAppId: "2c1f83137a", channel: AppConfig.channelCode);
  } else {
    FlutterBugly.init(androidAppId: "4172861916", iOSAppId: "9054e325b9", channel: AppConfig.channelCode);
  }

  //获取版本号
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    //app名称
    String appName = packageInfo.appName;
    //包名
    String packageName = packageInfo.packageName;
    //app版本
    String version = packageInfo.version;
    //build号
    String buildNumber = packageInfo.buildNumber;
    AppConfig.version = version;
    AppConfig.buildNumber = buildNumber;
    print('appName==&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&=========$appName');
    print('packageName======&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&======$packageName');
    print('version=========&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&===$version');
    print('buildNumber=====&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&=======$buildNumber');
  });

  //获取操作系统
  CheckPhoneSystemUtil.platform = Platform.isAndroid
      ? 0
      : Platform.isIOS
          ? 1
          : -1;

  Application.openAppTime = DateTime.now().millisecondsSinceEpoch;

  // 申请通知权限 iOS在此处处理 Android要APP自己写弹窗所以放在IfPage中
  if (CheckPhoneSystemUtil.init().isIos()) {
    // 检查是否已有通知的权限
    PermissionStatus permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
    bool status = permissionStatus != null && permissionStatus == PermissionStatus.granted;
    //判断如果还没拥有通知权限就申请获取权限
    if (!status) {
      permissionStatus = await NotificationPermissions.requestNotificationPermissions();
    }
  }
  DateTime dateTime = DateUtil.getDateTimeByMs(1630382381246);
  print('--DateTime---DateTime-${dateTime.month}----${dateTime.hour}----${dateTime.minute}----${dateTime.second}');

  //初始化SharedPreferences
  AppPrefs.init();
  //初始化数据库
  await DBHelper.instance.initDB();

  //初始化融云IM
  Application.rongCloud = RongCloud.init();

  //初始化页面路由
  final router = FluroRouter();
  AppRouter.configureRouter(router);
  Application.router = router;

  //创建各文件路径
  AppConfig.createAppDir();

  //获取相机信息
  try {
    Application.cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
    Application.cameras = [];
  }

  //全局的音频播放器
  Application.audioPlayer = new AudioPlayer();

  //初始化省市信息
  _initRegionMap();
  // await enableFluttifyLog(false);
  // //设置ios的key
  // await AmapService.instance.init(
  //   iosKey: AppConfig.amapIOSKey,
  //   androidKey: AppConfig.amapAndroidKey,
  // );

  //初始化极光推送
  // JPush jpush = _initJPush();
  Application.jpush = _initJPush();

  MessageManager.chatGroupUserInformationMap = await GroupChatUserInformationDBHelper().queryAllMap();

  //FIXME 需要检测网络连接 确认有网后再进行以下操作 不然会报错卡住流程 没有网则需要跳转至初始无网络的引导页面
  // 用户信息先赋值个uid为-1的初始值
  Application.profile = ProfileDto.fromUserModel(UserModel());

  //从数据库获取已登录的用户token或匿名用户token
  TokenDto token = await TokenDBHelper().queryToken();
  bool isTokenValid = false;
  if (token == null ||
      (token.anonymous == 0 && (token.isPerfect == 0 || token.isPhone == 0)) ||
      DateTime.now().second + token.expiresIn > (token.createTime / 1000)) {
    //如果token是空的 或者token非匿名但未完善资料
    isTokenValid = false;
  } else {
    //通过一个小接口校验token是否可用（已过期或被清除时需要视为未登录，重新获取匿名token）
    //无论是否有效 先赋值 不然请求是不会带上token的
    Application.token = token;
    isTokenValid = await checkToken();
  }
  if (!isTokenValid) {
    Application.token = null;
    BaseResponseModel responseModel = await login("anonymous", null, null, null);
    if (responseModel != null && responseModel.code == 200) {
      TokenModel tokenModel = TokenModel.fromJson(responseModel.data);
      token = TokenDto.fromTokenModel(tokenModel);
      bool result = await TokenDBHelper().insertToken(token);
    } else {
      //FIXME 如果失败的情况下 流程无法走通 则需要一样跳转至初始无网络的引导页面
      return;
    }
  }
  print("token:${token.accessToken}");
  Application.token = token;

  //如果token不是匿名用户则需要从库里取出保存的用户信息 库里没有的话从接口中取
  ProfileDto profile;
  if (token.anonymous == 0) {
    profile = await ProfileDBHelper().queryProfile(token.uid);
    if (profile == null) {
      UserModel user = await getUserInfo();
      if (user != null) {
        profile = ProfileDto.fromUserModel(user);
        await ProfileDBHelper().insertProfile(profile);
        Application.profile = profile;
      } else {
        //没能成功取到用户信息时 则视为登录失效 删掉之前的token
        Application.token = null;
      }
    } else {
      Application.profile = profile;
    }
  } else {
    //匿名用户时 保持上面已赋值的默认初始值
  }
  //提前获取新版本信息
  getNewVersion().then((value) {
    if (value != null && AppConfig.version != value.version) {
      Application.versionModel = value;
      Application.haveNewVersion = true;
    }
  });
  // todo 获取背景图配置表
  try {
    Application.topicBackgroundConfig.clear();
    DataResponseModel dataResponseModel = await getBackgroundConfig();
    if (dataResponseModel != null && dataResponseModel.list != null) {
      dataResponseModel.list.forEach((v) {
        Application.topicBackgroundConfig.add(TopicBackgroundConfigModel.fromJson(v));
      });
    }
  } catch (e) {}
  //todo 获取视频课标签列表 其实在没有登录时无法获取
  Map<String, dynamic> videoCourseTagMap = await getAllTags();
  if (videoCourseTagMap != null) {
    Application.videoTagModel = VideoTagModel.fromJson(videoCourseTagMap);
  }

  //TODO ==========================下面是已登录用户获取的信息需要统一在用户登录后获取================================
  if (Application.token.anonymous == 0) {
    //上报极光推送RegistrationID
    Application.jpush.getRegistrationID().then((rid) {
      uploadDeviceId(rid);
    });
    //todo 获取登录的机器信息
    try {
      List<MachineModel> machineList = await getMachineStatusInfo();
      if (machineList != null && machineList.isNotEmpty) {
        Application.machine = machineList.first;
      }
    } catch (e) {}
    //todo 获取有哪些消息是置顶的消息
    try {
      MessageManager.topChatModelList.clear();
      Map<String, dynamic> topChatModelMap = await getTopChatList();
      if (topChatModelMap != null && topChatModelMap["list"] != null) {
        topChatModelMap["list"].forEach((v) {
          MessageManager.topChatModelList.add(TopChatModel.fromJson(v));
        });
      }
    } catch (e) {}
    //todo 获取有哪些消息是免打扰的消息
    try {
      MessageManager.queryNoPromptUidList.clear();
      Map<String, dynamic> queryNoPromptUidListMap = await queryNoPromptUidList();
      if (queryNoPromptUidListMap != null && queryNoPromptUidListMap["list"] != null) {
        queryNoPromptUidListMap["list"].forEach((v) {
          MessageManager.queryNoPromptUidList.add(NoPromptUidModel.fromJson(v));
        });
      }
    } catch (e) {}
  }
  // Note 服务端清除推荐池数据 启动app调用(服务端处理数据)
  await startApp();
}

//初始化地区数据
_initRegionMap() {
  RegionDBHelper().queryRegionList().then((regionList) {
    for (RegionDto region in regionList) {
      if (region.level == 1) {
        Application.provinceMap[region.id] = region;
      } else if (region.level == 2) {
        if (!Application.cityMap.containsKey(region.parentId)) {
          //如果map里没有该key 则需要向该key中放入一个空list
          Application.cityMap[region.parentId] = List<RegionDto>();
        }
        Application.cityMap[region.parentId].add(region);
      }
    }
  });
}

//初始化极光推送
_initJPush() {
  JPush jpush = JPush();
  jpush.addEventHandler(
    // 接收通知回调方法。
    onReceiveNotification: (Map<String, dynamic> message) async {
      print("main flutter onReceiveNotification1: $message");
      Map<String, dynamic> mapModel = json.decode(message["extras"]["cn.jpush.android.EXTRA"]);
      print("main flutter onReceiveNotification2: ${mapModel["redirectUri"]}");
      int notificationId = message["extras"]["cn.jpush.android.NOTIFICATION_ID"];
      //fixme 等待接通厂商通道后测试杀掉app会不会走这里
      if (!Application.isBackGround && CheckPhoneSystemUtil.init().isAndroid()) {
        jpush.clearNotification(notificationId: notificationId);
      }
      if (await CheckPhoneSystemUtil.init().isHuawei()) {
        //判断是不是华为手机
        BadgerUtil.init().setBadgeCount();
      }

      // if (message["alert"] != null && message["alert"].toString().contains("撤回了一条消息")) {
      //   return;
      // }
    },
    // 点击通知回调方法。
    onOpenNotification: (Map<String, dynamic> message) async {
      print("main flutter onOpenNotification1: $message");
      Map<String, dynamic> mapModel = json.decode(message["extras"]["cn.jpush.android.EXTRA"]);
      if (mapModel != null && mapModel["redirectUri"] != null) {
        JpushAnalyzeCodeUtil.init().analyzeCode(mapModel["redirectUri"]);
      } else {
        print("mapModel有问题:${message["extras"]["cn.jpush.android.EXTRA"]}");
      }
    },
    // 接收自定义消息回调方法。
    onReceiveMessage: (Map<String, dynamic> message) async {
      print("main flutter onReceiveMessage: $message");
    },
  );
  jpush.setup(
    appKey: "94357c150b038fa1183def8f",
    channel: AppConfig.channelCode,
    production: AppConfig.env != Env.DEV,
    debug: AppConfig.env == Env.DEV, // 设置是否打印 debug 日志
  );
  jpush.clearAllNotifications();
  return jpush;
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Connectivity connectivity = Connectivity();

  @override
  void initState() {
    //需要APP环境的初始化
    //设置友盟收集模式
    UmengCommonSdk.setPageCollectionModeAuto();
    //融云的状态管理者
    Application.rongCloud.initStatusManager(context);
    //融云的收信管理者
    Application.rongCloud.initReceiveManager(context);
    //设置一个全局的上下文
    Application.appContext = context;
    Application.connectivity = Connectivity();
    //全局音频播放器的回调
    context.read<VoiceSettingNotifier>().onPlayerCompletion();
    context.read<VoiceSettingNotifier>().onPlayerError();
    context.read<VoiceSettingNotifier>().onAudioPositionChanged();
    initAtMesGroupModel();
    //如果已登录
    if (context.read<TokenNotifier>().isLoggedIn) {
      // 读取会话数据库
      MessageManager.loadConversationListFromDatabase(context);
      // 连接融云
      Application.rongCloud.connect();
      // 友盟上报登录账号
      UmengCommonSdk.onProfileSignIn("${Application.profile.uid}");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Main_________________________________build");
    // fps检测器配置
    kFpsInfoMaxSize = 3600;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      overlayState = Application.navigatorKey.currentState.overlay;
    });
    return MaterialApp(
      // title: 'Flutter Demo',
      showPerformanceOverlay: AppConfig.checkLayoutRefresh,
      //使用了saveLayer的图形会显示为棋盘格式并随着页面刷新而闪烁
      checkerboardOffscreenLayers: AppConfig.checkLayoutRefresh,
      //做了缓存的静态图片在刷新页面时不会改变棋盘格的颜色；如果棋盘格颜色变了说明被重新缓存了，这是我们要避免的
      checkerboardRasterCacheImages: AppConfig.checkLayoutRefresh,
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        platform: TargetPlatform.iOS,
      ),
      navigatorKey: Application.navigatorKey,
      //通过统一方法处理页面跳转路由
      onGenerateRoute: Application.router.generator,
      /*
       本地化的代理类
      */
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate, // 指定本地化的字符串和一些其他的值
        GlobalCupertinoLocalizations.delegate, // 对应的Cupertino风格
        GlobalWidgetsLocalizations.delegate, // 指定默认的文本排列方向, 由左到右或由右到左
        /// 注册我们的Delegate
        FZLocalizationDelegate.delegate
      ],
      supportedLocales: [
        const Locale('zh', 'CN'),
        const Locale('en', 'US'),
      ],

      /// 监听系统语言切换
      localeListResolutionCallback: (deviceLocale, supportedLocales) {
        print('deviceLocale: $deviceLocale');
        // 系统语言是英语： deviceLocale: [en_CN, en_CN, zh_Hans_CN]
        // 系统语言是中文： deviceLocale: [zh_CN, zh_Hans_CN, en_CN]
        print('supportedLocales: $supportedLocales');
      },

      // fps检测器
      builder: (ctx, child) => CustomWidgetInspector(
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    print("❌APP dispose！！！❌");
    DBHelper.instance.closeDB();

    super.dispose();
  }
}
