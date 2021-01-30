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

  MachineModel(
      {this.isConnect,
      this.status,
      this.machineId,
      this.luminance,
      this.volume,
      this.name,
      this.deviceNumber,
      this.sysVersion,
      this.wifi});

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
    return map;
  }
}
