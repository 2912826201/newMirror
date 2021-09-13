import 'package:flutter/foundation.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/event_bus.dart';

/// unread_message_notifier
/// Created by yangjiayi on 2021/1/27.

class UnreadMessageNotifier extends ChangeNotifier {
  int comment;
  int at;
  int laud;

  UnreadMessageNotifier({this.comment = 0, this.at = 0, this.laud = 0});

  void changeUnreadMsg({int comments, int ats, int lauds}) {
    bool needChange = false;
    if (MessageManager.unreadNoticeNumber == 0) {
      if (comments != null&&comment!=comments) {
        needChange = true;
        MessageManager.unreadNoticeNumber += comments;
        comment = comments;
      }
      if (ats != null&&at!=ats) {
        needChange = true;
        MessageManager.unreadNoticeNumber += ats;
        at = ats;
      }
      if (lauds != null&&laud!=lauds) {
        needChange = true;
        MessageManager.unreadNoticeNumber += lauds;
        laud = lauds;
      }
    } else {
      if (comments != null&&comment!=comments) {
        needChange = true;
        MessageManager.unreadNoticeNumber -= comment;
        MessageManager.unreadNoticeNumber += comments;
        comment = comments;
      }
      if (ats != null&&at!=ats) {
        needChange = true;
        MessageManager.unreadNoticeNumber -= at;
        MessageManager.unreadNoticeNumber += ats;
        at = ats;
      }
      if (lauds != null&&laud!=lauds) {
        needChange = true;
        MessageManager.unreadNoticeNumber -= laud;
        MessageManager.unreadNoticeNumber += lauds;
        laud = lauds;
      }
    }
    if(needChange){
      EventBus.init().post(registerName: EVENTBUS_IF_TAB_BAR_UNREAD);
      notifyListeners();
    }
  }

}
