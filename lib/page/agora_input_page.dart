import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/agora_test_page.dart';
import 'package:mirror/widget/custom_appbar.dart';

/// agora_input_page
/// Created by yangjiayi on 2020/11/30.

class AgoraInputPage extends StatefulWidget {
  @override
  _AgoraInputState createState() => _AgoraInputState();
}

class _AgoraInputState extends State<AgoraInputPage> {
  TextEditingController _tokenController = TextEditingController();
  TextEditingController _channelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "输入token及频道号",
          style: AppStyle.textMedium18,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("token"),
            TextField(
              controller: _tokenController,
            ),
            Text("频道"),
            TextField(
              controller: _channelController,
            ),
            FlatButton(
                onPressed: () {
                  String token = _tokenController.text;
                  String channel = _channelController.text;
                  int uid = Random().nextInt(10000);
                  if (token.trim().isNotEmpty && channel.trim().isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AgoraTestPage(token, channel, uid);
                    }));
                  }
                },
                child: Text("进入直播间"))
          ],
        ),
      ),
    );
  }
}
