import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

import 'currency_msg.dart';


class AlertMsg extends StatefulWidget {
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

  @override
  _AlertMsgState createState() => _AlertMsgState();
}

class _AlertMsgState extends State<AlertMsg> {
  bool isMyself;
  List<String> textArray = [];
  List<bool> isChangColorArray = [];
  List<Color> colorArray = [];

  Timer timer;
  int timeCount=0;

  @override
  Widget build(BuildContext context) {
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Container(
        alignment: Alignment.bottomCenter,
        width: MediaQuery.of(context).size.width,
        child: getAlertText(context),
      ),
    );
  }

//获取提示消息
  Widget getAlertText(BuildContext context) {
    textArray.clear();
    isChangColorArray.clear();
    colorArray.clear();

    if (widget.recallNotificationMessage != null) {
      colorArray.add(AppColor.textSecondary);
      colorArray.add(AppColor.mainBlue);

      //撤回消息
      isMyself = widget.recallNotificationMessage.mOperatorId == Application.profile.uid.toString();
      if (isMyself) {
        textArray.add("你撤回了一条消息 ");
        isChangColorArray.add(false);
        if (new DateTime.now().millisecondsSinceEpoch - widget.recallNotificationMessage.recallActionTime < 5 * 60 * 1000) {
          print("开始判断时间1${new DateTime.now().millisecondsSinceEpoch - widget.recallNotificationMessage.recallActionTime}");
          try {
            if (json.decode(widget.recallNotificationMessage.recallContent)["subObjectName"] == TextMessage.objectName) {
              textArray.add("重新编辑");
              isChangColorArray.add(true);
              timer=Timer.periodic(Duration(seconds: 1), (timer) {
                timeCount++;
                if(timeCount>60){
                  timeCount=0;
                  timer.cancel();
                  timer=null;
                  if(mounted) {
                    setState(() {
                    });
                  }
                }
              });
            }
          } catch (e) {
            if (widget.recallNotificationMessage.mOriginalObjectName == TextMessage.objectName) {
              textArray.add("重新编辑");
              isChangColorArray.add(true);
            }
          }
        }
      } else {
        textArray.add("“${widget.chatUserName}”撤回了一条消息");
        isChangColorArray.add(false);
      }
    } else if (widget.map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME) {
      //时间提示
      colorArray.add(AppColor.textSecondary);
      colorArray.add(AppColor.textSecondary);

      textArray.add(DateUtil.formatMessageAlertTime(widget.map["data"]));
      isChangColorArray.add(false);
    } else if (widget.map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT) {
      //文字提示

      colorArray.add(AppColor.textSecondary);
      colorArray.add(AppColor.textSecondary);

      textArray.add(widget.map["data"]);
      isChangColorArray.add(false);
    } else if (widget.map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP) {
      //0--加入群聊
      //1--退出群聊
      //2--移除群聊
      //3--群主转移
      //4--群名改变
      //5--扫码加入群聊
      //群通知
      Map<String, dynamic> mapGroupModel = json.decode(widget.map["data"]["data"]);
      if (mapGroupModel["subType"] == 5) {
        getGroupEntryByQRCode(mapGroupModel, context);
      }else if (mapGroupModel["subType"] == 4) {
        updateGroupName(mapGroupModel, context);
      } else {
        if(context.watch<GroupUserProfileNotifier>().loadingStatus==LoadingStatus.STATUS_COMPLETED) {
          ChatGroupUserModel chatGroupUserModel = context.watch<GroupUserProfileNotifier>().chatGroupUserModelList[0];
          if (mapGroupModel["subType"] == 1 && chatGroupUserModel.uid!=Application.profile.uid) {
            textArray.clear();
          } else {
            if(mapGroupModel["subType"] == 0&&widget.map["data"]["name"]=="Entry"){
              textArray.clear();
            }else {
              getGroupText(mapGroupModel, context);
            }
          }
        }else{
          if (mapGroupModel["subType"] == 1) {
            textArray.clear();
          } else {
            if(mapGroupModel["subType"] == 0&&widget.map["data"]["name"]=="Entry"){
              textArray.clear();
            }else {
              getGroupText(mapGroupModel, context);
            }
          }
        }
      }
    }

    if (textArray.length > 0) {
      return alertText();
    } else {
      return Container();
    }
  }

  //修改群名
  void updateGroupName(Map<String, dynamic> mapGroupModel, BuildContext context){
    colorArray.add(AppColor.textSecondary);
    colorArray.add(AppColor.textPrimary1);

    if (mapGroupModel["operator"].toString() == Application.profile.uid.toString()) {
      textArray.add("你 ");
      isChangColorArray.add(true);
    } else {
      textArray.add(mapGroupModel["operatorName"].toString());
      isChangColorArray.add(true);
    }
    textArray.add("修改群名为 \"");
    isChangColorArray.add(false);
    textArray.add(mapGroupModel["groupChatName"].toString());
    isChangColorArray.add(true);
    textArray.add("\"");
    isChangColorArray.add(false);
  }


  //判断是加入群聊还是退出群聊
  void getGroupText(Map<String, dynamic> mapGroupModel, BuildContext context) {
    colorArray.add(AppColor.textSecondary);
    colorArray.add(AppColor.textPrimary1);

    int userCount = 0;

    bool isHaveUserSelf=false;

    List<dynamic> users = mapGroupModel["users"];
    if (users == null || users.length < 1) {
      textArray.clear();
      isChangColorArray.clear();
      colorArray.clear();
      return;
    }

    if (mapGroupModel["subType"] == 0) {
      //邀请
      if (mapGroupModel["operator"].toString() == Application.profile.uid.toString()) {
        textArray.add("你邀请了");
        isChangColorArray.add(false);
        isHaveUserSelf=true;
      } else {
        textArray.add(mapGroupModel["operatorName"].toString());
        isChangColorArray.add(true);
        textArray.add("邀请了");
        isChangColorArray.add(false);
        userCount++;
      }
    } else if (mapGroupModel["subType"] == 2) {
      //移除
      if (mapGroupModel["operator"].toString() == Application.profile.uid.toString()) {
        textArray.add("你将");
        isChangColorArray.add(false);
        isHaveUserSelf=true;
      } else {
        textArray.add(mapGroupModel["operatorName"].toString());
        isChangColorArray.add(true);
        textArray.add("将");
        isChangColorArray.add(false);
        userCount++;
      }
    }
    for (dynamic d in users) {
      userCount++;
      try {
        if (d != null) {
          if (d["uid"] == Application.profile.uid) {
            textArray.add("你${userCount > users.length ? " " : "、"}");
            isHaveUserSelf=true;
          } else {
            if (mapGroupModel["subType"] == 3) {
              textArray.add("${d["currentMasterName"]}${userCount > users.length ? " " : "、"}");
            } else {
              textArray.add("${d["groupNickName"]}${userCount > users.length ? " " : "、"}");
            }
          }
          isChangColorArray.add(true);
        }
      } catch (e) {
        break;
      }
      // if (userCount >= 3) {
      //   break;
      // }
    }
    if (textArray.length > 0) {
      textArray[textArray.length - 1] = textArray[textArray.length - 1].trim().replaceAll("、", "");
    }

    if (mapGroupModel["subType"] == 0) {
      textArray.add("加入群聊");
    } else if (mapGroupModel["subType"] == 1) {
      textArray.add("退出群聊");
      if(!isHaveUserSelf){
        if(context.watch<GroupUserProfileNotifier>().loadingStatus==LoadingStatus.STATUS_COMPLETED&&
            context.watch<GroupUserProfileNotifier>().chatGroupUserModelList!=null&&
            context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length>0) {
          ChatGroupUserModel chatGroupUserModel = context.watch<GroupUserProfileNotifier>().chatGroupUserModelList[0];
          if(chatGroupUserModel.uid!=Application.profile.uid){
            textArray.clear();
          }
        }else{
          textArray.clear();
        }
      }
    } else if (mapGroupModel["subType"] == 2) {
      textArray.add("移出了群聊");
      if(!isHaveUserSelf){
        if(context.watch<GroupUserProfileNotifier>().loadingStatus==LoadingStatus.STATUS_COMPLETED&&
            context.watch<GroupUserProfileNotifier>().chatGroupUserModelList!=null&&
            context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length>0) {
          ChatGroupUserModel chatGroupUserModel = context.watch<GroupUserProfileNotifier>().chatGroupUserModelList[0];
          if(chatGroupUserModel.uid!=Application.profile.uid){
            textArray.clear();
          }
        }else{
          textArray.clear();
        }
      }
    } else if (mapGroupModel["subType"] == 3) {
      textArray.add("已成为新群主");
    }
    isChangColorArray.add(false);
  }

  //扫码进入群聊
  void getGroupEntryByQRCode(Map<String, dynamic> mapGroupModel, BuildContext context) {
    colorArray.add(AppColor.textSecondary);
    colorArray.add(AppColor.textPrimary1);

    List<dynamic> users = mapGroupModel["users"];
    if (users == null || users.length < 1) {
      textArray.clear();
      isChangColorArray.clear();
      colorArray.clear();
      return;
    }

    bool isMe=false;
    String name="";
    for (dynamic d in users) {
      if (d != null) {
        if (d["uid"] == Application.profile.uid) {
          isMe=true;
          break;
        } else {
          name=d["groupNickName"];
        }
      }
    }
    if(isMe){
      textArray.add("你通过二维码扫描加入群聊");
      isChangColorArray.add(false);
    }else{
      textArray.add(name);
      isChangColorArray.add(true);
      textArray.add(" 通过扫描 ");
      isChangColorArray.add(false);
      if (mapGroupModel["operator"] == Application.profile.uid) {
        textArray.add("你");
      } else {
        textArray.add(mapGroupModel["operatorName"]);
      }
      isChangColorArray.add(true);
      textArray.add(" 分享的二维码加入群聊 ");
      isChangColorArray.add(false);
    }
  }


  //获取消息
  Widget alertText() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      color: AppColor.transparent,
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
            map["type"] = widget.recallNotificationMessage.mOriginalObjectName;
            map["content"] = widget.recallNotificationMessage.recallContent;
            widget.voidMessageClickCallBack(
                contentType: RecallNotificationMessage.objectName, map: map, position: widget.position);
          }
        },
      style: TextStyle(
          color: isChangeColor ? colorArray[1] : colorArray[0],
          fontSize: 14
      ),
    );
  }
}



