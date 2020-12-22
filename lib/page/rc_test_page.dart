

import 'package:flutter/material.dart';
import 'package:mirror/api/rongcloud_api.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// rc_test_page
/// Created by yangjiayi on 2020/11/2.

//融云的测试页
String USERID;
class RCTestPage extends StatefulWidget {
  @override
  RCTestState createState() => RCTestState();
}

class RCTestState extends State<RCTestPage> {
  String _token = "";
  String _status = "未连接";
  TextEditingController controller = TextEditingController();
  TextEditingController controller1 = TextEditingController();
  TextField inputText;

  TextField inputText1;

  @override
  void initState() {
    super.initState();
    //TODO 测试数据 暂时写死 需要从接口获取
    _token = "";
    controller.addListener(() {});
    inputText = TextField(
      controller: controller,
    );
    inputText1 = TextField(
      controller: controller1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("融云测试"),
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
            Container(
              child: inputText,
              width: 100,
              height: 20,
            ),
            Container(
              child: inputText1,
              width: 100,
              height: 20,
            ),
            FlatButton(onPressed: () async {
              TextMessage msg = TextMessage();
              msg.content = controller1.text;
              USERID = controller.text;
              Message message = await RongCloudReceiveManager.shareInstance()
                  .sendPrivateMessage(USERID, msg);
              print("=====发送给：${USERID}---消息是：${message.toString()}");
            }, child: Text("发送消息"), minWidth: 100, height: 20,)
          ],
        ),
      ),
    );
  }

  void _connectRC() {
    print("开始连接");
    RongCloud().connect(_token, (int code, String userId) {
      print('connect result ' + code.toString());
      if (code == 0) {
        // if (userId == "1001531")
        //   {
        //     USERID =  "1021057";
        //   }else{
        //
        // };
        print("connect success userId" + userId);
        // 连接成功后打开数据库
        // _initUserInfoCache();
        setState(() {
          _status = "连接成功，userId为" + userId;
        });
      } else if (code == 31004) {
        // token 非法，需要重新从 APP 服务获取新 token 并连接
        setState(() {
          _status = "连接失败";
        });
      }
    });
  }

  void _disconnectRC() {
    RongCloud().disconnect();
    setState(() {
      _status = "已断开连接";
    });
  }
}
