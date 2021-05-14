import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';

class UserNotifierModel {
  Map<int, ProfileUiChangeModel> _profileUiChangeModel = {};

  Map<int, ProfileUiChangeModel> get profileUiChangeModel => _profileUiChangeModel;
  bool _watchScroll = true;

  bool get watchScroll => _watchScroll;
  List<int> _removeId;

  List<int> get removeId => _removeId;
  set removeId(List<int> result){
    _removeId = result;
  }
  List<int> _userFollowChangeIdList;

  List<int> get userFollowChangeIdList => _userFollowChangeIdList;
  set userFollowChangeIdList(List<int> result){
    _userFollowChangeIdList = result;
  }
  int _fansUnreadCount = 0;

  int get fansUnreadCount => _fansUnreadCount;
  bool _showImageFrame = false;

  bool get showImageFrame => _showImageFrame;
  set showImageFrame(bool result){
    _showImageFrame = result;
  }
  UserInteractiveNotifier wrapper;

  UserNotifierModel(this._profileUiChangeModel);
}

class UserInteractiveNotifier extends  ValueNotifier<UserNotifierModel>  {
  UserInteractiveNotifier(UserNotifierModel value) : super(value){
    value.wrapper = this;
  }
  ///FIXME 当用户登出登录时需要重置provider为默认值

  //是否显示对比图选框
  void changeShowImageFrame(bool isShow) {
    value._showImageFrame = isShow;
    notifyListeners();
  }

  //未读粉丝数
  void changeUnreadFansCount(int count) {
    value._fansUnreadCount = count;
    notifyListeners();
  }
  //改变点赞数
  void laudedChange(int id, int lauded) {
    if (lauded == 0) {
      value._profileUiChangeModel[id].attentionModel.laudedCount -= 1;
    } else {
      value._profileUiChangeModel[id].attentionModel.laudedCount += 1;
    }
    notifyListeners();
  }

  //从列表跳转界面对列表做移除操作
  void removeListId(int id, {bool isAdd = true}) {
    if (value._removeId == null) {
      return;
    }
    if (isAdd) {
      value._removeId.add(id);
    } else {
      if (value._removeId.contains(id)) {
        value._removeId.remove(id);
      }
    }
    notifyListeners();
  }

  //从用户列表跳转界面对用户列表做移除操作
  void removeUserFollowId(int id, {bool isAdd = true}) {
    if (value._userFollowChangeIdList == null) {
      return;
    }
    if (isAdd) {
      value._userFollowChangeIdList.add(id);
    } else {
      if (value._userFollowChangeIdList.contains(id)) {
        value._userFollowChangeIdList.remove(id);
      }
    }
    notifyListeners();
  }
  void changeBalckStatus(int id,bool status,{bool needNotify = true}) {
    value.profileUiChangeModel[id].inMyBlack  = status;
    if(needNotify){
      notifyListeners();
    }
  }
  //初始化model
  void setFirstModel(int id, {bool isFollow}) {
    if (!value._profileUiChangeModel.containsKey(id)) {
      ProfileUiChangeModel model = ProfileUiChangeModel();
      if (isFollow != null) {
        model.isFollow = isFollow;
        model.feedStringList.clear();
        if (!isFollow) {
          model.feedStringList.add("取消关注");
        }
        model.feedStringList.add("举报");
      }
      value._profileUiChangeModel[id] = model;
    } else {
      if (isFollow != null && value._profileUiChangeModel[id].isFollow == null) {
        value._profileUiChangeModel[id].isFollow = isFollow;
      }
    }
  }

  //清理provider
  void clearProfileUiChangeModel() {
    value._profileUiChangeModel = {};
    notifyListeners();
  }

  //改变用户是否关注
  void changeIsFollow(bool needNotify, bool bl, int id) {
    value._profileUiChangeModel[id].isFollow = bl;
    value._profileUiChangeModel[id].feedStringList.clear();
    if (!bl) {
      value._profileUiChangeModel[id].feedStringList.add("取消关注");
    }
    value._profileUiChangeModel[id].feedStringList.add("举报");
    if (needNotify) {
      print('=====================关注以后的notify${value._profileUiChangeModel[id].isFollow}');
      notifyListeners();
    }
  }

  //改变关注数
  void changeFollowCount(int id, bool follow) {
    if (value._profileUiChangeModel.containsKey(id)) {
      if (follow) {
        value._profileUiChangeModel[id].attentionModel.followerCount += 1;
      } else {
        value._profileUiChangeModel[id].attentionModel.followerCount -= 1;
      }
    }
    if (value._profileUiChangeModel.containsKey(Application.appContext.read<ProfileNotifier>().profile.uid)) {
      if (follow) {
        value._profileUiChangeModel[Application.appContext.read<ProfileNotifier>().profile.uid]
            .attentionModel
            .followingCount += 1;
      } else {
        value._profileUiChangeModel[Application.appContext.read<ProfileNotifier>().profile.uid]
            .attentionModel
            .followingCount -= 1;
      }
    }
    notifyListeners();
  }

  //改变用户关注粉丝model
  void changeAttentionModel(ProfileModel model, int id) {
    print('=id==========id======id=======id======$id');
    value._profileUiChangeModel[id].attentionModel = model;
    notifyListeners();
  }
}

class ProfileUiChangeModel {
  bool isFollow = false;
  ProfileModel attentionModel = ProfileModel();
  List<String> feedStringList = [];
  bool inMyBlack = false;
}
