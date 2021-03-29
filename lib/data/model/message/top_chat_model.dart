class TopChatModel {
  //0-私聊 1-群聊
  int type;

  //群聊id/私聊id
  int chatId;

  TopChatModel({
    this.type, //默认给个uid为0
    this.chatId,
  });

  TopChatModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    chatId = json["chatId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["chatId"] = chatId;
    return map;
  }


  static bool contains(List<TopChatModel> modelList,TopChatModel model) {
    for (TopChatModel e in modelList) {
      if(e.type==model.type&&e.chatId==model.chatId){
        return true;
      }
    }
    return false;
  }
  static int containsIndex(List<TopChatModel> modelList,TopChatModel model) {
    for (int i=0;i<modelList.length;i++) {
      if(modelList[i].type==model.type&&modelList[i].chatId==model.chatId){
        return i;
      }
    }
    return -1;
  }
}
