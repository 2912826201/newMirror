/// targetWeight : 60.0
/// recordList : [{"id":109,"weight":55.0,"dateTime":"2021-04-13"}]

class WeightRecordsModel {
  double targetWeight;
  List<RecordData> recordList;


  WeightRecordsModel({
      double targetWeight, 
      List<RecordData> recordList}){
    this.targetWeight = targetWeight;
    this.recordList = recordList;
}

  WeightRecordsModel.fromJson(dynamic json) {
    this.targetWeight = json["targetWeight"];
    if (json["recordList"] != null) {
      this.recordList = [];
      json["recordList"].forEach((v) {
        this.recordList.add(RecordData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["targetWeight"] = this.targetWeight;
    if (this.recordList != null) {
      map["recordList"] = this.recordList.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 109
/// weight : 55.0
/// dateTime : "2021-04-13"

class RecordData {
  int id;
  double weight;
  String dateTime;

  RecordData({
      int id, 
      double weight, 
      String dateTime}){
    this.id = id;
    this.weight = weight;
    this.dateTime = dateTime;
}

  RecordData.fromJson(dynamic json) {
    this.id = json["id"];
    this.weight = json["weight"];
    this.dateTime = json["dateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = this.id;
    map["weight"] = this.weight;
    map["dateTime"] = this.dateTime;
    return map;
  }

}