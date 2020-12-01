import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'delegate/hooks.dart';
import 'delegate/message_interfaces.dart';
import 'delegate/message_page_ui_provider.dart';
import 'delegate/message_types.dart';
import 'delegate/regular_events.dart';
import 'delegate/business.dart';
import 'delegate/frame.dart';
import 'delegate/message_page_datasource.dart';
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
    print("messagePage build");
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
    print("${this.hashCode} initState");
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
   // //数据proxy
   // @override
   // MPDataSourceProxy dataSource;
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
    dataSource = MessagePageDataSource();
    //UI
    uiProvider = MessagePageUiProvider();
    //用于交互事件的反馈以及ui显示需要数据的提供
    uiProvider.dataActionPipe = this;
    dataSource.delegate = this;
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
      print("regularEventsCall");
    }
    //视图第一次出现时，在flutter中对应是在build中
    @override
    void viewWillAppear() {
    print("viewWillAppear");
    }

   //当转去其他视图界面时(目前暂时放在dispose方法中)
    @override
    void viewDidDisappear() {
    print("viewDidDisappear");
    }
    @override
    void dispose() {
      print("dispose");
      this.uiProvider = null;
      this.dataSource = null;
      print(this.runtimeType);
      print(this.hashCode);
      print("\n");
    RongCloudReceiveManager.shareInstance().removeObserver(this);
    this.viewDidDisappear();
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
    print("event comes");
    }
    //及时通讯消息的到来
    @override
    void imArrived() {
    print("页面消息来到整页性回调");
    }
   //////////////////////////////////////
   /////////////////////////////////////

   //  -------------------代理------------------------//
   //融云消息的注册的新消息来临的回调，可以选择性去调用imArrived()去执行ui上的变化
   @override
   Future<void> msgDidCome(Set<Message> msg, bool offLine) {
      print("msgDidCome");
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
      print("_manipulateRegularMsg");
      Set<Message> _t = Set<Message>();
      _t.add(msg);
      this.newMsgsArrive(_t);
   }
   //列表性离线信息的来临
   void _manipulateOffLineMessage(Set<Message> msgs){
     print("_manipulateOffLineMessage");
    this.newMsgsArrive(msgs);
   }
   //UI源发送来的交互事件
   @override
   void action(String identifier, {payload = Map}) {
    //setState(){}方法调用事件
    if (identifier == MessagePageUiProvider.FuncOf_setState_) {
      print("before setState");
      setState(() {});
    }
    //点赞和评论等事件
    else if (identifier == MessagePageUiProvider.FuncOfinterCourses) {
      if (payload != null && payload[MessagePageUiProvider.IntercoursesKey] != null) {
        MPIntercourses t = payload[MessagePageUiProvider.IntercoursesKey];
        switch (t) {
          case MPIntercourses.Thumb:
            this.regularEventsCall(MPIntercourses.Thumb);
            break;
          case MPIntercourses.At:
            this.regularEventsCall(MPIntercourses.At);
            break;
          case MPIntercourses.Comment:
            this.regularEventsCall(MPIntercourses.Comment);
            break;
        }
      }
    }
    //聊天cell的点击
    else if (identifier == MessagePageUiProvider.FuncOfCellTap) {
      // TODO: implement _MessagePageUiProvider.FuncOfCellTap
    }
    //导航栏按钮点击
    else if (identifier == MessagePageUiProvider.FuncOfNaviBtn) {
      // TODO: implement _MessagePageUiProvider.FuncOfNaviBtn
    }
    //跳转去处理网络
    else if (identifier == MessagePageUiProvider.FuncOfHandleNet) {
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNet
    }
    //跳转去处理通知
    else if (identifier == MessagePageUiProvider.FuncOfHandleNotify) {
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNotify
    }
  }
   //数据源的事件
   @override
   void signals({Map<String,dynamic> payload}) {
      print("datasource signals");
    //事件区分
    String thekey = payload.keys.first;
    //刷新一个cell
    if(thekey == MessagePageDataSource.REFRESH_A_CHAT){
      print("single refresh");
      print("the key  $thekey");
      int index  = payload[thekey];
      print("the index $index");
      uiProvider.imFreshData(index: index);
    }
    //刷新整个列表
    else if (thekey == MessagePageDataSource.REFRESH_ALL_LIST){
      print("whole refresh");
      uiProvider.imFreshData();
    }
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



  //数据源属性
  @override
  MPDataSourceProxy dataSource;

  //即时消息ui 数据代理
  @override
  List<ConversationDto> imCellData() {
    // print("messagePage imCellData");
   return dataSource.imCellData();
  }
  //有及时消息的来临
  @override
  void newMsgsArrive(Set<Message> msgs) {
    print("dataSource.newMsgsArrive(msgs)");
    if(dataSource != null) {
      dataSource.newMsgsArrive(msgs);
    }
  }
   //-------------------------------------------------------------------//
}




