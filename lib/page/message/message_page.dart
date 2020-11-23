

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:mirror/widget/message/intercourse_widget.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'delegate/hooks.dart';
import 'delegate/message_types.dart';
import 'delegate/regular_events.dart';
import 'delegate/business.dart';
import 'delegate/content_generate.dart';
import 'delegate/frame.dart';
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//这个消息页面的构成如下：
//本页面State对象作controller,内置两个代理proxy，分别提供数据和ui，页面选择性响应若干总体性事件的发生
//ui部分采用代理方式将点击等事件转给此页面state对象处理，用字符串做区分
////
class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MessagePageState();
  }
}

class _MessagePageState extends State<MessagePage> implements MPBasements,MPInterCourses,MPHookFunc,MPNetworkEvents,MPUIActionPortal,MessageObserver {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width,height:44),
          uiProvider.navigationBar(),
          uiProvider.mainContent(),
        ],
      ),
    );
  }
  @override
  void initState() {
    _registrations();
    _allocations();
    super.initState();
  }
  
  //一些注册绑定类型的事情
  _registrations(){
    //考虑到此页面可能会涉及到消息到来时情景的处理,所以需要进行注册一下
    RongCloudReceiveManager.shareInstance().observeAllMsgs(this);
  }
  //初始化和分配资源的事情
  _allocations(){
    //UI代理和数据代理生成//
    //数据源
    dataSource = _MessagePageDataSource();
    //UI
    uiProvider = _MessagePageUiProvider();
    uiProvider.delegate = this;
  }
  @override
  MPDataSourceProxy dataSource;

  @override
  MPUiProxy uiProvider;

  @override
  void aChatArrived(MPChatVarieties type) {
    // TODO: implement aChatArrived
  }

  @override
  // ignore: non_constant_identifier_names
  void didDelete_a_Chat(MPChatVarieties type) {
    // TODO: implement didDelete_a_Chat
  }

  @override
  void regularEventsCall(MPIntercourses type) {
    // TODO: implement regularEventsCall
  }

  @override
  void viewDidAppear() {
    // TODO: implement viewDidAppear
  }

  @override
  void willDisappear() {
    // TODO: implement willFade
  }

  @override
  void eventsDidCome() {
    // TODO: implement eventsDidCome
  }



  @override
  void loseConnection() {
    // TODO: implement loseConnection
  }

  @override
  void reconnected() {
    // TODO: implement reconnected
  }

  @override
  void connecting() {
    // TODO: implement connecting
  }

  @override
  void activateNotification() {
    // TODO: implement activateNotification
  }

  @override
  void imArrived() {
    // TODO: implement imArrived
  }

  @override
  Future<void> msgDidCome(Set<Message> msg,bool offLine) {
    // TODO: implement msgDidCome
    throw UnimplementedError();
  }

  @override
  void action(String identifier, {payload = Map}) {
    // TODO: implement action
  }

 

}

//ui绑定的函数出口
abstract class MPUIActionPortal{
  void action(String identifier,{payload:Map});
}
//消息页面的ui代理类
class _MessagePageUiProvider implements MPUiProxy{
  MPUIActionPortal delegate;
  static const String funcOfNaviBtn = "funcOfNaviBtn";
  static const String funcOfCommentEvent = "funcOfCommentEvent";
  static const String funcOfLikesEvent = "funcOfLikesEvent";
  static const String funcOfAtEvent = "funcOfAtEvent";
  static const String funcOfCellTap = "funcOfCellTap";
  //浮点数最大值
  final _infinity = double.infinity;
  //交互事件外发
  _actionsDispatch(String identifier){
    if(delegate != null){
      delegate.action(identifier);
    }
  }
  //顶部栏
  @override
  Widget navigationBar(){
  return Container(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Container(
              height: 44,
            ),flex: 1,),
            Container(
              height: 28,
              width: 28,
              child: FlatButton(onPressed: _actionsDispatch(funcOfNaviBtn),
               child: Container(child: Image.asset("images/resource/Nav_search_icon .png",
                fit:BoxFit.fill),),
                minWidth: 28,
                height: 28,
                padding: EdgeInsets.all(0),
            ),
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.only(top: 6.5,bottom: 9.5,right: 16),
            )
          ]
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text("消息",
                  style: TextStyle(fontFamily: "PingFangSC",
                      fontSize: 18,
                      decoration: TextDecoration.none,fontWeight: FontWeight.w500),),
                margin: EdgeInsets.only(left: 44,right: 44),
              )
            ],
          ),
          height: 44,
        )
      ],
    )
  );
  }
  //页面主要内容
  @override
  Widget mainContent(){
  return Column(
    children: [
      //点赞交互区域
     _interactiveAreas(),

    ],
  );
  }

  //点赞交互区域
  Widget _interactiveAreas(){
    return  Row(
      //横向排列交互区域
      children: [
        Expanded(child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              child: Center(child: MPIntercourseWidget(title: Text("评论",
                style: TextStyle(color: AppColor.textPrimary1,
                    fontFamily: "PingFangSC",
                    fontSize: 16,
                    fontWeight:FontWeight.w400 ,
                    decoration: TextDecoration.none),),
                onTap: _actionsDispatch(funcOfCommentEvent),
                badges: "1+",),
              ),)
        ),
          flex: 1,),
        Expanded(child: AspectRatio(
          aspectRatio: 1,
          child: Container(
              child: Center(child: MPIntercourseWidget(title: Text("@我",
                style: TextStyle(color: AppColor.textPrimary1,
                    fontFamily: "PingFangSC",
                    fontSize: 16,
                    fontWeight:FontWeight.w400 ,
                    decoration: TextDecoration.none),),
                onTap: _actionsDispatch(funcOfAtEvent),
                badges: "1+",),)
          ),
        ),
          flex: 1,),
        Expanded(child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            child: Center(child: MPIntercourseWidget(title: Text("点赞",
              style: TextStyle(color: AppColor.textPrimary1,
                  fontFamily: "PingFangSC",
                  fontSize: 16,
                  fontWeight:FontWeight.w400 ,
                  decoration: TextDecoration.none),),
              onTap: _actionsDispatch(funcOfLikesEvent),
              badges: "1+",)),
          ),
        ),
          flex: 1,)
      ],
    );
  }
  //即时通讯相关的区域
  Widget _imArea(){

  }
  //断网时横幅
  @override
  Widget loseConnectionBanner(){

  }
  //通知开启提醒的横幅
  @override
  Widget notificationBanner(){

  }
  //突发型横幅（位于聊天列表上方）
  @override
  Widget emergentBanner(){

  }
}
//消息页面的数据源代理类
class _MessagePageDataSource implements MPDataSourceProxy{
  //会话数据源
  @override
  List chats(){

  }
  //点赞、评论ui的数据源
  @override
  List operations(){
    
  }
}