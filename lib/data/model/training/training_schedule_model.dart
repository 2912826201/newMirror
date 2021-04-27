/// pause : 1
/// index : 0
/// courseId : 65
/// uid : 1008051
/// progressBar : 7901
/// timestamp : 1619430327676
/// machineId : 101770

class TrainingScheduleModel {
  int _pause;
  int _index;
  int _courseId;
  int _uid;
  int _progressBar;
  int _timestamp;
  int _machineId;

  int get pause => _pause;
  int get index => _index;
  int get courseId => _courseId;
  int get uid => _uid;
  int get progressBar => _progressBar;
  int get timestamp => _timestamp;
  int get machineId => _machineId;

  TrainingScheduleModel({
      int pause, 
      int index, 
      int courseId, 
      int uid, 
      int progressBar, 
      int timestamp, 
      int machineId}){
    _pause = pause;
    _index = index;
    _courseId = courseId;
    _uid = uid;
    _progressBar = progressBar;
    _timestamp = timestamp;
    _machineId = machineId;
}

  TrainingScheduleModel.fromJson(dynamic json) {
    _pause = json["pause"];
    _index = json["index"];
    _courseId = json["courseId"];
    _uid = json["uid"];
    _progressBar = json["progressBar"];
    _timestamp = json["timestamp"];
    _machineId = json["machineId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["pause"] = _pause;
    map["index"] = _index;
    map["courseId"] = _courseId;
    map["uid"] = _uid;
    map["progressBar"] = _progressBar;
    map["timestamp"] = _timestamp;
    map["machineId"] = _machineId;
    return map;
  }

}