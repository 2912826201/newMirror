import 'package:flutter/material.dart';
import 'package:mirror/im/rongcloud.dart';

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

  @override
  void initState() {
    super.initState();
    //TODO 测试数据 暂时写死 需要从接口获取
    _token = "LMPunFEPWuljAp+x9rzoylrhQgi6NdICS9L2Q89okn0=@n37a.cn.rongnav.com;n37a.cn.rongcfg.com";
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
              onPressed: _connectRC,
              child: Text("连接"),
            ),
            RaisedButton(
              onPressed: _disconnectRC,
              child: Text("断开连接"),
            ),
            Text("${_status}"),
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
