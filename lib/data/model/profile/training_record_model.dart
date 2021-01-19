/// data : {"list":[{"finishTime":"2021-01-14","courseModelList":[{"id":63,"targetId":1,"title":"测试","type":1,"createTime":1610600221764,"calorie":0,"finishTime":"2021-01-14","mseconds":75000,"no":17},{"id":62,"targetId":1,"title":"测试","type":1,"createTime":1610600050317,"calorie":0,"finishTime":"2021-01-14","mseconds":75000,"no":16},{"id":61,"targetId":1,"title":"测试","type":1,"createTime":1610598722322,"calorie":10,"finishTime":"2021-01-14","mseconds":1000000,"no":15}],"dmsecondsCount":1150000,"dcalorieCount":10},{"finishTime":"2021-01-12","courseModelList":[{"id":50,"targetId":1,"title":"测试","type":1,"createTime":1610447863972,"calorie":100,"finishTime":"2021-01-12","mseconds":100,"no":13},{"id":49,"targetId":1,"title":"测试","type":1,"createTime":1610447355184,"calorie":100,"finishTime":"2021-01-12","mseconds":100,"no":12},{"id":48,"targetId":1,"title":"测试","type":1,"createTime":1610447347141,"calorie":100,"finishTime":"2021-01-12","mseconds":100,"no":11},{"id":47,"targetId":1,"title":"测试","type":1,"createTime":1610447340662,"calorie":100,"finishTime":"2021-01-12","mseconds":100,"no":10},{"id":46,"targetId":1,"title":"测试","type":1,"createTime":1610447260341,"calorie":100,"finishTime":"2021-01-12","mseconds":100,"no":9},{"id":45,"targetId":1,"title":"测试","type":1,"createTime":1610445805370,"calorie":1000,"finishTime":"2021-01-12","mseconds":1000,"no":8},{"id":44,"targetId":1,"title":"测试","type":1,"createTime":1610444301048,"calorie":100,"finishTime":"2021-01-12","mseconds":100,"no":7}],"dmsecondsCount":61600,"dcalorieCount":2200}]}
/// code : 200

/// finishTime : "2021-01-14"
/// courseModelList : [{"id":63,"targetId":1,"title":"测试","type":1,"createTime":1610600221764,"calorie":0,"finishTime":"2021-01-14","mseconds":75000,"no":17},{"id":62,"targetId":1,"title":"测试","type":1,"createTime":1610600050317,"calorie":0,"finishTime":"2021-01-14","mseconds":75000,"no":16},{"id":61,"targetId":1,"title":"测试","type":1,"createTime":1610598722322,"calorie":10,"finishTime":"2021-01-14","mseconds":1000000,"no":15}]
/// dmsecondsCount : 1150000
/// dcalorieCount : 10

class TrainingRecordModel {
  String finishTime;
  List<CourseModelList> courseModelList=<CourseModelList>[];
  int dmsecondsCount;
  int dcalorieCount;


  TrainingRecordModel({
      String finishTime, 
      List<CourseModelList> courseModelList, 
      int dmsecondsCount, 
      int dcalorieCount}){
    this.finishTime = finishTime;
    this.courseModelList = courseModelList;
    this.dmsecondsCount = dmsecondsCount;
    this.dcalorieCount = dcalorieCount;
}

  TrainingRecordModel.fromJson(dynamic json) {
    this.finishTime = json["finishTime"];
    if (json["courseModelList"] != null) {
      this.courseModelList = [];
      json["courseModelList"].forEach((v) {
        this.courseModelList.add(CourseModelList.fromJson(v));
      });
    }
    this.dmsecondsCount = json["dmsecondsCount"];
    this.dcalorieCount = json["dcalorieCount"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["finishTime"] = this.finishTime;
    if (this.courseModelList != null) {
      map["courseModelList"] = this.courseModelList.map((v) => v.toJson()).toList();
    }
    map["dmsecondsCount"] = this.dmsecondsCount;
    map["dcalorieCount"] = this.dcalorieCount;
    return map;
  }

}


//周
class TrainingRecordWeekModel {
  String dateString="";
  int dcalorieCount=0;
  int dmsecondsCount=0;
  int allCount=0;
  List<String> dataStringList=<String>[];
  List<int> dayListIndex=<int>[];
}

//月
class TrainingRecordMonthModel {
  String dateString="";
  int dcalorieCount=0;
  int dmsecondsCount=0;
  int allCount=0;
  List<String> dataStringList=<String>[];
  List<int> dayListIndex=<int>[];
}




/// id : 63
/// targetId : 1
/// title : "测试"
/// type : 1
/// createTime : 1610600221764
/// calorie : 0
/// finishTime : "2021-01-14"
/// mseconds : 75000
/// no : 17

class CourseModelList {
  int _id;
  int _targetId;
  String _title;
  int _type;
  int _createTime;
  int _calorie;
  String _finishTime;
  int _mseconds;
  int _no;

  int get id => _id;
  int get targetId => _targetId;
  String get title => _title;
  int get type => _type;
  int get createTime => _createTime;
  int get calorie => _calorie;
  String get finishTime => _finishTime;
  int get mseconds => _mseconds;
  int get no => _no;

  CourseModelList({
      int id, 
      int targetId, 
      String title, 
      int type, 
      int createTime, 
      int calorie, 
      String finishTime, 
      int mseconds, 
      int no}){
    _id = id;
    _targetId = targetId;
    _title = title;
    _type = type;
    _createTime = createTime;
    _calorie = calorie;
    _finishTime = finishTime;
    _mseconds = mseconds;
    _no = no;
}

  CourseModelList.fromJson(dynamic json) {
    _id = json["id"];
    _targetId = json["targetId"];
    _title = json["title"];
    _type = json["type"];
    _createTime = json["createTime"];
    _calorie = json["calorie"];
    _finishTime = json["finishTime"];
    _mseconds = json["mseconds"];
    _no = json["no"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["targetId"] = _targetId;
    map["title"] = _title;
    map["type"] = _type;
    map["createTime"] = _createTime;
    map["calorie"] = _calorie;
    map["finishTime"] = _finishTime;
    map["mseconds"] = _mseconds;
    map["no"] = _no;
    return map;
  }

}