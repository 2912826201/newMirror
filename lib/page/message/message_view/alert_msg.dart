import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'currency_msg.dart';

// ignore: must_be_immutable
class AlertMsg extends StatelessWidget {
  final RecallNotificationMessage recallNotificationMessage;
  final int position;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Map<String, dynamic> map;
  final String chatUserName;
  final String sendChatUserId;
  final bool isShowChatUserName;

  AlertMsg({
    this.recallNotificationMessage,
    this.position,
    this.isShowChatUserName = false,
    this.sendChatUserId,
    this.voidMessageClickCallBack,
    this.voidItemLongClickCallBack,
    this.map,
    this.chatUserName,
  });

  bool isMyself;

  @override
  Widget build(BuildContext context) {
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: getAlertText(),
    );
  }

//获取提示消息
  Widget getAlertText() {
    if (recallNotificationMessage != null) {
      //获取撤回消息
      return getRecallNotificationMessageBox();
    } else if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME) {
      return getTimeAlertUi();
    } else if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT) {
      return alertText(map["data"]);
    }
    return Container();
  }

  //获取撤回消息
  Widget alertText(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: AppColor.textSecondary),
      ),
    );
  }

  //获取消息提示
  Widget getTimeAlertUi() {
    try {
      return Container(
        child: Text(
          DateUtil.formatMessageAlertTime(map["data"]),
          style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  //获取撤回消息
  Widget getRecallNotificationMessageBox() {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
        children: getRecallNotificationMessage(),
      ),
    );
  }

  //获取撤回消息
  List<TextSpan> getRecallNotificationMessage() {
    isMyself = recallNotificationMessage.mOperatorId ==
        Application.profile.uid.toString();
    List<TextSpan> listTextSpan = <TextSpan>[];
    if (isMyself) {
      TextSpan textSpan1 = TextSpan(
        text: "你撤回了一条消息  ",
      );
      listTextSpan.add(textSpan1);
      // print("recallNotificationMessage.mOriginalObjectName:${recallNotificationMessage.mOriginalObjectName}-----TextMessage.objectName:${TextMessage.objectName}");
      try {
        if (json.decode(recallNotificationMessage.recallContent)["subObjectName"] == TextMessage.objectName) {
          listTextSpan.add(getTextSpan());
        }
      } catch (e) {
        if (recallNotificationMessage.mOriginalObjectName == TextMessage.objectName) {
          listTextSpan.add(getTextSpan());
        }
      }
    } else {
      TextSpan textSpan1 = TextSpan(
        text: "“$chatUserName”撤回了一条消息",
      );
      listTextSpan.add(textSpan1);
    }
    return listTextSpan;
  }

  //获取重新编辑的text
  TextSpan getTextSpan() {
    return TextSpan(
      text: "重新编辑",
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          Map<String, dynamic> map = Map();
          map["type"] = recallNotificationMessage.mOriginalObjectName;
          map["content"] = recallNotificationMessage.recallContent;
          voidMessageClickCallBack(
              contentType: RecallNotificationMessage.objectName, map: map, position: position);
        },
      style: TextStyle(
        color: AppColor.urlText,
      ),
    );
  }
}
