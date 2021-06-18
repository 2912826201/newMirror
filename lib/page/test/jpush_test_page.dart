import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class JpushTestPage extends StatefulWidget {
  @override
  _JpushTestPageState createState() => _JpushTestPageState();
}

class _JpushTestPageState extends State<JpushTestPage> {
  String debugLable = 'Unknown';
  final JPush jpush = new JPush();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

// 编写视图
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('Plugin example app'),
      ),
      body: new Center(
          child: new Column(children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          color: Colors.brown,
          child: SingleChildScrollView(
            child: Text(debugLable ?? "Unknown"),
          ),
          width: 350,
          height: 100,
        ),
        new CustomButton(
            title: "发本地推送",
            onPressed: () {
              // 三秒后出发本地推送
              var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3000);
              var localNotification = LocalNotification(
                  id: 234,
                  title: 'fadsfa',
                  buildId: 1,
                  content: 'fdas',
                  fireTime: fireDate,
                  subtitle: 'fasf',
                  badge: 5,
                  extra: {"fa": "0"});
              jpush.sendLocalNotification(localNotification).then((res) {
                setState(() {
                  debugLable = res;
                });
              });
            }),
      ])),
    );
  }
}

/// 封装控件
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const CustomButton({@required this.onPressed, @required this.title});

  @override
  Widget build(BuildContext context) {
    return new TextButton(
      onPressed: onPressed,
      child: new Text("$title"),
      style: new ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Color(0xff888888)),
        backgroundColor: MaterialStateProperty.all(Color(0xff585858)),
        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(10, 5, 10, 5)),
      ),
    );
  }
}
