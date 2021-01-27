import 'package:flutter/foundation.dart';

/// unread_message_notifier
/// Created by yangjiayi on 2021/1/27.

class UnreadMessageNotifier extends ChangeNotifier {
  int comment;
  int at;
  int laud;

  UnreadMessageNotifier({this.comment = 0, this.at = 0, this.laud = 0});

  void changeUnreadMsg({int comments, int ats, int lauds}) {
    comment = comments;
    at = ats;
    laud = lauds;
    notifyListeners();
  }
}