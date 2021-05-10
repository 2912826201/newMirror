/// machine_model
/// Created by yangjiayi on 2021/1/29.

// 机器信息
class MachineModel {
  // 0-未登录机器 1-登录了机器
  int isConnect;

  // 机器状态 0-机器离线 1-机器休眠 2-机器唤醒 3-游戏中
  int status;

  // 机器ID
  int machineId;

  // 0-100
  int luminance;

  // 0-100
  int volume;

  String name;
  String deviceNumber;
  String sysVersion;
  String wifi;
  int inGame;
  int pause;
  int index;
  int courseId;
  int type;
  int progressBar;
  int timestamp;
  int startCourse;
  int liveRoomId;

  MachineModel(
      {this.isConnect,
      this.status,
      this.machineId,
      this.luminance,
      this.volume,
      this.name,
      this.deviceNumber,
      this.sysVersion,
      this.wifi,
      this.inGame,
      this.pause,
      this.index,
      this.courseId,
      this.type,
      this.progressBar,
      this.timestamp,
      this.startCourse,
      this.liveRoomId});

  MachineModel.fromJson(Map<String, dynamic> json) {
    isConnect = json["isConnect"];
    status = json["status"];
    machineId = json["machineId"];
    luminance = json["luminance"];
    volume = json["volume"];
    name = json["name"];
    deviceNumber = json["deviceNumber"];
    sysVersion = json["sysVersion"];
    wifi = json["wifi"];
    inGame = json["inGame"];
    pause = json["pause"];
    index = json["index"];
    courseId = json["courseId"];
    type = json["type"];
    progressBar = json["progressBar"];
    timestamp = json["timestamp"];
    startCourse = json["startCourse"];
    liveRoomId = json["liveRoomId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["isConnect"] = isConnect;
    map["status"] = status;
    map["machineId"] = machineId;
    map["luminance"] = luminance;
    map["volume"] = volume;
    map["name"] = name;
    map["deviceNumber"] = deviceNumber;
    map["sysVersion"] = sysVersion;
    map["wifi"] = wifi;
    map["inGame"] = inGame;
    map["pause"] = pause;
    map["index"] = index;
    map["courseId"] = courseId;
    map["type"] = type;
    map["progressBar"] = progressBar;
    map["timestamp"] = timestamp;
    map["startCourse"] = startCourse;
    map["liveRoomId"] = liveRoomId;
    return map;
  }
}
