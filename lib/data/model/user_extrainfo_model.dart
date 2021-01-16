


class UserExtraInfoModel{
  int uid;
  int trainingSeconds;
  int weight;
  int albumNum;

  UserExtraInfoModel(
    {this.uid,
      this.trainingSeconds,
      this.weight,
      this.albumNum,
    });

  UserExtraInfoModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    trainingSeconds = json["trainingSeconds"];
    weight = json["weight"];
    albumNum = json["albumNum"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["trainingSeconds"] = trainingSeconds;
    map["weight"] = weight;
    map["albumNum"] = albumNum;
    return map;
  }



}