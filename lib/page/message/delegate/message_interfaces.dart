import 'package:flutter/cupertino.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/page/message/delegate/callbacks.dart';
import 'package:mirror/page/message/delegate/message_page_datasource.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'business.dart';



//
//对ui的生成和数据源的数据提供定义约定和接口
//

//消息界面UI的Proxy
abstract class MPUiProxy implements MPNetworkEvents {
  BuildContext context;
  //导航栏
  Widget navigationBar();
  //页面主要内容
  Widget mainContent();
  //断网时横幅
  Widget loseConnectionBanner();
  //通知开启提醒的横幅
  Widget notificationBanner();
  //缺省占位图
  Widget placeholderWhenNoData();
  //ui的交互函数的代理
  MPUIActionWithDataSource dataActionPipe;

  //可向本实例发送的消息
  //点赞
  void interCourseAction(MPBusiness eventType, {dynamic payload});
  //开启网络提示横幅
  void displayBadNetBanner(bool switchOn);
  //开启系统提示横幅
  void displaySysNotiBanner(bool switchOn);
  //融云消息列表的ui刷新，三个参数均不传则刷新整个消息列表，否则刷新摸个指定的cell
  void imFreshData({ int index,ConversationDto dto,int newBadgets});
}
abstract class MPIMDataSourceAction {
  //数据源本身的一些事件（工作）的回调
  void signals({Map<String,dynamic> payload});
  //用于反馈的作用，振动等
  void  feedBackForSys();
//
}
//数据源的Proxy
abstract class MPDataProxy implements MPInterCourcesDataSource,MPIMDataSource{
  MPIMDataSourceAction delegate;
}
//即时通讯的ui的展示需要的数据集
abstract class MPIMDataSource {
  //最新的官方会话的一条及时消息
  Map<SystemMsgType,List<ConversationDto>> latestAuthorizedMsgs();
  void newMsgsArrive(Set<Message> msgs);
  //返回即时聊天的数据集
  List<ConversationDto> imCellData();
  //及时会话的cell的高度
  double cellHeightAtIndex(int index);
  //存储历史会话数据
  saveChats();
  //增加一个会话
  createNewConversation(ConversationDto dto);
}
//社交事件未读数数据源
abstract class MPInterCourcesDataSource{
  Future<Map<MPIntercourses,int>> unreadOfIntercources(MPCallbackWithValue callback);
}
//消息界面的点击等事件
abstract class MPUIAction {
  void action(String identifier, {payload: Map, BuildContext context});
}
//ui绑定的函数出口接口
abstract class MPUIActionWithDataSource implements MPIMDataSource,MPUIAction,MPInterCourcesDataSource{
}

