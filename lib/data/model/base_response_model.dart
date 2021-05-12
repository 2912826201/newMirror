/// base_response_model
/// Created by yangjiayi on 2020/11/2.

class BaseResponseModel {
  //这个属性是服务端接口返回体中没有的，用于清晰判断请求是否成功
  bool isSuccess;

  Map<String, dynamic> data;
  int code;
  String message;

  BaseResponseModel({this.data, this.code, this.message});

  BaseResponseModel.fromJson(Map<String, dynamic> json) {
    data = json["data"];
    code = json["code"];
    message = json["message"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["data"] = data;
    map["code"] = code;
    map["message"] = message;
    return map;
  }
}
