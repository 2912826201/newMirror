import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin/src/info/message.dart';
import 'chat_page_interfaces/chat_page_interfaces.dart';
import 'chat_page_datasource.dart';
import 'chat_page_ui.dart';
////////////////////////////////
//
/////////////聊天会话页面
//
///////////////////////////////


//聊天界面 私聊、群聊
class ChatPage extends StatefulWidget{
  //会话的数据model
  final ConversationDto conversation;
  ChatPage({Key key, @required this.conversation}):super(key: key);
  final _ChatPageState _state = _ChatPageState();
  @override
  State<StatefulWidget> createState() {
   return _state;
  }
}

class _ChatPageState extends State<ChatPage> implements MessageObserver,ChatUiDelegate,ChatDataSourceDelegate{
  //ui
  ChatUI ui;
  //数据源
  ChatDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
        children: [
            ui.eyebrowBar(context),
            ui.navigationBar(),
            ui.mainContent(),
            ui.inputArea(),
            ui.chinBar(context)
        ],
        ),
      ),
    );
  }

  @override
  void initState() {
    print("chatPage conversationType is ${this.widget.conversation.type}");
    //对融云相关类型消息进行观察
    //FIXME:暂时未私聊消息
    RongCloudReceiveManager.shareInstance().observeSpecificTypeMsg(RCConversationType.Private, this);
    ui =  ChatPageUi();
    ui.actions_dataSource = this;
    dataSource = ChatPageDataSource(this.widget);
    dataSource.delegate = this;
    super.initState();
  }
  //////////////////////////////
  ///////////////////////////
  ///////////////////////////
  //融云回调
  @override
  Future<void> msgDidCome(Set<Message> msg, bool offLine) {
    print("消息数据已经到达了聊天页面");
  }
  //////////////////////
  //////////////////////
  ////////////////////
  @override
  void dispose() {
    //取消注册
    RongCloudReceiveManager.shareInstance().removeObserver(this);
    super.dispose();
  }
  //导航栏图标
  @override
  String navigationBarTitle() {
    return this.widget.conversation.name;
  }
 //UI事件源
  @override
  void uiEvent({String identifier,dynamic paylaod}) {
    switch(identifier){
      case ChatPageUi.popAction:
        Navigator.of(context).pop();
        break;
      case ChatPageUi.moreAction:
        throw UnimplementedError("more action hasn't complete in Chat_page class: uiEvent() function");
        break;
    }
  }
  //datasource的事件
  @override
  void NewMesage(msg, MsgContentType type) {
    // TODO: implement NewMesage
  }
  //数据代理
  @override
  ChatDataSourceDelegate delegate;


  @override
  void eventArrives({payload}) {
    // TODO: implement eventArrives
  }
  //发送一条消息
  @override
  void sendMessage({msg, String identifier}) {
    // TODO: implement sendMessage
  }
  //列表数据
  @override
  List sentences() {
   return dataSource.sentences();
  }
  //取得widget属性
  @override
  dynamic getWidget() {

    return this.widget;
  }
  //刷新列表
  @override
  void refreshList() {
    print("chat_page setState");
    setState(() {
    });
  }
}

