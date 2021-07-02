import 'package:flutter/cupertino.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/jump_app_page_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/user_model.dart';
import '../page/message/util/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/jump_app_page_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'event_bus.dart';

//解析推送代码
//代码说明网址:https://shimo.im/docs/RgXjVRj6TxjVPyjR
class JpushAnalyzeCodeUtil {
  static JpushAnalyzeCodeUtil _util;

  static JpushAnalyzeCodeUtil init() {
    if (_util == null) {
      _util = JpushAnalyzeCodeUtil();
    }
    return _util;
  }

  void analyzeCode(String code) {
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
    BuildContext context = Application.navigatorKey.currentState.overlay.context;
    switch (command) {
      case "if://redirect/user":
        print("极光代码解析----跳转用户详情界面:code:$code");
        try {
          int userId = int.parse(params["userId"]);
          jumpToUserProfilePage(context, userId);
        } catch (e) {
          print("极光代码解析----跳转用户详情界面--参数错误:code:$code");
        }
        break;
      case "if://redirect/feed":
        print("极光代码解析----跳转动态详情页:code:$code");
        try {
          int feedId = int.parse(params["feedId"]);
          getFeedDetail(feedId, context);
        } catch (e) {
          print("极光代码解析----跳转动态详情页--参数错误:code:$code");
        }
        break;
      case "if://redirect/topic":
        print("极光代码解析----跳转话题详情页:code:$code");
        try {
          int topicId = int.parse(params["topicId"]);
          AppRouter.navigateToTopicDetailPage(context, topicId);
        } catch (e) {
          print("极光代码解析----跳转话题详情页--参数错误:code:$code");
        }
        break;
      case "if://redirect/promotion":
        print("极光代码解析----跳转活动界面:code:$code");
        print("活动暂时没有定");
        break;
      case "if://redirect/course":
        print("极光代码解析----跳转课程界面:code:$code");
        try {
          int courseId = int.parse(params["courseId"]);
          int type = int.parse(params["type"]);
          //0-直播课程，1-视频课程
          if (type == 0) {
            AppRouter.navigateToLiveDetail(context, courseId);
          } else if (type == 1) {
            AppRouter.navigateToVideoDetail(context, courseId);
          } else {
            print("极光代码解析----跳转课程界面--未知课程:code:$code");
          }
        } catch (e) {
          print("极光代码解析----跳转课程界面--参数错误:code:$code");
        }
        break;
      case "if://redirect/html5":
        print("极光代码解析----跳转H5界面:code:${params["url"]}");
        var uri = Uri.decodeFull(params["url"]); //反编码
        if (StringUtil.isURL(uri)) {
          StringUtil.launchUrl(uri, context);
        }
        break;
      case "if://redirect/page/if":
        print("极光代码解析----跳转app界面:code:$code");
        try {
          int type = int.parse(params["type"]);
          _jumpAppPage(type, context);
        } catch (e) {
          print("极光代码解析----跳转聊天界面--参数错误:code:$code");
        }
        break;
      case "if://redirect/chat":
        print("极光代码解析----跳转聊天界面:code:$code");
        try {
          int targetId = int.parse(params["targetId"]);
          int type = int.parse(params["type"]);
          _jumpChatPageJudgeType(targetId, type, context);
        } catch (e) {
          print("极光代码解析----跳转聊天界面--参数错误:code:$code");
        }
        break;
    }
  }

// // app界面id
//   class PageType {
//   static const int AttentionPage = 1;//关注页
//   static const int RecommendPage = 2;//推荐页
//   static const int TrainingPage= 3;//训练页
//   static const int MessagePage = 4;//消息页
//   static const int ProfilePage = 5;//我的页面
//   }

  ///[JumpAppPageModel]
  void _jumpAppPage(int type, BuildContext context) {
    switch (type) {
      case 1:
        //关注页
        print("极光代码解析-app界面-关注页");
        break;
      case 2:
        //推荐页
        print("极光代码解析-app界面-推荐页");
        break;
      case 3:
        //训练页
        print("极光代码解析-app界面-训练页");
        break;
      case 4:
        //消息页
        print("极光代码解析-app界面-消息页");
        break;
      case 5:
        //我的页面
        print("极光代码解析-app界面-我的页面");
        break;
      default:
        print("极光代码解析-app界面-未知界面");
        break;
    }
    if (type > 0 && type < 6) {
      JumpAppPageUtil.init(context).jumpPageType(type);
    }
  }

  void _jumpChatPageJudgeType(int targetId, int type, BuildContext context) async {
    switch (type) {
      case RCConversationType.Private:
        print("极光代码解析-聊天--私聊");
        UserModel userModel = await getUserInfo(uid: targetId);
        if (userModel != null) {
          jumpChatPageUser(context, userModel);
        } else {
          print("极光代码解析-聊天--私聊-用户为空targetId:$targetId");
        }
        break;
      case RCConversationType.Group:
        print("极光代码解析-聊天--群聊");
        List<GroupChatModel> list = await getGroupChatByIds(id: targetId);
        if (list != null && list.length > 0) {
          jumpGroupPage(context, list.first.name, targetId);
        } else {
          print("极光代码解析-聊天--群聊-群聊信息为空targetId:$targetId");
        }
        break;
      case RCConversationType.ChatRoom:
        print("极光代码解析-聊天--聊天室");
        print("暂不做聊天室的解析");
        break;
      case RCConversationType.System:
        print("极光代码解析-聊天--系统消息");
        if (targetId == OFFICIAL_TYPE) {
          jumpChatPageSystem(context, targetId.toString());
        } else {
          print("极光代码解析-聊天--系统消息-暂不支持其他系统消息targetId:$targetId");
        }
        break;
      default:
        print("极光代码解析-聊天--未知消息");
        break;
    }
  }
}
