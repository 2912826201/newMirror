import 'package:flutter/material.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/im/rongcloud_receive_manager1.dart';
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
    //TODO 原方法需废弃
    RongCloudReceiveManager1.shareInstance();
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
    }

    return _receiveManager;
  }

  //连接融云服务器
  void connect(String token, Function(int code, String userId) finished) {
    RongIMClient.connect(token, finished);
  }

  //断开融云服务器
  void disconnect() {
    RongIMClient.disconnect(false);
  }

  Future<Message> sendGroupMessage(String targetId,MessageContent content) {
    return RongIMClient.sendMessage(RCConversationType.Group, targetId, content);
  }

  Future<Message> sendPrivateMessage(String targetId,MessageContent content) {
    return RongIMClient.sendMessage(RCConversationType.Private, targetId, content);
  }
}
