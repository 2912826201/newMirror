
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/notifier/rongcloud_connection_notifier.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';
//在融云状态管理类进行注册后的对象的需要实现的协议
abstract class RCStatusObservable{
  //状态回调
  void statusChangeNotification(int status);
  //暂存回调
}
// //融云连接状态（参考融云sdk的RCConnectionStatus）
//融云状态管理类，单例
abstract class RongCloudStatusManager{
  //上下文参数
  BuildContext context;
  //注册对某状态通知
  void registerNotificationForStatus<T extends RCStatusObservable >(int status,T target);
  //取消对某状态的通知
  void cancelSpecificNotification<T extends RCStatusObservable >(int status,T target);
  //取消所有通知
  void cancelNotifications<T extends RCStatusObservable >(T target);
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
    _rongCloudSdkStatusCoordinate();
    _alloc();
  }
  //融云回调
  _rongCloudSdkStatusCoordinate(){
    //和融云sdk状态回调挂钩
    RongIMClient.onConnectionStatusChange = (int connectionStatus){
      print("_rongCloudStatus $connectionStatus");
      // _statusChange(connectionStatus);
      //使用README.md文件中的ValueNotifier进行通知
      context.read<RongCloudStatusNotifier>().setTStatus(connectionStatus);
    };
  }
  //分配相关资源
  _alloc(){
    //根据sdk有的状态
    for(int i = RCConnectionStatus.Connected;i<=RCConnectionStatus.Timeout;i++)
    {
      //处理区间缺口
      if  (i>RCConnectionStatus.DisConnected&&i<RCConnectionStatus.Suspend) continue;
      var t =  ValueNotifier(0);
      _toNotifiers[i]=t;
    }
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!after alloc $_toNotifiers");
  }
  //回调集合，保存的是用于通知对象们的操作的集合
  Map<RCStatusObservable,Map<int,VoidCallback>> _closures = Map<RCStatusObservable,Map<int,VoidCallback>>();
  //保存需要进行通知的对象和它关心的状态集合及其映射关系
  List<RCStatusObservable> _listeners = List<RCStatusObservable>();
  //融云的状态和ValueNotifier对象的关系映射，valueNotifier用于通知关心这个状态的所有对象（利用closures中的闭包达到目的）
  Map<int,ValueNotifier> _toNotifiers = Map();
  //
  //状态变化回调
  void _statusChange(int currentStatus) {
    print("_statusChange");
   //触发通知
    _triggerNotification(currentStatus);
  }
  //触发通知
  void _triggerNotification(int currentStatus){
    print("_triggerNotification");
    var notifier = _toNotifiers[currentStatus];
    print("notifier $notifier");
    //简单地通过赋予初值来进行触发通知
    notifier.value = ++notifier.value;
  }
  //针对某一状态进行关注
  @override
  void registerNotificationForStatus<T extends RCStatusObservable>(int status, T target) {
    assert((status>=RCConnectionStatus.Connected&&status<=RCConnectionStatus.DisConnected)||(status>=RCConnectionStatus.Suspend&&status<=RCConnectionStatus.Timeout));
    RCStatusObservable tt = target;
    //设置回调
    VoidCallback callback =  _storeUniqueClosure(tt, status);
    //通知器
    ValueNotifier nf = _toNotifiers[status];
    //添加唯一性的回调闭包,闭包中包含触发通知行为
    nf.addListener((){
      callback.call();
    });
    //若在listener中没有此观察者则创建
    if (_listeners.contains(tt) == false){
      _listeners.add(tt);
    }
  }
  //设置回调
  VoidCallback _storeUniqueClosure(RCStatusObservable target,int status){
    print("_storeUniqueClosure $status");
    //如果为第一次注册监听则设置为其生成闭包
    if (!_listeners.contains(target)){
      Map<int,VoidCallback> map = Map<int,VoidCallback>();
      _closures[target] = map;
    }
    if(_closures[target][status]==null){
      //生成回调闭包
      VoidCallback  callback = (){
       if(target != null){
         target.statusChangeNotification(status);
       }
      };
       _closures[target][status] = callback;
     }
     return  _closures[target][status];
  }
  @override
  void cancelNotifications<T extends RCStatusObservable>(T target) {
     _closures[target].clear();
    _remove_A_Listener(target);
  }
  @override
  void cancelSpecificNotification<T extends RCStatusObservable>(int status, T target) {
    assert((status>=RCConnectionStatus.Connected&&status<=RCConnectionStatus.DisConnected)||(status>=RCConnectionStatus.Suspend&&status<=RCConnectionStatus.Timeout));
    _closures[target].remove(status);
  }
  //移除一个监听者
  void _remove_A_Listener<T extends RCStatusObservable>(T target){
    _listeners.remove(target);
  }
}
