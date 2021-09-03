import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class ActivityFlow extends StatefulWidget {
  ActivityFlow({
    Key key,
    this.activityModel,
  }) : super(key: key);

  @override
  _ActivityFlowState createState() => _ActivityFlowState();

  // 活动model
  ActivityModel activityModel;
}

class _ActivityFlowState extends State<ActivityFlow> {
  // 是否有下一页
  int feedHasNext;

  // 下一页的参数
  int feedLastTime;
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  // 活动动态列表
  List<HomeFeedModel> activityList = [];

  // 是否显示缺省图
  bool isShowDefaultMap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestFeednIterface();
  }

  // 请求动态接口
  requestFeednIterface({bool isRefresh = false}) async {
    if (isRefresh) {
      feedHasNext = null;
      feedLastTime = null;
      activityList.clear();
    }
    if (feedHasNext != 0) {
      DataResponseModel model =
          await getPullList(type: 8, size: 20, targetId: widget.activityModel.id, lastTime: feedLastTime);

      if (model != null) {
        feedLastTime = model.lastTime;
        feedHasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            activityList.add(HomeFeedModel.fromJson(v));
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
          } else {
            _refreshController.loadComplete();
          }
        }
        //筛选首页关注页话题动态
        List<HomeFeedModel> homeFollowModel = [];
        context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
          if (value.recommendSourceDto != null) {
            homeFollowModel.add(value);
          }
        });
        homeFollowModel.forEach((element) {
          activityList.forEach((v) {
            if (element.id == v.id) {
              v.recommendSourceDto = element.recommendSourceDto;
            }
          });
        });
        // 更新全局内没有的数据
        context.read<FeedMapNotifier>().updateFeedMap(activityList);
      } else {
        if (isRefresh) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadFailed();
        }
      }
    } else {
      if (isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        _refreshController.loadFailed();
      }
    }
    if (activityList.length > 0) {
      isShowDefaultMap = false;
    } else {
      isShowDefaultMap = true;
    }
    if (feedHasNext == 0) {
      if (isRefresh) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
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
        titleString: "活动动态",
        hasLeading: true,
      ),
      body: isShowDefaultMap == null
          ? Container()
          : isShowDefaultMap == true
              ? defaultMap()
              : Stack(
                  children: [
                    Container(
                        child: SmartRefresher(
                      enablePullUp: true,
                      enablePullDown: true,
                      footer: SmartRefresherHeadFooter.init().getFooter(),
                      header: SmartRefresherHeadFooter.init().getHeader(),
                      controller: _refreshController,
                      onLoading: () {
                        requestFeednIterface(isRefresh: false);
                      },
                      onRefresh: () {
                        requestFeednIterface(isRefresh: true);
                      },
                      child: CustomScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate((content, index) {
                                return DynamicListLayout(
                                  index: index,
                                  pageName: "activityFlowPage",
                                  isShowConcern: false,
                                  isShowRecommendUser: false,
                                  model: activityList[index],
                                  deleteFeedChanged: (int id) {},
                                );
                              }, childCount: activityList.length),
                            )
                          ]),
                    )),
                    Positioned(
                      bottom: ScreenUtil.instance.bottomBarHeight + 28,
                      left: (ScreenUtil.instance.width - 127) / 2,
                      right: (ScreenUtil.instance.width - 127) / 2,
                      child: _gotoRelease(),
                    )
                  ],
                ),
    );
  }

  // 发布按钮
  Widget _gotoRelease() {
    return InkWell(
      onTap: () {
        if (!context.read<TokenNotifier>().isLoggedIn) {
          AppRouter.navigateToLoginPage(context);
          return;
        }
        AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
            publishMode: 1, activityModel: widget.activityModel);
      },
      child: Container(
        width: 127,
        height: 43,
        decoration: const BoxDecoration(
          color: AppColor.imageBgGrey,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 27,
              width: 27,
              decoration: const BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Center(
                child: AppIcon.getAppIcon(
                  AppIcon.camera_27,
                  27,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              "发布动态",
              style: AppStyle.whiteRegular16,
            )
          ],
        ),
      ),
    );
  }

  // 缺省图
  Widget defaultMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 224,
            height: 224,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
            ),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          const Text(
            "这里空空如也，去推荐看看吧",
            style: AppStyle.text1Regular14,
          ),
        ],
      ),
    );
  }
}
