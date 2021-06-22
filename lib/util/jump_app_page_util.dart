import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/jump_app_page_model.dart';
import 'package:mirror/route/router.dart';

import 'event_bus.dart';

class JumpAppPageUtil {
  static JumpAppPageUtil _util;

  BuildContext _context;

  static JumpAppPageUtil init(BuildContext context) {
    if (_util == null) {
      _util = JumpAppPageUtil();
    }
    _util._context = context;
    return _util;
  }

  //跳转关注页
  jumpAttentionPage() {
    _jumpAppPage(JumpAppPageModel.AttentionPage);
  }

  //跳转推荐页
  jumpRecommendPage() {
    _jumpAppPage(JumpAppPageModel.RecommendPage);
  }

  //跳转训练页
  jumpTrainingPage() {
    _jumpAppPage(JumpAppPageModel.TrainingPage);
  }

  //跳转消息页
  jumpMessagePage() {
    _jumpAppPage(JumpAppPageModel.MessagePage);
  }

  //跳转我的页面
  jumpProfilePage() {
    _jumpAppPage(JumpAppPageModel.ProfilePage);
  }

  //跳转指定界面
  jumpPageType(int type) {
    if (type > 0 && type < 6) {
      _jumpAppPage(type);
    }
  }

  ///[JumpAppPageModel]
  void _jumpAppPage(int type) {
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
      Navigator.of(_context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
      EventBus.getDefault().post(msg: type, registerName: MAIN_PAGE_JUMP_PAGE);
    }
  }
}
