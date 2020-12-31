import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

class GroupMorePage extends StatefulWidget {
  ///对话用户id
  final String chatUserId;

  ///这个是什么类型的对话--中文
  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  final int chatType;

  GroupMorePage({this.chatUserId, this.chatType});

  @override
  createState() => GroupMorePageState();
}

class GroupMorePageState extends State<GroupMorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("群聊消息"),
      ),
      body: Text("13232"),
    );
  }
}
