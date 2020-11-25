import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:provider/provider.dart';

import 'package:mirror/route/router.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("我的页");
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        FlatButton(
          child: Text("我的页"),
          onPressed: () {
            AppRouter.navigateToLoginPage(context);
          },
        ),
        Text(context.select((TokenNotifier notifier) => notifier.isLoggedIn ? "已登录" : "未登录")),
        FlatButton(
          child: Text("token变匿名/真实用户"),
          onPressed: () {
            TokenDto token = Application.token;
            token.anonymous = (token.anonymous + 1) % 2;
            context.read<TokenNotifier>().setToken(token);
          },
        ),
        FlatButton(
          child: Text("token绑定手机/解绑手机"),
          onPressed: () {
            TokenDto token = Application.token;
            if (token.isPhone == null) {
              token.isPhone = 0;
            }
            token.isPhone = (token.isPhone + 1) % 2;
            context.read<TokenNotifier>().setToken(token);
          },
        ),
        FlatButton(
          child: Text("token完善资料/清空资料"),
          onPressed: () {
            TokenDto token = Application.token;
            if (token.isPerfect == null) {
              token.isPerfect = 0;
            }
            token.isPerfect = (token.isPerfect + 1) % 2;
            context.read<TokenNotifier>().setToken(token);
          },
        ),
      ]),
    );
  }
}
