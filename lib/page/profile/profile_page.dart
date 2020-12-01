import 'package:flutter/material.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
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
            //先取个匿名token
            TokenModel tokenModel = await login("anonymous", null, null, null);
            if (tokenModel != null) {
              TokenDto tokenDto = TokenDto.fromTokenModel(tokenModel);
              bool result = await logout();
              //TODO 这里先不处理登出接口的结果
              await TokenDBHelper().insertToken(tokenDto);
              context.read<TokenNotifier>().setToken(tokenDto);
              await ProfileDBHelper().clearProfile();
              context.read<ProfileNotifier>().setProfile(ProfileDto.fromUserModel(UserModel()));
            } else {
              //失败的情况下 登出将无token可用 所以不能继续登出
            }
          },
        ),
      ]),
    );
  }
}
