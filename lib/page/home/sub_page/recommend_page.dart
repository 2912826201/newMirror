import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/live_label_widget.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

FocusNode commentFocus = FocusNode();

// 加载中的布局
class LoadingView extends StatelessWidget {
  String loadText;
  LoadingStatus loadStatus;

  LoadingView({this.loadText, this.loadStatus});

  Widget _pad(Widget widget, {l, t, r, b}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(l ??= 0.0, t ??= 0.0, r ??= 0.0, b ??= 0.0),
      child: widget,
    );
  }

  var loadingTs = TextStyle(color: AppColor.textHint, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    var loadingText = _pad(
        Text(
          loadText,
          style: loadingTs,
        ),
        l: 0.0);
    var loadingIndicator = Visibility(
        visible: loadStatus == LoadingStatus.STATUS_LOADING ? true : false,
        child: SizedBox(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
            // loading 大小
            strokeWidth: 2,
          ),
          width: 12.0,
          height: 12.0,
        ));
    return _pad(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loadingIndicator,
            loadingText,
          ],
        ),
        b: 20.0);
  }
}

// 推荐
class RecommendPage extends StatefulWidget {
  RecommendPage({Key key, this.pc}) : super(key: key);
  PanelController pc = new PanelController();

  RecommendPageState createState() => RecommendPageState();
}

