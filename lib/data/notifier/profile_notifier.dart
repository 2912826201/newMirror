import 'package:flutter/foundation.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/profile_dto.dart';

/// profile_notifier
/// Created by yangjiayi on 2020/10/29.

class ProfileNotifier with ChangeNotifier {
  ProfileNotifier(this._profile);

  ProfileDto _profile;

  ProfileDto get profile => _profile;

  void setProfile(ProfileDto profile) {
    _profile = profile;
    //要将全局的profile赋值
    Application.profile = profile;
    notifyListeners();
  }

  void setNickName(String nickName) {
    _profile.nickName = nickName;
    notifyListeners();
  }
}