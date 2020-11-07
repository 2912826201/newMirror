import 'package:flutter/foundation.dart';
import 'package:mirror/data/model/user_model.dart';

/// user_notifier
/// Created by yangjiayi on 2020/10/29.

class UserNotifier with ChangeNotifier {
  UserModel _user = UserModel(uid: 0, userName: "默认用户", avatarUri: "http://www.abc.com/default.png");

  UserModel get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void setUserName(String userName) {
    _user.userName = userName;
    notifyListeners();
  }
}