class RecommendPageState extends State<RecommendPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 数据源
  List<int> recommendIdList = [];
  List<HomeFeedModel> recommendModelList = [];
  List<LiveVideoModel> liveVideoModel = [];
  RefreshController _refreshController = RefreshController();

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 请求下一页
  int lastTime;

  // 是否存在下一页
  int hasNext;

  // 加载中默认文字
  String loadText = "";
  GlobalKey globalKey = GlobalKey();
  bool showNoMore = true;

  // 初始化的第一个item上的间距
  double initHeight = 0.0;

  // 声明定时器
  Timer timer;

  // 是否请求过数据
  bool isRequestData;

  @override
  void dispose() {
    _controller.dispose();
    EventBus.getDefault().unRegister(registerName: AGAIN_LOGIN_REPLACE_LAYOUT, pageName: EVENTBUS_RECOMMEND_PAGE);
    super.dispose();
  }

  @override
  void initState() {
    // 合并请求
    mergeRequest();
    // 重新登录替换推荐页数据
    EventBus.getDefault().registerNoParameter(_againLoginReplaceLayout, EVENTBUS_RECOMMEND_PAGE,
        registerName: AGAIN_LOGIN_REPLACE_LAYOUT);
    super.initState();
  }

  // 合并请求
  mergeRequest() {
    // 合并请求
    Future.wait([
      // 请求推荐接口
      getHotList(size: 20),
      // 请求推荐教练
      newRecommendCoach(),
    ]).then((results) {
      if (mounted) {
        if (recommendModelList.isNotEmpty) {
          recommendIdList.clear();
          recommendModelList.clear();
        }
        if (liveVideoModel.isNotEmpty) {
          liveVideoModel.clear();
        }
        setState(() {
          if (results[1] != null) {
            // initHeight += 93;
            liveVideoModel = results[1];
            print("推荐教练书剑返回");
            print(liveVideoModel.toString());
          }
          if (results[0] != null) {
            isRequestData = true;
            DataResponseModel dataModel = results[0];
            if (dataModel.list.isNotEmpty) {
              print('==========================dataModel.list.isNotEmpty');
              dataModel.list.forEach((v) {
                context.read<UserInteractiveNotifier>().profileUiChangeModel.remove(HomeFeedModel.fromJson(v).pushId);
                recommendIdList.add(HomeFeedModel.fromJson(v).id);
                recommendModelList.add(HomeFeedModel.fromJson(v));
              });
              _refreshController.refreshCompleted();
            }
            hasNext = dataModel.hasNext;
          } else {
            _refreshController.refreshCompleted();
            isRequestData = false;
          }
        });
        // 更新全局监听
        context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
      }
    }).catchError((e) {
      print("报错了");
      print(e);
    });
  }

  // 推荐页model
  getRecommendFeed() async {
    print('==================推荐页数据加载');
    DataResponseModel dataModel = DataResponseModel();
    if (hasNext != 0) {
      // 请求推荐接口
      dataModel = await getHotList(size: 20);
      if (dataModel == null) {
        _refreshController.loadNoData();
      }
      if (dataModel != null && dataModel.list.isNotEmpty) {
        print('===============================dataModel!=null&&dataModel.list.isNotEmpty');
        hasNext = dataModel.hasNext;
        dataModel.list.forEach((v) {
          recommendIdList.add(HomeFeedModel.fromJson(v).id);
          recommendModelList.add(HomeFeedModel.fromJson(v));
        });
        _refreshController.loadComplete();
      }
    }
    if (hasNext == 0) {
      _refreshController.loadNoData();
    }
    if (mounted) {
      setState(() {});
    }
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
  }

  _againLoginReplaceLayout() {
    mergeRequest();
  }

  @override
  Widget build(BuildContext context) {
    print("RecommendPageState_______build ");
    return Stack(
      children: [
        Container(
          child: SmartRefresher(
              enablePullUp: recommendModelList.isNotEmpty ? true : false,
              enablePullDown: true,
              footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: showNoMore),
              header: SmartRefresherHeadFooter.init().getHeader(),
              controller: _refreshController,
              onLoading: () {
                setState(() {
                  showNoMore = IntegerUtil.showNoMore(globalKey);
                });
                getRecommendFeed();
              },
              onRefresh: () {
                hasNext = null;
                mergeRequest();
              },
              child: CustomScrollView(
                key: globalKey,
                controller: _controller,
                // BouncingScrollPhysics
                physics:
                    // ClampingScrollPhysics(),
                    // FixedExtentScrollPhysics(),
                    AlwaysScrollableScrollPhysics(),
                // BouncingScrollPhysics(),
                slivers: [
                  // 因为SliverList并不支持设置滑动方向由CustomScrollView统一管理，所有这里使用自定义滚动
                  // CustomScrollView要求内部元素为Sliver组件， SliverToBoxAdapter可包裹普通的组件。
                  // 横向滑动区域
                  SliverToBoxAdapter(
                    child: liveVideoModel.isNotEmpty ? getCourse() : Container(),
                  ),
                  // 垂直列表
                  isRequestData == null
                      ? SliverToBoxAdapter()
                      : recommendModelList.isNotEmpty
                          ? SliverList(
                              // controller: _controller,
                              delegate: SliverChildBuilderDelegate((content, index) {
                                // 获取动态id
                                int id;
                                // 获取动态id指定model
                                HomeFeedModel model;
                                if (index < recommendIdList.length) {
                                  id = recommendIdList[index];
                                  model = context.read<FeedMapNotifier>().value.feedMap[id];
                                }
                                return ExposureDetector(
                                  key: Key('recommend_page_${id}'),
                                  child: DynamicListLayout(
                                      index: index,
                                      model: model,
                                      pageName: "recommendPage",
                                      isShowConcern: true,
                                      // 可选参数 子Item的个数
                                      // key: GlobalObjectKey("recommend$index"),
                                      isShowRecommendUser: false),
                                  onExposure: (visibilityInfo) {
                                    print("回调看数据:${recommendIdList.toString()}");
                                    // 如果没有显示
                                    if (context
                                        .read<FeedMapNotifier>()
                                        .value
                                        .feedMap[recommendIdList[index]]
                                        .isShowInputBox) {
                                      context.read<FeedMapNotifier>().showInputBox(recommendIdList[index]);
                                    }
                                    print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                                  },
                                );
                              }, childCount: recommendIdList.length + 1),
                            )
                          : SliverToBoxAdapter(
                              child: Container(
                              height: ScreenUtil.instance.height -
                                  48 -
                                  44 -
                                  ScreenUtil.instance.bottomBarHeight -
                                  ScreenUtil.instance.statusBarHeight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 224,
                                    height: 224,
                                    color: AppColor.color246,
                                    margin: const EdgeInsets.only(bottom: 16),
                                  ),
                                  const Text(
                                    "这里空空如也，去关注看看吧",
                                    style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                                  ),
                                ],
                              ),
                            )),
                ],
              )),
        ),
      ],
    );
  }

  // 课程横向布局
  getCourse() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 18),
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: liveVideoModel.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (context.read<TokenNotifier>().isLoggedIn) {
                if (liveVideoModel[index].coachDto.isLiving == 0) {
                  AppRouter.navigateToMineDetail(context, liveVideoModel[index].coachDto.uid,
                      avatarUrl: liveVideoModel[index].coachDto.avatarUri,
                      userName: liveVideoModel[index].coachDto.nickName);
                } else {
                  AppRouter.navigateLiveRoomPage(context, liveVideoModel[index]);
                }
              } else {
                AppRouter.navigateToLoginPage(context);
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index > 0 ? 29 : 16,
                right: index == liveVideoModel.length - 1 ? 16 : 0,
              ),
              // decoration: BoxDecoration(border: Border.all(color: AppColor.mainRed)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  liveVideoModel[index].coachDto.isLiving == 1
                      ? Stack(
                          // 显示超出Stack显示空间的子组件
                          overflow: Overflow.visible,
                          alignment: Alignment(0, -1),
                          children: [
                            Container(
                              height: 53,
                              width: 53,
                              decoration: BoxDecoration(
                                  color: AppColor.mainRed,
                                  // 渐变色
                                  // gradient: const LinearGradient(
                                  //   begin: Alignment.topLeft,
                                  //   end: Alignment.bottomLeft,
                                  //   colors: [
                                  //     Color.fromRGBO(0xFD, 0x86, 0x8A, 1.0),
                                  //     Color.fromRGBO(0xFE, 0x56, 0x68, 1.0),
                                  //     AppColor.mainRed,
                                  //   ],
                                  // ),
                                  borderRadius: BorderRadius.circular((26.5))),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: new BoxDecoration(
                                      color: AppColor.white, borderRadius: BorderRadius.circular((25))),
                                  child: Center(
                                    child: Container(
                                        height: 47,
                                        width: 47,
                                        decoration: BoxDecoration(
                                          // color: Colors.redAccent,
                                          image: DecorationImage(
                                              image: NetworkImage(liveVideoModel[index].coachDto.avatarUri),
                                              fit: BoxFit.cover),
                                          // image
                                          borderRadius: BorderRadius.all(Radius.circular(23.5)),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(bottom: -2.5, child: LiveLabelWidget(isWhiteBorder: true))
                          ],
                        )
                      : Container(
                          height: 53,
                          width: 53,
                          child: Container(
                              height: 47,
                              width: 47,
                              decoration: BoxDecoration(
                                // color: Colors.redAccent,
                                image: DecorationImage(
                                    image: NetworkImage(liveVideoModel[index].coachDto.avatarUri), fit: BoxFit.cover),
                                // image
                                borderRadius: BorderRadius.all(Radius.circular(23.5)),
                              )),
                        ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 53,
                    child: Center(
                      child: Text(
                        liveVideoModel[index].coachDto.nickName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
