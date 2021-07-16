import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/training/course_mode.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/dialog_image.dart';
import 'package:mirror/widget/live_label_widget.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:mirror/widget/version_update_dialog.dart';
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
  RecommendPage({
    Key key,
    this.pc,
  }) : super(key: key);
  PanelController pc = new PanelController();

  RecommendPageState createState() => RecommendPageState();
}

GlobalKey<RecommendPageState> recommendKey = GlobalKey();

class RecommendPageState extends State<RecommendPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 数据源
  List<int> recommendIdList = [];
  List<HomeFeedModel> recommendModelList = [];
  List<CourseModel> liveVideoModel = [];
  RefreshController _refreshController = RefreshController();

  // 列表监听
  // ScrollController _controller = new ScrollController();

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
    // _controller.dispose();
    // EventBus.getDefault().unRegister(registerName: AGAIN_LOGIN_REPLACE_LAYOUT, pageName: EVENTBUS_RECOMMEND_PAGE);
    super.dispose();
  }

  @override
  void initState() {
    // 合并请求
    mergeRequest();
    // 重新登录替换推荐页数据
    EventBus.getDefault().registerSingleParameter(againLoginReplaceLayout, EVENTBUS_RECOMMEND_PAGE,
        registerName: AGAIN_LOGIN_REPLACE_LAYOUT);
    EventBus.getDefault()
        .registerSingleParameter(_getMachineStatusInfo, EVENTBUS_RECOMMEND_PAGE, registerName: GET_MACHINE_STATUS_INFO);
    EventBus.getDefault()
        .registerNoParameter(_isHaveLoginSuccess, EVENTBUS_RECOMMEND_PAGE, registerName: SHOW_IMAGE_DIALOG);
    super.initState();
    _isMachineModelInGame();
    _versionDialog();
  }

  void _versionDialog() {
    if (Application.versionModel != null && Application.haveOrNotNewVersion) {
      if (Application.versionModel.isForceUpdate != 1) {
        Application.haveOrNotNewVersion = false;
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showVersionDialog(
            context: context,
            strong: Application.versionModel.isForceUpdate == 1,
            url: Application.versionModel.url,
            content: Application.versionModel.description);
      });
    }
  }

  // 合并请求
  mergeRequest() {
    List<Future> requestList = [
      // 请求推荐接口
      getHotList(size: 20),
    ];
    if (AppConfig.needShowTraining) requestList.add(newRecommendCoach());
    // 合并请求
    Future.wait(requestList).then((results) {
      if (mounted) {
        if (recommendModelList.isNotEmpty) {
          recommendIdList.clear();
          recommendModelList.clear();
        }
        if (liveVideoModel.isNotEmpty) {
          liveVideoModel.clear();
        }
        setState(() {
          if (AppConfig.needShowTraining && results[1] != null) {
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
                recommendIdList.add(HomeFeedModel.fromJson(v).id);
                recommendModelList.add(HomeFeedModel.fromJson(v));
                if(HomeFeedModel.fromJson(v).topics.length!=0){
                  print('----${recommendModelList.indexOf(HomeFeedModel.fromJson(v))}---------topicFrist---------${HomeFeedModel.fromJson(v).topics
                      .first.img}');
                }else{
                  print('----${recommendModelList.indexOf(HomeFeedModel.fromJson(v))
                  }---------topicFrist-----length=0}');
                }
              });
            }
            // 默认关闭话题动态
            // recommendModelList.forEach((v) {
            //   if (v.recommendSourceDto != null) {
            //     v.recommendSourceDto.type = 0;
            //   }
            // });
            _refreshController.refreshCompleted();
            hasNext = dataModel.hasNext;
            print("第一次的hasNext：：$hasNext");
          } else {
            _refreshController.refreshCompleted();
            isRequestData = false;
          }
        });
        // 更新全局监听
        context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
      }
    });
  }

  // 推荐页model
  getRecommendFeed() async {
    print('==================推荐页数据加载');
    // streamController.sink.add(false);
    // 禁止滑动
    context.read<FeedMapNotifier>().setDropDown(false);
    DataResponseModel dataModel = DataResponseModel();
    print("第二次的hasNext：：$hasNext");
    if (hasNext != 0) {
      // 请求推荐接口
      dataModel = await getHotList(size: 20);
      if (dataModel == null) {
        _refreshController.loadNoData();
      }
      if (dataModel != null) {
        if (dataModel.list.isNotEmpty) {
          print('===============================dataModel!=null&&dataModel.list.isNotEmpty');
          dataModel.list.forEach((v) {
            recommendIdList.add(HomeFeedModel.fromJson(v).id);
            recommendModelList.add(HomeFeedModel.fromJson(v));
          });
          // 默认关闭话题动态
          recommendModelList.forEach((v) {
            if (v.recommendSourceDto != null) {
              v.recommendSourceDto.type = 0;
            }
          });
          _refreshController.loadComplete();
        }
        hasNext = dataModel.hasNext;
      }
    }
    if (hasNext == 0) {
      _refreshController.loadNoData();
    }
    print("第三次的hasNext：：$hasNext");
    // 可以滑动
    context.read<FeedMapNotifier>().setDropDown(true);
    // streamController.sink.add(true);
    if (mounted) {
      setState(() {});
    }
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
  }

  againLoginReplaceLayout([bool isBottomNavigationBar = false]) {
    print('----------againLoginReplaceLayout-----$isBottomNavigationBar');
    if (isBottomNavigationBar) {
      _refreshController.requestRefresh(duration: Duration(milliseconds: 250));
    } else {
      PrimaryScrollController.of(context).jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("RecommendPageState_______build ");
    return Stack(
      children: [
        Container(
          child: SizeCacheWidget(
            // 粗略估计一屏上列表项的最大数量如3个，将 SizeCacheWidget 的 estimateCount 设置为 3*2。快速滚动场景构建响应更快，并且内存更稳定
            estimateCount: 6,
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
                  _refreshController.loadComplete();
                  mergeRequest();
                },
                child: CustomScrollView(
                  key: globalKey,
                  controller: PrimaryScrollController.of(context),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  // BouncingScrollPhysics
                  physics:
                      // ClampingScrollPhysics(),
                      // RangeMaintainingScrollPhysics(),
                      // FixedExtentScrollPhysics(),
                      // AlwaysScrollableScrollPhysics(),
                      // Platform
                      context.watch<FeedMapNotifier>().value.isDropDown
                          ? AlwaysScrollableScrollPhysics()
                          : NeverScrollableScrollPhysics(),
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
                                  return FrameSeparateWidget(
                                    index: index,
                                    placeHolder: Container(
                                      height: 512,
                                      width: ScreenUtil.instance.width,
                                    ),
                                    child:  ExposureDetector(
                                      key: Key('recommend_page_${id}'),
                                      child: DynamicListLayout(
                                          index: index,
                                          model: model,
                                          pageName:DynamicPageType.recommendPage,
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
                                    ),
                                  );
                                }, childCount: recommendIdList.length),
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
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
                                      ),
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
        )
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
                  jumpToUserProfilePage(context, liveVideoModel[index].coachDto.uid,
                      avatarUrl: liveVideoModel[index].coachDto.avatarUri,
                      userName: liveVideoModel[index].coachDto.nickName);
                } else {
                  AppRouter.navigateLiveRoomPage(context, liveVideoModel[index], callback: (int coachRelation) {
                    liveVideoModel[index].coachDto.relation = coachRelation;
                  });
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
                                      child: ClipOval(
                                    child: CachedNetworkImage(
                                      height: 47,
                                      width: 47,
                                      useOldImageOnUrlChange: true,
                                      imageUrl: liveVideoModel[index].coachDto.avatarUri != null
                                          ? FileUtil.getSmallImage(liveVideoModel[index].coachDto.avatarUri)
                                          : "",
                                      fit: BoxFit.cover,
                                      // 调整磁盘缓存中图像大小
                                      maxHeightDiskCache: 150,
                                      maxWidthDiskCache: 150,
                                      placeholder: (context, url) => Container(
                                        color: AppColor.bgWhite,
                                      ),
                                      errorWidget: (context, url, e) {
                                        return Container(
                                          color: AppColor.bgWhite,
                                        );
                                      },
                                    ),
                                  )),
                                ),
                              ),
                            ),
                            Positioned(bottom: -3, child: LiveLabelWidget(isWhiteBorder: true))
                          ],
                        )
                      : Container(
                          height: 53,
                          width: 53,
                          child: Center(
                              child: ClipOval(
                            child: CachedNetworkImage(
                              height: 47,
                              width: 47,
                              imageUrl: liveVideoModel[index].coachDto.avatarUri != null
                                  ? FileUtil.getSmallImage(liveVideoModel[index].coachDto.avatarUri)
                                  : "",
                              fit: BoxFit.cover,
                              // 调整磁盘缓存中图像大小
                              maxHeightDiskCache: 150,
                              maxWidthDiskCache: 150,
                              placeholder: (context, url) => Container(
                                color: AppColor.bgWhite,
                              ),
                              errorWidget: (context, url, e) {
                                return Container(
                                  color: AppColor.bgWhite,
                                );
                              },
                            ),
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

  //成功
  _isHaveLoginSuccess() {
    Future.delayed(Duration(seconds: 1), () {
      if (!AppRouter.isHaveLoginSuccess()) {
        _isMachineModelInGame();
      }
    });
  }

  bool isShowNewUserDialog = false;
  bool isFutureDelayed = false;

  //判断是不是显示活动的dialog
  //todo 新用户登录展示活动的入口---活动入口好吃
  //todo 用户今天第一次登录展示活动的入口
  _isMachineModelInGame() {
    if (!this.isFutureDelayed) {
      this.isFutureDelayed = true;
      Future.delayed(Duration(milliseconds: 300), () {
        getMachineStatusInfo().then((list) {
          if (list != null && list.isNotEmpty) {
            MachineModel model = list.first;
            if (model != null && model.isConnect == 1 && model.inGame == 1) {
              if (model.type == 0) {
                _getMachineStatusInfo(model);
              }
              this.isFutureDelayed = false;
              return;
            }
          }
          _showImageDialog();
          this.isFutureDelayed = false;
        }).catchError((e) {
          _showImageDialog();
        });
      });
    }
  }

  _showImageDialog() {
    if (!AppConfig.needShowTraining) {
      return;
    }
    if (context.read<TokenNotifier>().isLoggedIn &&
        !this.isShowNewUserDialog &&
        Application.profile.uid != coachAccountId) {
      bool isShowNewUserDialog = false;
      if (RuntimeProperties.isShowNewUserDialog) {
        isShowNewUserDialog = true;
      } else if (AppPrefs.isFirstLaunchToDay()) {
        isShowNewUserDialog = true;
      }
      if (AppRouter.isHaveNewUserPromotionPage()) {
        isShowNewUserDialog = false;
      }
      if (isShowNewUserDialog && Application.haveOrNotNewVersion) {
        RuntimeProperties.isShowNewUserDialog = false;
        this.isShowNewUserDialog = true;
        showImageDialog(context, onClickListener: () {
          AppRouter.navigateNewUserPromotionPage(context);
        }, onExitListener: () {
          this.isShowNewUserDialog = false;
        });
      }
    }
  }

  _getMachineStatusInfo(MachineModel model) {
    print("MachineModel:${model.toJson().toString()}");
    if (model != null && model.isConnect == 1 && model.inGame == 1) {
      if (model.type == 0) {
        print("+-++++++++++++++++++++++++++++++++++++++++++++++");
        if (!AppRouter.isHaveMachineRemoteControllerPage()) {
          BuildContext context = Application.navigatorKey.currentState.overlay.context;
          AppRouter.navigateToMachineRemoteController(context,
              courseId: model.courseId, liveRoomId: model.liveRoomId, modeType: mode_live);
        }
      }
    }
  }
}
