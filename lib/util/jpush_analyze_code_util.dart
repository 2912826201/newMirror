import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class JpushAnalyzeCodeUtil {
  static JpushAnalyzeCodeUtil _util;

  static JpushAnalyzeCodeUtil init() {
    if (_util == null) {
      _util = JpushAnalyzeCodeUtil();
    }
    return _util;
  }

  void _analyzeCode(String code) {
    if (code == null || code.length < 1) {
      print("极光代码解析----代码不能为空");
      return;
    }
    if (!(code.contains("if://redirect/"))) {
      print("极光代码解析----不是我们的代码或者不是已知的代码code:$code");
      return;
    }
    _startAnalyze(code);
  }

  void _startAnalyze(String code) {
    List<String> strs = code.split("?");
    String command = strs.first;
    Map<String, String> params = {};
    if (strs.length > 1) {
      List<String> paramsStrs = strs.last.split("&");
      paramsStrs.forEach((str) {
        params[str.split("=").first] = str.split("=").last;
      });
    }

    switch (command) {
      case "if://redirect/chat":
        print("极光代码解析----跳转聊天界面:code:$code");
        try {
          int targetId = int.parse(params["targetId"]);
          int type = int.parse(params["type"]);
          _jumpChatPageJudgeType(targetId, type);
        } catch (e) {
          print("极光代码解析----跳转聊天界面--参数错误:code:$code");
        }
        break;
    }
  }

  void _jumpChatPageJudgeType(int targetId, int type) {
    switch (type) {
      case RCConversationType.Private:
        print("极光代码解析-聊天--私聊");

        break;
      case RCConversationType.Group:
        print("极光代码解析-聊天--群聊");
        break;
      case RCConversationType.ChatRoom:
        print("极光代码解析-聊天--聊天室");
        break;
      case RCConversationType.System:
        print("极光代码解析-聊天--系统消息");
        break;
      default:
        print("极光代码解析-聊天--未知消息");
        break;
    }
  }
}
