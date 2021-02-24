import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';

/// profile_notifier
/// Created by yangjiayi on 2020/10/29.

class ProfileNotifier with ChangeNotifier {
  ProfileNotifier(this._profile);

  ProfileDto _profile;

  ProfileDto get profile => _profile;
  double weight = 0.0;
  int albumNum = 0;
  int trainingSeconds = 0;

  void setExtraInfo(UserExtraInfoModel model) {
    weight = model.weight;
    albumNum = model.albumNum;
    trainingSeconds = model.trainingSeconds;
  }
  void setWeight(double weights) {
    weight = weights;
    notifyListeners();
  }

  void setImagePageSize(int pageSizes) {
    albumNum = pageSizes;
    notifyListeners();
  }
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