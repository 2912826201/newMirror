import 'package:flutter/cupertino.dart';

import '../loading_status.dart';
import 'chat_group_user_model.dart';

class GroupUserProfileNotifier extends ChangeNotifier {
  //群成员信息
  List<ChatGroupUserModel> chatGroupUserModelList = <ChatGroupUserModel>[];

  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;

  clearAllUser() {
    chatGroupUserModelList.clear();
    loadingStatus = LoadingStatus.STATUS_IDEL;
  }

  addAll(List<ChatGroupUserModel> chatGroupUserModelList) {
    if (chatGroupUserModelList == null || chatGroupUserModelList.length < 1) {
      return;
    }
    this.chatGroupUserModelList.clear();
    this.chatGroupUserModelList.addAll(chatGroupUserModelList);
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
    notifyListeners();
  }
}
