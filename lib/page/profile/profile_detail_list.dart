import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

///个人主页动态List
class ProfileDetailsList extends StatefulWidget {
  int type;
  int id;

  ProfileDetailsList({this.type, this.id});

  @override
  State<StatefulWidget> createState() {
    return ProfileDetailsListState();
  }
}

class ProfileDetailsListState extends State<ProfileDetailsList> with AutomaticKeepAliveClientMixin {
  ///动态model
  List<HomeFeedModel> followModel = [];

  ///动态id
  List<int> _followListId = [];
  int followDataPage = 1;
  int followlastTime;
  RefreshController _refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  StateResult fllowState = StateResult.RESULTNULL;

  _getDynamicData() async {
    if (followDataPage > 1 && followlastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model =
        await getPullList(type: widget.type, size: 20, targetId: widget.id, lastTime: followlastTime);
    setState(() {
      if (followDataPage == 1) {
        followModel.clear();
        _followListId.clear();
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            _followListId.add(HomeFeedModel.fromJson(result).id);
          });
          _followListId.insert(0, -1);
          fllowState = StateResult.HAVERESULT;
          _refreshController.refreshCompleted();
        } else {
          fllowState = StateResult.RESULTNULL;
          _refreshController.resetNoData();
        }
      } else if (followDataPage > 1 && followlastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            _followListId.add(HomeFeedModel.fromJson(result).id);
          });
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }
    });
    followlastTime = model.lastTime;
    List<HomeFeedModel> feedList = [];
     context.read<FeedMapNotifier>().feedMap.forEach((key, value) {
       feedList.add(value);
     });
     // 只同步没有的数据
    context.read<FeedMapNotifier>().updateFeedMap(followModelProfileDeta(followModel,feedList));
  }

  /** 个人主页全局动态和个人主页请求数据比较
   * 比较两数组 取出不同的，
   * array1 数组一
   * array2 数组二
   * **/
  followModelProfileDeta(List<HomeFeedModel> array1, List<HomeFeedModel> array2) {
    var arr1 = array1;
    var arr2 = array2;
    List<HomeFeedModel> result = [];
    for (var i = 0; i < array1.length; i++) {
      var obj = array1[i].id;
      var isExist = false;
      for (var j = 0; j < array2.length; j++) {
        var aj = array2[j].id;
        if (obj == aj) {
          isExist = true;
          continue;
        }
      }
      if (!isExist) {
        result.add(array1[i]);
      }
    }
    print("result${result.toString()}");
    return result;
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
    _getDynamicData();
  }

  @override
  Widget build(BuildContext context) {
    var _listData = Container(
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,

      ///刷新控件
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
        onLoading: _onLoadding,
        onRefresh: _onRefresh,
        child: ListView.builder(
            shrinkWrap: true, //解决无限高度问题
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: _followListId.length,
            itemBuilder: (context, index) {
              int id = _followListId[index];
              HomeFeedModel model = context.read<FeedMapNotifier>().feedMap[id];
              if (index == 0) {
                return Container(
                  height: 10,
                );
              } else {
                return DynamicListLayout(
                    index: index,
                    pageName: "profileDetails",
                    isShowRecommendUser: false,
                    model: model,
                    key: GlobalObjectKey("attention$index"));
              }
            }),
      ),
    );
    switch (fllowState) {
      case StateResult.RESULTNULL:
        return Container(
            padding: EdgeInsets.only(top: 12),
            color: AppColor.white,
            child: ListView(
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
                    widget.type == 3 ? "他还没有发布动态~" : "快发布你的第一条动态吧",
                    style: AppStyle.textPrimary3Regular14,
                  ),
                )
              ],
            ));
        break;
      case StateResult.HAVERESULT:
        return _listData;
        break;
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
