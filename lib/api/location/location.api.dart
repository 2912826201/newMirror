
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';

//超时时长 单位毫秒
const int _CONNECT_TIMEOUT = 10000;
const int _RECEIVE_TIMEOUT = 20000;
class Config {
  String base_url = "https://restapi.amap.com/v3/place";
  int connectTimeout = _CONNECT_TIMEOUT;
  int receiveTimeout = _RECEIVE_TIMEOUT;
}

/**
 * 通过网络请求工具
 */
class Http {
  static Http instance;
  static String token;
  Config _config = new Config();
  Dio _dio;

  static Http getInstance() {
    if (instance == null) {
      instance = new Http();
    }
    return instance;
  }

  Http() {
    // 初始化 Options
    _dio = new Dio();
    _dio.options.baseUrl = _config.base_url;
    _dio.options.connectTimeout = _config.connectTimeout;
    _dio.options.receiveTimeout = _config.receiveTimeout;
    // _dio.options.headers["aimy-drivers"] =
    // "{\"os\":${Application.platform},\"clientVersion\":\"${AppConfig.version}\",\"channel\":0}";
    // _dio.options.headers["Authorization"] = Application.token.accessToken;
    // _dio.options.headers["user-agent"] = "IFITNESS";
    //https证书校验
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      // 在请求被发送之前做一些事情
      // Map<String,dynamic> _headers = options.headers["aimy-drivers"] = "{\"os\":${Application.platform},\"clientVersion\":\"${AppConfig.version}\",\"channel\":0}";]??{};
      print("\n================== 请求数据 ==========================");
      print("url = ${options.uri.toString()}");
      print("headers = ${options.headers}");
      return options; //continue
      // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
      //
      // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      // 在返回响应数据之前做一些预处理
      print("================== 响应数据 ==========================");
      print("statusCode：${response.statusCode}");
      print("response.data：${response.data}");
      return response;
    }, onError: (DioError err, ErrorInterceptorHandler handler) {
      // 当请求失败时做一些预处理
      return err; //continue
    }));
  }

  Dio get dio {
    return _dio;
  }
}