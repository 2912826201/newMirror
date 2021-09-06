import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/rongcloud_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'add_time_message_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

import 'chat_message_profile_util.dart';
import 'message_chat_page_manager.dart';

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
        CustomAppBarIconButton(svgName: AppIcon.nav_more, iconColor: AppColor.white, onTap: _topMoreBtnClick);
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
        if (MessageManager.chatGroupUserInformationMap["${conversation.conversationId}_${Application.profile.uid}"] ==
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
          width: MediaQuery
              .of(context)
              .size
              .width,
          color: AppColor.layoutBgGrey.withOpacity(0.5),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  height: 48,
                  width: 48,
                  color: AppColor.transparent,
                  child: AppIcon.getAppIcon(AppIcon.close_18, 16, color: AppColor.textWhite60),
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
                style: AppStyle.whiteRegular16,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ))),
              GestureDetector(
                child: Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColor.transparent,
                    border: Border.all(width: 1, color: AppColor.white),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon.getAppIcon(AppIcon.add_follow, 16, color: AppColor.white),
                      Text("关注", style: AppStyle.whiteMedium12),
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
    if (MessageManager.postChatDataModelList[conversation.id] == null ||
        MessageManager.postChatDataModelList[conversation.id].length < 1) {
      return;
    } else {
      for (int i = MessageManager.postChatDataModelList[conversation.id].length - 1; i >= 0; i--) {
        bool isHave = false;
        for (int j = 0; j < chatDataList.length; j++) {
          if (chatDataList[j].msg != null &&
              MessageManager.postChatDataModelList[conversation.id][i].msg != null &&
              chatDataList[j].msg.messageId == MessageManager.postChatDataModelList[conversation.id][i].msg.messageId) {
            isHave = true;
          }
        }
        if (isHave) {
          MessageManager.postChatDataModelList[conversation.id].removeAt(i);
        } else {
          chatDataList.insert(0, MessageManager.postChatDataModelList[conversation.id][i]);
        }
      }
    }
  }

  //加入时间提示
  void setTimeAlert(List<ChatDataModel> chatDataList, String chatId) {
    if (chatDataList != null && chatDataList.length > 0) {
      for (int i = chatDataList.length - 1; i >= 0; i--) {
        if (i == chatDataList.length - 1) {
          if (AddTimeMessageUtil.init().isCanAddTimeMessage(chatDataList[i]) &&
              chatDataList[i].msg != null &&
              chatDataList[i].msg.sentTime != null) {
            chatDataList.add(getTimeAlertModel(chatDataList[i].msg.sentTime, chatId));
          }
        } else if (chatDataList[i].msg != null &&
            chatDataList[i + 1].msg != null &&
            (chatDataList[i].msg.sentTime - chatDataList[i + 1].msg.sentTime > 5 * 60 * 1000)) {
          if (AddTimeMessageUtil.init().isCanAddTimeMessage(chatDataList[i])) {
            chatDataList.insert(i + 1, getTimeAlertModel(chatDataList[i].msg.sentTime, chatId));
          }
        }
      }
    }
  }

  //加入 以下是新消息 提示
  void addNewAlertMsg(List<ChatDataModel> chatDataList, int position, String chatId) {
    if (chatDataList != null && chatDataList.length > 0 && position != null && position < chatDataList.length) {
      chatDataList.insert(position, getNewAlertMsgModel(chatDataList[position].msg.sentTime, chatId));
    }
  }

  //获取 以下是新消息的临时消息
  ChatDataModel getNewAlertMsgModel(int sendTime, String chatId) {
    ChatDataModel dataModel = new ChatDataModel();
    dataModel.msg = getTemporaryMsg(
      text: "--- 以下是新消息 ---",
      sendTime: sendTime,
      targetId: chatId,
      conversationType: RCConversationType.Private,
      subObjectName: ChatTypeModel.MESSAGE_TYPE_NEW_MSG_ALERT,
      name: ChatTypeModel.MESSAGE_TYPE_NEW_MSG_ALERT_NAME,
    );
    return dataModel;
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
    deletePostCompleteMessage(conversation);
    addPostNoCompleteMessage(conversation, chatDataList);

    if (shareMessage != null && chatDataList.length > 0) {
      chatDataList[0].isHaveAnimation = true;
    }

    //加入时间提示
    setTimeAlert(chatDataList, conversation.conversationId);

    return chatDataList;
  }

  //获取系统通知
  Future<List> getSystemInformationNet(ConversationDto conversation) async {
    String systemLastTime;
    int systemPage = 0;
    List<ChatDataModel> dataList = <ChatDataModel>[];
    Map<String, dynamic> dataListMap = await querySysMsgList(type: conversation.type, size: chatAddHistoryMessageCount);
    try {
      systemLastTime = dataListMap["lastTime"].toString();
    } catch (e) {}
    if (dataListMap != null && dataListMap["list"] != null) {
      systemPage++;
      dataListMap["list"].forEach((v) {
        ChatSystemMessageModel model = ChatSystemMessageModel.fromJson(v);
        dataList.add(getMessage(getSystemMsg(model, conversation.type), isHaveAnimation: false));
      });
    }
    setTimeAlert(dataList, conversation.conversationId);
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



  //进入聊天界面判断需不需加载网路历史数据
  void isInitAddRemoteHistoryMessages(List<ChatDataModel> chatDataList,
      ConversationDto conversation){
    print("获取网络历史记录:${chatDataList.length}");
    if(chatDataList.length<chatAddHistoryMessageCount){
      print("111111111111");
      int recordTime;
      if(chatDataList.length>0&&
          chatDataList[chatDataList.length-1].msg!=null&&
          chatDataList[chatDataList.length-1].msg.sentTime!=null){
        recordTime=chatDataList[chatDataList.length-1].msg.sentTime;
      }else{
        recordTime=DateTime.now().millisecondsSinceEpoch;
      }
      _getRemoteHistoryMessages(
        conversation.getType(),
        conversation.conversationId,
        recordTime,
        chatAddHistoryMessageCount-chatDataList.length,
        (chatMessageList){
          if(chatMessageList!=null&&chatMessageList.length>0){
            print("chatAddHistoryMessageCount-chatDataList.length:${chatAddHistoryMessageCount-chatDataList.length}");
            print("recordTime:$recordTime");
            print("有历史消息:${chatMessageList.length}");
            if(chatDataList.length<1){
              MessageManager.updateConversationByMessage(context, chatMessageList[0].msg);
            }
          chatDataList.addAll(chatMessageList);
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
      });
    }
  }

  //刷新数据--加载更多以前的数据
  onLoadMoreHistoryMessages(
      List<ChatDataModel> chatDataList, ConversationDto conversation, Function(bool isHaveMore) onFinishListener,
      {int loadMsgCount}) async {
    List msgList = new List();
    msgList = await RongCloud.init().getHistoryMessages(conversation.getType(), conversation.conversationId,
        chatDataList[chatDataList.length - 1].msg.sentTime, loadMsgCount ?? chatAddHistoryMessageCount, 0);
    List<ChatDataModel> dataList = <ChatDataModel>[];
    if (msgList != null && msgList.length > 1) {
      dataList.clear();
      for (int i = 1; i < msgList.length; i++) {
        dataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
      if (dataList != null && dataList.length > 0) {
        setTimeAlert(dataList, conversation.conversationId);
        //print("value:${chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime}-----------");
        if (chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime < 5 * 60 * 1000) {
          chatDataList.removeAt(chatDataList.length - 1);
        }
        chatDataList.addAll(dataList);
      }
      onFinishListener(true);
    } else {
      onFinishListener(false);
      // _addMoreRemoteHistoryMessages(chatDataList,conversation,onFinishListener);
    }
  }

  //获取网络的历史记录
  _addMoreRemoteHistoryMessages(List<ChatDataModel> chatDataList,
      ConversationDto conversation,Function(bool isHaveMore) onFinishListener){
    int recordTime;
    if(chatDataList.length>0&&
        chatDataList[chatDataList.length-1].msg!=null&&
        chatDataList[chatDataList.length-1].msg.sentTime!=null){
      recordTime=chatDataList[chatDataList.length-1].msg.sentTime;
    }else{
      recordTime=DateTime.now().millisecondsSinceEpoch;
    }
    _getRemoteHistoryMessages(
        conversation.getType(),
        conversation.conversationId,
        recordTime,
        chatAddHistoryMessageCount,
        (chatMessageList){
          if(chatMessageList!=null&&chatMessageList.length>0){
            print("chatAddHistoryMessageCount-chatDataList.length:${chatAddHistoryMessageCount-chatDataList.length}");
            print("recordTime:$recordTime");
            print("有历史消息:${chatMessageList.length}");
            chatDataList.addAll(chatMessageList);
            onFinishListener(true);
          }else{
            onFinishListener(false);
          }
        });
  }


  _getRemoteHistoryMessages(int conversationType, String targetId, int recordTime, int count,
      Function(List<ChatDataModel> chatMessageList,) finished){
    print("222222");
    if(finished==null){
      return;
    }
    print("开始获取历史");
    Application.rongCloud.getRemoteHistoryMessages(conversationType, targetId, recordTime, count,
    (List/*<Message>*/ msgList, int code){
      if(msgList==null||msgList.length<1){
        print("没有历史消息");
        finished(null);
      }else{
        print("有历史消息:${msgList.length}");
        List<ChatDataModel> chatDataModelList = [];
        for (int i = 0; i < msgList.length; i++) {
          chatDataModelList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
        }
        ChatPageUtil.init(context).setTimeAlert(chatDataModelList, targetId);
        finished(chatDataModelList);
      }
    });
  }



  //检查消息为什么发送失败
  checkPostMessageFailed(int conversationType,String conversationId)async{
    if(await isOffline()){
      ToastShow.show(msg: "请检查网络", context: context, gravity: 1);
      return;
    }else if(conversationType == PRIVATE_TYPE){
      BlackModel blackModel = await ProfileCheckBlack(int.parse(conversationId));
      if (blackModel != null) {
        if (blackModel.inYouBlack == 1) {
          //print("发送失败，你已将对方加入黑名单");
          ToastShow.show(msg: "发送失败，你已将对方加入黑名单", context: context, gravity: 1);
          return;
        } else if (blackModel.inThisBlack == 1) {
          //print("发送失败，你已被对方加入黑名单");
          ToastShow.show(msg: "发送失败，你已被对方加入黑名单", context: context, gravity: 1);
          return;
        }
      }
    }
    _resetConnectRC();
  }

  //重新连接融云
  _resetConnectRC()async{
    Application.rongCloud.disconnect();
    String token = await requestRongCloudToken();
    if (token != null) {
      Application.rongCloud.doConnect(token, (int code, String userId) {
        print('connect result $code');
        if (code == 0) {
          print("connect success userId" + userId);
          // 连接成功后打开数据库
          // _initUserInfoCache();
          print("连接成功，userId为" + userId);
        } else if (code == 34001) {
          // 已经连接上了
        } else if (code == 31004) {
          // token 非法，需要重新从 APP 服务获取新 token 并连接
          print("连接失败");
        }
      });
    }
  }



  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return false;
    } else {
      return true;
    }
  }

  //判断这个消息是不是提示消息
  bool getIsAlertMessage(String chatTypeModel) {
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
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_NEW_MSG_ALERT) {
      return true;
    }
    return false;
  }

  Future<ConversationDto> getConversationDto(String chatId) async {
    ConversationDto conversation;

    conversation = ChatMessageProfileUtil.init().getConversation(chatId);
    if (conversation != null) return conversation;

    conversation = await ConversationDBHelper().querySingleConversation(chatId);
    if (conversation != null) return conversation;

    List<GroupChatModel> list = await getGroupChatByIds(id: int.parse(chatId));
    if (list != null && list.length > 0) {
      conversation = ConversationDto.fromGroupChat(list.first);
    }

    return conversation;
  }
}
