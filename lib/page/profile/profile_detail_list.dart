import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '../../widget/overscroll_behavior.dart';

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
  String hintText;
  int followDataPage = 1;
  int followlastTime;
  String defaultImage = DefaultImage.nodata;
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  ScrollController scrollController = ScrollController();
  bool refreshOver = false;
  bool listNoData = false;

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
        if(followModel.isNotEmpty){
          followModel.clear();
        }
        if (model.list!=null&&model.list.length!=0) {
          listNoData = false;
          model.list.forEach((result) {
            print('---------------------${HomeFeedModel.fromJson(result).id}');
            followModel.add(HomeFeedModel.fromJson(result));
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
            followModel.add(HomeFeedModel.fromJson(result));
          });
        }
        _refreshController.loadComplete();
      } else {
        _refreshController.loadFailed();
      }
    }
    if(mounted){
      setState(() {
      });
    }
    Future.delayed(Duration.zero,(){
      // 同步数据
      context.read<FeedMapNotifier>().updateFeedMap(followModel);
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus.getDefault().unRegister(registerName: EVENTBUS_PROFILE_DELETE_FEED, pageName: EVENTBUS_PROFILE_PAGE);
  }

  @override
  void initState() {
    super.initState();
    print('-----------------------------profileDetailsListInit');
    EventBus.getDefault().registerSingleParameter(_deleteFeedCallBack, EVENTBUS_PROFILE_PAGE,
        registerName: EVENTBUS_PROFILE_DELETE_FEED);
    widget.type == 3
        ? hintText = "这个人很懒，什么都没发"
        : widget.type == 2
            ? hintText = "发布动态，增加人气哦"
            : hintText = "你还没有喜欢的内容~去逛逛吧";
  }

  _deleteFeedCallBack(int id) {
      followModel.removeWhere((element) {
        return element.id == id;
      });
    if(followModel.length==0){
      listNoData = true;
    }
    if(mounted){
      setState(() {});
    }
    if (context.read<FeedMapNotifier>().value.feedMap.containsKey(id)) {
      context.read<FeedMapNotifier>().deleteFeed(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,
      ///刷新控件
      child: ScrollConfiguration(
          behavior: OverScrollBehavior(),
          child: SmartRefresher(
              enablePullUp: true,
              enablePullDown: true,
              footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore:listNoData?false:true),
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
  }

  Widget _showDataUi() {
    return !listNoData
        ? ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10),
            //解决无限高度问题
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: followModel.length,
            itemBuilder: (context, index) {
              HomeFeedModel model;
              model = followModel[index];
              return ExposureDetector(
                key: widget.type == 2
                    ? Key('profile_feed_${followModel[index].id}')
                    : Key('profile_like_${followModel[index].id}'),
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
            })
        :  ListView(
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
                    style: AppStyle.textPrimary3Regular14,
                  ),
                )
              ],
            );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
