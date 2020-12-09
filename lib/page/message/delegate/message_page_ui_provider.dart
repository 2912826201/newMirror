//即时消息数据源
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/intercourse_model.dart';
import 'package:mirror/page/message/delegate/callbacks.dart';
import 'package:mirror/page/message/delegate/message_page_datasource.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:mirror/widget/message/chatcell.dart';
import 'package:mirror/widget/message/intercourse_widget.dart';
import 'business.dart';
import 'message_interfaces.dart';
//消息页面的ui代理类
class MessagePageUiProvider implements MPUiProxy {
  //用于局部刷新List视图的key数组
  List<GlobalKey<MPChatCellState>> listKeys = List<GlobalKey<MPChatCellState>>();
  //保存局部刷新"点赞、评论、点赞"区域的key数组
  Map<MPIntercourses,GlobalKey<MPIntercourseWidgetState>> icWidgetsKeys = Map<MPIntercourses,GlobalKey<MPIntercourseWidgetState>>();
  //交互事件及数据代理
  MPUIActionWithDataSource dataActionPipe;
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
  Map<MPIntercourses,int> _unreadBadges = {MPIntercourses.Comment:0,MPIntercourses.Laud:0,MPIntercourses.At:0};
  //交互事件外发
  _actionsDispatch(String identifier, {payload: Map}) {
    if (dataActionPipe != null) {
      dataActionPipe.action(identifier, payload: payload);
    }
  }
  void dispose(){
    this.dataActionPipe = null;
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
                  onPressed: ()=>_actionsDispatch(FuncOfNaviBtn),
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

  //对旧的数据做清除的工作
  _cleanDirties(){
    listKeys.clear();
  }
  //页面主要内容
  @override
  Widget mainContent() {
     //清除旧配置
     _cleanDirties();
     //读取未读信息,设置回调
     _getBadges((t){
      UnreadInterCourses ur = t();
      ur.laud = 5;
      ur.comment = 12;
      ur.at = 90;
     List<MPIntercourses> events = List<MPIntercourses>();
      if(ur.at != _unreadBadges[MPIntercourses.At]){
        print("at !");
        _unreadBadges[MPIntercourses.At] = ur.at;
       events.add(MPIntercourses.At);
       print(_unreadBadges[MPIntercourses.At]);
      }
      if(ur.comment != _unreadBadges[MPIntercourses.Comment]){
        print("comment !");
        _unreadBadges[MPIntercourses.Comment] = ur.comment;
        events.add(MPIntercourses.Comment);
        print(_unreadBadges[MPIntercourses.Comment]);
      }
      if(ur.laud != _unreadBadges[MPIntercourses.Laud]){
        print("laund !");
        events.add(MPIntercourses.Laud);
        _unreadBadges[MPIntercourses.Laud] = ur.laud;
        print(_unreadBadges[MPIntercourses.Laud]);
      }
      print("before _refreshISpecificInterCource");
      print(events.length);
      _refreshISpecificInterCource(events);
    });
    print("ui-provider  mainContent");
    //整体setState(）之后，清空之前的每个子元素的globalKey数组
    //  this.listKeys.clear();
    //外层是一个column所以需要使用Expanded
    return Expanded(child: Column(
      children: [
        //网络状态横幅不跟随滑动
        loseConnectionBanner(),
        //除去网络横幅以外的区域
        Expanded(child: ListView.builder(
          //大致分为3个区域
          itemCount: _expectedCount(),
          itemBuilder: (BuildContext context, int index) {
            //点赞交互区域
            if(index == 0){
              return  _interactiveAreas();
            }
            //需要进行消息提醒的横幅的显示
            else if (index ==1){
              print(this.consistsOfMP + (dataActionPipe.imCellData().length));
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
  //分配key
  Key _distributeKeys(MPIntercourses event){
    GlobalKey<MPIntercourseWidgetState> theKey = GlobalKey<MPIntercourseWidgetState>();
    icWidgetsKeys[event] = theKey;
    return theKey;
  }
  //ListView的元素数量
   int _expectedCount(){
    int dataSourceCount  = dataActionPipe.imCellData().length ;
    if(dataSourceCount==0){
      return this.consistsOfMP;
    }
     return this.consistsOfMP + dataSourceCount - 1;
   }
  //点赞交互区域
  Widget _interactiveAreas() {
    print("_interactiveAreas");
    return Row(
      //横向排列交互区域
      children: [
        Expanded(
          child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                child: Center(
                  child: MPIntercourseWidget(
                    key: _distributeKeys(MPIntercourses.Comment),
                    title: Text(
                      "评论",
                      style: TextStyle(
                          color: AppColor.textPrimary1,
                          fontFamily: "PingFangSC",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none),
                    ),
                    onTap:()=> _actionsDispatch(FuncOfinterCourses, payload: {IntercoursesKey: MPIntercourses.Comment}),
                    badges: ()=>_unreadBadges[MPIntercourses.Comment],
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
                    key: _distributeKeys(MPIntercourses.At),
                    title: Text(
                      "@我",
                      style: TextStyle(
                          color: AppColor.textPrimary1,
                          fontFamily: "PingFangSC",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none),
                    ),
                    onTap: ()=>_actionsDispatch(FuncOfinterCourses, payload: {IntercoursesKey: MPIntercourses.At}),
                    badges: ()=>_unreadBadges[MPIntercourses.At],
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
                    key: _distributeKeys(MPIntercourses.Laud),
                    title: Text(
                      "点赞",
                      style: TextStyle(
                          color: AppColor.textPrimary1,
                          fontFamily: "PingFangSC",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none),
                    ),
                    onTap:()=> _actionsDispatch(FuncOfinterCourses, payload: {IntercoursesKey: MPIntercourses.Laud}),
                    badges: ()=>_badgesNum[MPIntercourses.Laud],
                  )),
            ),
          ),
          flex: 1,
        )
      ],
    );
  }

   //提供点赞事件的未读数
   Map<MPIntercourses,int> get _badgesNum {
    print(">>>>>>>>>>>>>reload unreads ");
    print("~~~~~~~~${_unreadBadges[MPIntercourses.At]}~~~~${_unreadBadges[MPIntercourses.Comment]}~~~~~~~~~~~${_unreadBadges[MPIntercourses.Laud]}~~~");
    // _unreadBadges.keys.forEach((element) {
    //   if(_unreadBadges[element]==null || _unreadBadges[element] == 0){
    //     _unreadBadges[element] = 99;
    //   }
    // });
    return _unreadBadges;
   }

  //异步读取未读数
   _getBadges(MPCallbackWithValue callback) async{
     print("_getBadges");
     //跟新未读数
     await dataActionPipe.unreadOfIntercources(callback);
     print("after async _getBadges");
     callback;
  }
  //刷新"评论、点赞、at的其中之一"
  _refreshISpecificInterCource(List<MPIntercourses> events) {
    print(">>>>>>>_refreshISpecificInterCourse<<<<<<<<<<<<<<");
    print(events.length);
     events.forEach((event) {
       print("for circling");
       print(event);
       icWidgetsKeys[event].currentState.setState(() {
       });
     });
     //刷新系统会话的最新消息
     _refreshSysChatsLatestMsg();
  }
  //刷新系统会话的最新的一条消息
   _refreshSysChatsLatestMsg(){
    print("_refreshSysChatsLatestMsg");
    dataActionPipe.imCellData().forEach((element) {
      if(element.type == OFFICIAL){
        int k = -1 ;
       listKeys.forEach((element) {
         ++k;
         MPChatCellState cellState = listKeys[k].currentState;
         if(cellState.widget.model.type == OFFICIAL){
           ConversationDto dto =ConversationDto();
           dto.content = dataActionPipe.latestAuthorizedMsgs()[Authorizeds.SysMsg].last.content;
           print("SysMsg   ${dataActionPipe.latestAuthorizedMsgs()[Authorizeds.SysMsg]}");
           cellState.refresh(model: dto);
         }
       });
      }
      if(element.type == LIVE_OFFICIAL){
        int k = -1 ;
        listKeys.forEach((element) {
          ++k;
          MPChatCellState cellState = listKeys[k].currentState;
          if(cellState.widget.model.type == LIVE_OFFICIAL){
            ConversationDto dto =ConversationDto();
            dto.content = dataActionPipe.latestAuthorizedMsgs()[Authorizeds.LiveMsg].last.content;
            print("LiveMsg   ${dataActionPipe.latestAuthorizedMsgs()[Authorizeds.LiveMsg]}");
            cellState.refresh(model: dto);
          }
        });
      }
      if(element.type == EXERCISE_OFFICIAL){
        int k = -1 ;
        listKeys.forEach((element) {
          ++k;
          MPChatCellState cellState = listKeys[k].currentState;
          if(cellState.widget.model.type == EXERCISE_OFFICIAL){
            ConversationDto dto =ConversationDto();
            dto.content = dataActionPipe.latestAuthorizedMsgs()[Authorizeds.ExerciseMsg].last.content;
            print("Exercise   ${dataActionPipe.latestAuthorizedMsgs()[Authorizeds.ExerciseMsg]}");
            cellState.refresh(model: dto);
          }
        });
      }
    });
   }
  //即时通讯会话相关的区域,因为本身为一个ListView的item，所以需要高度
  Widget _imArea(int index) {
    print("----------------------------_imArea----------------------------");
    //数据源没有数据的时候显示展位图
    if(dataActionPipe.imCellData().length == 0){
      print("placehoulder");
      return placeholderWhenNoData();
    }
    print("theindex $index");
    //三个板块中需要减去代表会话cell总体作为一部分的"1"
    int expectedIndex = index - 2 ;
    print("the expected index $expectedIndex");
    //唯一标识key
    GlobalKey<MPChatCellState> key = GlobalKey();
    print("the key:");
    print(listKeys);
    listKeys.add(key);
    //获取对应的cell
    MPChatCell cell = MPChatCell(key: key,model:dataActionPipe.imCellData()[expectedIndex],unreadMsgCount: dataActionPipe.imCellData()[expectedIndex].unread,);
    //构建单个cell的过程
    return Row(children:
    [
      Expanded(child:
       GestureDetector(
        //绑定点击事件，传参需要一个索引位置
        onTap: ()=>_actionsDispatch(FuncOfCellTap,payload: {CellTapKey:expectedIndex}),
        child: Container(child: cell,
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
        onTap: ()=>_actionsDispatch(FuncOfHandleNet),
      ),);
  }

  //通知开启提醒的横幅生成
  @override
  Widget notificationBanner() {
    print(" notificationBanner()");
    return Offstage(
      offstage: _sysNotificationBannerShow,
      child: GestureDetector(
        onTap: ()=>_actionsDispatch(FuncOfHandleNotify),
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
    dataActionPipe.action(MessagePageUiProvider.FuncOfinterCourses,payload: payload);
  }
  //某会话数据到来而走这里
  @override
  void imFreshData( { int index,ConversationDto dto,int newBadgets}) {
    print("imFreshData $index");
    //单独刷新
    if(index != null){
     MPChatCellState state = listKeys[index].currentState;
      if(state != null) {
        if(dto != null) {
          print("cell begin refresh ${dto.toStirng()}");
          }
          state.refresh(model: dto);
        //若未读数有值，则进行刷新的操作
        if(newBadgets != null){
          print("refresh badges ${newBadgets}");
          state.refresh(newBadges: newBadgets);
        }
      }

    }else{
     _actionsDispatch(FuncOf_setState_);
    }
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
