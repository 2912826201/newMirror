import 'package:flutter/cupertino.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'delegate/hooks.dart';
import 'delegate/message_types.dart';
import 'delegate/regular_events.dart';
import 'delegate/business.dart';
import 'delegate/content_delegates.dart';
import 'delegate/frame.dart';
///////////////////////////////////////////////////////////////////////////////////////////////////////////

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MessagePageState();
  }
}

class _MessagePageState extends State<MessagePage> implements MPBasements,MPHookFunc,MPNetworkEvents,MessageObserver {
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("消息页"),
    );
  }
  @override
  void initState() {
    //考虑到此页面可能会涉及到每个消息来临时的处理
    RongCloudReceiveManager.shareInstance().observeAllMsgs(this);



    super.initState();
  }
  @override
  Future<void> msgDidCome(Message msg,bool offLine){

  }

  @override
  MPModuleDataSource dataSource;

  @override
  MPUiProvider uiProvider;

  @override
  void aChatArrived(MPChatVarieties type) {
    // TODO: implement aChatArrived
  }

  @override
  // ignore: non_constant_identifier_names
  void didDelete_a_Chat(MPChatVarieties type) {
    // TODO: implement didDelete_a_Chat
  }

  @override
  void regularEventsCall(MPIntercourses type) {
    // TODO: implement regularEventsCall
  }

  @override
  void viewDidAppear() {
    // TODO: implement viewDidAppear
  }

  @override
  void willDisappear() {
    // TODO: implement willFade
  }

  @override
  void eventsDidCome<T extends MPIntercourses>(T type) {
    // TODO: implement eventsDidCome
  }



  @override
  void loseConnection() {
    // TODO: implement loseConnection
  }

  @override
  void reconnected() {
    // TODO: implement reconnected
  }

  @override
  void connecting() {
    // TODO: implement connecting
  }

  @override
  void activateNotification() {
    // TODO: implement activateNotification
  }

}
