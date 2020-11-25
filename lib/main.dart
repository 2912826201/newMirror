import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:provider/provider.dart';

import 'config/application.dart';
import 'data/dto/token_dto.dart';
import 'data/model/token_model.dart';
import 'data/notifier/token_notifier.dart';
import 'data/notifier/user_notifier.dart';
import 'route/router.dart';

void main() {
  _initApp().then((value) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TokenNotifier(Application.token)),
            ChangeNotifierProvider(create: (_) => UserNotifier()),
          ],
          child: MyApp(),
        ),
      ));
}

//初始化APP
Future _initApp() async {
  //要先执行该方法 不然插件无法加载调用
  WidgetsFlutterBinding.ensureInitialized();

  //从数据库获取已登录的用户token或匿名用户token
  TokenDto token = await TokenDBHelper().queryToken();
  if (token == null) {
    //如果token是空的 那么需要先去取一个匿名token
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

  //TODO 如果token不是匿名用户则需要从库里取出保存的用户信息 库里没有的话从接口中取

  //初始化融云IM
  RongCloud().init();
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
