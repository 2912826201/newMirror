import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/Message/message_ui_related.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:mirror/widget/message/chatcell.dart';
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
//本页面State对象作controller,内置两个proxy，分别提供数据和ui，页面选择性地变化ui时，向ui的这一个proxy发送消息（见UIProxy接口）
//ui部分采用其dataActionPipe属性，通过代理方式将点击等事件转给此页面state对象处理，用字符串做区分(见MPUIAction接口)
//UI的数据是通过也通过dataActionPipe属性从本页面处的controller获取(实际是间接地从数据proxy出来，经过controller处置过后)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MessagePageState();
  }
}

class _MessagePageState extends State<MessagePage>
    implements MPBasements, MPBusiness, MPHookFunc, MPNetworkEvents, MPUIActionAndDataPipe,MPIMDataSourceAction, MessageObserver {
  List imData = List();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            //需要为状态栏留出空隙
            SizedBox(width: MediaQuery.of(context).size.width, height: 44),
            uiProvider.navigationBar(),
            uiProvider.mainContent(),
          ],
        ),
      ),
    );
   }

    @override
    void initState() {
    _registrations();
     _allocations();
     //根据安排需要放在initState方法中
     this.viewWillAppear();
     super.initState();
   }

   //一些注册绑定类型的事情
   _registrations() {
    //考虑到此页面可能会涉及到消息到来时情景的处理,所以需要进行注册一下
    RongCloudReceiveManager.shareInstance().observeAllMsgs(this);
   }
   //数据proxy
   @override
   MPDataSourceProxy dataSource;
   //ui_proxy
   @override
   MPUiProxy uiProvider;
    //需要进行振动等向controller反馈的事件
    @override
    void feedBackForSys() {

    }
   //初始化和分配资源的事情
    _allocations() {
    //UI代理和数据代理生成//
    //数据源
    dataSource = _MessagePageDataSource();
    //UI
    uiProvider = _MessagePageUiProvider();
    //用于交互事件的反馈以及ui显示需要数据的提供
    uiProvider.dataActionPipe = this;
    dataSource.delegate = this;
    }
  
   //当有及时消息来临时调用
    @override
    void aChatArrived(MPChatVarieties type) {
      // TODO: implement aChatArrived
    }
   //当删除一个会话cell时调用
    @override
    // ignore: non_constant_identifier_names
    void didDelete_a_Chat(MPChatVarieties type) {
     // TODO: implement didDelete_a_Chat
    }
   //发生点赞、评论、@事件时
    @override
    void regularEventsCall(MPIntercourses type) {
    // TODO: implement regularEventsCall
    }
    //视图第一次出现时，在flutter中对应是在build中
    @override
    void viewWillAppear() {
   
    }

   //当转去其他视图界面时(目前暂时放在dispose方法中)
    @override
    void willDisappear() {

    }
    @override
    void dispose() {
    this.willDisappear();
    super.dispose();
   }
   // 下方均为向ui发送消息来处理对应事件，虽然本质上还是
   // ui将消息代理出来本controller处理，但是可以给ui本身一次处理事件的机会，让controller内部
   // 事件处理相对清晰一些

   //当网络连接丢失时，向ui源发送对应消息使其变化，
   @override
   void loseConnection() {
    uiProvider.reconnected();
   }
   //进行再连接时
    @override
    void reconnected() {
    uiProvider.reconnected();
   }
   //连接中时
   @override
   void connecting() {
    uiProvider.connecting();
   }
   //检测到需要开启系统通知后调用
   @override
   void activateNotificationBanner() {
    uiProvider.activateNotificationBanner();
   }
   //检测到系统通知已经被打开，需要关闭开启通知的横幅
   @override
   void dismissNotificationBanner() {
    uiProvider.dismissNotificationBanner();
   }
   ////////////////////////////////////
   //MPBusiness内协议（接口）
   ////////////////////////////////////
    //社交事件到来时调用（通常是调取服务器接口发现未读数不为0）
    @override
    void eventsDidCome() {

    }

   @override
   void imArrived() {

   }

   //////////////////////////////////////
   /////////////////////////////////////

   //  -------------------代理------------------------//
   //融云消息的注册的新消息来临的回调，可以选择性去调用imArrived()去执行ui上的变化
   @override
   Future<void> msgDidCome(Set<Message> msg, bool offLine) {
      print("msgDidCome+${msg}");
      print(msg.hashCode);
      //调取一下页面的消息来临的函数，让页面本身做一些处理
      this.imArrived();
      //只有一条消息的情况，一般即为及时的消息
      if (msg.length == 1){
       _manipulateRegularMsg(msg.first);
      }
      //以消息集合的方式处理，一般为离线消息的来临
      else{
      _manipulateOffLineMessage(msg);
      }
   }

   //单个在线信息来到的处理
   void _manipulateRegularMsg(Message msg){
      Set<Message> _t = Set<Message>();
      _t.add(msg);
      dataSource.newMsgsArrive(_t);
      uiProvider.imFreshData();
   }
   //列表性离线信息的来临
   void _manipulateOffLineMessage(Set<Message> msgs){
    dataSource.newMsgsArrive(msgs);
   }
   //UI源发送来的交互事件
   @override
   void action(String identifier, {payload = Map}) {
    //setState(){}方法调用事件
    if (identifier == _MessagePageUiProvider.FuncOf_setState_) {
      setState(() {});
    }
    //点赞和评论等事件
    else if (identifier == _MessagePageUiProvider.FuncOfinterCourses) {
      if (payload != null && payload[_MessagePageUiProvider.IntercoursesKey] != null) {
        MPIntercourses t = payload[_MessagePageUiProvider.IntercoursesKey];
        switch (t) {
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
    else if (identifier == _MessagePageUiProvider.FuncOfCellTap) {
      // TODO: implement _MessagePageUiProvider.FuncOfCellTap
    }
    //导航栏按钮点击
    else if (identifier == _MessagePageUiProvider.FuncOfNaviBtn) {
      // TODO: implement _MessagePageUiProvider.FuncOfNaviBtn
    }
    //跳转去处理网络
    else if (identifier == _MessagePageUiProvider.FuncOfHandleNet) {
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNet
    }
    //跳转去处理通知
    else if (identifier == _MessagePageUiProvider.FuncOfHandleNotify) {
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNotify
    }
  }

   //给聊天cell提供数据
   @override
   List<ChatModel> imCellData() {
   return dataSource.imCellData();
   }
   //及时会话的高度的ui代理
   @override
   double cellHeightAtIndex(int index) {
    return dataSource.cellHeightAtIndex(index);
   }
   //社交事件未读数
   @override
   Map<MPIntercourses, int> unreadOfIntercources() {
   return dataSource.unreadOfIntercources();
   }

  @override
  void newMsgsArrive(Set<Message> msgs) {
    // TODO: implement newMsgsArrive
  }

  @override
  void signals({Map<String,dynamic> payload}) {
    // TODO: implement dataFlow
  }

   //-------------------------------------------------------------------//
}
 //即时消息数据源
 abstract class MPIMDataSource{
  void newMsgsArrive(Set<Message> msgs);
  //返回即时聊天的数据集
  List<ChatModel>  imCellData();
  double cellHeightAtIndex(int index);
 }
 //社交事件未读数数据源
 abstract class MPInterCourcesDataSource{
  Map<MPIntercourses,int> unreadOfIntercources();
 }
 //消息界面的点击等事件
 abstract class MPUIAction {
 void action(String identifier, {payload: Map});
 }
 //ui绑定的函数出口接口
 abstract class MPUIActionAndDataPipe implements MPIMDataSource,MPUIAction,MPInterCourcesDataSource{
 }
 //消息页面的ui代理类
 class _MessagePageUiProvider implements MPUiProxy {
  //交互事件及数据代理
  MPUIActionAndDataPipe dataActionPipe;
  //在_actionsDispatch（）中的相关函数关联字符
  //navibar上的点击
  static const String FuncOfNaviBtn = "funcOfNaviBtn";

  //点击了点赞、评论按钮的事件
  static const String FuncOfinterCourses = "funcOfinterCourses";

  //为上面⬆️提到的函数在payload中作区分
  static const String IntercoursesKey = "intercourcesKey";

  //会话cell的点击
  static const String FuncOfCellTap = "funcOfCellTap";
  //为上面⬆️提到的函数在payload中作区分
  static const String CellTapKey = "CellTapKey";
  //和setState(）函数关联
  static const String FuncOf_setState_ = "funcOf_setState_";

  //和跳转去管理网络的页面的函数有关
  static const String FuncOfHandleNet = "FuncOfHandleNet";

  //和跳转去准许消息提示页面有关
  static const String FuncOfHandleNotify = "FuncOfLocalNotify";

  //消息界面的组成版块，为三个板块，无数据时的页面构成也为三，但是末尾的index=2时分为两种情况
  final int consistsOfMP = 3;

  // 是否选择展示一些banner
  //是否展示网络问题横幅的开关量
  bool _badNetBannerShow = false;

  //是否展示系统通知提醒的横幅
  bool _sysNotificationBannerShow = false;
  
  //交互事件外发
  _actionsDispatch(String identifier, {payload: Map}) {
    if (dataActionPipe != null) {
      dataActionPipe.action(identifier, payload: payload);
    }
  }

  //顶部栏
  @override
  Widget navigationBar() {
    return Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
             Expanded(
              child: Container(
              height: 44,
            ),
              flex: 1,
          ),
             Container(
              height: 28,
              width: 28,
              child: FlatButton(
               onPressed: _actionsDispatch(FuncOfNaviBtn),
               child: Container(
                child: Image.asset("images/resource/Nav_search_icon .png", fit: BoxFit.fill),
              ),
              minWidth: 28,
              height: 28,
              padding: EdgeInsets.all(0),
            ),
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.only(top: 6.5, bottom: 9.5, right: 16),
          )
        ]),
         Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  "消息",
                  style: TextStyle(
                      fontFamily: "PingFangSC",
                      fontSize: 18,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500),
                ),
                margin: EdgeInsets.only(left: 44, right: 44),
              )
            ],
          ),
          height: 44,
        )
      ],
    ));
  }

  //页面主要内容
  @override
  Widget mainContent() {
     //外层是一个column所以需要使用Expanded
    return Expanded(child: Column(
      children: [
         //网络状态横幅不跟随滑动
          loseConnectionBanner(),
         //除去网络横幅以外的区域
        Expanded(child: ListView.builder(
          //大致分为3个区域
          //尾部减一是因为thisConsitsOfMp和dataActionPipe.imCellData().length有一个单位的重合
          itemCount: this.consistsOfMP + (dataActionPipe.imCellData().length-1),
          itemBuilder: (BuildContext context, int index) {
           //点赞交互区域
           if(index == 0){
           return  _interactiveAreas();
           }
           //需要进行消息提醒的横幅的显示
            else if (index ==1){
             return notificationBanner();
           }
            //即时通讯会话显示区域
            else {
            return  _imArea(index);
            }
           },
           //ListView的内边距需要设置为0
           padding: EdgeInsets.all(0),
           //不要回弹效果
           physics: ClampingScrollPhysics(),
          )),
      ],
    ));
  }

  //点赞交互区域
  Widget _interactiveAreas() {
    return Row(
      //横向排列交互区域
      children: [
        Expanded(
          child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                child: Center(
                  child: MPIntercourseWidget(
                    title: Text(
                      "评论",
                      style: TextStyle(
                          color: AppColor.textPrimary1,
                          fontFamily: "PingFangSC",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none),
                    ),
                    onTap: _actionsDispatch(FuncOfinterCourses, payload: {IntercoursesKey: MPIntercourses.Comment}),
                    badges: _badgesNum(MPIntercourses.Comment),
                  ),
                ),
              )),
          flex: 1,
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                child: Center(
              child: MPIntercourseWidget(
                title: Text(
                  "@我",
                  style: TextStyle(
                      color: AppColor.textPrimary1,
                      fontFamily: "PingFangSC",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none),
                ),
                onTap: _actionsDispatch(FuncOfinterCourses, payload: {IntercoursesKey: MPIntercourses.At}),
                badges: _badgesNum(MPIntercourses.At),
              ),
            )),
          ),
          flex: 1,
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              child: Center(
                  child: MPIntercourseWidget(
                   title: Text(
                  "点赞",
                  style: TextStyle(
                      color: AppColor.textPrimary1,
                      fontFamily: "PingFangSC",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none),
                ),
                onTap: _actionsDispatch(FuncOfinterCourses, payload: {IntercoursesKey: MPIntercourses.Thumb}),
                badges: _badgesNum(MPIntercourses.Thumb),
              )),
            ),
          ),
          flex: 1,
        )
      ],
    );
  }

  //提供点赞事件的未读数
  int _badgesNum(MPIntercourses type) {
    return dataActionPipe.unreadOfIntercources()[type];
  }

  //即时通讯会话相关的区域,因为本身为一个ListView的item，所以需要高度
  Widget _imArea(int index) {
    //数据源没有数据的时候显示展位图
    if(dataActionPipe.imCellData().length == 0){
      return placeholderWhenNoData();
    }
    //三个板块中需要减去代表会话cell总体作为一部分的"1"
    int expectedIndex = index - (this.consistsOfMP-1) ;
    //构建单个cell的过程
    return Row(children:
    [
      Expanded(child:
       GestureDetector(
         //绑定点击事件，传参需要一个索引位置
         onTap: _actionsDispatch(FuncOfCellTap,payload: {CellTapKey:expectedIndex}),
         child: Container(child:
          MPChatCell(model: dataActionPipe.imCellData()[expectedIndex],),
          color: Color.fromRGBO(expectedIndex*15, expectedIndex*10, expectedIndex*11, 0.5),
          height: dataActionPipe.cellHeightAtIndex(expectedIndex),),
      )
      )
    ],
    );
  }

  //断网时横幅生成
  @override
  Widget loseConnectionBanner() {
    return Offstage(
        offstage: _badNetBannerShow,
        child: GestureDetector(
          child:Row(
            children: [
              Expanded(
                child: Container(
                  color: AppColor.mainRed.withOpacity(0.1),
                  height: 36,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 17, right: 16),
                  child: Row(
                    children: [
                      //"!"的显示
                      Container(
                        alignment: Alignment.center,
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.22 / 2),
                            color: AppColor.mainRed.withOpacity(0.1),
                            border: Border.all(width: 1, color: AppColor.mainRed)),
                        child: Text(
                          "!",
                          style: TextStyle(color: AppColor.mainRed),
                        ),
                      ),
                      Container(
                        child: Text(
                          "网络连接已断开，请检查网络设置",
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 6),
                      ),
                      Spacer(),
                      Image.asset(
                        "images/resource/news_icon_arrow-red.png",
                        width: 16,
                        height: 16,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: _actionsDispatch(FuncOfHandleNet),
    ),);
  }

  //通知开启提醒的横幅生成
  @override
  Widget notificationBanner() {
    return Offstage(
      offstage: _sysNotificationBannerShow,
      child: GestureDetector(
        onTap: _actionsDispatch(FuncOfHandleNotify),
        child: Container(
          height: 56,
          color: Colors.grey,
          margin: EdgeInsets.only(left: 15, right: 15,bottom: 12),
        ),
      ),
    );
  }
  //没有数据时的占位图生成
  @override
  Widget placeholderWhenNoData() {
    return Container(
      height: 306,
      width: 111,
      padding: EdgeInsets.only(top: 28),
      child: Row(
       children: [
         Expanded(child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             SizedBox(
               width: 224,
                 height: 224,
               child: Container(
                 color: Colors.red,
               ),
             ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Text("这里空空如也，去推荐看看吧",
                  style: TextStyle(color: AppColor.textSecondary,
                      decoration: TextDecoration.none,
                      fontFamily: "PingFangSC",
                      fontWeight: FontWeight.w400,
                      fontSize: 14),),
              )
           ],
         )),
       ],
     ),
    );
  }
  ///////////////////
  //下面是可向本类发送消息的实现
  //////////////////
  //控制展示网络有误的横幅
  @override
  void displayBadNetBanner(bool switchOn) {
    _badNetBannerShow = switchOn;
    _actionsDispatch(FuncOf_setState_);
  }
  //控制展示系统通知的的横幅
  @override
  void displaySysNotiBanner(bool switchOn) {
    _sysNotificationBannerShow = switchOn;
    _actionsDispatch(FuncOf_setState_);
  }
  //有社交事件的来临走这里
  @override
  void interCourseAction(MPBusiness eventType, {payload}) {
    // TODO: implement interCourseAction
  }
   //某会话数据来临走这里
  @override
  void imFreshData( {bool incomplete, int identifier, int index}) {
    // TODO: implement imFreshData
  }
  //
  
  //下方为ui跟随变化的消息
  /////
  //正在进行重连时
  @override
  void connecting() {
    // TODO: implement connecting
  }
  //断开连接时
  @override
  void loseConnection() {
    // TODO: implement loseConnection
  }
  //重连时
  @override
  void reconnected() {
    // TODO: implement reconnected
  }
  //需要提示开启系统提醒
  @override
  void activateNotificationBanner() {
    this.displaySysNotiBanner(true);
  }
  //关闭系统消息开启引导横幅
  @override
  void dismissNotificationBanner() {
    this.displaySysNotiBanner(false);
  }

 

}



 //消息页面的会话数据源代理类
 class _MessagePageDataSource implements MPDataSourceProxy {
   static const String REFRESH_A_CHAT = "REFRESH_A_CHAT";
   static const String REFRESH_ALL_LIST = "REFRESH_ALL_LIST";
   //保存接收到的会话数据
   LinkedHashMap<String,ChatModel> _chatData = LinkedHashMap<String,ChatModel>();
   //最新接受到的消息放在这里
   List<Message> _msgs = List<Message>();
   //保存社交事件未读数
   Map _unreads = Map<MPIntercourses,int>();
   //为显示的不同index的cell提供高度
   @override
   double cellHeightAtIndex(int index) {
    return 69.0;
   }
   //为会话cell提供数据
    @override
    List<ChatModel> imCellData() {
    List<ChatModel> _chats = List<ChatModel>();
    for(String id in _chatData.keys){
      _chats.add(_chatData[id]);
    }
    return _chats;
  }
   //提供交互事件的未读数量信息
    @override
     Map<MPIntercourses, int> unreadOfIntercources() {
    if(_unreads.isEmpty){
      _unreads[MPIntercourses.Thumb] = 1;
      _unreads[MPIntercourses.At] = 2;
      _unreads[MPIntercourses.Comment] = 100;
    }
     return _unreads;
  }
    //新消息来临后走这个函数加入到消息集合当中
    @override
    void newMsgsArrive(Set<Message> msgs) {
     _msgs.addAll(msgs);
     for(Message msg in msgs){
      //是否已存在消息对应的会话
      switch(_isExistRelevantChat(msg)){
        case true:
          if(delegate==null){return;}
          delegate.signals(payload:{REFRESH_A_CHAT:_indexOf_A_ChatByMessage(msg)});
          break;
          default:
          if(delegate==null){return;}
          delegate.signals(payload: {REFRESH_ALL_LIST:null});
          break;
      }
    }
    //每回来新的数据的时候，都需要进行排序
    _sortChats();
   }
   //根据消息找对对应的会话
    int _indexOf_A_ChatByMessage(Message msg){
      String targetId = msg.senderUserId;
      int index = -1;
      for(String id in _chatData.keys){
        ++index;
        if(id == targetId){
        return index;
        }
      }
    }
    //对会话的数据进行按照时间的顺序来进行排序，新到的顺序较高
    _sortChats(){

    }
    //是否存在"已有会话"
    bool _isExistRelevantChat(Message msg){
      String targetId = msg.senderUserId;
      for(String id in _chatData.keys){
        if(id == targetId){
        return true;
        }
      }
      return false;
    }
    @override
    MPIMDataSourceAction delegate;
}
