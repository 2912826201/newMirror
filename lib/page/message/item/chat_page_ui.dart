


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

import '../message_chat_page_manager.dart';

class ChatPageUtil{
  static ChatPageUtil _chatPageUi;
  BuildContext context;

  static ChatPageUtil init(BuildContext context){
    if(_chatPageUi==null){
      _chatPageUi=ChatPageUtil();
    }
    _chatPageUi.context=context;
    return _chatPageUi;
  }

  //获取appbar
  Widget getAppBar(ConversationDto conversation,Function() _topMoreBtnClick) {
    Widget action=CustomAppBarIconButton(svgName: AppIcon.nav_more, iconColor: AppColor.black, onTap: _topMoreBtnClick);
    String chatName;
    if (conversation.name == null || conversation.name.trim().length < 1) {
      chatName = conversation.conversationId;
    } else {
      chatName = conversation.name;
    }
    if (conversation.getType() == RCConversationType.Group) {
      if(context.read<GroupUserProfileNotifier>().chatGroupUserModelList.length>0) {
        if (context.read<GroupUserProfileNotifier>().isNoHaveMe()) {
          action = Container();
        }
      }else{
        if(Application.chatGroupUserInformationMap["${conversation.conversationId}_${Application.profile.uid}"]==null){
          action = Container();
        }
      }
      int userCount;
      if(context.read<GroupUserProfileNotifier>().isNoHaveMe()){
        userCount=0;
      }else {
        userCount = context.read<GroupUserProfileNotifier>().chatGroupUserModelList.length;
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
  Widget getTopAttentionUi(bool isShowTopAttentionUi,
      int conversationType,
      Function() _attntionOnClick,
      Function(bool isShow) _showTopAttentionUi){
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
                  child: Icon(Icons.close, size: 16, color: AppColor.colorb9b9b9),
                ),
                onTap: () {
                  if(_showTopAttentionUi!=null){
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
                      Icon(Icons.add, size: 16, color: AppColor.textPrimary1),
                      Text("关注",
                          style: AppStyle.textMedium14),
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
  clearUnreadCount(ConversationDto conversation){
    MessageManager.clearUnreadCount(
        context,
        conversation.conversationId,
        Application.profile.uid,
        conversation.type
    );
  }



  //加入发送未完成的消息
  addPostNoCompleteMessage(ConversationDto conversation,List<ChatDataModel> chatDataList) {
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
  void getTimeAlert(List<ChatDataModel> chatDataList,String chatId) {
    if (chatDataList != null && chatDataList.length > 0) {
      for (int i = chatDataList.length - 1; i >= 0; i--) {
        if (i == chatDataList.length - 1) {
          chatDataList.add(getTimeAlertModel(chatDataList[i].msg.sentTime,chatId));
        } else if (chatDataList[i].msg!=null&&(chatDataList[i].msg.sentTime - chatDataList[i + 1].msg.sentTime > 5 * 60 * 1000)) {
          chatDataList.insert(i + 1, getTimeAlertModel(chatDataList[i].msg.sentTime,chatId));
        }
      }
    }
  }

  //获取普通消息
  Future<List<ChatDataModel>> getChatMessageList(ConversationDto conversation,Message shareMessage)async{
    List msgList = new List();
    List<ChatDataModel> chatDataList = <ChatDataModel>[];
    msgList = await RongCloud.init().getHistoryMessages(
        conversation.getType(), conversation.conversationId, new DateTime.now().millisecondsSinceEpoch,
        chatAddHistoryMessageCount, 0);
    if (msgList != null && msgList.length > 0) {
      for (int i = 0; i < msgList.length; i++) {
        chatDataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
    }

    //添加没有发生完成的消息
    addPostNoCompleteMessage(conversation,chatDataList);

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
    Map<String, dynamic> dataListMap =
    await querySysMsgList(type: conversation.type, size: chatAddHistoryMessageCount);
    try {
      systemLastTime = dataListMap["lastTime"].toString();
    } catch (e) {}
    if (dataListMap != null && dataListMap["list"] != null) {
      systemPage++;
      dataListMap["list"].forEach((v) {
        dataList.add(getMessage(getSystemMsg(v, conversation.type), isHaveAnimation: false));
      });
    }
    getTimeAlert(dataList, conversation.conversationId);
    return [dataList,systemLastTime,systemPage];
  }
}