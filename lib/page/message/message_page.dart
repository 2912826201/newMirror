

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/Message/message_ui_related.dart';
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

class _MessagePageState extends State<MessagePage> implements MPBasements,MPBusiness,MPHookFunc,MPNetworkEvents,MPUIActionPortal,MessageObserver {
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
    //setState(){}方法调用事件
    if (identifier == _MessagePageUiProvider.FuncOf_setState_){
      setState(() {
      });
    }
    //点赞和评论等事件
    else if(identifier == _MessagePageUiProvider.FuncOfinterCourses){
      if(payload != null&&payload[_MessagePageUiProvider.IntercoursesKey]!=null){
        MPIntercourses t = payload[_MessagePageUiProvider.IntercoursesKey];
        switch(t){
          case MPIntercourses.Thumb:
          // TODO: implement MPIntercourses.Thumb
            break;
          case MPIntercourses.At:
          // TODO: implement MPIntercourses.At
            break;
          case MPIntercourses.Comment:
          // TODO: implement MPIntercourses.Comment
            break;
        }
      }
    }
    //聊天cell的点击
    else if (identifier == _MessagePageUiProvider.FuncOfCellTap){
      // TODO: implement _MessagePageUiProvider.FuncOfCellTap
    }
    //导航栏按钮点击
    else if (identifier == _MessagePageUiProvider.FuncOfNaviBtn){
      // TODO: implement _MessagePageUiProvider.FuncOfNaviBtn
    }
    //跳转去处理网络
    else if (identifier == _MessagePageUiProvider.FuncOfHandleNet){
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNet
    }
    //跳转去处理通知
    else if (identifier == _MessagePageUiProvider.FuncOfHandleNotify){
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNotify
    }

  }
  //需要进行振动等事件
  @override
  void feedBackForSys() {
    // TODO: implement sysfeedBack
  }

 

}

//ui绑定的函数出口
abstract class MPUIActionPortal {
  void action(String identifier,{payload:Map});
}
//消息页面的ui代理类
class _MessagePageUiProvider implements MPUiProxy{
  //交互事件代理
  MPUIActionPortal delegate;
  //在_actionsDispatch（）中的相关函数关联字符
  //navibar上的点击
  static const String FuncOfNaviBtn = "funcOfNaviBtn";
  //点击了点赞、评论按钮的事件
  static const String FuncOfinterCourses = "funcOfinterCourses";
  //为上面⬆️提到的函数作区分
  static const String IntercoursesKey = "intercourcesKey";
  //会话cell的点击
  static const String FuncOfCellTap = "funcOfCellTap";
  //和setState(）函数关联
  static const String FuncOf_setState_ = "funcOf_setState_";
  //和跳转去管理网络的页面的函数有关
  static const String FuncOfHandleNet = "FuncOfHandleNet";
  //和跳转去准许消息提示页面有关
  static const String FuncOfHandleNotify = "FuncOfLocalNotify";
  // 是否选择展示一些banner
  //是否展示网络问题横幅
  bool _badNetBannerShow = false;
  //是否展示系统通知提醒的横幅
  bool _sysNotificationBannerShow = false;
  //浮点数最大值
  final _infinity = double.infinity;
  //交互事件外发
  _actionsDispatch(String identifier,{payload:Map}){
    if(delegate != null){
      delegate.action(identifier,payload: payload);
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
              child: FlatButton(onPressed: _actionsDispatch(FuncOfNaviBtn),
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
      //网络情况横幅
      loseConnectionBanner(),
      //点赞交互区域
      _interactiveAreas(),
      //需要进行消息提醒的横幅的显示
      notificationBanner(),
      //即时通讯相关的区域
     _imArea()
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
                onTap: _actionsDispatch(FuncOfinterCourses,payload: {IntercoursesKey:MPIntercourses.Comment}),
                badges: _badgesNum(0),),
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
                onTap: _actionsDispatch(FuncOfinterCourses,payload: {IntercoursesKey:MPIntercourses.At}),
                badges: _badgesNum(1),),)
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
              onTap: _actionsDispatch(FuncOfinterCourses,payload: {IntercoursesKey:MPIntercourses.Thumb}),
              badges: _badgesNum(2),)),
          ),
        ),
          flex: 1,)
      ],
    );
  }
  //提供点赞事件的未读数
  String _badgesNum(int index){
   return "9+";
  }

  //即时通讯相关的区域
  Widget _imArea(){
  return Container(color: Colors.green,
  height: 100,);
  }
  //断网时横幅
  @override
  Widget loseConnectionBanner(){
    return Offstage(
      offstage: _badNetBannerShow,
      child:GestureDetector(
        child: Expanded(
          child: Container(
            color: AppColor.mainRed.withOpacity(0.1),
            height: 36,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 17,right: 16),
            child: Row(
              children: [
                //"!"的显示
                Container(
                  alignment: Alignment.center,
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.22/2),
                      color: AppColor.mainRed.withOpacity(0.1),
                      border: Border.all(
                          width: 1,
                          color: AppColor.mainRed
                      )
                  ),
                  child: Text("!",style: TextStyle(color: AppColor.mainRed),),
                ),
                Container(child: Text("网络连接已断开，请检查网络设置",),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 6),
                ),
                Spacer(),
                Image.asset("images/resource/news_icon_arrow-red.png",width: 16,height: 16,)
              ],
            ),
          ),
        ),
        onTap: _actionsDispatch(FuncOfHandleNet),
      )
    );
  }
  //通知开启提醒的横幅
  @override
  Widget notificationBanner(){
    return Offstage(
      offstage: _sysNotificationBannerShow,
      child: GestureDetector(
        onTap: _actionsDispatch(FuncOfHandleNotify),
        child: Container(
          height: 56,
          color: Colors.grey,
          margin: EdgeInsets.only(left: 15,right: 15),
        ),
      ),
    );
  }
  ///////////////////
  //下面是可向本类发送消息的实现
  //////////////////
  @override
  void displayBadNetBanner(bool switchOn) {
     _badNetBannerShow = switchOn;
     _actionsDispatch(FuncOf_setState_);
  }

  @override
  void displaySysNotiBanner(bool switchOn) {
     _sysNotificationBannerShow = switchOn;
      _actionsDispatch(FuncOf_setState_);
  }
  
  @override
  void interCourseAction(MPBusiness eventType, {payload}) {
    // TODO: implement interCourseAction
  }

  @override
  void imFreshData(ChatCellModel model, {bool incomplete, int identifier, int index}) {
    // TODO: implement imFreshData
  }
}
//消息页面的会话数据源代理类
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