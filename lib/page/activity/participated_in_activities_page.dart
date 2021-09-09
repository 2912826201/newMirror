import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/page/activity/util/activity_default_map.dart';
import 'package:mirror/page/activity/util/activity_loading.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'activity_page.dart';

class ParticipatedInActivitiesPage extends StatefulWidget {
  @override
  _ParticipatedInActivitiesPageState createState() => _ParticipatedInActivitiesPageState();
}

class _ParticipatedInActivitiesPageState extends State<ParticipatedInActivitiesPage> {
  List<ActivityModel> activityList = [];
  int lastTime;
  int activityHasNext;
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  // 是否显示缺省图
  bool isShowDefaultMap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestActivity();
  }

  // 请求活动接口数据
  requestActivity({bool isRefresh = false}) async {
    if (isRefresh) {
      activityHasNext = null;
      _refreshController.loadComplete();
      lastTime = null;
    }
    if (activityHasNext != 0) {
      DataResponseModel model = await getMyJoinActivityList(lastTime: lastTime);
      if (isRefresh) {
        activityList.clear();
      }
      if (model != null) {
        lastTime = model.lastTime;
        activityHasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            activityList.add(ActivityModel.fromJson(v));
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
            PrimaryScrollController.of(context).jumpTo(0);
          } else {
            _refreshController.loadComplete();
          }
        }
      } else {
        if (isRefresh) {
          _refreshController.refreshCompleted();
          PrimaryScrollController.of(context).jumpTo(0);
        } else {
          _refreshController.loadComplete();
        }
      }
    } else {
      if (isRefresh) {
        _refreshController.refreshCompleted();
        PrimaryScrollController.of(context).jumpTo(0);
      } else {
        _refreshController.loadFailed();
      }
    }
    if (activityHasNext == 0) {
      if (isRefresh) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
        PrimaryScrollController.of(context).jumpTo(0);
      } else {
        _refreshController.loadNoData();
      }
    }
    if (activityList.length > 0) {
      isShowDefaultMap = false;
    } else {
      isShowDefaultMap = true;
    }
    print("activityList::::${activityList.length}");
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      appBar: CustomAppBar(
        titleString: "参加过的活动",
      ),
      body: isShowDefaultMap == null
          ? ActivityLoading()
          : SmartRefresher(
              enablePullUp: true,
              enablePullDown: true,
              footer: SmartRefresherHeadFooter.init().getFooter(),
              header: SmartRefresherHeadFooter.init().getHeader(),
              controller: _refreshController,
              onLoading: () {
                requestActivity(isRefresh: false);
              },
              onRefresh: () {
                requestActivity(isRefresh: true);
              },
              child: isShowDefaultMap
                  ? ActivityDefaultMap()
                  : ListView.builder(
                      itemCount: activityList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        interceptText(activityList[index]);
                        return ActivityListItem(
                          activityModel: activityList[index],
                          index: index,
                        );
                      })),
    );
  }
}
