import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/base_response_model.dart';
import '../config/config.dart';

/// api
/// Created by yangjiayi on 2020/10/26.

//超时时长 单位毫秒
const int _CONNECT_TIMEOUT = 10000;
const int _RECEIVE_TIMEOUT = 20000;

//服务端接口返回code
const int CODE_SUCCESS = 200;
const int CODE_SERVER_ERROR = 500;

//身份认证的类型
const int AUTH_TYPE_COMMON = 0;
const int AUTH_TYPE_NONE = 1;
const int AUTH_TYPE_TEMP = 2;

Dio _dio;

//通用的请求api的方法，请在具体的子api中进行入参封装和结果处理 authType只在特定的接口中赋值
Future<BaseResponseModel> requestApi(String path, Map<String, dynamic> queryParameters,
    {int authType = AUTH_TYPE_COMMON}) async {
  BaseResponseModel responseModel;
  try {
    _setHeaders(authType);
    Response response = await _getDioInstance().post(path, queryParameters: queryParameters);
    responseModel = BaseResponseModel.fromJson(json.decode(response.toString()));
    //要注意 只有服务端系统错误500被视为失败 其他错误码要在具体业务中处理
    responseModel.isSuccess = responseModel.code != CODE_SERVER_ERROR;
    return responseModel;
  } on DioError catch (e) {
    responseModel = BaseResponseModel(message: e.message);
    responseModel.isSuccess = false;
    return responseModel;
  } catch (e) {
    responseModel = BaseResponseModel(message: "Unknown error");
    responseModel.isSuccess = false;
    return responseModel;
  }
}

//获取dio单例
Dio _getDioInstance() {
  if (_dio == null) {
    _dio = Dio();
    _dio.options.baseUrl = AppConfig.getApiHost();
    _dio.options.connectTimeout = _CONNECT_TIMEOUT;
    _dio.options.receiveTimeout = _RECEIVE_TIMEOUT;
    //TODO 还需要更多详细的参数
    //设置拦截器用于打印log
    _dio.interceptors.add(_LogInterceptors());
  }
  return _dio;
}

//因为APP运行过程中 headers的参数可能发生变化 所以不能在初始化时写死
//TODO 每次请求时都要设置headers是否会降低网络请求效率有待测试对比
//FIXME 如果token已过期或即将过期则需要做刷新token或重新获取token的操作
void _setHeaders(int authType) {
  //TODO 操作系统和版本号渠道号暂时写死
  _getDioInstance().options.headers["aimy-drivers"] = "{\"os\":0,\"clientVersion\":\"1.0.0\",\"channel\":0}";
  //授权认证信息根据个别请求不同取不同的token
  String auth;
  switch (authType) {
    case AUTH_TYPE_COMMON:
      auth = "bearer ${Application.token == null ? "" : Application.token.accessToken}";
      break;
    case AUTH_TYPE_NONE:
      auth = "Basic dXNlckFwcDpBaW15Rml0bmVzcw==";
      break;
    case AUTH_TYPE_TEMP:
      auth = "bearer ${Application.tempToken == null ? "" : Application.tempToken.accessToken}";
      break;
    default:
      auth = "";
  }
  _getDioInstance().options.headers["Authorization"] = auth;
}

//用于print log的拦截器
class _LogInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    print("REQUEST[${options?.headers}][${options?.queryParameters}] ==> URL: ${options?.baseUrl}${options?.path}");
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    print(
        "RESPONSE[${response?.statusCode}][${response?.data}] ==> URL: ${response?.request?.baseUrl}${response?.request?.path}");
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    print("ERROR[${err?.message}] ==> URL: ${err?.request?.baseUrl}${err?.request?.path}");
    return super.onError(err);
  }
}
