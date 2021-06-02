import 'package:flutter/material.dart';
import 'package:mirror/api/rongcloud_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/im/rongcloud_status_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../config/config.dart';
import 'message_manager.dart';

/// rongcloud
/// Created by yangjiayi on 2020/11/2.

//所有RongIMClient的方法都要经过此类封装,禁止直接调用RongIMClient
class RongCloud {
  static RongCloud _instance;
  RongCloudReceiveManager _receiveManager;
  RongCloudStatusManager _statusManager;

  int _retryCount = 0;
  List<int> _retryInterval = [1, 3, 5, 10, 30, 60];

  //初始化融云组件
  static RongCloud init() {
    if (_instance == null) {
      _instance = RongCloud();
      RongIMClient.init(AppConfig.getRCAppKey());
    }
    return _instance;
  }

  RongCloudStatusManager initStatusManager(BuildContext context) {
    if (_statusManager == null) {
      _statusManager = RongCloudStatusManager.init(context);

      RongIMClient.onConnectionStatusChange = _statusManager.onConnectionStatusChange;
    }

    return _statusManager;
  }

  RongCloudReceiveManager initReceiveManager(BuildContext context) {
    if (_receiveManager == null) {
      _receiveManager = RongCloudReceiveManager.init(context);

      RongIMClient.onMessageReceivedWrapper = _receiveManager.onMessageReceivedWrapper;
      RongIMClient.onMessageSend = _receiveManager.onMessageSend;
      RongIMClient.onRecallMessageReceived = _receiveManager.onRecallMessageReceived;
    }

    return _receiveManager;
  }

  //连接融云服务器
  void connect() async {
    String token = await requestRongCloudToken();
    if (token != null) {
      doConnect(token, (int code, String userId) {
        print('RongCloud connect result ' + code.toString());
        if (code == 0) {
          print("RongCloud connect success userId" + userId);
          // 连接成功 一般来说状态交给回调监听即可
        } else if (code == 34001) {
          // 已经连接上了 这种情况一般是回调监听还没有接到回调就去连接时 需要调用方法手动更新状态
          _statusManager.setStatus(RCConnectionStatus.Connected);
        } else if (code == 31004) {
          //token 非法，需要重新从 APP 服务获取新 token 并连接
          _retryConnect();
        }
      });
    } else {
      //token没有取到，需要重新从 APP 服务获取新 token 并连接
      _retryConnect();
    }
  }

  // 重连方法
  void _retryConnect() {
    // 未登录的情况不重试 并将重试次数清零
    if (Application.token == null || Application.token.anonymous == 1) {
      _instance._retryCount = 0;
      return;
    }
    int interval = 0;
    //当重试次数超出递增数列上限时赋值最大值，否则从响应次数取值
    if (_instance._retryCount >= _instance._retryInterval.length) {
      interval = _instance._retryInterval.last;
    } else {
      interval = _instance._retryInterval[_instance._retryCount];
    }
    //重试次数加一
    _instance._retryCount += 1;
    //在延迟间隔时间后获取token连接融云
    Future.delayed(Duration(seconds: interval), (){
      print("重连融云第${_instance._retryCount}次，间隔$interval秒，时间戳${DateTime.now().millisecondsSinceEpoch}");
      connect();
    });
  }

  //连接融云服务器 错误码见common_define.dart中的RCErrorCode
  void doConnect(String token, Function(int code, String userId) finished) {
    RongIMClient.connect(token, finished);
  }

