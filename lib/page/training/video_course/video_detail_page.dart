
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/download_video_course_db_helper.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/training/currency/currency_comment_page.dart';
import 'package:mirror/page/training/currency/currency_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/widget/sliver_custom_header_delegate_video.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

/// 视频详情页
class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage(
      {Key key,
        this.heroTag,
        this.commentDtoModel,
        this.fatherComment,
        this.videoCourseId,
        this.videoModel})
      : super(key: key);

  final String heroTag;
  final int videoCourseId;
  final LiveVideoModel videoModel;
  final CommentDtoModel commentDtoModel;
  final CommentDtoModel fatherComment;

  @override
  createState() {
    return VideoDetailPageState(videoModel: videoModel);
  }
}

class VideoDetailPageState extends State<VideoDetailPage> {
  VideoDetailPageState({Key key, this.videoModel});


  //当前视频课程的model
  LiveVideoModel videoModel;

  //其他用户的完成训练
  DataResponseModel dataResponseModel;
  List<HomeFeedModel> recommendTopicList = [];

  //加载状态
  LoadingStatus loadingStatus;
  LoadingStatus recommendLoadingStatus;

  //title文字的样式
  var titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textPrimary1);

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //是否可以回弹
  bool isBouncingScrollPhysics = false;

  //下载监听
  Function(String, int, int) _progressListener;

  //下载进度
  double _progress = 0.0;

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


  GlobalKey<CurrencyCommentPageState> childKey = GlobalKey();
  List<GlobalKey> globalKeyList=<GlobalKey>[];


  //判断用户登陆没有
  bool isLoggedIn;

  //判断是否绑定了终端
  bool bindingTerminal;


  @override
  void initState() {
    super.initState();

    isLoggedIn=context.read<TokenNotifier>().isLoggedIn;
    bindingTerminal=context.read<MachineNotifier>().machine!=null;


    if(videoModel==null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
    }else{
      if(videoModel.isInMyCourseList!=null) {
        isFavor = videoModel.isInMyCourseList == 1;
      }
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    }
    recommendLoadingStatus = LoadingStatus.STATUS_LOADING;
    getDataAction();
    initProgressListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
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
        widgetArray.add(Expanded(
            child: SizedBox(
                child: Center(
          child: CircularProgressIndicator(),
        ))));
      } else {
        //加载失败
        widgetArray.add(Expanded(
            child: SizedBox(
          child: Center(
            child: GestureDetector(
              child: Text("加载失败"),
              onTap: () {
                loadingStatus = LoadingStatus.STATUS_LOADING;
                if(mounted){
                  setState(() {});
                }
                getDataAction();
              },
            ),
          ),
        )));
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
              height: MediaQuery.of(context).size.height - 50-ScreenUtil.instance.bottomBarHeight,
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
              height: 50.0+ScreenUtil.instance.bottomBarHeight,
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
    GlobalKey globalKey0=new GlobalKey();
    GlobalKey globalKey1=new GlobalKey();
    GlobalKey globalKey2=new GlobalKey();
    GlobalKey globalKey3=new GlobalKey();
    GlobalKey globalKey4=new GlobalKey();
    GlobalKey globalKey5=new GlobalKey();
    globalKeyList.add(globalKey0);
    globalKeyList.add(globalKey1);
    globalKeyList.add(globalKey2);
    globalKeyList.add(globalKey3);
    globalKeyList.add(globalKey4);
    globalKeyList.add(globalKey5);
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: footerWidget(),
      controller: _refreshController,
      onLoading: (){
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
              heroTag: widget.heroTag,
              startTime: videoModel.startTime,
              endTime: videoModel.endTime,
              shareBtnClick: _shareBtnClick,
              favorBtnClick: _favorBtnClick,
              isFavor: isFavor,
              globalKey: globalKeyList[0],
            ),
          ),
          getTitleWidget(videoModel, context,globalKeyList[1]),
          getCoachItem(videoModel, context, onClickAttention, onClickCoach,globalKeyList[2]),
          getLineView(),
          getTrainingEquipmentUi(videoModel, context, titleTextStyle,globalKeyList[3]),
          getActionUiVideo(videoModel, context, titleTextStyle,globalKeyList[4]),
          getOtherUsersUi(recommendTopicList, context, titleTextStyle, onClickOtherComplete,globalKeyList[5]),
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
        if(!isLoggedIn&&notifier.isLoggedIn){
          getDataAction();
        }
        isLoggedIn=notifier.isLoggedIn;
        return child;
      },
      child: Container(),
    );
  }
  //当用户绑定设备后
  Widget userBindingTerminal() {
    return Consumer<MachineNotifier>(
      builder: (context, notifier, child) {
        if(notifier.machine!=null){
          bindingTerminal=true;
          Future.delayed(Duration(milliseconds: 300),(){
            if(mounted){
              setState(() {});
            }
          });
        }else{
          bindingTerminal=false;
        }
        return child;
      },
      child: Container(),
    );
  }


  Widget _getCourseCommentUi(){

    return SliverToBoxAdapter(
      child: Visibility(
        visible: recommendLoadingStatus==LoadingStatus.STATUS_COMPLETED,
        child: CurrencyCommentPage(
          key:childKey,
          scrollController: scrollController,
          refreshController: _refreshController,
          fatherComment:widget.fatherComment,
          targetId:videoModel.id,
          targetType:3,
          pageCommentSize:20,
          pageSubCommentSize:3,
          isShowHotOrTime:true,
          commentDtoModel:widget.commentDtoModel,
          isShowAt:false,
          globalKeyList: globalKeyList,
        ),
      ),
    );
  }


  //获取下载中的ui
  Widget getDownloadingUi(String text) {
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
              child: Text(text, style: const TextStyle(color: AppColor.white, fontSize: 16)),
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
    childKey.currentState.scrollHeightOld=metrics.pixels;
    if (metrics.pixels < 10) {
      if (isBouncingScrollPhysics) {
        isBouncingScrollPhysics = false;
        if(mounted){
          setState(() {});
        }
      }
    } else {
      if (!isBouncingScrollPhysics) {
        isBouncingScrollPhysics = true;
        if(mounted){
          setState(() {});
        }
      }
    }
    return false;
  }

  //分享的点击事件
  void _shareBtnClick() {
    print("分享点击事件视频课");
    openShareBottomSheet(
        context: context,
        sharedType: 1,
        map: videoModel.toJson(),
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE);
  }

  //收藏按钮
  void _favorBtnClick() async {
    if(!(mounted&&context.read<TokenNotifier>().isLoggedIn)){
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    print("点击了${isFavor ? "取消收藏" : "收藏"}按钮");
    Map<String, dynamic> map = await (!isFavor ? addToMyCourse : deleteFromMyCourse)(videoModel.id);
    if (map != null && map["state"] != null && map["state"]) {
      isFavor = !isFavor;
      if(mounted){
        setState(() {});
      }
    }
  }

  void toastShow(String text) {
    ToastShow.show(msg: text, context: context);
  }

  //下载监听
  void initProgressListener() {
    _progressListener = (taskId, received, total) async {
      isDownLoading = true;
      _progress = received / total * (1.0 / allDownLoadCount) + completeDownCount * (1.0 / allDownLoadCount);
      _progress = ((_progress * 10000) ~/ 1) / 10000.0;
      if (received == total) {
        completeDownCount++;
        downloadStringArray.removeAt(0);
        if (downloadStringArray.length < 1) {
          isDownLoading = false;
          downloadAllCompleteVideo();
        } else {
          startDownVideo(downloadStringArray[0]);
        }
      }
      print("[${DateTime.now().millisecondsSinceEpoch}]taskId:$taskId; received:$received; total:$total; "
          "progress:$_progress; allDownLoadCount:$allDownLoadCount; completeDownCount:$completeDownCount");
      if(mounted){
        setState(() {});
      }
    };
  }

  //没有登陆点击事件
  void onNoLoginClickListener() {
    ToastShow.show(msg: "请先登陆app!", context: context);
    // 去登录
    AppRouter.navigateToLoginPage(context);
  }

  //判断有没有完整的下载好视频
  void onJudgeIsDownLoadCompleteVideo() async {
    if (videoModel.coursewareDto.videoMapList != null || videoModel.coursewareDto.videoMapList.length > 0) {
      for (Map<String, dynamic> map in videoModel.coursewareDto.videoMapList) {
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
      startDownVideo(downloadStringArray[0]);
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
          filePaths.add(videoPathMap[map["videoUrl"]]);
        }
      }
      DownloadVideoCourseDBHelper().update(videoModel, urls, filePaths);
      AppRouter.navigateToVideoCoursePlay(context, videoPathMap, videoModel);
    });
  }

  //开始下载
  void startDownVideo(String downloadUrl) async {
    String taskId = (await FileUtil().download(downloadUrl, _progressListener))?.taskId;
    print("task的id是：$taskId");
  }

  //格式化进度
  String formatProgress(double progress) {
    int value = (progress * 10000) ~/ 1;
    return "${value ~/ 100}.${value % 100}";
  }

  //获取底部按钮
  Widget _getBottomBar() {

    //todo 判断用户是不是vip
    bool isVip = false;

    TextStyle textStyle = const TextStyle(color: AppColor.white, fontSize: 16);
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
          Icon(Icons.headset),
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
          onTap: onJudgeIsDownLoadCompleteVideo,
        ));

        if (videoModel.priceType == 0 || (videoModel.priceType == 1 && isVip)) {
          if (bindingTerminal) {
            childrenArray.add(Expanded(
                child: SizedBox(
              child: GestureDetector(
                child: getBtnUi(false, "使用终端训练", textStyle, double.infinity, 40, margin_32),
                onTap: () {
                  print("绑定了终端");
                  ToastShow.show(msg: "使用终端训练", context: context);
                },
              ),
            )));
          } else {
            childrenArray.add(Expanded(
                child: SizedBox(
              child: GestureDetector(
                child: getBtnUi(false, "登陆终端使用终端播放", textStyle, double.infinity, 40, margin_32),
                onTap: () {
                  print("没有绑定终端");
                  ToastShow.show(msg: "登陆终端", context: context);
                },
              ),
            )));
          }
        } else if (videoModel.priceType == 2) {
          //todo 付费视频--目前是开通vip
          if (bindingTerminal) {
            childrenArray.add(Expanded(
                child: SizedBox(
              child: GestureDetector(
                child: getBtnUi(true, "开通vip使用终端播放", textStyleVip, double.infinity, 40, margin_32),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return VipNotOpenPage(
                      type: VipState.NOTOPEN,
                    );
                  }));
                },
              ),
            )));
          } else {
            childrenArray.add(Expanded(
                child: SizedBox(
              child: GestureDetector(
                child: getBtnUi(false, "登陆终端使用终端播放", textStyle, double.infinity, 40, margin_32),
                onTap: () {
                  print("没有绑定终端");
                  ToastShow.show(msg: "登陆终端", context: context);
                },
              ),
            )));
          }
        } else {
          //需要开通vip

          if (bindingTerminal) {
            childrenArray.add(Expanded(
                child: SizedBox(
              child: GestureDetector(
                child: getBtnUi(true, "开通vip使用终端播放", textStyleVip, double.infinity, 40, margin_32),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return VipNotOpenPage(
                      type: VipState.NOTOPEN,
                    );
                  }));
                },
              ),
            )));
          } else {
            childrenArray.add(Expanded(
                child: SizedBox(
              child: GestureDetector(
                child: getBtnUi(false, "登陆终端使用终端播放", textStyle, double.infinity, 40, margin_32),
                onTap: () {
                  print("没有绑定终端");
                  ToastShow.show(msg: "登陆终端", context: context);
                },
              ),
            )));
          }
        }
      }
    } else {
      childrenArray.add(Expanded(
          child: SizedBox(
        child: GestureDetector(
          child: getDownloadingUi(_progress == 0.0 ? "下载准备中" : "下载中 ${formatProgress(_progress)}%"),
          onTap: () {
            print("下载中");
            ToastShow.show(msg: "下载中", context: context);
          },
        ),
      )));
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
    //其他人完成训练
    if (recommendTopicList == null || recommendTopicList.length < 1) {
      dataResponseModel = await getPullList(
        type: 7,
        size: 3,
        targetId: widget.videoCourseId,
      );
      if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
        dataResponseModel.list.forEach((v) {
          recommendTopicList.add(HomeFeedModel.fromJson(v));
        });
      }
    }

    recommendLoadingStatus = LoadingStatus.STATUS_COMPLETED;


    //获取视频详情数据
    //加载数据
    Map<String, dynamic> model = await getVideoCourseDetail(courseId: widget.videoCourseId);
    if (model == null) {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        if(mounted){
          setState(() {});
        }
      });
    } else {
      videoModel = LiveVideoModel.fromJson(model);

      if(videoModel.isInMyCourseList!=null) {
        isFavor = videoModel.isInMyCourseList == 1;
      }
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      if(mounted){
        setState(() {});
      }
    }
  }

  ///这是关注的方法
  onClickAttention() {
    if(!(mounted&&context.read<TokenNotifier>().isLoggedIn)){
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    if (!(videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3)) {
      _getAttention(videoModel.coachDto?.uid);
    }
  }

  ///这是关注的方法
  _getAttention(int userId) async {
    int attntionResult = await ProfileAddFollow(userId);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      videoModel.coachDto?.relation = 1;
      if(mounted){
        setState(() {});
      }
    }
  }

  ///点击了教练
  onClickCoach() {
    AppRouter.navigateToMineDetail(context, videoModel.coachDto?.uid);
  }

  ///点击了他人刚刚训练完成
  onClickOtherComplete() {
    AppRouter.navigateToOtherCompleteCoursePage(context, videoModel.id);
  }

}
