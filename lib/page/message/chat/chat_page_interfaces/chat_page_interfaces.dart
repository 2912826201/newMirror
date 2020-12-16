import 'package:flutter/cupertino.dart';
//长按
typedef LongPressCall = void Function ();
//轻点
typedef TapCall = void Function ();
//动画调用
typedef AnimationAbleCall = void Function(Widget widget);
//是自己发的消息还是别人发送的消息
enum MsgDirection{
  //本地
  local,
  //对方
  remote
}
//消息状态
enum MsgStatus{
  //发送成功
  Send,
  //发送失败
  failed,
  //发送中.
  sending,
}
//消息内容分类
enum MsgContentType{
  //文字
  text,
  //语音
  voice,
  //图片
  image,
  //视频
  video,
  //课程
  course,
  //直播课程
  liveCourse,
  //未知
  unknown
}
//辅助类消息种类
enum EventMsgType{
  //At类型消息
  at,
  //撤回类型消息
  retract,
  //邀请事件
  invite,
  //移除成员
  kick,
  //未知
  unknown
}
//本地消息负载取值类,用于MessageObject中payload中取值
class PayloadKeys{
  static const MOImageKey = "MOImageKey";
  static const MOVoiceKey = "MOVoiceKey";
  static const MOVideoKey = "MOVideoKey";
  static const MOTextKey = "MOTextKey";
}
//融云消息包装类
class MessageObject{
   //消息种类
   MsgContentType type;
   //发送者id
   final String senderId;
   //消息的内容
   final Map<String,dynamic> payload;
   //事件类型信息
   EventMsgType eventType;
   ///////////////////////////////////////
   //构造函数
   MessageObject({
     //事件种类
     EventMsgType event,
     //消息的种类
     MsgContentType type,
     //时间戳
     @required int timesTamp,
     //消息负载
     this.payload,
     //发送者id
     this.senderId,
  }
  );
   ////////////////////////////////////////

}
//媒体播放支持
abstract class MediaPlay{
  void play();
  void stop();
  void pause();
}
//内容再刷新支持
abstract class RefreshAble{
  void reFreshAction(dynamic newContent);
}
//动画支持
abstract class AnimationAble{
  AnimationAbleCall   animationAbleCall;
}
//长按或者点击支持
abstract class Touchable{
  //长按
  LongPressCall  longPress;
  //点击
  TapCall tap;
}
//聊天页的通用cell
abstract class UniversalCell{
  //消息内容承载区域
  Widget content;
  //最小的默认尺寸
  double  intrinsicHeight();
  MsgDirection direction;
}
//辅助显示性质的基类cell，比如（时间显示和群聊的成员增减显示）
abstract class SupplementaryBaseCell extends UniversalCell{
}
//消息状态指示器
abstract class StatusIndicator extends StatefulWidget implements AnimationAble,RefreshAble{
}
//消息类cell的基类
abstract class MessageBaseCell extends UniversalCell implements Touchable{
  //消息旁的指示器显示区域
  T  indicator<T extends StatusIndicator>();
  //名称显示
  Widget  name();
  //头像显示
  Widget  portrait();

}
abstract class CellHeight{
  //本身的高度
  double cellHeight();
}
//聊天页面的能力及功能
abstract class ChatUiAbilities{
  //滑动到指定的位置
  void scrollTo({double location,int whichCell});
}
//聊天界面绘制
abstract class ChatUI implements ChatUiAbilities{
  ChatUiDelegate actions_dataSource;
  //上方留白区域
  Widget eyebrowBar(BuildContext context);
  //导航栏
  Widget navigationBar();
  //内容显示区域
  Widget mainContent();
  //信息录入区域
  Widget inputArea();
  //下方留白区域
 Widget chinBar(BuildContext context);
}
//聊天页面数据源
abstract class ChatDataSource{
  ChatDataSourceDelegate delegate;
   //聊天内容显示区域
   List sentences();
   //发送消息
   void sendMessage({@required dynamic msg,String identifier});
   //主动撤回等事件的发生
   void eventArrives({dynamic payload});
}
//数据源的代理回调
abstract class ChatDataSourceDelegate{
   //新消息来临时的回调
   void NewMesage(dynamic msg,MsgContentType type);
   //取到widget
   dynamic getWidget();
   //刷新操作
   void refreshList();
}
//消息ui的代理回调
abstract class ChatUiDelegate extends ChatDataSource{
   //交互事件
   void uiEvent({String identifier,dynamic paylaod});
   //导航栏的标题
   String navigationBarTitle();

}
abstract class ChatCell extends Widget implements CellHeight{
  static ChatCell init(MessageObject object){
    throw UnimplementedError("基类cell不能被初始化");
  }

  @override
  double cellHeight() {
    // TODO: implement cellHeight
    throw UnimplementedError();
  }

}