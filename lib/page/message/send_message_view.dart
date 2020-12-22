import 'dart:io' as send_message_view;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';

import 'message_view/text_msg.dart';

class SendMessageView extends StatefulWidget {
  final ChatDataModel model;

  SendMessageView(this.model);

  @override
  _SendMessageViewState createState() => _SendMessageViewState();
}

class _SendMessageViewState extends State<SendMessageView> {
  @override
  Widget build(BuildContext context) {
    Map msg = widget.model.msg;
    if (msg == null) {
      print(msg.toString() + "为空");
      return Container();
    }

    String msgType = msg["type"];
    String msgStr = msg.toString();

    // bool isIos = send_message_view.Platform.isIOS;
    // bool iosText = isIos && msgStr.contains('text:');
    // bool iosImg = isIos && msgStr.contains('imageList:');
    // var iosS = msgStr.contains('downloadFlag:') && msgStr.contains('second:');
    // bool iosSound = isIos && iosS;

    if (msgType == ChatTypeModel.COMMENT_TEXT) {
      return TextMsg(msg['text'], widget.model);
    } else if (msgType == "Image") {
      // return new ImgMsg(msg, widget.model);
    } else if (msgType == 'Sound') {
      // return new SoundMsg(widget.model);
//    } else if (msg.toString().contains('snapshotPath') &&
//        msg.toString().contains('videoPath')) {
//      return VideoMessage(msg, msgType, widget.data);
    } else if (msg['tipsType'] == 'Join') {
      // return JoinMessage(msg);
    } else if (msg['tipsType'] == 'Quit') {
      // return QuitMessage(msg);
    } else if (msg['groupInfoList'][0]['type'] == 'ModifyIntroduction') {
      // return ModifyNotificationMessage(msg);
    } else if (msg['groupInfoList'][0]['type'] == 'ModifyName') {
      // return ModifyGroupInfoMessage(msg);
    } else {
      return new Text('未知消息');
    }
  }
}
