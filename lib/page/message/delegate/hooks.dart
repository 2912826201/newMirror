

import 'regular_events.dart';
import 'message_types.dart';
//消息页逻辑埋点行为
abstract class MPHookFunc {
  //删除了一个聊天
  // ignore: non_constant_identifier_names
  void didDelete_a_Chat(MPChatVarieties type);
  //点赞等类型事件发生
  void regularEventsCall(MPIntercourses type);
  //视图每次显示时
  void viewWillAppear();
  //离开页面时
  void viewDidDisappear();
}
