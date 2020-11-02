/// base_response
/// Created by yangjiayi on 2020/11/2.

class BaseResponseModel {
  BaseResponseModel(this.code, this.data, this.message);

  int code;
  String data;
  String message;
}