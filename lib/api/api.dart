import 'package:dio/dio.dart';
import 'package:mirror/config.dart';

/// api
/// Created by yangjiayi on 2020/10/26.

//超时时长 单位毫秒
const int CONNECT_TIMEOUT = 10000;
const int RECEIVE_TIMEOUT = 20000;
//各环境api请求基础路径
const String DEV_HOST = "http://alitadev.aimymusic.com";
const String MIRROR_HOST = "https://alitamirror.aimymusic.com";
const String PROD_HOST = "https://alita.aimymusic.com";

Dio _dio;

//通用的请求api的方法，请在具体的子api中进行入参封装和结果处理
//TODO 这里返回的出参是String，可能不能满足复杂的使用场景，需要考虑是否进一步封装
Future<String> requestApi(String path, Map<String, dynamic> queryParameters) async{
  try {
    _setHeaders();
    Response response = await _getDioInstance().post(path, queryParameters: queryParameters);
    return response.toString();
  } on DioError catch (e) {
    return null;
  }
}

//获取dio单例
Dio _getDioInstance() {
  if (_dio == null) {
    _dio = Dio();
    _dio.options.baseUrl = _getApiHost();
    _dio.options.connectTimeout = CONNECT_TIMEOUT;
    _dio.options.receiveTimeout = RECEIVE_TIMEOUT;
    //TODO 还需要更多详细的参数
    //设置拦截器用于打印log
    _dio.interceptors.add(LogInterceptors());
  }
  return _dio;
}

//因为APP运行过程中 headers的参数可能发生变化 所以不能在初始化时写死
//TODO 每次请求时都要设置headers是否会降低网络请求效率有待测试对比
void _setHeaders() {
  //TODO 暂时写死
  _getDioInstance().options.headers["aimy-drivers"] =
  "{\"os\":0,\"clientVersion\":\"1.0.0\",\"channel\":0}";
  _getDioInstance().options.headers["Authorization"] =
  "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiIxMDAwMTQyMTgwIiwidXNlcl9uYW1lIjoiMTAwMDE0MjE4MCIsInNjb3BlIjpbImFwcCIsInVjZW50ZXIiLCJiaWdkYXRhIiwidWFhIiwicHVibGljIiwicmVzb3VyY2UiLCJlcyJdLCJpc1Bob25lIjoxLCJpc1BlcmZlY3QiOjEsIm1pZCI6bnVsbCwiYW5vbnltb3VzIjowLCJleHAiOjE2MDYyNzMzNzYsImp0aSI6ImM0YTQxNGY4LWU5NjktNGI5Ny1iMTEyLTdiYjJlYjc5ZWYxMCIsImNsaWVudF9pZCI6Im11c2ljQXBwIn0.IWIh-UkCBqx6A3GgXDhwuSzmt-6dXnB_M79j67I7ST0";
}

//用于print log的拦截器
class LogInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    print("REQUEST[${options?.headers}][${options?.queryParameters}] ==> URL: ${options?.baseUrl}${options?.path}");
    return super.onRequest(options);
  }
  @override
  Future onResponse(Response response) {
    print("RESPONSE[${response?.statusCode}][${response?.data}] ==> URL: ${response?.request?.baseUrl}${response?.request?.path}");
    return super.onResponse(response);
  }
  @override
  Future onError(DioError err) {
    print("ERROR[${err?.message}] ==> URL: ${err?.request?.baseUrl}${err?.request?.path}");
    return super.onError(err);
  }
}

//根据环境获取api的host地址
String _getApiHost() {
  switch (AppConfig.ENV) {
    case Env.DEV:
      return DEV_HOST;
    case Env.MIRROR:
      return MIRROR_HOST;
    case Env.PROD:
      return PROD_HOST;
    default:
      return "";
  }
}
