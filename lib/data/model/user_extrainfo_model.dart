


class UserExtraInfoModel{
  int uid;
  int trainingSeconds;
  double weight;
  int albumNum;

  UserExtraInfoModel(
    {this.uid =0,
      this.trainingSeconds = 0,
      this.weight = 0,
      this.albumNum = 0,
    });

  UserExtraInfoModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    trainingSeconds = json["trainingSeconds"]==null?0:json["trainingSeconds"];
    weight = json["weight"]==null?0:json["weight"];
    albumNum = json["albumNum"]==null?0:json["albumNum"];
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