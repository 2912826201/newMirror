import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Scaffold;
import 'package:mirror/api/api.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/download_video_course_db_helper.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/feed/feed_flow_data_notifier.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/scan_code/scan_code_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/ScaffoldChatPage.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/widget/sliver_custom_header_delegate_video.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mirror/constant/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 视频详情页
class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage(
      {Key key,
      @required this.videoCourseId,
      this.heroTag,
      this.commentDtoModel,
      this.fatherComment,
      this.videoModel,
      this.isInteractive})
      : super(key: key);

  final CourseModel videoModel;
  final String heroTag;
  final int videoCourseId;
  final CommentDtoModel commentDtoModel;
  final CommentDtoModel fatherComment;
  final bool isInteractive;

  @override
  createState() {
    return VideoDetailPageState(
        videoModel: videoModel,
        heroTag: heroTag,
        videoCourseId: videoCourseId,
        commentDtoModel: commentDtoModel,
        fatherComment: fatherComment,
        isInteractive: isInteractive);
  }
}

class VideoDetailPageState extends XCState {
  VideoDetailPageState(
      {Key key,
      this.videoModel,
      this.heroTag,
      this.videoCourseId,
      this.commentDtoModel,
      this.fatherComment,
      this.isInteractive});

  String heroTag;
  int videoCourseId;
  CommentDtoModel commentDtoModel;
  CommentDtoModel fatherComment;
  bool isInteractive;

  //当前视频课程的model
  CourseModel videoModel;

  //其他用户的完成训练
  List<HomeFeedModel> recommendTopicList = [];

  //加载状态
  LoadingStatus loadingStatus;
  LoadingStatus recommendLoadingStatus;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //是否可以回弹
  bool isBouncingScrollPhysics = false;

  //下载监听
  Function(String, int, int) _progressListener;

  CancelToken cancelToken = CancelToken();
  Connectivity connectivity = Connectivity();
  Dio dio = Dio();

  //下载进度
  double _progress = 0.0;
  String _progressText = "正常下载";

  //全部需要下载多少个文件
  int allDownLoadCount = 0;

  //已经下载了多少个文件
  int completeDownCount = 0;

  //剩余下载的文件地址
  var downloadStringArray = <String>[];

  //是不是在下载中
  bool isDownLoading = false;

  //下载完成后视频文件的本地地址Map
  Map<String, String> videoPathMap = {};

  //是否收藏
  bool isFavor = false;

  //粘合剂控件滚动控制
  ScrollController scrollController = ScrollController();

  GlobalKey<CommonCommentPageState> childKey = GlobalKey();
  List<GlobalKey> globalKeyList = <GlobalKey>[];

  //判断用户登陆没有
  bool isLoggedIn;

  //判断是否绑定了终端
  bool bindingTerminal;

  String pageName = "VideoDetailPage";

  @override
  void initState() {
    super.initState();

    context.read<FeedFlowDataNotifier>().clear();
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    bindingTerminal = context.read<MachineNotifier>().machine != null;
    print("bindingTerminal:$bindingTerminal");

    //如果已登录且有关联的机器 发送指令让机器跳转页面
    if (isLoggedIn && Application.machine != null) {
      openVideoCourseDetailPage(Application.machine.machineId, videoCourseId);
    }

    if (videoModel == null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
    } else {
      if (videoModel.isInMyCourseList != null) {
        isFavor = videoModel.isInMyCourseList == 1;
      }
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    }
    recommendLoadingStatus = LoadingStatus.STATUS_LOADING;
    getDataAction();
    initProgressListener();
    initConnectivity();
  }

