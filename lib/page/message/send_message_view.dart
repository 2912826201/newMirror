import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/page/message/message_view/feed_msg.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

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
    Message msg = widget.model.msg;
    if (msg == null) {
      print(msg.toString() + "为空");
      return Container();
    }
    String msgType = msg.objectName;

    //todo 目前是使用的是 TextMessage 等以后有了自定义的 再改
    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // return TextMsg(((msg.content) as TextMessage).content, widget.model);

      Map<String, dynamic> model =
          json.decode(((msg.content) as TextMessage).content);
      if (model["type"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
        return TextMsg(model["content"], widget.model);
      } else if (model["type"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
        return FeedMsg(widget.model);
      }
    }
    return new Text('未知消息');
  }
}
