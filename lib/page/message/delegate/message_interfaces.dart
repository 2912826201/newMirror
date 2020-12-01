import 'package:flutter/cupertino.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'business.dart';



//
//对ui的生成和数据源的数据提供定义约定和接口
//

//消息界面UI的Proxy
abstract class MPUiProxy implements MPNetworkEvents {
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
  MPUIActionAndDataPipe dataActionPipe;

  //可向本实例发送的消息
  //点赞
  void interCourseAction(MPBusiness eventType, {dynamic payload});
  //开启网络提示横幅
  void displayBadNetBanner(bool switchOn);
  //开启系统提示横幅
  void displaySysNotiBanner(bool switchOn);
  //融云消息列表的ui刷新，三个参数均不传则刷新整个消息列表，否则刷新摸个指定的cell
  void imFreshData({ int index,ConversationDto dto});
}
abstract class MPIMDataSourceAction{
  //数据源本身的一些事件（工作）的回调
  void signals({Map<String,dynamic> payload});
//
}
//数据源的Proxy
abstract class MPDataSourceProxy implements MPInterCourcesDataSource,MPIMDataSource{
  MPIMDataSourceAction delegate;
}
//即时通讯的ui的展示需要的数据集
abstract class MPIMDataSource{
  void newMsgsArrive(Set<Message> msgs);
  //返回即时聊天的数据集
  List<ConversationDto>  imCellData();
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

