import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'overscroll_behavior.dart';

///个人主页动态List
class ProfileDetailsList extends StatefulWidget {
  int type;
  int id;
  bool isMySelf;
  Key key;

  ProfileDetailsList({this.key, this.type, this.id, this.isMySelf});

  @override
  State<StatefulWidget> createState() {
    return ProfileDetailsListState();
  }
}

class ProfileDetailsListState extends State<ProfileDetailsList>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  ///动态model
  List<HomeFeedModel> followModel = [];
  List<int> feedIdList = [];
  String hintText;
  int followDataPage = 1;
  int followlastTime;
  RefreshController _refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  bool refreshOver = false;
  StreamController<List<int>> feedIdListController = StreamController<List<int>>();

  _getDynamicData() async {
    if (followDataPage > 1 && followlastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model =
        await getPullList(type: widget.type, size: 20, targetId: widget.id, lastTime: followlastTime);
    if (followDataPage == 1) {
      _refreshController.loadComplete();
      if (model != null) {
        followlastTime = model.lastTime;
        followModel.clear();
        feedIdList.clear();
        feedIdList.insert(0, -1);
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            feedIdList.add(HomeFeedModel.fromJson(result).id);
          });
        }
        _refreshController.refreshCompleted();
      } else {
        hintText = "内容君在来的路上出了点状况...";
        _refreshController.refreshFailed();
      }
      refreshOver = true;
    } else if (followDataPage > 1 && followlastTime != null) {
      if (model != null) {
        followlastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            feedIdList.add(HomeFeedModel.fromJson(result).id);
          });
        }
        _refreshController.loadComplete();
      } else {
        _refreshController.loadFailed();
      }
    }
    if (mounted) {
      setState(() {});
    }
    Future.delayed(Duration.zero, () {
      List<HomeFeedModel> feedList = [];
      context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
        feedList.add(value);
      });
      // 只同步没有的数据
      context.read<FeedMapNotifier>().updateFeedMap(StringUtil.followModelFilterDeta(followModel, feedList));
    });
  }

  ///上拉加载
  _onLoadding() {
    followDataPage += 1;
    _getDynamicData();
  }

  _onRefresh() {
    followDataPage = 1;
    followlastTime = null;
    _getDynamicData();
  }

  @override
  void initState() {
    super.initState();
    print('-----------------------------profileDetailsListInit');
    EventBus.getDefault()
        .registerSingleParameter(_deleteFeedCallBack, EVENTBUS_PROFILE_PAGE, registerName: EVENTBUS_PROFILE_DELETE_FEED);
    widget.type == 3
        ? hintText = "这个人很懒，什么都没发"
        : widget.type == 2
            ? hintText = "发布动态，增加人气哦"
            : hintText = "你还没有喜欢的内容~去逛逛吧";
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 250), () {
        _getDynamicData();
      });
    });
  }

  _deleteFeedCallBack(int id) {
    print('--------$feedIdList------------------删除回调$id');
    if (feedIdList.contains(id)) {
      feedIdList.removeWhere((element) {
        return element == id;
      });
    }
    if (context.read<FeedMapNotifier>().value.feedMap.containsKey(id)) {
      context.read<FeedMapNotifier>().deleteFeed(id);
    }
    feedIdListController.sink.add(feedIdList);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
    switch (state) {

      ///resumed 界面可见， 同安卓的onResume
      case AppLifecycleState.resumed:
        print('============================resumed');
        break;

      ///inactive界面退到后台或弹出对话框情况下， 即失去了焦点但仍可以执行
      ///drawframe回调；同安卓的onPause
      case AppLifecycleState.inactive:
        print('============================inactive');
        break;

      ///paused应用挂起，比如退到后台，失去了焦点且不会收到
      ///drawframe 回调；同安卓的onStop
      case AppLifecycleState.paused:
        print('============================paused');
        break;

      ///页面销毁
      case AppLifecycleState.detached:
        print('============================detached');

        /// TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,
      ///刷新控件
      child: StreamBuilder<List<int>>(
          initialData: feedIdList,
          stream: feedIdListController.stream,
          builder: (BuildContext stramContext, AsyncSnapshot<List<int>> snapshot) {
            return ScrollConfiguration(
                behavior: OverScrollBehavior(),
                child: SmartRefresher(
                    enablePullUp: true,
                    enablePullDown: true,
                    footer: SmartRefresherHeadFooter.init().getFooter(),
                    header: SmartRefresherHeadFooter.init().getHeader(),
                    controller: _refreshController,
                    onLoading: () {
                      if (refreshOver) {
                        _onLoadding();
                      }
                    },
                    onRefresh: _onRefresh,
                    child: _showDataUi(snapshot)));
          }),
    );
  }

  Widget _showDataUi(AsyncSnapshot<List<int>> snapshot) {
    var list = ListView.builder(
        shrinkWrap: true, //解决无限高度问题
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          HomeFeedModel model;
          if (index > 0) {
            try {
              int id = snapshot.data[index];
              model = context.read<FeedMapNotifier>().value.feedMap[id];
            } catch (e) {
              print(e);
            }
          }
          if (index == 0) {
            return Container(
              height: 10,
            );
          } else {
            return ExposureDetector(
              key: widget.type == 2
                  ? Key('profile_feed_${snapshot.data[index]}')
                  : Key('profile_like_${snapshot.data[index]}'),
              child: DynamicListLayout(
                  index: index,
                  pageName: "profileDetails",
                  isShowRecommendUser: false,
                  isShowConcern: false,
                  model: model,
                  isMySelf: widget.isMySelf,
                  mineDetailId: widget.id,
                  key: GlobalObjectKey("attention$index"),
                  removeFollowChanged: (model) {},
                  deleteFeedChanged: (feedId) {}),
              onExposure: (visibilityInfo) {
                // 如果没有显示
                if (model.isShowInputBox) {
                  context.read<FeedMapNotifier>().showInputBox(model.id);
                }
                print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
              },
            );
          }
        });
    var noDataUi = Container(
        padding: EdgeInsets.only(top: 12),
        color: AppColor.white,
        child: Column(
          children: [
            Center(
              child: Container(
                width: 224,
                height: 224,
                color: AppColor.bgWhite.withOpacity(0.65),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                hintText,
                style: AppStyle.textPrimary3Regular14,
              ),
            )
          ],
        ));
    if (snapshot.data.length < 2) {
      return noDataUi;
    } else {
      return list;
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
