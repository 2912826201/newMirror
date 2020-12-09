/// qiniu_token_model
/// Created by yangjiayi on 2020/11/23.

//七牛token
class QiniuTokenModel {
  String upToken;
  String domain;

  QiniuTokenModel({this.upToken, this.domain});

  QiniuTokenModel.fromJson(Map<String, dynamic> json) {
    upToken = json["upToken"];
    domain = json["domain"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["upToken"] = upToken;
    map["domain"] = domain;
    return map;
  }
}
