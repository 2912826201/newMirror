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
    bool needChange = false;
    if (Application.unreadNoticeNumber == 0) {
      if (comments != null&&comment!=comments) {
        needChange = true;
        Application.unreadNoticeNumber += comments;
        comment = comments;
      }
      if (ats != null&&at!=ats) {
        needChange = true;
        Application.unreadNoticeNumber += ats;
        at = ats;
      }
      if (lauds != null&&laud!=lauds) {
        needChange = true;
        Application.unreadNoticeNumber += lauds;
        laud = lauds;
      }
    } else {
      if (comments != null&&comment!=comments) {
        needChange = true;
        Application.unreadNoticeNumber -= comment;
        Application.unreadNoticeNumber += comments;
        comment = comments;
      }
      if (ats != null&&at!=ats) {
        needChange = true;
        Application.unreadNoticeNumber -= at;
        Application.unreadNoticeNumber += ats;
        at = ats;
      }
      if (lauds != null&&laud!=lauds) {
        needChange = true;
        Application.unreadNoticeNumber -= laud;
        Application.unreadNoticeNumber += lauds;
        laud = lauds;
      }
    }
    if(needChange){
      notifyListeners();
    }
  }

}
