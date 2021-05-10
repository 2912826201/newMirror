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
  int fansUnreadCount = 0;
  bool showImageFrame = false;
  ///FIXME 当用户登出登录时需要重置provider为默认值

  //是否显示对比图选框
  void changeShowImageFrame(bool isShow){
    showImageFrame = isShow;
    notifyListeners();
  }
  //未读粉丝数
  void changeUnreadFansCount(int count){
    fansUnreadCount = count;
    notifyListeners();
  }
  //改变点赞数
  void laudedChange(int id, int lauded) {
    if (lauded == 0) {
      profileUiChangeModel[id].attentionModel.laudedCount -= 1;
    } else {
      profileUiChangeModel[id].attentionModel.laudedCount += 1;
    }
    notifyListeners();
  }
  //从列表跳转界面对列表做移除操作
  void removeListId(int id,{bool isAdd = true}) {
    if(removeId==null){
      return;
    }
    if(isAdd){
      removeId.add(id);
    }else{
      if(removeId.contains(id)){
        removeId.remove(id);
      }
    }
    notifyListeners();
  }
  //从用户列表跳转界面对用户列表做移除操作
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
  //初始化model
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
  //清理provider
  void clearProfileUiChangeModel() {
    profileUiChangeModel = {};
    notifyListeners();
  }

  //改变用户是否关注
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

    //改变关注数
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

  //改变用户关注粉丝model
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
