
import 'package:mirror/page/message/foundation/foundation_RegularEvents.dart';
import 'package:mirror/page/message/foundation/foundation_message_types.dart';

//消息页业务行为
abstract class MPBusiness {
  //社交事件
  void eventsDidCome<T extends MPIntercourses>(T type);
  //消息事件
  void msgDidCome<T extends MPChatVarieties>(T type);
  //通知开启消息
  void activateNotification();
}
// //评论事件
// void commentEvent();
// //点赞事件
// void thumbEvent();
// //@事件
// void atEvent();
// //私有管家（销售、售后）消息~
// void salesManMsg();
// //单聊消息
// void individualChatMsg();
// //群聊
// void groupChatMsg();
// //系统消息
// void officialRegularMsg();
// //直播消息
// void officialLiveMsg();
// //运动数据消息
// void  exerciseDataMsg();