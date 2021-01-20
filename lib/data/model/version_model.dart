class VersionModel {
  int os; // 平台，0-安卓，1-ios
  String version; // 版本
  String url; // 包地址
  String channel; // 渠道
  int isForceUpdate; // 是否强更，0-不强更，1-强更
  String description; // 更新说明
  int versionCreator;
  int versionFileCreator;
  int dataState;
  int createTime;
  int updateTime;

  VersionModel(
      {this.version,
      this.url,
      this.description,
      this.createTime,
      this.channel,
      this.dataState,
      this.isForceUpdate,
      this.os,
      this.updateTime,
      this.versionCreator,
      this.versionFileCreator});

  VersionModel.fromJson(Map<String, dynamic> json) {
    print('===========================${json["version"]}');
    version = json["version"];
    url = json["url"];
    description = json["description"];
    createTime = json["createTime"];
    channel = json["channel"];
    dataState = json["dataState"];
    isForceUpdate = json["isForceUpdate"];
    os = json["os"];
    updateTime = json["updateTime"];
    versionCreator = json["versionCreator"];
    versionFileCreator = json["versionFileCreator"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["version"] = version;
    map["url"] = url;
    map["description"] = description;
    map["createTime"] = createTime;
    map["channel"] = channel;
    map["dataState"] = dataState;
    map["isForceUpdate"] = isForceUpdate;
    map["os"] = os;
    map["updateTime"] = updateTime;
    map["versionCreator"] = versionCreator;
    map["versionFileCreator"] = versionFileCreator;

    return map;
  }
}
