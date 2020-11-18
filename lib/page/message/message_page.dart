import 'package:flutter/cupertino.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
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

class _MessagePageState extends State<MessagePage> implements MPBasements,MPHookFunc,MPBusiness,MPNetworkEvents {
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("消息页"),
    );
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
  void msgDidCome<T extends MPChatVarieties>(T type) {
    // TODO: implement msgDidCome
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
