import 'api.dart';

/// user_api
/// Created by yangjiayi on 2020/10/26.

const String USER_SEARCH = "/app/web/user/search";

//TODO 这里实际需要将请求结果处理为具体的业务数据
Future<String> requestUserSearch(String key, int size, bool requestNext) {
  return requestApi(USER_SEARCH, {"key": key, "size": size, "requestNext": requestNext ? 1 : 0});
}
