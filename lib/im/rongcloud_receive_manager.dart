//融云消息接收类,单例
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
//监听消息来到的回调
abstract class MessageObserver{
  //当注册通知后会受到的消息,第二个参数表示的是是否离线
  Future<void> msgDidCome(Set<Message> msg,bool offLine);
}
// RCSentStatus 
// static const int Sending = 10; //发送中
//   static const int Failed = 20; //发送失败
//   static const int Sent = 30; //发送成功
//   static const int Received = 40; //对方已接收
//   static const int Read = 50; //对方已阅读

//消息状态的观察接口,需要先在RongCloudReceiveManger中相关方法中注册
abstract class MessageStatusObserver{
  //可有的消息状态回调，status参考[RCSentStatus]
  Future<void> msgStatus(int msgId,int status);
}
abstract class RongCloudReceiveManager {
  //获取单例
  static RongCloudReceiveManager shareInstance(){
    if (_me==null){
      _me = _RongCloudReceiveManager();
    }
    return _me;
  }
  //发送私聊消息
  Future<Message> sendPrivateMessage(String targetId,MessageContent content);
  //发送群聊消息
  Future<Message> sendGroupMessage(String targetId,MessageContent content);
  //发送
  //观察所有消息来临的通知(一般情况下是这个函数被使用，关注私聊群聊系统聊等所有类型的信息，否则使用其他下面的函数，可以提高效率)
  void observeAllMsgs<T extends MessageObserver>(T target);
  //观察特点类型消息来临，参数值域参考RCConversationType(例如：私聊、群聊、系统聊天)
  void observeSpecificTypeMsg<T extends MessageObserver>(int conversationType,T target);
  //取消某种消息类型消息来临的通知
  void ignoreSpecificTypeMsg<T extends MessageObserver>(int conversationType,T target);
  //观察某条消息的状态
  void observeMsgStatus<T extends MessageStatusObserver>(int msgId, T target);
  static RongCloudReceiveManager _me;
  //是否开启离线消息缓冲
  activeBuffer(bool activate);
}
//融云的离线消息具有保质期，一般为7天。所以对于系统消息来说这是不可靠的，我们需要确保系统、官方消息是可靠的，
// 所以需要针对这类消息以服务端的为准，而不是以融云服务器的为准，但在这里的确是只处理来自融云的消息。
class _RongCloudReceiveManager extends RongCloudReceiveManager{
  static bool _activeBuffer = true;
   _RongCloudReceiveManager(){
     _init();
   }
   //初始化工作
   _init(){
     _rongCloudMessageResponse();
    _alloc();
   }
  //融云回调
   _rongCloudMessageResponse(){
     //第二个参数表示的是还剩下的未取的消息数量，第三个参数表示是否是按照包的形势拉取的信息，第三个参数表示的是是否是离线消息
     RongIMClient.onMessageReceivedWrapper = (Message msg, int left, bool hasPackage, bool offline) {
       switch (offline){
         case true:
           _processOffLineRawMsg(msg, left, hasPackage);
           break;
         default:
           _processCurrentRawMsg(msg,left);
       }
     };
     //发送消息结果的回调
     RongIMClient.onMessageSend = (int messageId,int status,int code) {
       Set<MessageStatusObserver> _t = _msgs[messageId];
            _t.forEach((element) async{
              await element.msgStatus(messageId, status);
            });
            if (status==RCSentStatus.Read){
              _msgs.remove(messageId);
            }
     };
   }
   //分配资源
   _alloc(){
     for(int i= RCConversationType.Private;i<=RCConversationType.System;i++){
       Set _set =Set<MessageObserver>();
       _observers[i] = _set;
     }
   }
   //处理离线消息,需要使用到Stream和异步的支持等(但是最好做成可选的),
   //第三个参数表示是否以包的方式从服务端取数据，
   // SDK 拉取服务器的消息以包( package )的形式批量拉取，有 package 存在就意味着远端服务器还有消息尚未被 SDK 拉取
   void _processOffLineRawMsg(Message msg,int left,bool hasPackage){
     switch(_RongCloudReceiveManager._activeBuffer){
       case true:
         //使用缓冲的情况
       _cacheOrDrain((left==0&&hasPackage==false),msg,left);
         break;
       default:
         //不使用缓存的情况
         _messageDispatchWithType(msg,true);
     }
   }
   //缓存以及清空
   void _cacheOrDrain(bool drain,Message msg,int left){
     //单个离线信息无需缓冲
     if (left == 0&&_tempCache.isEmpty){
       _messageDispatchWithType(msg,true);
       int msgType = msg.conversationType;
       Set _toNotify = _observers[msgType];
       Set<Message> _singleSet = Set<Message>();
       _singleSet.add(msg);
       //直接转发通知出去
       _toNotify.forEach((element) async {
         MessageObserver tt = element;
         await tt.msgDidCome(_singleSet, true);
       });
       return;
     }
     //大于一个通知的情况
     switch (drain){
       case true:
         _drainCache(msg: msg);
         break;
       default:
         _cache(msg);
     }
   }
   //清空消息缓存池
    _drainCache({Message msg}){
     if (msg != null) {
       _tempCache.add(msg);
     }
     _classifyMessagesAndDispatch(_tempCache);
     _tempCache.clear();
    }
    //缓存消息
    _cache(Message msg){
      _tempCache.add(msg);
    }
    //离线消息缓冲池
    Set<Message> _tempCache = Set<Message>();
    //无人监听的消息缓冲池子
    Set<Message> _nonAdaptableMsg = Set<Message>();
    //消息监听者信息保存
    Map<int,Set<MessageObserver>> _observers = Map();
    // ignore: slash_for_doc_comments
    /**class Message extends Object {
       int conversationType; //会话类型 参见 RCConversationType
       String targetId; //会话 id
       int messageId; //messageId ，本地数据库的自增 id
       int messageDirection; //消息方向 参见 RCMessageDirection
       String senderUserId; //发送者 id
       int receivedStatus; //消息接收状态 参见 RCReceivedStatus
       int sentStatus; //消息发送状态 参见 RCSentStatus
       int sentTime; //发送时间，unix 时间戳，单位毫秒
       String objectName; //消息 objName
       MessageContent content; //消息内容
       String messageUId; //消息 UID，全网唯一 Id
       String extra; // 扩展信息
       bool canIncludeExpansion; // 消息是否可以包含扩展信息
       Map expansionDic; // 消息扩展信息列表
       ReadReceiptInfo readReceiptInfo; //阅读回执状态
       MessageConfig messageConfig; // 消息配置
       //如果 content 为 null ，说明消息内容本身未被 flutter 层正确解析，则消息内容会保存到该 map 中
       Map originContentMap;*/
    //处理当前消息，第二个参数为服务端的剩余消息
   _processCurrentRawMsg(Message msg,int left){
    _messageDispatchWithType(msg,false);
   }
   @override
   void ignoreSpecificTypeMsg<T extends MessageObserver>(int conversationType, T target) {
      assert(conversationType>=RCConversationType.Private&&conversationType<=RCConversationType.System);
      _observers[conversationType].remove(target);
   }
   @override
   void observeSpecificTypeMsg<T extends MessageObserver>(int conversationType, T target) {
     assert(conversationType>=RCConversationType.Private&&conversationType<=RCConversationType.System);
     _observers[conversationType].add(target);
     //如果在注册时，已经有消息提前到达，则对其下发清空
     if(_nonAdaptableMsg.isNotEmpty){
       Set<Message> _t = Set<Message>();
       _classifyMessagesAndDispatch(_nonAdaptableMsg);
        _nonAdaptableMsg.removeAll(_t);
     }
   }
    //开启或关闭缓冲
    @override
    activeBuffer(bool activate) {
    switch(activate){
      case false:
        if(_tempCache.isEmpty==false){
          _drainCache();
        }
        break;
      default:
    }
    _activeBuffer = activate;
  }
  //将不同种类的消息打包发送(于函数_drainCache()清空缓存池时发生)
   _classifyMessagesAndDispatch(Set<Message> msgs){
    Map<int,Set<Message>> typeStreams = Map();
    msgs.forEach((element) {
      if(!typeStreams.keys.contains(element.conversationType)){
        Set<Message> bag = Set();
        typeStreams[element.conversationType] = bag;
      }
      typeStreams[element.conversationType].add(element);
     });
     typeStreams.forEach((key, value) {
      _messageStreamDispatchWithType(value, key);
    });
  }
  //同一种类型的消息流的发送（肯定是离线消息，只有离线消息才会打包下发）
   _messageStreamDispatchWithType(Set<Message> msgs,int type){
     Set _toNotify = _observers[type];
     if (_toNotify.isEmpty){
       _tempStorage(msgs);
       return;
     }
     _toNotify.forEach((element) async {
       MessageObserver tt = element;
       if(tt == null) {
         //null对象沉默
         _toNotify.remove(tt);
       }else{
         await tt.msgDidCome(msgs, true);
       }
     });
   }
  //单个消息出口下发（只会发生在在线消息以及单个的离线消息的情况）
   _messageDispatchWithType( Message msg, bool offline)  {
   int msgType = msg.conversationType;
   Set<MessageObserver> _toNotify = _observers[msgType];
   Set<Message> _set = Set<Message>();
   _set.add(msg);
   //暂时无需要通知的对象时需要将消息暂存
   if(_toNotify.isEmpty){
     Set<Message> _set = Set<Message>();
     _set.add(msg);
     _tempStorage(_set);
     return;
   }
   _toNotify.forEach((element) async {
      MessageObserver tt = element;
      if(tt == null) {
        //null对象沉默
        _toNotify.remove(tt);
      }else {
        await tt.msgDidCome(_set, offline);
      }
   });
  }
   //当此种消息还没有观察者时触发这里
   _tempStorage(Set<Message> msgs){
      _nonAdaptableMsg.addAll(msgs);
   }
   //需要观察消息状态改变的观察者的集合，按照它们关心的消息类别进行了分类扎堆
   Map<int,Set<MessageStatusObserver>> _msgs = Map();
   //消息状态的观察
   @override
   void observeMsgStatus<T extends MessageStatusObserver>(int msgId, T target) {
    _msgs[msgId].add(target);
   }
   //
   @override
   void observeAllMsgs<T extends MessageObserver>(T target) {
    this.observeSpecificTypeMsg(RCConversationType.Private, target);
    this.observeSpecificTypeMsg(RCConversationType.Group, target);
    this.observeSpecificTypeMsg(RCConversationType.System, target);
    // this.observeSpecificTypeMsg(RCConversationType.ChatRoom, target);
  }

  @override
  Future<Message> sendGroupMessage(String targetId,MessageContent content) {
    // TODO: implement sendGroupMessage
    throw UnimplementedError();
  }

  @override
  Future<Message> sendPrivateMessage(String targetId,MessageContent content)  async{
     Message msh = await  RongIMClient.sendMessage(RCConversationType.Private, targetId, content);
   return msh;
  }
}