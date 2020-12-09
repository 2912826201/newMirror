/// upload_result_model
/// Created by yangjiayi on 2020/12/9.

class UploadResultModel {
  bool isSuccess;
  String error;
  String filePath;
  String url;
}

class UploadResults {
  bool isSuccess;
  Map<String, UploadResultModel> resultMap = {};
}