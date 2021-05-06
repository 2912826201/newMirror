import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';

class UserInteractiveNotifier extends ChangeNotifier {
  bool watchScroll = true;
  Map<int, ProfileUiChangeModel> profileUiChangeModel = {};
  List<int> removeId;
  List<int> userFollowChangeIdList;
  bool haveNewFans = false;

  ///FIXME 当用户登出登录时需要重置provider为默认值

  void laudedChange(int id, int lauded) {
    if (lauded == 0) {
      profileUiChangeModel[id].attentionModel.laudedCount -= 1;
    } else {
      profileUiChangeModel[id].attentionModel.laudedCount += 1;
    }
    notifyListeners();
  }

  void removeListId(int id,{bool isAdd = true}) {
    if(isAdd){
      removeId.add(id);
    }else{
      if(removeId.contains(id)){
        removeId.remove(id);
      }
    }
    notifyListeners();
  }

  void removeUserFollowId(int id,{bool isAdd = true}){
    if(userFollowChangeIdList==null){
      return;
    }
    if(isAdd){
      userFollowChangeIdList.add(id);
    }else{
      if(userFollowChangeIdList.contains(id)){
        userFollowChangeIdList.remove(id);
      }
    }
    notifyListeners();
  }

  void setFirstModel(int id, {bool isFollow}) {
    if (!profileUiChangeModel.containsKey(id)) {
      ProfileUiChangeModel model = ProfileUiChangeModel();
      if (isFollow != null) {
        model.isFollow = isFollow;
        model.feedStringList.clear();
        if (!isFollow) {
          model.feedStringList.add("取消关注");
        }
        model.feedStringList.add("举报");
      }
      profileUiChangeModel[id] = model;
    } else {
      if (isFollow != null&&profileUiChangeModel[id].isFollow==null) {
        profileUiChangeModel[id].isFollow = isFollow;
      }
    }
  }

  void clearProfileUiChangeModel() {
    profileUiChangeModel = {};
    notifyListeners();
  }

  void changeIsFollow(bool needNotify, bool bl, int id) {
    profileUiChangeModel[id].isFollow = bl;
    profileUiChangeModel[id].feedStringList.clear();
    if (!bl) {
      profileUiChangeModel[id].feedStringList.add("取消关注");
    }
    profileUiChangeModel[id].feedStringList.add("举报");
    if (needNotify) {
      print('=====================关注以后的notify${profileUiChangeModel[id].isFollow}');
      notifyListeners();
    }
  }

  void changeFollowCount(int id, bool follow) {
    if (profileUiChangeModel.containsKey(id)) {
      if (follow) {
        profileUiChangeModel[id].attentionModel.followerCount += 1;
      } else {
        profileUiChangeModel[id].attentionModel.followerCount -= 1;
      }
    }
    if (profileUiChangeModel.containsKey(Application.appContext.read<ProfileNotifier>().profile.uid)) {
      if (follow) {
        profileUiChangeModel[Application.appContext.read<ProfileNotifier>().profile.uid]
            .attentionModel
            .followingCount += 1;
      } else {
        profileUiChangeModel[Application.appContext.read<ProfileNotifier>().profile.uid]
            .attentionModel
            .followingCount -= 1;
      }
    }
    notifyListeners();
  }

  void changeAttentionModel(ProfileModel model, int id) {
    print('=id==========id======id=======id======$id');
    profileUiChangeModel[id].attentionModel = model;
    notifyListeners();
  }
}

class ProfileUiChangeModel {
  bool isFollow = false;
  ProfileModel attentionModel = ProfileModel();
  List<String> feedStringList = [];
}
