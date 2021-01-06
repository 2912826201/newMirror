class FitnessEntryModel {
  int height; //" : 180, 身高 cm
  int weight; //" : 55,  体重 kg
  int bodyType; //" : 1, 体型 0，1，2...
  int target; //" : 1, 目标 0:减脂 1:塑型 2：增肌 3：健康
  int hard; //": 3, 难度 0：初级 1：中级 2：高级
  List<int> keyPartList; //" : [1,2], 重点部位 0：全身 1：手臂 2：肩部 ...
  int startTime; //" : 1604851200000, 开始时间 毫秒
  int timesOfWeek; //" : 3             //每周次数
  FitnessEntryModel(
      {this.height,
      this.weight,
      this.bodyType,
      this.hard,
      this.keyPartList,
      this.startTime,
      this.target,
      this.timesOfWeek});
  FitnessEntryModel.fromJson(Map<String, dynamic> json) {
    height = json["height"];
    weight = json["weight"];
    bodyType = json["bodyType"];
    hard = json["hard"];
    if (json["keyPartList"] != null) {
      keyPartList = [];
      json["keyPartList"].forEach((v) {
        keyPartList.add(v);
      });
    }
    startTime = json["startTime"];
    target = json["target"];
    timesOfWeek = json["timesOfWeek"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["height"] = height;
    map["weight"] = weight;
    map["bodyType"] = bodyType;
    map["hard"] = hard;
    map["startTime"] = startTime;
    map["target"] = target;
    map["timesOfWeek"] = timesOfWeek;
    if (keyPartList != null) {
      map["keyPartList"] = keyPartList.map((v) => v.toString()).toList();
    }
    return map;
  }
}
