///体重记录model
class WeightModel {
  int targetWeight;
  List<recordList> list;

  WeightModel({
    this.targetWeight,
    this.list});

  WeightModel.fromJson(dynamic json) {
    targetWeight = json["targetWeight"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(recordList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["targetWeight"] = targetWeight;
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class recordList {
  int weight;
  int createTime;

  recordList({
    this.createTime,
    this.weight,
   });

  recordList.fromJson(dynamic json) {
    createTime = json["createTime"];
    weight = json["weight"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["createTime"] = createTime;
    map["weight"] = weight;
    return map;
  }

}