  @override
  void deactivate() {
    super.deactivate();
    cancelToken.cancel();
    dio.lock();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
      handleStatusBarTap: _animateToIndex,
    );
  }

  //判断加载什么布局
  Widget _buildSuggestions() {
    var widgetArray = <Widget>[];
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      //有数据
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(height: 40));
      widgetArray.add(getNoCompleteTitle(context, "视频课程详情页"));
      //在加载中
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        widgetArray.add(
          Expanded(
            child: SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      } else {
        //加载失败
        widgetArray.add(
          Expanded(
            child: SizedBox(
              child: Center(
                child: GestureDetector(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 224,
                          height: 224,
                          child: Image.asset(
                            "assets/png/default_no_data.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: 14,
                        ),
                        Text(
                          "暂无视频课程数据，去看看其他的吧~",
                          style: AppStyle.text1Regular14,
                        ),
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    loadingStatus = LoadingStatus.STATUS_LOADING;
                    if (mounted) {
                      reload(() {});
                    }
                    getDataAction();
                  },
                ),
              ),
            ),
          ),
        );
      }
      return Container(
        child: Column(children: widgetArray),
      );
    }
  }

  //加载数据成功时的布局
  Widget _buildSuggestionsComplete() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        color: AppColor.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 50 - ScreenUtil.instance.bottomBarHeight,
              child: ScrollConfiguration(
                behavior: NoBlueEffectBehavior(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onDragNotification,
                  child: getSmartRefresher(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50.0 + ScreenUtil.instance.bottomBarHeight,
              padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
              color: AppColor.white,
              child: _getBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  //获取上拉下拉加载
  Widget getSmartRefresher() {
    globalKeyList.clear();
    GlobalKey globalKey0 = new GlobalKey();
    GlobalKey globalKey1 = new GlobalKey();
    GlobalKey globalKey2 = new GlobalKey();
    GlobalKey globalKey3 = new GlobalKey();
    GlobalKey globalKey4 = new GlobalKey();
    globalKeyList.add(globalKey0);
    globalKeyList.add(globalKey1);
    globalKeyList.add(globalKey2);
    globalKeyList.add(globalKey3);
    globalKeyList.add(globalKey4);
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: false, isShowAddMore: false),
      controller: _refreshController,
      onLoading: () {
        if (childKey == null || childKey.currentState == null || childKey.currentState.onLoading == null) {
          return;
        }
        childKey.currentState.onLoading();
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: isBouncingScrollPhysics ? BouncingScrollPhysics() : ClampingScrollPhysics(),
        slivers: <Widget>[
          // header,
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverCustomHeaderDelegateVideo(
              title: videoModel.title ?? "",
              collapsedHeight: 44,
              expandedHeight: 300,
              paddingTop: MediaQuery.of(context).padding.top,
              coverImgUrl: getCourseShowImage(videoModel),
              heroTag: heroTag,
              startTime: videoModel.startTime,
              endTime: videoModel.endTime,
              shareBtnClick: _shareBtnClick,
              favorBtnClick: _favorBtnClick,
              isFavor: isFavor,
              globalKey: globalKeyList[0],
            ),
          ),
          getTitleWidget(videoModel, context, globalKeyList[1]),
          getCoachItem(videoModel, context, onClickAttention, onClickCoach, globalKeyList[2], getDataAction),
          getLineView(),
          getTrainingEquipmentUi(videoModel, context, AppStyle.textMedium18, globalKeyList[3]),
          getActionUiVideo(videoModel, context, AppStyle.textMedium18),
          getOtherUsersUi(
              recommendTopicList, context, AppStyle.textMedium18, onClickOtherComplete, globalKeyList[4], pageName),
          getLineView(),
          _getCourseCommentUi(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          SliverToBoxAdapter(
            child: Offstage(
              offstage: true,
              child: userLoginComplete(),
            ),
          ),
          SliverToBoxAdapter(
            child: Offstage(
              offstage: true,
              child: userBindingTerminal(),
            ),
          )
        ],
      ),
    );
  }

  //当用户登陆成功后需要刷新数据
  Widget userLoginComplete() {
    return Consumer<TokenNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoggedIn) {
          if (!isLoggedIn) {
            isLoggedIn = true;
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                reload(() {});
              }
            });
            getDataAction();
            //如果已登录且有关联的机器 发送指令让机器跳转页面
            if (Application.machine != null) {
              openVideoCourseDetailPage(Application.machine.machineId, videoCourseId);
            }
          }
        } else {
          if (isLoggedIn) {
            isLoggedIn = false;
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                reload(() {});
              }
            });
            getDataAction();
            //如果已登录且有关联的机器 发送指令让机器跳转页面
            if (Application.machine != null) {
              openVideoCourseDetailPage(Application.machine.machineId, videoCourseId);
            }
          }
        }
        return child;
      },
      child: Container(),
    );
  }

  //当用户绑定设备后
  Widget userBindingTerminal() {
    return Consumer<MachineNotifier>(
      builder: (context, notifier, child) {
        if (notifier.machine != null) {
          if (!bindingTerminal) {
            bindingTerminal = true;
            print("bindingTerminal1:$bindingTerminal");
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                reload(() {});
              }
            });
          }
        } else {
          if (bindingTerminal) {
            bindingTerminal = false;
            print("bindingTerminal2:$bindingTerminal");
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                reload(() {});
              }
            });
          }
        }
        return child;
      },
      child: Container(),
    );
  }

  Widget _getCourseCommentUi() {
    print("recommendLoadingStatus:${recommendLoadingStatus}");
    return SliverToBoxAdapter(
      child: Visibility(
        visible: recommendLoadingStatus == LoadingStatus.STATUS_COMPLETED,
        child: CommonCommentPage(
          key: childKey,
          scrollController: scrollController,
          refreshController: _refreshController,
          fatherComment: fatherComment,
          targetId: videoModel.id,
          targetType: 3,
          pageCommentSize: 20,
          pageSubCommentSize: 3,
          isShowHotOrTime: true,
          isInteractiveIn: isInteractive,
          commentDtoModel: commentDtoModel,
          isShowAt: false,
          globalKeyList: globalKeyList,
          isVideoCoursePage: true,
        ),
      ),
    );
  }

  //获取下载中的ui
  Widget getDownloadingUi(String text) {
    if (_progressText.contains("异常") || _progressText.contains("暂停")) {
      text = "下载暂停";
    }
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(left: 32, right: 32),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(40 / 2), color: AppColor.bgWhite),
          ),
          Container(
            width: double.infinity,
            height: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40 / 2),
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 64) * _progress,
                  height: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(40 / 2), color: AppColor.textPrimary1),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 40,
            child: Center(
              child: Text(text, style: AppStyle.whiteRegular16),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBtnUi(
      bool isVip, String text, TextStyle textStyle, double width1, double height1, EdgeInsetsGeometry marginData) {
    var colors = <Color>[];
    if (isVip) {
      colors.add(AppColor.bgVip1);
      colors.add(AppColor.bgVip2);
    } else {
      colors.add(AppColor.textPrimary1);
      colors.add(AppColor.textPrimary1);
    }
    return Container(
      width: width1,
      height: height1,
      margin: marginData,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height1 / 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }

  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
    ScrollMetrics metrics = notification.metrics;
    if (childKey == null || childKey.currentState == null || childKey.currentState.scrollHeightOld == null) {
      return false;
    }
    childKey.currentState.scrollHeightOld = metrics.pixels;
    if (metrics.pixels < 10) {
      if (isBouncingScrollPhysics) {
        isBouncingScrollPhysics = false;
        if (mounted) {
          reload(() {});
        }
      }
    } else {
      if (!isBouncingScrollPhysics) {
        isBouncingScrollPhysics = true;
        if (mounted) {
          reload(() {});
        }
      }
    }
    return false;
  }

  //分享的点击事件
  void _shareBtnClick() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (!(context != null && isLoggedIn)) {
      ToastShow.show(msg: "请先登录app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    openShareBottomSheet(
        context: context,
        sharedType: 1,
        map: videoModel.toJson(),
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE);
  }

  //收藏按钮
  void _favorBtnClick() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (!(mounted && isLoggedIn)) {
      ToastShow.show(msg: "请先登录app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    print("点击了${isFavor ? "取消收藏" : "收藏"}按钮");
    Map<String, dynamic> map = await (!isFavor ? addToMyCourse : deleteFromMyCourse)(videoModel.id);
    if (map != null && map["state"] != null && map["state"]) {
      isFavor = !isFavor;
      if (mounted) {
        reload(() {});
      }
    }
  }

  void toastShow(String text) {
    ToastShow.show(msg: text, context: context);
  }

  //下载监听
  void initProgressListener() {
    _progressListener = (taskId, received, total) async {
      print("task的id是：$taskId");
      isDownLoading = true;
      _progress = received / total * (1.0 / allDownLoadCount) + completeDownCount * (1.0 / allDownLoadCount);
      _progress = ((_progress * 10000) ~/ 1) / 10000.0;
      if (received == total) {
        completeDownCount++;
        if (downloadStringArray.length > 0) {
          downloadStringArray.removeAt(0);
        }
        if (downloadStringArray.length < 1) {
          isDownLoading = false;
          // downloadAllCompleteVideo();
        } else {
          startDownVideo(downloadStringArray[0]);
        }
      }
      print("[${DateTime.now().millisecondsSinceEpoch}]taskId:$taskId; received:$received; total:$total; "
          "progress:$_progress; allDownLoadCount:$allDownLoadCount; completeDownCount:$completeDownCount");
      if (mounted) {
        reload(() {});
      }
    };
  }

  initConnectivity() {
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.mobile:
          print('----------mobile-----------------mobile');
          break;
        case ConnectivityResult.wifi:
          print('----------wifi-----------------wifi');
          break;
        case ConnectivityResult.none:
          if (isDownLoading) {
            dio.lock();
            try {
              if (context != null && mounted) {
                ToastShow.show(msg: "网络异常", context: context);
              }
            } catch (e) {}
            _progressText = "下载异常";
            if (mounted) {
              setState(() {});
            }
          }
          break;
      }
    });
  }

  //没有登陆点击事件
  void onNoLoginClickListener() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    ToastShow.show(msg: "请先登录app!", context: context);
    // 去登录
    AppRouter.navigateToLoginPage(context);
  }

  void getStoragePermision() async {
    var permissionStatus = await Permission.storage.status;
    switch (permissionStatus) {
      case PermissionStatus.granted:
        onJudgeIsDownLoadCompleteVideo();
        break;
      case PermissionStatus.denied:
        var status = await Permission.storage.request();
        switch (status) {
          case PermissionStatus.granted:
            onJudgeIsDownLoadCompleteVideo();
            break;
          case PermissionStatus.permanentlyDenied:
            showAppDialog(context,
                title: "获取存储权限",
                info: "使用该功能需要打开存储权限",
                cancel: AppDialogButton("取消", () {
                  return true;
                }),
                confirm: AppDialogButton(
                  "去打开",
                  () {
                    AppSettings.openAppSettings();
                    return true;
                  },
                ),
                barrierDismissible: false);
            break;
        }
        break;
    }
  }

  //判断有没有完整的下载好视频
  void onJudgeIsDownLoadCompleteVideo() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (videoModel.coursewareDto.videoMapList != null || videoModel.coursewareDto.videoMapList.length > 0) {
      for (Map<String, dynamic> map in videoModel.coursewareDto.videoMapList) {
        print("map[videoUrl]:${map["videoUrl"]}");
        String path = await FileUtil().getDownloadedPath(map["videoUrl"]);
        if (path != null) {
          videoPathMap[map["videoUrl"]] = path;
        } else {
          downloadStringArray.add(map["videoUrl"]);
        }
      }
      allDownLoadCount = videoModel.coursewareDto.videoMapList.length;
    } else {
      // toastShow("没有视频");
    }
    if (downloadStringArray.length < 1) {
      completeDownCount = allDownLoadCount;
      downloadAllCompleteVideo();
    } else {
      completeDownCount = allDownLoadCount - downloadStringArray.length;
      dio = Dio();
      startDownVideo(downloadStringArray[0]);
    }
  }

  onDownLoadErrorClick() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (_progressText.contains("异常") || _progressText.contains("暂停")) {
      dio = Dio();
      _progressText = "正常下载";
      startDownVideo(downloadStringArray[0]);
    } else {
      dio.lock();
      _progressText = "下载暂停";
      setState(() {});
    }
  }

  //全部的视频地址已经下载完成--跳转
  void downloadAllCompleteVideo() {
    //等一下 避免数据还没有写进数据库
    Future.delayed(Duration(milliseconds: 200), () async {
      List<String> urls = <String>[];
      List<String> filePaths = <String>[];
      if (videoModel.coursewareDto.videoMapList != null || videoModel.coursewareDto.videoMapList.length > 0) {
        for (Map<String, dynamic> map in videoModel.coursewareDto.videoMapList) {
          urls.add(map["videoUrl"]);
          if (videoPathMap[map["videoUrl"]] == null) {
            videoPathMap[map["videoUrl"]] = await FileUtil().getDownloadedPath(map["videoUrl"]);
          }
          if (videoPathMap[map["videoUrl"]] != null) {
            filePaths.add(videoPathMap[map["videoUrl"]]);
          }
        }
      }
      if (filePaths.length < 1) {
        ToastShow.show(msg: "视频下载失败", context: context);
      } else {
        DownloadVideoCourseDBHelper().update(videoModel, urls, filePaths);
        if (context != null && mounted) {
          AppRouter.navigateToVideoCoursePlay(context, videoPathMap, videoModel);
        }
      }
    });
  }

  //开始下载
  void startDownVideo(String downloadUrl) async {
    print("downloadUrl:$downloadUrl");
    FileUtil().chunkDownLoad(context, downloadUrl, _progressListener,
        cancelToken: cancelToken, dio: dio, type: downloadTypeCourse, downloadCompleteListener: () {
      if (downloadStringArray.length < 1) {
        isDownLoading = false;
        downloadAllCompleteVideo();
      }
    });
  }

  //格式化进度
  String formatProgress(double progress) {
    int value = (progress * 10000) ~/ 1;
    return "${value ~/ 100}.${value % 100}";
  }

  //获取底部按钮
  Widget _getBottomBar() {
    //todo 判断用户是不是vip缺少开通vip的回调
    bool isVip = context.read<TokenNotifier>().isLoggedIn ? Application.profile.isVip == 1 : false;

    TextStyle textStyle = AppStyle.whiteRegular16;
    TextStyle textStyleVip = const TextStyle(color: AppColor.textVipPrimary1, fontSize: 16);
    EdgeInsetsGeometry margin_32 = const EdgeInsets.only(left: 32, right: 32);
    EdgeInsetsGeometry marginLeft26Right20 = const EdgeInsets.only(left: 26, right: 20);

    var childrenArray = <Widget>[];

    Widget widget3 = Container(
      width: 60,
      color: AppColor.transparent,
      height: double.infinity,
      margin: marginLeft26Right20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon.getAppIcon(AppIcon.headset, 24),
          Text("试听"),
        ],
      ),
    );

    if (!isDownLoading) {
      if (!isLoggedIn) {
        childrenArray.add(Expanded(
            child: SizedBox(
          child: GestureDetector(
            child: getBtnUi(false, "试听", textStyle, double.infinity, 40, margin_32),
            onTap: onNoLoginClickListener,
          ),
        )));
      } else {
        //试听图片
        childrenArray.add(GestureDetector(
          child: widget3,
          // onTap: CheckPhoneSystemUtil.init().isAndroid()?getStoragePermision:onJudgeIsDownLoadCompleteVideo,
          onTap: onJudgeIsDownLoadCompleteVideo,
        ));

        print("videoModel.priceType:${videoModel.priceType}");

        if (videoModel.priceType == 0 || (videoModel.priceType == 1 && isVip)) {
          print("bindingTerminal4:$bindingTerminal");
          if (bindingTerminal) {
            childrenArray.add(
              Expanded(
                child: SizedBox(
                  child: GestureDetector(
                    child: getBtnUi(false, "使用终端训练", textStyle, double.infinity, 40, margin_32),
                    onTap: _useTerminal,
                  ),
                ),
              ),
            );
          } else {
            childrenArray.add(
              Expanded(
                child: SizedBox(
                  child: GestureDetector(
                    child: getBtnUi(false, "登录终端使用终端播放", textStyle, double.infinity, 40, margin_32),
                    onTap: _loginTerminalBtn,
                  ),
                ),
              ),
            );
          }
        } else if (videoModel.priceType == 2) {
          //todo 付费视频--目前是开通vip
          if (bindingTerminal) {
            childrenArray.add(
              Expanded(
                child: SizedBox(
                  child: GestureDetector(
                    child: getBtnUi(true, "开通vip使用终端播放", textStyleVip, double.infinity, 40, margin_32),
                    onTap: _openVip,
                  ),
                ),
              ),
            );
          } else {
            childrenArray.add(
              Expanded(
                child: SizedBox(
                  child: GestureDetector(
                    child: getBtnUi(false, "登录终端使用终端播放", textStyle, double.infinity, 40, margin_32),
                    onTap: _loginTerminalBtn,
                  ),
                ),
              ),
            );
          }
        } else {
          //需要开通vip

          if (bindingTerminal) {
            childrenArray.add(
              Expanded(
                child: SizedBox(
                  child: GestureDetector(
                    child: getBtnUi(true, "开通vip使用终端播放", textStyleVip, double.infinity, 40, margin_32),
                    onTap: _openVip,
                  ),
                ),
              ),
            );
          } else {
            childrenArray.add(
              Expanded(
                child: SizedBox(
                  child: GestureDetector(
                    child: getBtnUi(false, "登录终端使用终端播放3", textStyle, double.infinity, 40, margin_32),
                    onTap: _loginTerminalBtn,
                  ),
                ),
              ),
            );
          }
        }
      }
    } else {
      childrenArray.add(
        Expanded(
          child: SizedBox(
            child: GestureDetector(
              child: getDownloadingUi(_progress == 0.0 ? "下载准备中" : "下载中 ${formatProgress(_progress)}%"),
              onTap: onDownLoadErrorClick,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        width: double.infinity,
        child: Row(
          children: childrenArray,
        ),
      ),
    );
  }

  //加载网络数据
  void getDataAction({bool isFold = false}) async {
    if (await isOffline()) {
      recommendLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        reload(() {});
      }
      return;
    }

    //其他人完成训练
    if (recommendTopicList == null || recommendTopicList.length < 1) {
      DataResponseModel dataResponseModel = await getPullList(
        type: 7,
        size: 3,
        targetId: videoCourseId,
      );
      if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
        dataResponseModel.list.forEach((v) {
          if (recommendTopicList.length < 3) {
            recommendTopicList.add(HomeFeedModel.fromJson(v));
          }
          context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
          context.read<FeedFlowDataNotifier>().pageLastTime = dataResponseModel.lastTime;
          context.read<FeedFlowDataNotifier>().pageSize = 1;
        });
      }
    }

    recommendLoadingStatus = LoadingStatus.STATUS_COMPLETED;

    //获取视频详情数据
    //加载数据
    Map<String, dynamic> model = await getVideoCourseDetail(courseId: videoCourseId);
    if (model["code"] != null && model["code"] == CODE_SUCCESS && model["dataMap"] != null) {
      videoModel = CourseModel.fromJson(model["dataMap"]);
      if (videoModel.isInMyCourseList != null) {
        isFavor = videoModel.isInMyCourseList == 1;
      }
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        reload(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          reload(() {});
        }
      });
    }
  }

  ///这是关注的方法
  onClickAttention(int attntionResult) async {
    videoModel.coachDto?.relation = 1;
  }

  ///点击了教练
  onClickCoach() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    jumpToUserProfilePage(context, videoModel.coachDto?.uid,
        avatarUrl: videoModel.coachDto?.avatarUri, userName: videoModel.coachDto?.nickName, callback: (dynamic r) {
      bool result =
          context.read<UserInteractiveNotifier>().value.profileUiChangeModel[videoModel.coachDto.uid].isFollow;
      print("result:$result");
      if (null != result && result is bool) {
        videoModel.coachDto.relation = result ? 0 : 1;
        if (mounted) {
          reload(() {});
        }
      }
    });
  }

  ///点击了他人刚刚训练完成
  onClickOtherComplete(int onClickPosition) async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    context.read<FeedFlowDataNotifier>().pageSelectPosition = onClickPosition;
    double scrollHeight = specifyItemHeight(onClickPosition);
    AppRouter.navigateToOtherCompleteCoursePage(context, videoModel.id, 7, scrollHeight, pageName, duration: 0);
  }

  //登陆终端按钮
  void _loginTerminalBtn() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (Application.token.anonymous == 0) {
      gotoScanCodePage(context);
    } else {
      AppRouter.navigateToLoginPage(context);
    }
  }

  bool isOfflineBool = false;

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (isOfflineBool) {
        isOfflineBool = false;
        getDataAction();
      }
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (isOfflineBool) {
        isOfflineBool = false;
        getDataAction();
      }
      return false;
    } else {
      isOfflineBool = true;
      return true;
    }
  }

  //计算高度
  double specifyItemHeight(int onClickPosition) {
    if (onClickPosition < 1) {
      return 0.0;
    }
    double clickTopItemHeight = getClickTopItemHeight(onClickPosition);
    double clickBottomItemHeight = judgeClickItemBottomHeightThenScreenHeight(onClickPosition);
    if (clickBottomItemHeight >= ScreenUtil.instance.height) {
      return clickTopItemHeight;
    } else {
      return max(
          clickTopItemHeight -
              ((ScreenUtil.instance.height - 44 - ScreenUtil.instance.statusBarHeight) - clickBottomItemHeight),
          0.0);
    }
  }

  //判断点击item以及他后面的item的高度是否大于手机屏幕
  double judgeClickItemBottomHeightThenScreenHeight(int onClickPosition) {
    int itemLength = context.read<FeedFlowDataNotifier>().homeFeedModelList.length;
    if (onClickPosition >= itemLength) {
      return 0.0;
    }
    double itemHeight = 0.0;
    for (int i = onClickPosition; i < itemLength; i++) {
      itemHeight += getFeedItemHeight(context.read<FeedFlowDataNotifier>().homeFeedModelList[i]);
      if (itemHeight >= (ScreenUtil.instance.height - 44 - ScreenUtil.instance.statusBarHeight)) {
        return itemHeight;
      }
    }
    return itemHeight;
  }

  //获取点击item的顶部所有item的高度
  double getClickTopItemHeight(int onClickPosition) {
    double itemHeight = 0.0;
    for (int i = 0; i < onClickPosition; i++) {
      itemHeight += getFeedItemHeight(recommendTopicList[i]);
    }
    return itemHeight;
  }

  //每一个动态流的item的高度
  double getFeedItemHeight(HomeFeedModel v) {
    double itemHeight = 0.0;
    // 头部
    itemHeight += 62;
    // 图片
    if (v.picUrls.isNotEmpty) {
      if (v.picUrls.first.height == 0) {
        itemHeight += ScreenUtil.instance.width;
      } else {
        itemHeight += (ScreenUtil.instance.width / v.picUrls[0].width) * v.picUrls[0].height;
      }
    }
    // 视频
    if (v.videos.isNotEmpty) {
      itemHeight += _calculateHeight(v);
    }
    // 转发评论点赞
    itemHeight += 48;

    //地址和课程
    if (v.address != null || v.courseDto != null) {
      itemHeight += 7;
      itemHeight += getTextSize("123", TextStyle(fontSize: 12), 1).height;
    }

    //文本
    if (v.content.length > 0) {
      itemHeight += 12;
      itemHeight += getTextSize(v.content, TextStyle(fontSize: 14), 2, ScreenUtil.instance.width - 32).height;
    }

    //评论文本
    if (v.comments != null && v.comments.length != 0) {
      itemHeight += 8;
      itemHeight += 6;
      itemHeight += getTextSize("共0条评论", AppStyle.text1Regular12, 1).height;
      itemHeight += getTextSize("第一条评论", AppStyle.text1Regular13, 1).height;
      if (v.comments.length > 1) {
        itemHeight += 8;
        itemHeight += getTextSize("第二条评论", AppStyle.text1Regular13, 1).height;
      }
    }

    // 输入框
    itemHeight += 48;

    //分割块
    itemHeight += 18;
    return itemHeight;
  }

  _calculateHeight(HomeFeedModel feedModel) {
    double containerWidth = ScreenUtil.instance.width;
    double containerHeight;
    double videoRatio = feedModel.videos.first.width / feedModel.videos.first.height;
    double containerRatio;

    //如果有裁剪的比例 则直接用该比例
    if (feedModel.videos.first.videoCroppedRatio != null) {
      containerRatio = feedModel.videos.first.videoCroppedRatio;
    } else {
      if (videoRatio < minMediaRatio) {
        containerRatio = minMediaRatio;
      } else if (videoRatio > maxMediaRatio) {
        containerRatio = maxMediaRatio;
      } else {
        containerRatio = videoRatio;
      }
    }
    containerHeight = containerWidth / containerRatio;
    return containerHeight;
  }

  //滚动到界面的顶部
  void _animateToIndex() async {
    print("滚动到顶部");
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  //开通vip
  void _openVip() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    AppRouter.navigateToVipPage(context, VipState.NOTOPEN, openOrNot: false);
  }

  //使用终端进行训练
  void _useTerminal() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    print("绑定了终端");
    startVideoCourse(Application.machine.machineId, videoCourseId);
    AppRouter.navigateToMachineRemoteController(context);
  }
}
