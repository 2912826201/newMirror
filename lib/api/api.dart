import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import 'basic_api.dart';

/// api
/// Created by yangjiayi on 2020/10/26.

//超时时长 单位毫秒
const int _CONNECT_TIMEOUT = 10000;
const int _RECEIVE_TIMEOUT = 20000;

///服务端接口返回code
//成功
const int CODE_SUCCESS = 200;
//无法描述无法应对的服务端异常
const int CODE_SERVER_ERROR = 500;
//未登录或token异常
const int CODE_NOT_LOGIN = 302;
//数据异常：直播课程预约失败-时间不对
const int CODE_DATA_EXCEPTION = 321;
//群聊不存在
const int CODE_GROUP_NOT_EXISTS = 315;
//无权限：邀请进入群聊--你不是群员
const int CODE_NO_AUTH = 305;
//入参错误
const int CODE_PARAMETER_ERROR = 300;
// 拉黑
const int CODE_BLACKED = 353;
// 没有找到回复的主体
const int CODE_NO_DATA = 404;
//验证码错误或。。
const int CODE_ERROR = 304;
//验证码过期或。。、
const int CODE_EXPIRED = 309;
//身份认证的类型
const int AUTH_TYPE_COMMON = 0;
const int AUTH_TYPE_NONE = 1;
const int AUTH_TYPE_TEMP = 2;

//请求方法
const String METHOD_GET = "get";
const String METHOD_POST = "post";

Dio _dioGet;
Dio _dioPost;

//通用的请求api的方法，请在具体的子api中进行入参封装和结果处理 authType只在特定的接口中赋值
Future<BaseResponseModel> requestApi(String path, Map<String, dynamic> queryParameters,
    {int authType = AUTH_TYPE_COMMON, String requestMethod = METHOD_POST, bool autoHandleLogout = true,
      CancelToken token}) async {
  BaseResponseModel responseModel;
  try {
    Response response;
    if (requestMethod == METHOD_GET) {
      _setHeaders(authType, _getDioGetInstance());
      response = await _getDioGetInstance().get(path, queryParameters: queryParameters);
      print("response：${response.toString()}");
    } else {
      _setHeaders(authType, _getDioPostInstance());
      response = await _getDioPostInstance().post(path, queryParameters: queryParameters,cancelToken: token);
    }
    responseModel = BaseResponseModel.fromJson(json.decode(response.toString()));
    //302为未登录 一般统一自动处理 登出清数据断开一些组件连接等操作
    if (responseModel.code == CODE_NOT_LOGIN && autoHandleLogout) {
      responseModel.isSuccess = false;
      //如果用户是已登录非匿名状态 则走登出流程，匿名状态则重新获取token重新请求接口
      if (Application.token != null && Application.token.anonymous == 0) {
        Application.appLogout(isKicked: true);
        return responseModel;
      } else {
        print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫进入了匿名用户重新获取token流程🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
        //先取个匿名token
        BaseResponseModel tokenResponse = await login("anonymous", null, null, null);
        if (tokenResponse != null && tokenResponse.code == 200) {
          TokenModel tokenModel = TokenModel.fromJson(tokenResponse.data);
          TokenDto tokenDto = TokenDto.fromTokenModel(tokenModel);
          //如果本来就是匿名token那么换个token就行 不用清任何东西也不用跳转页面
          await TokenDBHelper().insertToken(tokenDto);
          Application.appContext.read<TokenNotifier>().setToken(tokenDto);
          //替换完token后重新请求原本请求的接口
          return await requestApi(path, queryParameters,
              authType: authType, requestMethod: requestMethod, autoHandleLogout: autoHandleLogout);
        } else {
          ToastShow.show(msg: tokenResponse.message, context: Application.appContext);
          //失败的情况下 登出将无token可用 所以不能继续登出
          print("🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫重新获取token流程获取token失败🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫");
          return responseModel;
        }
      }
    } else {
      //要注意 只有服务端系统错误500被视为失败 其他错误码要在具体业务中处理
      responseModel.isSuccess = responseModel.code != CODE_SERVER_ERROR;
      return responseModel;
    }
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

/*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
void cancelRequests({CancelToken token}) {
  if (token == null) {
    var token1 = CancelToken();
    print("取消请求");
    token1.cancel("cancelled");
  } else {
    print("取消请求1");
    token.cancel("cancelled");
  }
}

//获取dio单例
Dio _getDioPostInstance() {
  if (_dioPost == null) {
    _dioPost = Dio();
    _dioPost.options.baseUrl = AppConfig.getApiHost();
    _dioPost.options.connectTimeout = _CONNECT_TIMEOUT;
    _dioPost.options.receiveTimeout = _RECEIVE_TIMEOUT;
    //TODO 还需要更多详细的参数
    //设置拦截器用于打印log
    _dioPost.interceptors.add(_LogInterceptors());

    // (_dioPost.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   //这一段是解决安卓https抓包的问题
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) {
    //     return Platform.isAndroid;
    //   };
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.10.117:8888";
    //   };
    // };
  }
  return _dioPost;
}

Dio _getDioGetInstance() {
  if (_dioGet == null) {
    _dioGet = Dio();
    _dioGet.options.connectTimeout = _CONNECT_TIMEOUT;
    _dioGet.options.receiveTimeout = _RECEIVE_TIMEOUT;
    //TODO 还需要更多详细的参数
    //设置拦截器用于打印log
    _dioGet.interceptors.add(_LogInterceptors());

    // (_dioGet.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   //这一段是解决安卓https抓包的问题
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) {
    //     return Platform.isAndroid;
    //   };
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.10.117:8888";
    //   };
    // };
  }
  return _dioGet;
}

//因为APP运行过程中 headers的参数可能发生变化 所以不能在初始化时写死
//TODO 每次请求时都要设置headers是否会降低网络请求效率有待测试对比
//FIXME 如果token已过期或即将过期则需要做刷新token或重新获取token的操作
void _setHeaders(int authType, Dio dio) {
  //TODO 渠道号暂时写死
  dio.options.headers["aimy-drivers"] =
      "{\"os\":${Application.platform},\"clientVersion\":\"${AppConfig.version}\",\"channel\":0}";
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
  dio.options.headers["Authorization"] = auth;
  dio.options.headers["user-agent"] = "IFITNESS";
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
