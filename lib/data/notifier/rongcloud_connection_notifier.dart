import 'package:flutter/material.dart';

class RongCloudStatusNotifier with ChangeNotifier {
  //   static const int Connected = 0; //连接成功
  //   static const int Connecting = 1; //连接中
  //   static const int KickedByOtherClient = 2; //该账号在其他设备登录，导致当前设备掉线
  //   static const int NetworkUnavailable = 3; //网络不可用
  //   static const int TokenIncorrect = 4; //token 非法，此时无法连接 im，需重新获取 token
  //   static const int UserBlocked = 5; //用户被封禁
  //   static const int DisConnected = 6; //用户主动断开
  //   static const int Suspend = 13; // 连接暂时挂起（多是由于网络问题导致），SDK 会在合适时机进行自动重连
  //   static const int Timeout = 14; // 自动连接超时，SDK 将不会继续连接，用户需要做超时处理，再自行调用 connectWithToken 接口进行连接


  int _status = -1;

  int get status => _status;

  //触发通知的行为
  void setStatus(int status) {
    _status = status;
    notifyListeners();
  }
}
