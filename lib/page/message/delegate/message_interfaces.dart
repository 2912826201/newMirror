import 'package:flutter/cupertino.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/chat_model.dart';
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
  //及时通讯ui相关，第三个参数的意思是当仅仅是某一种消息类型进行跟新时此参数需要传入true,
  //第二个参数用来指定需要跟新的cell，可以使index索引，也可以是一个会话标识,当标识和索引同时存在的时候
  //优先选择会话标识
  void imFreshData({bool incomplete, int identifier, int index});
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

