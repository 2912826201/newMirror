import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';
class UserInteractiveNotifier extends ChangeNotifier {
  bool watchScroll = true;
  Map<int, ProfileUiChangeModel> profileUiChangeModel = {};
  int removeId;

  ///FIXME 当用户登出登录时需要重置provider为默认值

  void loadChange(int id, int load) {
    if (load == 0) {
      profileUiChangeModel[id].attentionModel.laudedCount -= 1;
    } else {
      profileUiChangeModel[id].attentionModel.laudedCount += 1;
    }
    notifyListeners();
  }

  void removeListId(int id) {
    removeId = id;
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
    }
  }

  void setFeedIdList(int id, List<int> feedIdList, int type) {
    if (type == 2) {
      if (profileUiChangeModel[id].profileFeedListId.isEmpty) {
        profileUiChangeModel[id].profileFeedListId.insert(0, -1);
      }
      profileUiChangeModel[id].profileFeedListId.addAll(feedIdList);
    } else {
      if (profileUiChangeModel[id].profileLikeListId.isEmpty) {
        profileUiChangeModel[id].profileLikeListId.insert(0, -1);
      }
      profileUiChangeModel[id].profileLikeListId.addAll(feedIdList);
    }
    notifyListeners();
  }

  void idListClear(int id, {int type}) {
    if (type != null) {
      if (type == 2) {
        profileUiChangeModel[id].profileFeedListId.clear();
      } else {
        profileUiChangeModel[id].profileLikeListId.clear();
      }
    } else {
      profileUiChangeModel[id].profileFeedListId.clear();
      profileUiChangeModel[id].profileLikeListId.clear();
    }
  }

  void synchronizeIdList(int id, int deleteId) {
    for (int i = 0; i < profileUiChangeModel[id].profileFeedListId.length; i++) {
      if (profileUiChangeModel[id].profileFeedListId[i] == deleteId) {
        profileUiChangeModel[id].profileFeedListId.removeAt(i);
      }
    }
    for (int i = 0; i < profileUiChangeModel[id].profileLikeListId.length; i++) {
      if (profileUiChangeModel[id].profileLikeListId[i] == deleteId) {
        profileUiChangeModel[id].profileLikeListId.removeAt(i);
      }
    }
    notifyListeners();
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
    if(profileUiChangeModel.containsKey(Application.appContext.read<ProfileNotifier>().profile.uid)){
      if (follow) {
        profileUiChangeModel[Application.appContext.read<ProfileNotifier>().profile.uid].attentionModel.followingCount += 1;
      } else {
        profileUiChangeModel[Application.appContext.read<ProfileNotifier>().profile.uid].attentionModel.followingCount -= 1;
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
  List<int> profileFeedListId = [];
  List<int> profileLikeListId = [];
}