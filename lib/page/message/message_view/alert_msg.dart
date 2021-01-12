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
  List<String> textArray = [];
  List<bool> isChangColorArray = [];
  List<Color> colorArray = [];

  @override
  Widget build(BuildContext context) {
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.0),
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: getAlertText(),
    );
  }

//获取提示消息
  Widget getAlertText() {
    textArray.clear();
    isChangColorArray.clear();
    colorArray.clear();

    if (recallNotificationMessage != null) {
      colorArray.add(AppColor.textSecondary);
      colorArray.add(AppColor.mainBlue);

      //撤回消息
      isMyself = recallNotificationMessage.mOperatorId == Application.profile.uid.toString();
      if (isMyself) {
        textArray.add("你撤回了一条消息 ");
        isChangColorArray.add(false);
        try {
          if (json.decode(recallNotificationMessage.recallContent)["subObjectName"] == TextMessage.objectName) {
            textArray.add("重新编辑");
            isChangColorArray.add(true);
          }
        } catch (e) {
          if (recallNotificationMessage.mOriginalObjectName == TextMessage.objectName) {
            textArray.add("重新编辑");
            isChangColorArray.add(true);
          }
        }
      } else {
        textArray.add("“$chatUserName”撤回了一条消息");
        isChangColorArray.add(false);
      }
    } else if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME) {
      //时间提示
      colorArray.add(AppColor.textSecondary);
      colorArray.add(AppColor.textSecondary);

      textArray.add(DateUtil.formatMessageAlertTime(map["data"]));
      isChangColorArray.add(false);
    } else if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT) {
      //文字提示

      colorArray.add(AppColor.textSecondary);
      colorArray.add(AppColor.textSecondary);

      textArray.add(map["data"]);
      isChangColorArray.add(false);
    } else if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP) {
      //群通知
      Map<String, dynamic> mapGroupModel = json.decode(map["data"]["data"]);
      print("mapGroupModel:${map["data"].toString()}");
      getGroupText(mapGroupModel);
    }

    if (textArray.length > 0) {
      return alertText();
    } else {
      return Container();
    }
  }

  //判断是加入群聊还是退出群聊
  void getGroupText(Map<String, dynamic> mapGroupModel) {
    colorArray.add(AppColor.textSecondary);
    colorArray.add(AppColor.textPrimary1);

    int userCount = 0;

    List<dynamic> users = mapGroupModel["users"];
    if (users == null || users.length < 1) {
      textArray.clear();
      isChangColorArray.clear();
      colorArray.clear();
      return;
    }

    bool isAdd = mapGroupModel["subType"] == 0;
    if (isAdd && Application.chatGroupUserModelList.length > 0) {
      if (Application.chatGroupUserModelList[0].uid == Application.profile.uid) {
        textArray.add("你邀请了");
        isChangColorArray.add(false);
      } else {
        textArray.add(Application.chatGroupUserModelList[0].nickName + "邀请了");
        isChangColorArray.add(true);
        userCount++;
      }
    }

    if (Application.chatGroupUserModelList.length > 0) {
      for (dynamic d in users) {
        print("dynamicdynamic" + d.toString());
        String name = Application.chatGroupUserModelMap[d.toString()];
        if (name != null) {
          userCount++;
          textArray.add("$name${userCount >= 3 ? "等" : "、"}");
          isChangColorArray.add(true);
        }
        if (userCount >= 3) {
          break;
        }
      }
    }
    if (textArray.length > 0) {
      textArray[textArray.length - 1] = textArray[textArray.length - 1].trim().replaceAll("、", "");
    }

    if (isAdd) {
      textArray.add("加入群聊");
    } else {
      textArray.add("退出群聊");
    }
    isChangColorArray.add(false);
  }


  //获取消息
  Widget alertText() {
    return Container(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
          children: getMessage(),
        ),
      ),
    );
  }

  //获取所有的textspan
  List<TextSpan> getMessage() {
    List<TextSpan> listTextSpan = <TextSpan>[];
    for (int i = 0; i < textArray.length; i++) {
      listTextSpan.add(getTextSpan(textArray[i], isChangColorArray[i]));
    }
    return listTextSpan;
  }

  //获取重新编辑的text
  TextSpan getTextSpan(String text, bool isChangeColor) {
    return TextSpan(
      text: text,
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          if (text == "重新编辑") {
            Map<String, dynamic> map = Map();
            map["type"] = recallNotificationMessage.mOriginalObjectName;
            map["content"] = recallNotificationMessage.recallContent;
            voidMessageClickCallBack(
                contentType: RecallNotificationMessage.objectName, map: map, position: position);
          }
        },
      style: TextStyle(
          color: isChangeColor ? colorArray[1] : colorArray[0],
          fontSize: 14
      ),
    );
  }
}
