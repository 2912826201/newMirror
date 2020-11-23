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
const int CODE_SERVER_ERROR = 500;

Dio _dio;

//通用的请求api的方法，请在具体的子api中进行入参封装和结果处理
Future<BaseResponseModel> requestApi(String path, Map<String, dynamic> queryParameters) async {
  BaseResponseModel responseModel;
  try {
    _setHeaders(true);
    Response response = await _getDioInstance().post(path, queryParameters: queryParameters);
    responseModel = BaseResponseModel.fromJson(json.decode(response.toString()));
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

//通用的请求api的方法，请在具体的子api中进行入参封装和结果处理
Future<BaseResponseModel> requestApiWithoutAuth(String path, Map<String, dynamic> queryParameters) async {
  BaseResponseModel responseModel;
  try {
    _setHeaders(false);
    Response response = await _getDioInstance().post(path, queryParameters: queryParameters);
    responseModel = BaseResponseModel.fromJson(json.decode(response.toString()));
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
void _setHeaders(bool hasAuth) {
  //TODO 暂时写死
  _getDioInstance().options.headers["aimy-drivers"] = "{\"os\":0,\"clientVersion\":\"1.0.0\",\"channel\":0}";
  _getDioInstance().options.headers["Authorization"] = hasAuth?
      "bearer ${Application.token == null? "" : Application.token.accessToken}"
      : "Basic dXNlckFwcDpBaW15Rml0bmVzcw==";
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
