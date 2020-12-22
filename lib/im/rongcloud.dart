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

      RongIMClient.onMessageReceivedWrapper = _receiveManager.onMessageReceivedWrapper;
      RongIMClient.onMessageSend = _receiveManager.onMessageSend;
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

  Future<Message> sendGroupMessage(String targetId, MessageContent content) {
    return RongIMClient.sendMessage(RCConversationType.Group, targetId, content);
  }

  Future<Message> sendPrivateMessage(String targetId, MessageContent content) {
    return RongIMClient.sendMessage(RCConversationType.Private, targetId, content);
  }
}
