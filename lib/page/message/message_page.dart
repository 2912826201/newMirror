import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    implements MPBasements, MPBusiness, MPHookFunc, MPNetworkEvents, MPUIActionAndDataPipe, MessageObserver {
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
   //初始化和分配资源的事情
   _allocations() {
    //UI代理和数据代理生成//
    //数据源
    dataSource = _MessagePageDataSource();
    //UI
    uiProvider = _MessagePageUiProvider();
    //用于交互事件的反馈以及ui显示需要数据的提供
    uiProvider.dataActionPipe = this;
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
    //视图第一次出现时
   @override
    void viewDidAppear() {
    // TODO: implement viewDidAppear
   }
   //当转去其他视图界面时
   @override
    void willDisappear() {
     // TODO: implement willFade
   }
   //社交时间到来时调用
   @override
   void eventsDidCome() {
    // TODO: implement eventsDidCome
   }
   //当网络连接丢失时
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
   //开启系统通知，通常为跳转到手机的系统设置页面
   @override
   void activateNotification() {
    // TODO: implement activateNotification
   }
   //有及时消息来临时调用，ui源的修改向ui源发送消息，见MPUiProxy接口
   @override
   void imArrived() {
     // TODO: implement imArrived
   }
   //融云消息的注册的新消息来临的回调，可以选择性去调用imArrived()去执行ui上的变化
   @override
   Future<void> msgDidCome(Set<Message> msg, bool offLine) {
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

   //需要进行振动等事件
   @override
   void feedBackForSys() {
    // TODO: implement sysfeedBack
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

  
}
//即时消息数据源
abstract class MPIMDataSource{
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
//ui绑定的函数出口
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
  //是否展示网络问题横幅
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
          //大致分为4个区域，最后一个区域及n>=4时显示聊天的部分
          itemCount: this.consistsOfMP + dataActionPipe.imCellData().length,
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

  //即时通讯相关的区域,因为本身为一个ListView的item，所以需要高度
  Widget _imArea(int index) {
    //数据源没有数据的时候显示展位图
    if(dataActionPipe.imCellData().length == 0){
      return placeholderWhenNoData();
    }
    //三个板块中需要减去代表会话cell总体作为一部分的"1"
    int expectedIndex = index - this.consistsOfMP - 1;
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

  //断网时横幅
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

  //通知开启提醒的横幅
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
  //没有数据时的占位图
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
  //进行展示网络有误的横幅
  @override
  void displayBadNetBanner(bool switchOn) {
    _badNetBannerShow = switchOn;
    _actionsDispatch(FuncOf_setState_);
  }
  //进行展示系统通知的的横幅
  @override
  void displaySysNotiBanner(bool switchOn) {
    _sysNotificationBannerShow = switchOn;
    _actionsDispatch(FuncOf_setState_);
  }
  //有社交事件的来临
  @override
  void interCourseAction(MPBusiness eventType, {payload}) {
    // TODO: implement interCourseAction
  }
   //某会话数据来临
  @override
  void imFreshData(ChatModel model, {bool incomplete, int identifier, int index}) {
    // TODO: implement imFreshData
  }

  @override
  void activateNotification() {
    // TODO: implement activateNotification
  }

  @override
  void connecting() {
    // TODO: implement connecting
  }

  @override
  void loseConnection() {
    // TODO: implement loseConnection
  }

  @override
  void reconnected() {
    // TODO: implement reconnected
  }

}



//消息页面的会话数据源代理类
class _MessagePageDataSource implements MPDataSourceProxy {
  List<ChatModel> _chatData = List();
  Map _unreads = Map<MPIntercourses,int>();



  //新消息来临
  void newMsgsArrive(List<ChatModel> chats){
    _chatData.addAll(chats);
  }

  @override
  double cellHeightAtIndex(int index) {
    return 69.0;
  }

  @override
  List<ChatModel> imCellData() {
    // TODO: implement imCellData
    List datas = List<ChatModel>();
    for(int i=0;i<0;i++){
      var model = ChatModel();
      model.portraitUrl = "http://tiebapic.baidu.com/forum/w%3D580%3B/sign=0a77c837c609b3deebbfe460fc846d81/c2cec3fdfc0392458ab18e509094a4c27d1e256c.jpg";
      datas.add(model);
      model.name = "你好${i+1}";
      model.detailDes = "helloWorld,mobilePhone";
      model.time = DateTime(1606304956);
    }
    return datas;
  }

  @override
  Map<MPIntercourses, int> unreadOfIntercources() {
    if(_unreads.isEmpty){
      _unreads[MPIntercourses.Thumb] = 1;
      _unreads[MPIntercourses.At] = 2;
      _unreads[MPIntercourses.Comment] = 100;
    }
     return _unreads;
  }

}
