import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/util/event_bus.dart';

import '../loading_status.dart';
import 'chat_group_user_model.dart';

class GroupUserProfileNotifier extends ChangeNotifier {
  //群成员信息
  List<ChatGroupUserModel> chatGroupUserModelList = <ChatGroupUserModel>[];

  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;

  int len = -1;

  String searchText="";

  setLen(int len) {
    this.len = len;
    EventBus.init().post(registerName: EVENTBUS_CHAT_BAR);
    notifyListeners();
  }

  setSearchText(String searchText){
    this.searchText=searchText;
    notifyListeners();
  }

  List<ChatGroupUserModel> getSearchUserModelList(){
    if(searchText==null||searchText==""){
      return chatGroupUserModelList;
    }else{
      List<ChatGroupUserModel> modelList = <ChatGroupUserModel>[];
      for(ChatGroupUserModel model in chatGroupUserModelList){
        if(model.nickName.contains(searchText)){
          modelList.add(model);
        }
      }
      return modelList;
    }
  }


  bool isHave(String userId){
    for(ChatGroupUserModel model in chatGroupUserModelList){
      if(model.uid.toString()==userId){
        return true;
      }
    }
    return false;
  }
  bool isNoHaveMe(){
    return !isHave(Application.profile.uid.toString());
  }

  clearAllUser() {
    print("clearAllUser");
    chatGroupUserModelList.clear();
    loadingStatus = LoadingStatus.STATUS_IDEL;
    len = -1;
  }

  addAll(List<ChatGroupUserModel> chatGroupUserModelList, int len) {
    print("addAll(List<ChatGroupUserModel> chatGroupUserModelList, int len)");
    if (chatGroupUserModelList == null || chatGroupUserModelList.length < 1) {
      return;
    }
    this.chatGroupUserModelList.clear();
    for (ChatGroupUserModel chatGroupUserModel in chatGroupUserModelList) {
      if (chatGroupUserModel.isGroupLeader()) {
        this.chatGroupUserModelList.insert(0, chatGroupUserModel);
      } else {
        this.chatGroupUserModelList.add(chatGroupUserModel);
      }
    }
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
    this.len = len;
    EventBus.init().post(registerName: EVENTBUS_CHAT_BAR);
    notifyListeners();
  }
}
