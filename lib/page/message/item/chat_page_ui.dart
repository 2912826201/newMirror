import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

import '../message_chat_page_manager.dart';

class ChatPageUtil {
  static ChatPageUtil _chatPageUi;
  BuildContext context;

  static ChatPageUtil init(BuildContext context) {
    if (_chatPageUi == null) {
      _chatPageUi = ChatPageUtil();
    }
    _chatPageUi.context = context;
    return _chatPageUi;
  }

  //获取appbar
  Widget getAppBar(ConversationDto conversation, Function() _topMoreBtnClick) {
    Widget action =
        CustomAppBarIconButton(svgName: AppIcon.nav_more, iconColor: AppColor.black, onTap: _topMoreBtnClick);
    String chatName;
    if (conversation.name == null || conversation.name.trim().length < 1) {
      chatName = conversation.conversationId;
    } else {
      chatName = conversation.name;
    }
    if (conversation.getType() == RCConversationType.Group) {
      if (context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length > 0) {
        if (context.watch<GroupUserProfileNotifier>().isNoHaveMe()) {
          action = Container();
        }
      } else {
        if (Application.chatGroupUserInformationMap["${conversation.conversationId}_${Application.profile.uid}"] ==
            null) {
          action = Container();
        }
      }
      int userCount;
      if (context.watch<GroupUserProfileNotifier>().isNoHaveMe()) {
        userCount = 0;
      } else {
        userCount = context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length;
      }
      return CustomAppBar(
        titleString: chatName ?? "",
        subtitleString: userCount > 0 ? "($userCount)" : null,
        actions: [action],
      );
    } else {
      return CustomAppBar(
        titleString: chatName ?? "",
        actions: [action],
      );
    }
  }

