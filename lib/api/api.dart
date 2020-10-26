import 'package:dio/dio.dart';
import 'package:mirror/config.dart';

/// api
/// Created by yangjiayi on 2020/10/26.

//超时时长 单位毫秒
const int CONNECT_TIMEOUT = 10000;
const int RECEIVE_TIMEOUT = 20000;
const String DEV_HOST = "http://alitadev.aimymusic.com";
const String TEST_HOST = "https://alitamirror.aimymusic.com";
const String PROD_HOST = "https://alita.aimymusic.com";

Dio _dio;

Future<String> requestApi(String path, Map<String, dynamic> queryParameters) async{
  try {
    setHeaders();
    Response response = await getDioInstance().post(path, queryParameters: queryParameters);
    print(response);
    return response.toString();
  } on DioError catch (e) {
    print(e);
    return null;
  }
}

Dio getDioInstance() {
  if (_dio == null) {
    _dio = Dio();
    _dio.options.baseUrl = getApiHost();
    _dio.options.connectTimeout = CONNECT_TIMEOUT;
    _dio.options.receiveTimeout = RECEIVE_TIMEOUT;
    //TODO 还需要更多详细的参数
  }
  return _dio;
}

//因为APP运行过程中 headers的参数可能发生变化 所以不能在初始化时写死
//TODO 每次请求时都要设置headers是否会降低网络请求效率有待测试对比
void setHeaders() {
  //TODO 暂时写死
  getDioInstance().options.headers["aimy-drivers"] =
  "{\"os\":0,\"clientVersion\":\"1.0.0\",\"channel\":0}";
  getDioInstance().options.headers["Authorization"] =
  "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiIxMDAwMTQyMTgwIiwidXNlcl9uYW1lIjoiMTAwMDE0MjE4MCIsInNjb3BlIjpbImFwcCIsInVjZW50ZXIiLCJiaWdkYXRhIiwidWFhIiwicHVibGljIiwicmVzb3VyY2UiLCJlcyJdLCJpc1Bob25lIjoxLCJpc1BlcmZlY3QiOjEsIm1pZCI6bnVsbCwiYW5vbnltb3VzIjowLCJleHAiOjE2MDYyNzMzNzYsImp0aSI6ImM0YTQxNGY4LWU5NjktNGI5Ny1iMTEyLTdiYjJlYjc5ZWYxMCIsImNsaWVudF9pZCI6Im11c2ljQXBwIn0.IWIh-UkCBqx6A3GgXDhwuSzmt-6dXnB_M79j67I7ST0";
}

String getApiHost() {
  switch (Config.ENV) {
    case Env.DEV:
      return "http://alitadev.aimymusic.com";
    case Env.TEST:
      return "https://alitamirror.aimymusic.com";
    case Env.PROD:
      return "https://alita.aimymusic.com";
  }
}
