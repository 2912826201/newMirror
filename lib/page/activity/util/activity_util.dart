import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/util/toast_util.dart';

class ActivityUtil {
  static ActivityUtil _util;

  static ActivityUtil init() {
    if (_util == null) {
      _util = ActivityUtil();
    }
    return _util;
  }

  Future<bool> joinByInvitationActivity(BuildContext context, int activityId) async {
    ActivityModel model = await getActivityDetailApi(activityId);
    if (model == null) {
      ToastShow.show(msg: "活动已经失效了", context: context);
      return false;
    }
    if (model.status == 3) {
      ToastShow.show(msg: "活动已经结束了", context: context);
      return false;
    }
    if (model.status == 1) {
      ToastShow.show(msg: "活动已经招募满了", context: context);
      return false;
    }
    bool isJoinByInvitation = await joinByInvitation(activityId, Application.profile.uid);

    if (isJoinByInvitation) {
      return true;
    } else {
      ToastShow.show(msg: "参加失败", context: context);
      return false;
    }
  }
}
