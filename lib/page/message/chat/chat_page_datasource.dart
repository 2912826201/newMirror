import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'chat_page_interfaces/chat_page_interfaces.dart';

class ChatPageDataSource implements ChatDataSource{
  ChatDataSourceDelegate delegate;
  dynamic widget;
  //会话数据，含有本次会话标识等
  List<dynamic> models = List<dynamic>();

  ChatPageDataSource(Widget widget){
    this.widget = widget;
    _historicalMessage();
  }
  @override
  void eventArrives({payload}) {
    // TODO: implement eventArrives
  }
  //读取历史消息
   _historicalMessage() async{
    List result  = await RongIMClient.getHistoryMessages(widget.conversation.type, widget.conversation.conversationId, 0, 10, 10);
    models.addAll(result);
    print("add things to models ${result.length}");
    delegate.refreshList();
  }
  //发送一条消息出去
  @override
  void sendMessage({msg, String identifier}) {
    // TODO: implement sendMessage
  }
  //聊天的数据
  @override
  List sentences() {
    print("model's sentences count:${models.length}");
    return models;
  }



}