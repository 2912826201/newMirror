import 'package:flutter/material.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:provider/provider.dart';

import 'package:mirror/route/router.dart';

class LoginTestPage extends StatefulWidget {
  @override
  _LoginTestState createState() => _LoginTestState();
}

class _LoginTestState extends State<LoginTestPage> {
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    isLogin = context.read<TokenNotifier>().isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    print("登录测试页");
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "登录测试页",
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Consumer<TokenNotifier>(
            builder: (context, notifier, child) {
              if (isLogin == false && notifier.isLoggedIn == true) {
                print("执行用户完成登录后的操作");
              }
              isLogin = notifier.isLoggedIn;
              return child;
            },
            child: Container(),
          ),
          FlatButton(
            child: Text("去登录"),
            onPressed: () {
              AppRouter.navigateToLoginPage(context);
            },
          ),
          Text(context.select((TokenNotifier notifier) => notifier.isLoggedIn ? "已登录" : "未登录")),
          Text(context.watch<ProfileNotifier>().profile.toMap().toString()),
          FlatButton(
            child: Text("登出"),
            onPressed: () async {
              await Application.appLogout();
            },
          ),
        ]),
      ),
    );
  }
}
