/// router
/// Created by yangjiayi on 2020/10/26.

import 'package:flutter/material.dart';
import 'package:mirror/page/test_page.dart';

import 'main.dart';

class AppRouter {
  // 主页面路由分发处理
  static Route<dynamic> dispatchRoute(RouteSettings settings) {
    //通过路由的名称来处理跳转页面
    String routeName = settings.name;
    //TODO 获取是否登录 暂时写为true
    bool hasAuth = true;

    //TODO 暂时逻辑写为都需要登录
    if (!hasAuth) {
      return MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Error"),
          ),
          body: Center(
            child: Text("Need login"),
          ),
        );
      });
    } else {
      switch (routeName) {
        case PageName.HOME:
          return MaterialPageRoute(builder: (context) {
            return MyHomePage(
              title: 'Flutter Demo Home Page',
            );
          });
        case PageName.LOGIN:
        case PageName.TEST:
          return MaterialPageRoute(builder: (context) {
            return TestPage();
          });
        default:
          return MaterialPageRoute(builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Error"),
              ),
              body: Center(
                child: Text("Page not found"),
              ),
            );
          });
      }
    }
  }

  static void goToTestPage(BuildContext context) {
    Navigator.pushNamed(context, "test");
  }
}

class PageName {
  static const String HOME = "home";
  static const String LOGIN = "login";
  static const String TEST = "test";
}