  //获取关注按钮条
  Widget getTopAttentionUi(bool isShowTopAttentionUi, int conversationType, Function() _attntionOnClick,
      Function(bool isShow) _showTopAttentionUi) {
    if (conversationType != PRIVATE_TYPE) {
      isShowTopAttentionUi = false;
    }
    return Visibility(
      visible: isShowTopAttentionUi,
      child: UnconstrainedBox(
        alignment: Alignment.topCenter,
        child: Container(
          height: 48,
          padding: const EdgeInsets.only(right: 16),
          width: MediaQuery.of(context).size.width,
          color: AppColor.textSecondary.withOpacity(0.1),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  height: 48,
                  width: 48,
                  color: AppColor.transparent,
                  child: AppIcon.getAppIcon(AppIcon.close_18, 16, color: AppColor.textHint),
                ),
                onTap: () {
                  if (_showTopAttentionUi != null) {
                    _showTopAttentionUi(false);
                  }
                },
              ),
              Expanded(
                  child: SizedBox(
                      child: Text(
                "点击关注,及时看到对方动态",
                style: TextStyle(color: AppColor.textPrimary1, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ))),
              GestureDetector(
                child: Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColor.transparent,
                    border: Border.all(width: 1, color: AppColor.textPrimary1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon.getAppIcon(AppIcon.add_follow, 16, color: AppColor.textPrimary1),
                      Text("关注", style: AppStyle.textMedium14),
                      SizedBox(width: 2),
                    ],
                  ),
                ),
                onTap: _attntionOnClick,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //清聊天未读数
  clearUnreadCount(ConversationDto conversation) {
    MessageManager.clearUnreadCount(context, conversation.conversationId, Application.profile.uid, conversation.type);
  }

  //加入发送未完成的消息
  addPostNoCompleteMessage(ConversationDto conversation, List<ChatDataModel> chatDataList) {
    if (Application.postChatDataModelList[conversation.id] == null ||
        Application.postChatDataModelList[conversation.id].length < 1) {
      return;
    } else {
      for (int i = Application.postChatDataModelList[conversation.id].length - 1; i >= 0; i--) {
        bool isHave = false;
        for (int j = 0; j < chatDataList.length; j++) {
          if (chatDataList[j].msg != null &&
              Application.postChatDataModelList[conversation.id][i].msg != null &&
              chatDataList[j].msg.messageId == Application.postChatDataModelList[conversation.id][i].msg.messageId) {
            isHave = true;
          }
        }
        if (isHave) {
          Application.postChatDataModelList[conversation.id].removeAt(i);
        } else {
          chatDataList.insert(0, Application.postChatDataModelList[conversation.id][i]);
        }
      }
    }
  }

  //加入时间提示
  void getTimeAlert(List<ChatDataModel> chatDataList, String chatId) {
    if (chatDataList != null && chatDataList.length > 0) {
      for (int i = chatDataList.length - 1; i >= 0; i--) {
        if (i == chatDataList.length - 1) {
          if(isShowNewChatDataModel(chatDataList[i])) {
            chatDataList.add(getTimeAlertModel(chatDataList[i].msg.sentTime, chatId));
          }
        } else if (chatDataList[i].msg != null &&
            (chatDataList[i].msg.sentTime - chatDataList[i + 1].msg.sentTime > 5 * 60 * 1000)) {
          if(isShowNewChatDataModel(chatDataList[i])) {
            chatDataList.insert(i + 1, getTimeAlertModel(chatDataList[i].msg.sentTime, chatId));
          }
        }
      }
    }
  }

  //获取普通消息
  Future<List<ChatDataModel>> getChatMessageList(ConversationDto conversation, Message shareMessage) async {
    List msgList = new List();
    List<ChatDataModel> chatDataList = <ChatDataModel>[];
    msgList = await RongCloud.init().getHistoryMessages(conversation.getType(), conversation.conversationId,
        new DateTime.now().millisecondsSinceEpoch, chatAddHistoryMessageCount, 0);
    if (msgList != null && msgList.length > 0) {
      for (int i = 0; i < msgList.length; i++) {
        chatDataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
    }

    //添加没有发生完成的消息
    addPostNoCompleteMessage(conversation, chatDataList);

    if (shareMessage != null && chatDataList.length > 0) {
      chatDataList[0].isHaveAnimation = true;
    }

    //加入时间提示
    getTimeAlert(chatDataList, conversation.conversationId);

    return chatDataList;
  }

  //获取系统消息
  Future<List> getSystemInformationNet(ConversationDto conversation) async {
    String systemLastTime;
    int systemPage = 0;
    List<ChatDataModel> dataList = <ChatDataModel>[];
    // Map<String, dynamic> dataListMap = await querySysMsgList(type: conversation.type, size: chatAddHistoryMessageCount);
    // try {
    //   systemLastTime = dataListMap["lastTime"].toString();
    // } catch (e) {}
    // if (dataListMap != null && dataListMap["list"] != null) {
    //   systemPage++;
    //   dataListMap["list"].forEach((v) {
    //     dataList.add(getMessage(getSystemMsg(v, conversation.type), isHaveAnimation: false));
    //   });
    // }
    // getTimeAlert(dataList, conversation.conversationId);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    dataList.add(ChatDataModel()..isTemporary=true..status=RCSentStatus.Sent..type=ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON);
    return [dataList, systemLastTime, systemPage];
  }


  //添加这些用户
  Future<bool> addUserGroup(String addUserId,int groupChatId) async {
    Map<String, dynamic> model = await inviteJoin(groupChatId:groupChatId, uids: addUserId);
    if (model != null) {
      if (model["NotFriendList"] != null && model["NotFriendList"].length > 0) {
        String name = "";
        for (int i = 0; i < model["NotFriendList"].length; i++) {
          if (i == 0) {
            name += model["NotFriendList"][i]["nickName"];
          } else {
            name += "," + model["NotFriendList"][i]["nickName"];
          }
        }
        ToastShow.show(msg: "邀请失败", context: context);
        return false;
      } else {
        ToastShow.show(msg: "邀请成功", context: context);
        return true;
      }
    } else {
      ToastShow.show(msg: "邀请失败", context: context);
      return false;
    }
  }

  bool isShowNewMessage(Message message){
    return isShowNewChatDataModel(getMessage(message, isHaveAnimation: false));
  }


  bool isShowNewChatDataModel(ChatDataModel chatDataModel){
    return true;
    // if(chatDataModel.isTemporary){
    //   return true;
    // }else{
    //   switch(chatDataModel.msg.objectName){
    //     case ChatTypeModel.MESSAGE_TYPE_TEXT:
    //       TextMessage textMessage = ((chatDataModel.msg.content) as TextMessage);
    //       try {
    //         Map<String, dynamic> mapModel = json.decode(textMessage.content);
    //         if (_getIsAlertMessage(mapModel["subObjectName"])) {
    //           //-------------------------------------------------提示消息--------------------------------------------
    //           return _isNoShowMsg(map: mapModel);
    //         } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
    //           //-------------------------------------------------群通知消息-第二种-------------------------------------------
    //           Map<String, dynamic> map = Map();
    //           map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
    //           map["data"] = json.decode(mapModel["data"]);
    //           return _isNoShowMsg(map: map);
    //         }
    //       } catch (e) {}
    //       return false;
    //     case ChatTypeModel.MESSAGE_TYPE_GRPNTF:
    //       // -----------------------------------------------群通知-群聊-第一种---------------------------------------------
    //       Map<String, dynamic> map = Map();
    //       map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
    //       map["data"] = chatDataModel.msg.originContentMap;
    //       return _isNoShowMsg(map: map);
    //     case ChatTypeModel.MESSAGE_TYPE_CMD:
    //       // -----------------------------------------------通知-私聊-----------------------------------------------
    //       Map<String, dynamic> map = Map();
    //       map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
    //       map["data"] = chatDataModel.msg.originContentMap;
    //       return _isNoShowMsg(map: map);
    //     default:
    //       return false;
    //   }
    // }
  }

  //todo 获取群主的方式是有问题的 目前还好 如果以后有管理员 这样是不行的
  bool _isNoShowMsg({@required Map<String, dynamic> map}){
    //0--加入群聊
    //1--退出群聊
    //2--移除群聊
    //3--群主转移
    //4--群名改变
    //5--扫码加入群聊
    if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP) {
      Map<String, dynamic> mapGroupModel = json.decode(map["data"]["data"]);
      if (mapGroupModel["subType"] == 0||mapGroupModel["subType"] ==1||mapGroupModel["subType"] ==2) {
        if (context.read<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED) {
          ChatGroupUserModel chatGroupUserModel = context.read<GroupUserProfileNotifier>().chatGroupUserModelList[0];


          if (mapGroupModel["subType"] == 1 && chatGroupUserModel.uid != Application.profile.uid) {
            return false;
          } else {
            if (mapGroupModel["subType"] == 0 && map["data"]["name"] == "Entry") {
              return false;
            }else{
              return _isHaveUserMessageAlert(mapGroupModel);
            }
          }
        } else {
          if (mapGroupModel["subType"] == 1) {
            return false;
          } else {
            if (mapGroupModel["subType"] == 0 && map["data"]["name"] == "Entry") {
              return false;
            }else{
              return _isHaveUserMessageAlert(mapGroupModel);
            }
          }
        }
      }
    }
    return true;
  }

  //判断这个提示里面有没有我或者 我是不是群主
  bool _isHaveUserMessageAlert(Map<String, dynamic> mapGroupModel){

    //0--加入群聊
    //1--退出群聊
    //2--移除群聊
    //3--群主转移
    //4--群名改变
    //5--扫码加入群聊
    bool isHaveUserSelf = false;
    List<dynamic> users = mapGroupModel["users"];

    if (mapGroupModel["subType"] == 0) {
      //邀请
      if (mapGroupModel["operator"].toString() == Application.profile.uid.toString()) {
        isHaveUserSelf = true;
      }
    } else if (mapGroupModel["subType"] == 2) {
      //移除
      if (mapGroupModel["operator"].toString() == Application.profile.uid.toString()) {
        isHaveUserSelf = true;
      }
    }
    for (dynamic d in users) {
      try {
        if (d != null) {
          if (d["uid"] == Application.profile.uid) {
            isHaveUserSelf = true;
          }
        }
      } catch (e) {
        break;
      }
    }

    //退出群聊
    if (mapGroupModel["subType"] == 1) {
      if (!isHaveUserSelf) {
        if (context.read<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED &&
            context.read<GroupUserProfileNotifier>().chatGroupUserModelList != null &&
            context.read<GroupUserProfileNotifier>().chatGroupUserModelList.length > 0) {
          ChatGroupUserModel chatGroupUserModel = context.read<GroupUserProfileNotifier>().chatGroupUserModelList[0];
          if (chatGroupUserModel.uid != Application.profile.uid) {
            return false;
          }
        } else {
          return false;
        }
      }
    } else if (mapGroupModel["subType"] == 2) {
      //移出了群聊
      if (!isHaveUserSelf) {
        if (context.read<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED &&
            context.read<GroupUserProfileNotifier>().chatGroupUserModelList != null &&
            context.read<GroupUserProfileNotifier>().chatGroupUserModelList.length > 0) {
          ChatGroupUserModel chatGroupUserModel = context.read<GroupUserProfileNotifier>().chatGroupUserModelList[0];
          if (chatGroupUserModel.uid != Application.profile.uid) {
            return false;
          }
        } else {
          return false;
        }
      }
    }
    return true;
  }


  //判断这个消息是不是提示消息
  bool _getIsAlertMessage(String chatTypeModel) {
    if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_INVITE) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_NEW) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_UPDATE_GROUP_NAME) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_REMOVE) {
      return true;
    }
    return false;
  }



  //判断这个消息是不是时间的提示
  bool isTimeAlertMsg(ChatDataModel chatDataModel){
    if(chatDataModel==null)return false;
    if(chatDataModel.isTemporary)return false;
    if(chatDataModel.msg==null)return false;
    if(chatDataModel.msg.objectName!=TextMessage.objectName)return false;
    TextMessage textMessage = ((chatDataModel.msg.content) as TextMessage);
    Map<String, dynamic> mapModel = json.decode(textMessage.content);
    if(mapModel==null)return false;
    return mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME;
  }

  //
  bool isSystemMsg(String chatId){
    int id=0;
    try{
      id=int.parse(chatId);
    }catch (e){}
    return id>=minSystemId&&id<=maxSystemId;
  }

  bool isOfficialMsg(String chatId){
    int id=0;
    try{
      id=int.parse(chatId);
    }catch (e){}
    return id>=minOfficialNumberId&&id<=maxOfficialNumberId;
  }

}
