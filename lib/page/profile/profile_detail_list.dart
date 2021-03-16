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
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'overscroll_behavior.dart';

///个人主页动态List
class ProfileDetailsList extends StatefulWidget {
  int type;
  int id;
  bool isMySelf;

  ProfileDetailsList({this.type, this.id, this.isMySelf});

  @override
  State<StatefulWidget> createState() {
    return ProfileDetailsListState();
  }
}

class ProfileDetailsListState extends State<ProfileDetailsList>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  ///动态model
  List<HomeFeedModel> followModel = [];

  int followDataPage = 1;
  int followlastTime;
  RefreshController _refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  bool refreshOver = false;
  _getDynamicData() async {
    if (followDataPage > 1 && followlastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    List<int> idList = [];
    DataResponseModel model =
        await getPullList(type: widget.type, size: 20, targetId: widget.id, lastTime: followlastTime);
    if (followDataPage == 1) {
      _refreshController.loadComplete();
      if (model != null) {
        context.read<UserInteractiveNotifier>().idListClear(widget.id, type: widget.type);
        followModel.clear();
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            idList.add(HomeFeedModel.fromJson(result).id);
          });
        }
        _refreshController.refreshCompleted();
      } else {
        _refreshController.refreshFailed();
      }
      refreshOver = true;
    } else if (followDataPage > 1 && followlastTime != null) {
      if (model != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            idList.add(HomeFeedModel.fromJson(result).id);
          });
        }
        _refreshController.loadComplete();
      } else {
        _refreshController.loadFailed();
      }
    }
    followlastTime = model.lastTime;
    if (mounted) {
      setState(() {});
    }
    List<HomeFeedModel> feedList = [];
    context.read<UserInteractiveNotifier>().setFeedIdList(widget.id, idList, widget.type);
    context.read<FeedMapNotifier>().feedMap.forEach((key, value) {
      feedList.add(value);
    });
    // 只同步没有的数据
    context.read<FeedMapNotifier>().updateFeedMap(StringUtil.followModelFilterDeta(followModel, feedList));
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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 250), () {
        _getDynamicData();
      });
    });
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
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,

      ///刷新控件
      child: ScrollConfiguration(
          behavior: OverScrollBehavior(),
          child: SmartRefresher(
            enablePullUp: true,
            enablePullDown: true,
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.loading) {
                  body = Text("正在加载");
                } else if (mode == LoadStatus.idle) {
                  body = Text("上拉加载更多");
                } else if (mode == LoadStatus.failed) {
                  body = Text("加载失败,请重试");
                } else {
                  body = Text("没有更多了");
                }
                return Container(
                  child: Center(
                    child: body,
                  ),
                );
              },
            ),
            header: WaterDropHeader(
              complete: Text("刷新完成"),
              failed: Text(""),
            ),
            controller: _refreshController,
            onLoading: () {
              if (refreshOver) {
                _onLoadding();
              }
            },
            onRefresh: _onRefresh,
            child: _showDataUi(),
          )),
    );
  }

  Widget _showDataUi() {
    var list = ListView.builder(
        shrinkWrap: true, //解决无限高度问题
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: widget.type == 2
            ? context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].profileFeedListId.length
            : context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].profileLikeListId.length,
        itemBuilder: (context, index) {
          HomeFeedModel model;
          if (index > 0) {
            try {
              int id = widget.type == 2
                  ? context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].profileFeedListId[index]
                  : context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].profileLikeListId[index];
              model = context.read<FeedMapNotifier>().feedMap[id];
            } catch (e) {
              print(e);
            }
          }
          if (index == 0) {
            return Container(
              height: 10,
            );
          } else {
            return DynamicListLayout(
              index: index,
              pageName: "profileDetails",
              isShowRecommendUser: false,
              isShowConcern: false,
              model: model,
              isMySelf: widget.isMySelf,
              mineDetailId: widget.id,
              key: GlobalObjectKey("attention$index"),
              removeFollowChanged: (model) {},
              deleteFeedChanged: (feedId) {
                context.read<UserInteractiveNotifier>().synchronizeIdList(widget.id, feedId);
                if (context.read<FeedMapNotifier>().feedMap.containsKey(feedId)) {
                  context.read<FeedMapNotifier>().deleteFeed(feedId);
                }
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
                widget.type == 3
                    ? "ta还没有发布动态"
                    : widget.type == 2
                        ? "发布你的第一条动态吧~"
                        : "你还没有喜欢的内容~去逛逛吧",
                style: AppStyle.textPrimary3Regular14,
              ),
            )
          ],
        ));
    if (((widget.type == 6 || widget.type == 3) &&
            context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].profileLikeListId.length < 2) ||
        (widget.type == 2 &&
            context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].profileFeedListId.length < 2)) {
      return noDataUi;
    } else {
      return list;
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
