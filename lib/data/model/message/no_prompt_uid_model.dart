/// data : {"list":[{"targetId":1000000,"type":0},{"targetId":1008611,"type":0}]}
/// code : 200
/// targetId : 1000000
/// type : 0

class NoPromptUidModel {
  int targetId;
  int type;

  NoPromptUidModel({int targetId, int type}) {
    this.targetId = targetId;
    this.type = type;
  }

  NoPromptUidModel.fromJson(dynamic json) {
    this.targetId = json["targetId"];
    this.type = json["type"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["targetId"] = this.targetId;
    map["type"] = this.type;
    return map;
  }

  @override
  String toString() {
    return toJson().toString();
  }



  static bool contains(List<NoPromptUidModel> modelList,NoPromptUidModel model) {
    for (NoPromptUidModel e in modelList) {
      if(e.type==model.type&&e.targetId==model.targetId){
        return true;
      }
    }
    return false;
  }
  static int containsIndex(List<NoPromptUidModel> modelList,NoPromptUidModel model) {
    for (int i=0;i<modelList.length;i++) {
      if(modelList[i].type==model.type&&modelList[i].targetId==model.targetId){
        return i;
      }
    }
    return -1;
  }
}
