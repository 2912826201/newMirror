/// upload_result_model
/// Created by yangjiayi on 2020/12/9.

class UploadResultModel {
  bool isSuccess;
  String error;
  String filePath;
  String url;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["isSuccess"] = isSuccess;
    map["error"] = error;
    map["filePath"] = filePath;
    map["url"] = url;
    return map;
  }
}

class UploadResults {
  bool isSuccess;
  Map<String, UploadResultModel> resultMap = {};
}