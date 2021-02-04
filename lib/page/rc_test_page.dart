

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirror/api/rongcloud_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

/// rc_test_page
/// Created by yangjiayi on 2020/11/2.

//融云的测试页
class RCTestPage extends StatefulWidget {
  @override
  RCTestState createState() => RCTestState();
}

class RCTestState extends State<RCTestPage> {
  String _token = "";
  String _status = "未连接";
  TextEditingController controller = TextEditingController();
  TextField inputText ;
  @override
  void initState() {
    super.initState();
    _token = "";
    controller.addListener(() {

    });
    inputText = TextField(controller: controller,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "融云测试",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Token：${_token}"),
            RaisedButton(
              onPressed: () async {
                String token = await requestRongCloudToken();
                if (token != null) {
                  setState(() {
                    _token = token;
                  });
                }
              },
              child: Text("获取token"),
            ),
            RaisedButton(
              onPressed: _connectRC,
              child: Text("连接"),
            ),
            RaisedButton(
              onPressed: _disconnectRC,
              child: Text("断开连接"),
            ),
            Text("${_status}"),
            Text("状态码：${context.watch<RongCloudStatusNotifier>().status}"),
            Container(
              child: inputText,
              width: 100,
              height: 20,
            ),
            FlatButton(onPressed:  () async {
                TextMessage msg = TextMessage();
                UserInfo userInfo = UserInfo();
                userInfo.userId = Application.profile.uid.toString();
                userInfo.name = Application.profile.nickName;
                userInfo.portraitUri = Application.profile.avatarUri;
                msg.sendUserInfo = userInfo;
                msg.content = "测试消息${Random().nextInt(10000)}";
                Message message = await Application.rongCloud.sendPrivateMessage(controller.text, msg);
                print(message.toString());
             }, child: Text("发送消息"),minWidth: 100,height: 20,),
            RaisedButton(
              onPressed: _clearConversations,
              child: Text("清除所有会话数据"),
            ),
          ],
        ),
      ),
    );
  }
  void _connectRC() {
    print("开始连接");
    Application.rongCloud.doConnect(_token, (int code, String userId) {
      print('connect result ' + code.toString());
      if (code == 0) {
        print("connect success userId" + userId);
        // 连接成功后打开数据库
        // _initUserInfoCache();
        setState(() {
          _status = "连接成功，userId为" + userId;
        });
      } else if(code == 34001) {
        // 已经连接上了
      } else if (code == 31004) {
        // token 非法，需要重新从 APP 服务获取新 token 并连接
        setState(() {
          _status = "连接失败";
        });
      }
    });
  }
  void _disconnectRC() {
    Application.rongCloud.disconnect();
    setState(() {
      _status = "已断开连接";
    });
  }

  void _clearConversations() async{
    await ConversationDBHelper().clearConversation(Application.profile.uid);
    MessageManager.clearUserMessage(context);
  }
}
