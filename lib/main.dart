import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:provider/provider.dart';

import 'api/live_broadcast/live_api.dart';
import 'api/user_api.dart';
import 'config/application.dart';
import 'config/config.dart';
import 'config/shared_preferences.dart';
import 'data/dto/profile_dto.dart';
import 'data/dto/token_dto.dart';
import 'data/model/token_model.dart';
import 'data/notifier/token_notifier.dart';
import 'data/notifier/profile_notifier.dart';
import 'route/router.dart';

void main() {
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor:Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  _initApp().then((value) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TokenNotifier(Application.token)),
            ChangeNotifierProvider(create: (_) => ProfileNotifier(Application.profile)),
          ],
          child: MyApp(),
        ),
      ));
}

//初始化APP
Future _initApp() async {
  //要先执行该方法 不然插件无法加载调用
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  //初始化SharedPreferences
  AppPrefs.init();

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
  RongCloud().init();

  //创建各文件路径
  AppConfig.createAppDir();

  //获取相机信息
  try {
    Application.cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
    Application.cameras = [];
  }

  //获取视频课标签列表
  try {
    Map<String, dynamic> videoCourseTagMap = await getAllTags();
    Application.videoTagModel = VideoTagModel.fromJson(videoCourseTagMap);
  } catch (e) {}
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  MyAppState() {
    final router = FluroRouter();
    AppRouter.configureRouter(router);
    Application.router = router;
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
    );
  }
}
