/// timesCount : 5
/// calorieCount : 414
/// dayCount : 1
/// clockCount : 0
/// msecondsCount : 3540000

class TrainingRecordAllModel {
  //次数
  int _timesCount;
  //卡路里
  int _calorieCount;
  //天数
  int _dayCount;
  //打卡
  int _clockCount;
  //毫秒
  int _msecondsCount;

  int get timesCount => _timesCount;
  int get calorieCount => _calorieCount;
  int get dayCount => _dayCount;
  int get clockCount => _clockCount;
  int get msecondsCount => _msecondsCount;

  TrainingRecordAllModel({
      int timesCount, 
      int calorieCount, 
      int dayCount, 
      int clockCount, 
      int msecondsCount}){
    _timesCount = timesCount;
    _calorieCount = calorieCount;
    _dayCount = dayCount;
    _clockCount = clockCount;
    _msecondsCount = msecondsCount;
}

  TrainingRecordAllModel.fromJson(dynamic json) {
    _timesCount = json["timesCount"];
    _calorieCount = json["calorieCount"];
    _dayCount = json["dayCount"];
    _clockCount = json["clockCount"];
    _msecondsCount = json["msecondsCount"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["timesCount"] = _timesCount;
    map["calorieCount"] = _calorieCount;
    map["dayCount"] = _dayCount;
    map["clockCount"] = _clockCount;
    map["msecondsCount"] = _msecondsCount;
    return map;
  }

}