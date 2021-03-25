import 'package:flutter/foundation.dart';
import 'package:mirror/config/application.dart';

/// unread_message_notifier
/// Created by yangjiayi on 2021/1/27.

class UnreadMessageNotifier extends ChangeNotifier {
  int comment;
  int at;
  int laud;

  UnreadMessageNotifier({this.comment = 0, this.at = 0, this.laud = 0});

  void changeUnreadMsg({int comments, int ats, int lauds}) {
    bool isChanged = false;
    if (comments != null && comment != comments) {
      Application.unreadNoticeNumber=0;
      Application.unreadNoticeNumber+=comments;
      comment = comments;
      isChanged = true;
    }
    if (ats != null && at != ats) {
      if(!isChanged){
        Application.unreadNoticeNumber=0;
      }
      Application.unreadNoticeNumber+=ats;
      at = ats;
      isChanged = true;
    }
    if (lauds != null && laud != lauds) {
      if(!isChanged){
        Application.unreadNoticeNumber=0;
      }
      Application.unreadNoticeNumber+=lauds;
      laud = lauds;
      isChanged = true;
    }
    if (isChanged) {
      notifyListeners();
    }
  }
}
