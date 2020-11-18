import 'package:flutter/material.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:mirror/page/message/delegate/message_types.dart';
//UI的构成
abstract class MPUiProvider{
  //导航栏
  Widget navigationBar();
  //页面主要内容
  Widget mainContent();
  //断网时横幅
  Widget loseConnectionBanner();
  //通知开启提醒的横幅
  Widget notificationBanner();
  //突发型横幅（位于聊天列表上方）
  Widget emergentBanner();
}
//数据源
abstract class MPModuleDataSource{
  //会话数据源
  List chats<T extends MPChatVarieties>(T type);
  //点赞、评论ui的数据源
  List operations<T extends MPIntercourses>( T type);
}