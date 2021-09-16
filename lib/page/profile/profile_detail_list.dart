import 'dart:async';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart' hide TabBar, TabBarView, NestedScrollView, NestedScrollViewState;
import 'package:flutter/cupertino.dart' hide NestedScrollView, NestedScrollViewState;
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/overscroll_behavior.dart';

///个人主页动态List
class ProfileDetailsList extends StatefulWidget {
  int type;
  int id;
  bool isMySelf;
  Key pageKey;
  bool imageLoading;

  ProfileDetailsList({this.pageKey, this.type, this.id, this.isMySelf, this.imageLoading});

  @override
  ProfileDetailsListState createState() {
    return ProfileDetailsListState();
  }
}

class ProfileDetailsListState extends State<ProfileDetailsList>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, TickerProviderStateMixin {
  ///动态model
  List<HomeFeedModel> followModel = [];
  String hintText;
  int followDataPage = 1;
  int followlastTime;
  String defaultImage = DefaultImage.nodata;
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  bool refreshOver = false;
  bool listNoData = false;
  Map<int, AnimationController> animationMap = {};

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
        print('----获取到的动态列表--type==${widget.type}-----------${model.toJson()}');
        followlastTime = model.lastTime;
        if (followModel.isNotEmpty) {
          followModel.clear();
          animationMap.clear();
        }
        if (model.list != null && model.list.length != 0) {
          listNoData = false;
          model.list.forEach((result) {
            HomeFeedModel feedModel = HomeFeedModel.fromJson(result);
            followModel.add(feedModel);
            animationMap[feedModel.id] =
                AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
          });
        } else {
          widget.type == 3
              ? hintText = "这个人很懒，什么都没发"
              : widget.type == 2
                  ? hintText = "发布动态，增加人气哦"
                  : hintText = "你还没有喜欢的内容~去逛逛吧";
          defaultImage = DefaultImage.nodata;
          listNoData = true;
        }
        _refreshController.refreshCompleted();
      } else {
        listNoData = true;
        hintText = "内容君在来的路上出了点状况...";
        defaultImage = DefaultImage.error;
        _refreshController.refreshFailed();
      }
      refreshOver = true;
    } else if (followDataPage > 1 && followlastTime != null) {
      if (model != null) {
        followlastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            HomeFeedModel feedModel = HomeFeedModel.fromJson(result);
            followModel.add(feedModel);
            animationMap[feedModel.id] =
                AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
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
      // 同步数据
      if (mounted) {
        //筛选首页关注页话题动态
        List<HomeFeedModel> homeFollowModel = [];
        context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
          if (value.recommendSourceDto != null) {
            homeFollowModel.add(value);
          }
        });
        homeFollowModel.forEach((element) {
          followModel.forEach((v) {
            if (element.id == v.id) {
              v.recommendSourceDto = element.recommendSourceDto;
            }
          });
        });
        // 可以同步是因为加了页面去判断只在推荐页做展示
        context.read<FeedMapNotifier>().updateFeedMap(followModel);
      }
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
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    animationMap.clear();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus.init().unRegister(registerName: EVENTBUS_PROFILE_DELETE_FEED, pageName: EVENTBUS_PROFILE_PAGE);
  }

  @override
  void initState() {
    super.initState();
    EventBus.init().registerSingleParameter(_tabBarDoubleTap, EVENTBUS_PROFILE_PAGE, registerName: DOUBLE_TAP_TABBAR);
    EventBus.init().registerSingleParameter(_deleteFeedCallBack, EVENTBUS_PROFILE_PAGE,
        registerName: EVENTBUS_PROFILE_DELETE_FEED);
    widget.type == 3
        ? hintText = "这个人很懒，什么都没发"
        : widget.type == 2
            ? hintText = "发布动态，增加人气哦"
            : hintText = "你还没有喜欢的内容~去逛逛吧";
  }

  _tabBarDoubleTap(result) {
    int type = result as int;
    if (type == widget.type) {
      _refreshController.requestRefresh(duration: Duration(milliseconds: 250));
    }
  }

  _deleteFeedCallBack(int id) {
    if (animationMap.containsKey(id)) {
      animationMap[id].forward().then((value) {
        followModel.removeWhere((element) {
          return element.id == id;
        });
        if (followModel.length == 0) {
          listNoData = true;
        }
        animationMap.remove(id);
        if (mounted) setState(() {});
        if (context.read<FeedMapNotifier>().value.feedMap.containsKey(id)) {
          context.read<FeedMapNotifier>().deleteFeed(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    Widget child = Container(
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.mainBlack,

      ///刷新控件
      child: ScrollConfiguration(
          behavior: OverScrollBehavior(),
          child: SmartRefresher(
              enablePullUp: true,
              enablePullDown: true,
              footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: listNoData ? false : true),
              header: SmartRefresherHeadFooter.init().getHeader(),
              controller: _refreshController,
              onLoading: () {
                if (refreshOver) {
                  _onLoadding();
                }
              },
              onRefresh: _onRefresh,
              child: _showDataUi())),
    );
    return NestedScrollViewInnerScrollPositionKeyWidget(widget.pageKey, child);
  }

  Widget _showDataUi() {
    return !listNoData
        ? ListView.builder(
            itemCount: followModel.length,
            itemBuilder: (context, index) {
              return _listItem(index);
            })
        : ListView(
            children: [
              Center(
                child: Container(
                  width: 224,
                  height: 224,
                  child: Image.asset(defaultImage),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Center(
                child: Text(
                  hintText,
                  style: AppStyle.text1Regular14,
                ),
              )
            ],
          );
  }

  Widget _listItem(int index) {
    HomeFeedModel model;
    model = followModel[index];
    return SizeTransition(
        sizeFactor: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: animationMap[model.id],
          curve: Curves.fastOutSlowIn,
        )),
        axis: Axis.vertical,
        axisAlignment: 1.0,
        child: ExposureDetector(
          key: widget.type == 2
              ? Key('profile_feed_${followModel[index].id}')
              : Key('profile_like_${followModel[index].id}'),
          child: DynamicListLayout(
              index: index,
              pageName: DynamicPageType.profileDetailsPage,
              isShowRecommendUser: false,
              isShowConcern: false,
              model: model,
              isMySelf: widget.isMySelf,
              mineDetailId: widget.id,
              key: GlobalObjectKey("attention$index"),
              deleteFeedChanged: (feedId) {}),
          onExposure: (visibilityInfo) {
            // 如果没有显示
            if (model.isShowInputBox) {
              context.read<FeedMapNotifier>().showInputBox(model.id);
            }
            print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
          },
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
