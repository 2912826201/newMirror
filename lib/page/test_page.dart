import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/database/user_db_helper.dart';
import 'package:mirror/data/dto/user_dto.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/user_notifier.dart';
import 'package:mirror/page/media_picker_page.dart';
import 'package:provider/provider.dart';

/// test_page
/// Created by yangjiayi on 2020/10/27.

class TestPage extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      appBar: AppBar(
        title: Text("测试页"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("测试用页面，可随意添加组件"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("images/test.png"),
                    color: Colors.redAccent,
                    colorBlendMode: BlendMode.darken,
                    width: 100.0,
                    height: 100.0,
                  ),
                  Image(
                    image: NetworkImage("http://i2.hdslb.com/bfs/face/c2d82a7e6512a85657e997dc8f84ab538e87a8cc.jpg"),
                    width: 100.0,
                    height: 100.0,
                  ),
                ],
              ),
              //watch会监听全部数据
              Text("用户ID：${context.watch<UserNotifier>().user.uid}"),
              Text("用户名：${context.watch<UserNotifier>().user.userName}"),
              Text("用户头像地址：${context.watch<UserNotifier>().user.avatarUri}"),
              //select只监听想要的数据 当其他数据发生变化时不会触发更新
              Text("用户ID：${context.select((UserNotifier value) => value.user.uid)}"),
              Text("用户名：${context.select((UserNotifier value) => value.user.userName)}"),
              Text("用户头像地址：${context.select((UserNotifier value) => value.user.avatarUri)}"),
              //用consumer的方式监听数据
              Consumer<UserNotifier>(
                builder: (context, notifier, child) {
                  return Column(
                    children: [
                      Text("用户ID：${notifier.user.uid}"),
                      Text("用户名：${notifier.user.userName}"),
                      Text("用户头像地址：${notifier.user.avatarUri}"),
                    ],
                  );
                },
              ),
              //用Selector的方式监听数据
              Selector<UserNotifier, int>(builder: (context, uid, child) {
                return Text("用户ID：${uid}");
              }, selector: (context, notifier) {
                return notifier.user.uid;
              }),
              Selector<UserNotifier, String>(builder: (context, userName, child) {
                return Text("用户名：${userName}");
              }, selector: (context, notifier) {
                return notifier.user.userName;
              }),
              Selector<UserNotifier, String>(builder: (context, avatarUri, child) {
                return Text("用户头像地址：${avatarUri}");
              }, selector: (context, notifier) {
                return notifier.user.avatarUri;
              }),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () => _changeUser(context),
                    child: Text("换个用户"),
                  );
                },
              ),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () => _changeUserName(context),
                    child: Text("换个用户名"),
                  );
                },
              ),
              RaisedButton(
                onPressed: () {
                  UserDBHelper().insertUser(UserDto.fromModel(context.read<UserNotifier>().user));
                },
                child: Text("写入数据库"),
              ),
              RaisedButton(
                onPressed: () async {
                  UserDto dto = await UserDBHelper().queryUser();
                  UserModel model = dto.toModel();
                  print(model.uid.toString() + "," + model.userName + "," + model.avatarUri);
                },
                child: Text("查询数据库"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MediaPickerPage();
                  }));
                },
                child: Text("选图片视频"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _changeUser(BuildContext context) {
  int randomNum = Random().nextInt(10000);
  WordPair pair = WordPair.random();
  String userName = pair.first;
  String avatarUri = "http://www.abc.com/${pair.second}.png";
  UserModel user = context.read<UserNotifier>().user;
  user.uid = randomNum;
  user.userName = userName;
  user.avatarUri = avatarUri;
  context.read<UserNotifier>().setUser(user);
}

void _changeUserName(BuildContext context) {
  context.read<UserNotifier>().setUserName(WordPair.random().first);
}
