import 'package:flutter/cupertino.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/model/jump_app_page_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';

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

  //跳转活动页面
  jumpActivityPage() {
    _jumpAppPage(JumpAppPageModel.ActivityPage);
  }

  //跳转指定界面
  jumpPageType(int type) {
    if (type > 0 && type <= JumpAppPageModel.PageSize) {
      _jumpAppPage(type);
    }
  }

  ///[JumpAppPageModel]
  void _jumpAppPage(int type) {
    switch (type) {
      case JumpAppPageModel.AttentionPage:
        //关注页
        print("跳转界面-app界面-关注页");
        break;
      case JumpAppPageModel.RecommendPage:
        //推荐页
        print("跳转界面-app界面-推荐页");
        break;
      case JumpAppPageModel.TrainingPage:
        //训练页
        print("跳转界面-app界面-训练页");
        if (!AppConfig.needShowTraining) {
          print("没有打开训练模式");
          return;
        }
        break;
      case JumpAppPageModel.MessagePage:
        //消息页
        print("跳转界面-app界面-消息页");
        if (!(_context.read<TokenNotifier>().isLoggedIn)) {
          ToastShow.show(msg: "请先登录app!", context: _context);
          return;
        }
        break;
      case JumpAppPageModel.ProfilePage:
        //我的页面
        print("跳转界面-app界面-我的页面");
        if (!(_context.read<TokenNotifier>().isLoggedIn)) {
          ToastShow.show(msg: "请先登录app!", context: _context);
          return;
        }
        break;
      case JumpAppPageModel.ActivityPage:
        //活动页
        print("跳转界面-app界面-活动页");
        if (AppConfig.needShowTraining) {
          print("没有关闭训练模式");
          return;
        }
        break;
      default:
        print("跳转界面-app界面-未知界面");
        return;
    }
    if (type > 0 && type <= JumpAppPageModel.PageSize) {
      Navigator.of(_context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
      EventBus.getDefault().post(msg: type, registerName: MAIN_PAGE_JUMP_PAGE);
    }
  }
}
