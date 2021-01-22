import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/region_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/train_several_times.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/vip/vip_nameplate_page.dart';
import 'package:mirror/widget/address_Picker.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import 'api/training/live_api.dart';
import 'api/message_page_api.dart';
import 'api/user_api.dart';
import 'config/application.dart';
import 'config/config.dart';
import 'config/shared_preferences.dart';
import 'data/dto/profile_dto.dart';
import 'data/dto/token_dto.dart';
import 'data/model/message/chat_enter_notifier.dart';
import 'data/model/message/chat_message_profile_notifier.dart';
import 'data/model/message/chat_voice_setting.dart';
import 'data/model/message/group_user_model.dart';
import 'data/model/message/no_prompt_uid_model.dart';
import 'data/model/message/top_chat_model.dart';
import 'data/model/message/voice_alert_date_model.dart';
import 'data/model/token_model.dart';
import 'data/notifier/token_notifier.dart';
import 'data/notifier/profile_notifier.dart';
import 'im/message_manager.dart';
import 'route/router.dart';

void main() {
  SystemUiOverlayStyle systemUiOverlayStyle =
  SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  _initApp().then((value) => runApp(
    MultiProvider(
      providers: [
            ChangeNotifierProvider(
                create: (_) => TokenNotifier(Application.token)),
            ChangeNotifierProvider(create: (_) => ProfileNotifier(Application.profile)),
          // ValueListenableProvider<FeedMapNotifier>(builder: (_) => {},)
            ChangeNotifierProvider(create: (_) => FeedMapNotifier(feedMap: {})),
            ChangeNotifierProvider(create: (_) => RongCloudStatusNotifier()),
            ChangeNotifierProvider(create: (_) => ConversationNotifier()),
            ChangeNotifierProvider(create: (_) => VoiceAlertData()),
            ChangeNotifierProvider(create: (_) => VoiceSettingNotifier()),
            ChangeNotifierProvider(create: (_) => ChatMessageProfileNotifier()),
            ChangeNotifierProvider(create: (_) => ChatEnterNotifier()),
            ChangeNotifierProvider(create: (_) => AddressPickerNotifier()),
            ChangeNotifierProvider(create: (_) => FitnessInformationNotifier()),
            ChangeNotifierProvider(create: (_) => ProfilePageNotifier()),
        ChangeNotifierProvider(create: (_) => GroupUserProfileNotifier()),
        ChangeNotifierProvider(create: (_) => UnReadMessageNotifier()),
        ChangeNotifierProvider(create: (_)=>VipMoveNotifier()),
        ChangeNotifierProvider(create: (_)=>AppDialogNotifier()),
      ],
      child: MyApp(),
    ),
  ));
}

//初始化APP
Future _initApp() async {
  // 升级flutter版本1.10.2后，因为在main()方法中有异步操作，对一些插件做了初始化操作。
  //要先执行该方法 不然插件无法加载调用
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

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
  Application.platform = Platform.isAndroid
      ? 0
      : Platform.isIOS
          ? 1
          : -1;

  //初始化SharedPreferences
  AppPrefs.init();

  //初始化数据库
  await DBHelper.instance.initDB();

  //从数据库获取已登录的用户token或匿名用户token
  TokenDto token = await TokenDBHelper().queryToken();
  if (token == null ||
      (token.anonymous == 0 && (token.isPerfect == 0 || token.isPhone == 0)) ||
      DateTime.now().second + token.expiresIn > (token.createTime / 1000)) {
    //如果token是空的 或者token非匿名但未完善资料 或者已过期 那么需要先去取一个匿名token
    TokenModel tokenModel = await login("anonymous", null, null, null);
    if (tokenModel != null) {
      token = TokenDto.fromTokenModel(tokenModel);
      bool result = await TokenDBHelper().insertToken(token);
    } else {
      //TODO 如果失败的情况下 需要重试 也可以让流程先走下去 在下次网络请求时重试
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
      profile = ProfileDto.fromUserModel(user);
      await ProfileDBHelper().insertProfile(profile);
    }
  } else {
    //匿名用户时 给个uid为0的其他信息为空的用户
    profile = ProfileDto.fromUserModel(UserModel());
  }
  Application.profile = profile;

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

  _initRegionMap();

  //todo 获取视频课标签列表 其实在没有登录时无法获取
  try {
    Map<String, dynamic> videoCourseTagMap = await getAllTags();
    Application.videoTagModel = VideoTagModel.fromJson(videoCourseTagMap);
  } catch (e) {}

  //todo 获取有哪些消息是置顶的消息
  try {
    Application.topChatModelList.clear();
    Map<String, dynamic> topChatModelMap = await getTopChatList();
    if (topChatModelMap != null && topChatModelMap["list"] != null) {
      topChatModelMap["list"].forEach((v) {
        Application.topChatModelList.add(TopChatModel.fromJson(v));
      });
    }
  } catch (e) {}
  //todo 获取有哪些消息是免打扰的消息
  try {
    Application.queryNoPromptUidList.clear();
    Map<String, dynamic> queryNoPromptUidListMap = await queryNoPromptUidList();
    if (queryNoPromptUidListMap != null && queryNoPromptUidListMap["list"] != null) {
      queryNoPromptUidListMap["list"].forEach((v) {
        Application.queryNoPromptUidList.add(NoPromptUidModel.fromJson(v));
      });
    }
  } catch (e) {}

  //全局的音频播放器
  Application.audioPlayer = new AudioPlayer();
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

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    //需要APP环境的初始化
    //融云的状态管理者
    Application.rongCloud.initStatusManager(context);
    //融云的收信管理者
    Application.rongCloud.initReceiveManager(context);
    //设置一个全局的上下文
    Application.appContext = context;
    //全局音频播放器的回调
    context.read<VoiceSettingNotifier>().onPlayerCompletion();
    context.read<VoiceSettingNotifier>().onPlayerError();
    context.read<VoiceSettingNotifier>().onAudioPositionChanged();
    initAtMesGroupModel();
    //如果已登录
    if (context
        .read<TokenNotifier>()
        .isLoggedIn) {
      // 读取会话数据库
      MessageManager.loadConversationListFromDatabase(context);
      // 连接融云
      Application.rongCloud.connect();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //通过统一方法处理页面跳转路由
      onGenerateRoute: Application.router.generator,
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   const Locale('zh','CH'),
      //   const Locale('en', 'US'),
      // ],
    );
  }

  @override
  void dispose() {
    print("❌APP dispose！！！❌");
    DBHelper.instance.closeDB();

    super.dispose();
  }
}
