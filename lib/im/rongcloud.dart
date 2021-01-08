import 'package:flutter/material.dart';
import 'package:mirror/api/rongcloud_api.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/im/rongcloud_status_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../config/config.dart';

/// rongcloud
/// Created by yangjiayi on 2020/11/2.

//所有RongIMClient的方法都要经过此类封装,禁止直接调用RongIMClient
class RongCloud {
  static RongCloud _instance;
  RongCloudReceiveManager _receiveManager;
  RongCloudStatusManager _statusManager;

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

      RongIMClient.onMessageReceivedWrapper =
          _receiveManager.onMessageReceivedWrapper;
      RongIMClient.onMessageSend = _receiveManager.onMessageSend;
      RongIMClient.onRecallMessageReceived =
          _receiveManager.onRecallMessageReceived;
    }

    return _receiveManager;
  }

  //连接融云服务器
  void connect() async {
    //TODO 需要处理异常
    String token = await requestRongCloudToken();
    doConnect(token, (int code, String userId) {
      print('RongCloud connect result ' + code.toString());
      if (code == 0) {
        print("RongCloud connect success userId" + userId);
        // 连接成功 一般来说状态交给回调监听即可
      } else if (code == 34001) {
        // 已经连接上了 这种情况一般是回调监听还没有接到回调就去连接时 需要调用方法手动更新状态
        _statusManager.setStatus(RCConnectionStatus.Connected);
      } else if (code == 31004) {
        //TODO token 非法，需要重新从 APP 服务获取新 token 并连接
      }
    });
  }

  //连接融云服务器
  void doConnect(String token, Function(int code, String userId) finished) {
    RongIMClient.connect(token, finished);
  }

  //断开融云服务器
  void disconnect() {
    RongIMClient.disconnect(false);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendGroupMessage(String targetId, MessageContent content) {
    return RongIMClient.sendMessage(
        RCConversationType.Group, targetId, content);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendPrivateMessage(String targetId, MessageContent content) {
    return RongIMClient.sendMessage(
        RCConversationType.Private, targetId, content);
  }

  //todo 现在没有加 每一秒只发送5条数据的限制
  Future<Message> sendVoiceMessage(Message message) {
    return RongIMClient.sendIntactMessageWithCallBack(message, "", "", null);
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
  Future<List> getHistoryMessages(int conversationType, String targetId,
      int sentTime, int beforeCount, int afterCount) async {
    return await RongIMClient.getHistoryMessages(
        conversationType, targetId, sentTime, beforeCount, afterCount);
  }

  /// 批量删除消息
  ///
  /// [messages] 需要删除的 messages List
  void deleteMessageByIds(
      List<Message> messages, Function(int code) finished) async {
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

  //插入发送的消息
  void insertOutgoingMessage(int conversationType, String targetId,
      MessageContent content, Function(Message msg, int code) finished) {
    RongIMClient.insertOutgoingMessage(conversationType, targetId, 30, content,
        new DateTime.now().millisecondsSinceEpoch, finished);
  }

  //插入发送的消息
  void updateMessage(
      Map expansionDic, String messageUId, Function(int code) finished) {
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
}
