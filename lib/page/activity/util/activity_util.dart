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

  Future<List> joinByInvitationActivity(BuildContext context, int activityId) async {
    ActivityModel model = await getActivityDetailApi(activityId);
    if (model == null) {
      return [false, "活动已经失效了"];
    }
    if (model.status == 3) {
      return [false, "活动已经结束了"];
    }
    if (model.status == 1) {
      return [false, "活动已经招募满了"];
    }
    List list = await joinByInvitation(activityId, Application.profile.uid);

    return list;
  }
}