  //断开融云服务器
  void disconnect() {
    RongIMClient.disconnect(false);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendGroupMessage(String targetId, MessageContent content) async {
    return RongIMClient.sendMessage(RCConversationType.Group, targetId, content);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendPrivateMessage(String targetId, MessageContent content) async {
    return RongIMClient.sendMessage(RCConversationType.Private, targetId, content);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendChatRoomMessage(String targetId, MessageContent content) {
    return RongIMClient.sendMessage(RCConversationType.ChatRoom, targetId, content);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendVoiceMessage(Message message) async {
    if (Application.platform == 1) {
      return RongIMClient.getMessage(
          (await RongIMClient.sendIntactMessageWithCallBack(message, "", "", null)).messageId);
    } else {
      return RongIMClient.sendIntactMessageWithCallBack(message, "", "", null);
    }
  }

  //撤回消息
  Future<RecallNotificationMessage> recallMessage(Message message) async {
    return await RongIMClient.recallMessage(message, null);
  }

  ///获取特定方向的历史消息
  ///
  ///[conversationType] 会话类型，参见枚举 [RCConversationType]
  ///
  ///[targetId] 会话 id
  ///
  ///[sentTime] 消息的发送时间
  ///
  ///[beforeCount] 指定消息的前部分消息数量
  ///
  ///[afterCount] 指定消息的后部分消息数量
  ///
  ///[return] 获取到的消息列表
  Future<List> getHistoryMessages(
      int conversationType, String targetId, int sentTime, int beforeCount, int afterCount) async {
    return await RongIMClient.getHistoryMessages(conversationType, targetId, sentTime, beforeCount, afterCount);
  }


  /// 返回一个[Map] {"code":...,"messages":...,"isRemaining":...}
  /// code:是否获取成功
  /// messages:获取到的历史消息数组,
  /// isRemaining:是否还有剩余消息 YES 表示还有剩余，NO 表示无剩余
  ///
  /// [conversationType]  会话类型，参见枚举 [RCConversationType]
  ///
  /// [targetId]          聊天室的会话ID
  ///
  /// [recordTime]        起始的消息发送时间戳，毫秒
  ///
  /// [count]             需要获取的消息数量， 0 < count <= 200
  ///
  /// 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
  /// 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime应传入最早的消息的发送时间戳，count传入1~20之间的数值。
  void getRemoteHistoryMessages(
      int conversationType,
      String targetId,
      int recordTime,
      int count,
      Function(List/*<Message>*/ msgList, int code) finished) async {
    RongIMClient.getRemoteHistoryMessages(conversationType, targetId, recordTime, count, finished);
  }

  /// 批量删除消息
  ///
  /// [messages] 需要删除的 messages List
  void deleteMessageByIds(List<Message> messages, Function(int code) finished) async {
    List<int> messageIds = <int>[];
    if (messages == null || messages.length < 1) {
      return;
    }
    for (int i = 0; i < messages.length; i++) {
      messageIds.add(messages[i].messageId);
    }
    RongIMClient.deleteMessageByIds(messageIds, finished);
  }

  /// 删除消息
  ///
  /// [messages] 需要删除的 messages List
  void deleteMessageById(Message message, Function(int code) finished) async {
    List<int> messageIds = <int>[];
    if (message == null) {
      return;
    }
    messageIds.add(message.messageId);
    RongIMClient.deleteMessageByIds(messageIds, finished);
  }

  /// 清空指定类型，targetId 的某一会话所有聊天消息记录
  void clearMessages(int conversationType, String targetId, Function(int code) finished) {
    if (conversationType == null || targetId == null) {
      return;
    }
    RongIMClient.clearMessages(conversationType, targetId, finished);
  }

  //插入发送的消息
  void insertOutgoingMessage(
      int conversationType, String targetId, MessageContent content, Function(Message msg, int code) finished,
      {int sendTime = -1, int sendStatus = RCSentStatus.Sent}) {
    // 需要同时更新会话
    if (sendTime < 0) {
      RongIMClient.insertOutgoingMessage(
          conversationType, targetId, sendStatus, content, new DateTime.now().millisecondsSinceEpoch, (msg, code) {
        if (msg != null) {
          try {
            MessageManager.updateConversationByMessageList(Application.appContext, [msg]);
          } catch (e) {}
        }
        finished(msg, code);
      });
    } else {
      RongIMClient.insertOutgoingMessage(conversationType, targetId, sendStatus, content, sendTime, (msg, code) {
        if (msg != null) {
          try {
            MessageManager.updateConversationByMessageList(Application.appContext, [msg]);
          } catch (e) {}
        }
        finished(msg, code);
      });
    }
  }

  //更新消息
  void updateMessage(Map expansionDic, String messageUId, Function(int code) finished) {
    RongIMClient.updateMessageExpansion(expansionDic, messageUId, finished);
  }

  //将制定用户加入黑名单
  void addToBlackList(String userId, Function(int code) finished) {
    RongIMClient.addToBlackList(userId, finished);
  }

  //将用户移除黑名单
  void removeFromBlackList(String userId, Function(int code) finished) {
    RongIMClient.removeFromBlackList(userId, finished);
  }

  //获取特定用户的黑名单状态
  void getBlackListStatus(String userId, Function(int blackListStatus, int code) finished) {
    RongIMClient.getBlackListStatus(userId, finished);
  }

  //设置用户免打扰
  void setConversationNotificationStatus(
      int conversationType, String targetId, bool isBlocked, Function(int status, int code) finished) {
    RongIMClient.setConversationNotificationStatus(conversationType, targetId, isBlocked, finished);
  }

  //获取用户是否免打扰
  void getConversationNotificationStatus(
      int conversationType, String targetId, Function(int status, int code) finished) {
    RongIMClient.getConversationNotificationStatus(conversationType, targetId, finished);
  }

  //通过消息id查询消息
  Future<Message> getMessageById(int messageId) {
    return RongIMClient.getMessage(messageId);
  }

  //加入聊天室
  void joinChatRoom(String targetId, {int messageCount = -1}) {
    RongIMClient.joinChatRoom(targetId, messageCount);
  }

  //退出聊天室
  void quitChatRoom(String targetId) {
    RongIMClient.quitChatRoom(targetId);
  }
}
