


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
//在融云状态管理类进行注册后的对象的回调方法
abstract class RCStatusDelegate{
  //状态回调
  void statusChangeNotification(int status);
}
// //融云连接状态（参考融云sdk的RCConnectionStatus）
// enum RongCloudStatus{
//   //连接成功
//   CONNECTED ,
//   //连接中
//   CONNECTING,
//   //该账号在其他设备登录，导致当前设备掉线
//   KICKED_BY_OTHER_CLIENT,
//   //网络不可用
//   NETWORK_UNAVAILABLE,
//   //token 非法，此时无法连接im，需重新获取 token
//   TOKEN_INCORRECT,
//   //用户被封禁
//   USER_BLOCKED,
//   //用户主动断开
//   DISCONNECTED,
//   // 连接暂时挂起（多是由于网络问题导致），SDK 会在合适时机进行自动重连
//   SUSPEND,
//   // 自动连接超时，SDK 将不会继续连接，用户需要做超时处理，再自行调用 connectWithToken 接口进行连接
//   TIMEOUT
// }
//融云状态管理类，单例
abstract class RongCloudStatusManager{
  //注册对某状态通知
  void registerNotificationForStatus<T extends RCStatusDelegate >(int status,T target);
  //取消对某状态的通知
  void cancelSpecificNotification<T extends RCStatusDelegate >(int status,T target);
  //取消所有通知
  void cancelNotifications<T extends RCStatusDelegate >(T target);
  //状态变化
  void _statusChange(int currentStatus);
  static RongCloudStatusManager _me;
  //单例构造函数
  static RongCloudStatusManager shareInstance(){
    if (_me==null){
      _me = _RongCloudStatusManager();
    }
    return _me;
   }
}
class _RongCloudStatusManager extends RongCloudStatusManager{
  //构造函数
  _RongCloudStatusManager(){
   _init();
  }
  //初始化
  _init(){
    //和融云sdk状态回调挂钩
    RongIMClient.onConnectionStatusChange = (int connectionStatus){
      _statusChange(connectionStatus);
    };
    //
    for(int i = RCConnectionStatus.Connected;i<=RCConnectionStatus.Timeout;i++)
      {
        //处理区间缺口
        if  (i>RCConnectionStatus.DisConnected&&i<RCConnectionStatus.Suspend) continue;
        var t =  ValueNotifier(bool);
        _callChain[i]=t;
      }
  }
  //回调集合
  Map<RCStatusDelegate,VoidCallback> _closures = Map();
  //注册在线的对象
  Map<RCStatusDelegate,Set> _listeners = Map();
  //状态和通知的对应关系
  Map<int,ValueNotifier> _callChain = Map();
  //状态回调
  @override
  void _statusChange(int currentStatus) {
   //  switch (currentStatus){
   //    case RCConnectionStatus.Connected:
   //    
   //      break;
   //    case RCConnectionStatus.Connecting:
   //
   //      break;
   //    case RCConnectionStatus.DisConnected:
   //
   //      break;
   //    case RCConnectionStatus.KickedByOtherClient:
   //
   //      break;
   //    case RCConnectionStatus.NetworkUnavailable:
   //
   //      break;
   //    case RCConnectionStatus.TokenIncorrect:
   //
   //      break;
   //    case RCConnectionStatus.UserBlocked:
   //
   //      break;
   //    case RCConnectionStatus.Timeout:
   //
   //      break;
   //    case RCConnectionStatus.Suspend:
   //      break;
   //    default:
   //      throw FormatException('Unknown Status');
   // }
   //触发通知
    _triggerNotification(currentStatus);
  }
  void _triggerNotification(int currentStatus){
    var notifier = _callChain[currentStatus];
    notifier.value = true;
  }
  @override
  void registerNotificationForStatus<T extends RCStatusDelegate>(int status, T target) {
    assert((status>=RCConnectionStatus.Connected&&status<=RCConnectionStatus.DisConnected)||(status>=RCConnectionStatus.Suspend&&status<=RCConnectionStatus.Timeout));
    RCStatusDelegate tt = target;
    ValueNotifier nf = _callChain[status];
    //添加唯一性的回调闭包
    nf.addListener(_uniqueClosure(target,status));
    if (_listeners[tt] == null){
       Set _set = Set();
      _listeners[tt] = _set;
    }
    _listeners[tt].add(status);
  }
  //生成和RCStatusDelegate对应的closure
  VoidCallback _uniqueClosure(RCStatusDelegate target,int status){
    if (!_listeners.containsKey(target)){
       _closures[target] = (){
       target.statusChangeNotification(status);
     };
    }
    return _closures[target];
  }
  @override
  void cancelNotifications<T extends RCStatusDelegate>(T target) {
    Set _statuses = _listeners[target];
     _statuses.forEach((element) {
       int key = element;
       _callChain[key].removeListener(_uniqueClosure(target,element));
     });
    _remove_A_Listener(target);
  }

  @override
  void cancelSpecificNotification<T extends RCStatusDelegate>(int status, T target) {
    _callChain[status].removeListener(_uniqueClosure(target,status));
    _remove_A_Listener(target);
  }
  //移除一个监听者
  void _remove_A_Listener<T extends RCStatusDelegate>(T target){
    _listeners.remove(target);
  }
}
