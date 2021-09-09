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

  //通过邀请链接进入活动
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

//修改活动
  Future<List> updateActivityUtil(ActivityModel model,
      {int count, String cityCode, String address, String longitude, String latitude}) async {
    if (model == null) {
      return [false, "活动数据错误"];
    }
    if (count == null) count = model.count;
    if (cityCode == null) cityCode = model.cityCode;
    if (address == null) address = model.address;
    if (longitude == null) longitude = model.longitude.toString();
    if (latitude == null) latitude = model.latitude.toString();

    List list = await updateActivity(model.id, count, cityCode, address, longitude, latitude);

    return list;
  }
}
