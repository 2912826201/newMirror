import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/download_video_course_db_helper.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/training/video_course/sliver_custom_header_delegate_video.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

/// 视频详情页
class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({Key key, this.heroTag, this.liveCourseId, this.videoModel}) : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final LiveVideoModel videoModel;

  @override
  createState() {
    return VideoDetailPageState(heroTag: heroTag, videoCourseId: liveCourseId, videoModel: videoModel);
  }
}

class VideoDetailPageState extends State<VideoDetailPage> {
  VideoDetailPageState({Key key, this.heroTag, this.videoCourseId, this.videoModel});

  //头部hero的标签
  String heroTag;

  //视频课程的id
  int videoCourseId;


  //当前视频课程的model
  LiveVideoModel videoModel;

  //其他用户的完成训练
  List<UserModel> otherUsers;

  //加载状态
  LoadingStatus loadingStatus;

  //评论加载状态
  LoadingStatus loadingStatusComment;

  //加载状态--子评论
  var commentLoadingStatusList = <LoadingStatus>[];

  //title文字的样式
  var titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textPrimary1);

  //用户的评论热度
  CommentModel courseCommentHot;

  //评论
  CommentModel courseCommentTime;

  //回复第二级别人的评论时-别人的id
  int replyId = -1;

  //回复第二级别人时 别人评论的id
  int replyCommentId = -1;

  //发布评论时的targetId
  int targetId;

  //发布评论时的targetType
  int targetType;

  //判断是热度还是评论
  bool isHotOrTime = true;

  //用户评论的的一些动画参数
  var commentListSubSettingList = <CommentListSubSetting>[];

  //折叠动画的时间
  var animationTime = 500; //毫秒

  //是否可以回弹
  bool isBouncingScrollPhysics = false;

  //每次请求的评论个数
  int courseCommentPageSize = 3;

  //热门当前是第几页
  int courseCommentPageHot = 1;

  //时间排序当前是第几页
  int courseCommentPageTime = 1;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

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

  @override
  void initState() {
    super.initState();
    print("====heroTag:${heroTag}");
    courseCommentHot = null;
    courseCommentTime = null;
    loadingStatusComment = LoadingStatus.STATUS_LOADING;
    if (videoModel == null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
      getDataAction();
      return;
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      getDataAction();
    }

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
    //有数据
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(
        height: 40,
      ));
      widgetArray.add(_getNoCompleteTitle());
      //在加载中
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        widgetArray.add(Expanded(
            child: SizedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )));
      } else {
        //加载失败
        widgetArray.add(Expanded(
            child: SizedBox(
          child: Center(
            child: GestureDetector(
              child: Text("加载失败"),
              onTap: () {
                loadingStatus = LoadingStatus.STATUS_LOADING;
                setState(() {});
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

  //当没有加载完成或者没有加载成功时的title
  Widget _getNoCompleteTitle() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "直播课程详情页",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColor.textPrimary1,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  //加载数据成功时的布局
  Widget _buildSuggestionsComplete() {
    String imageUrl;

    if (videoModel.picUrl != null) {
      imageUrl = videoModel.picUrl;
    } else if (videoModel.coursewareDto?.picUrl != null) {
      imageUrl = videoModel.coursewareDto?.picUrl;
    } else if (videoModel.coursewareDto?.previewVideoUrl != null) {
      imageUrl = videoModel.coursewareDto?.previewVideoUrl;
    }

    Widget widget = Container(
      color: AppColor.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 50,
            child: ScrollConfiguration(
              behavior: NoBlueEffectBehavior(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  ScrollMetrics metrics = notification.metrics;
                  if (metrics.pixels < 10) {
                    if (isBouncingScrollPhysics) {
                      isBouncingScrollPhysics = false;
                      setState(() {});
                    }
                  } else {
                    if (!isBouncingScrollPhysics) {
                      isBouncingScrollPhysics = true;
                      setState(() {});
                    }
                  }
                  return false;
                },
                child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("");
                      } else if (mode == LoadStatus.loading) {
                        body = Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        );
                      } else if (mode == LoadStatus.failed) {
                        body = Text("");
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text("");
                      } else {
                        body = Text("");
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshController,
                  onLoading: _onLoading,
                  child: CustomScrollView(
                    physics: isBouncingScrollPhysics ? BouncingScrollPhysics() : ClampingScrollPhysics(),
                    slivers: <Widget>[
                      // header,
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverCustomHeaderDelegateVideo(
                          title: videoModel.title ?? "",
                          collapsedHeight: 40,
                          expandedHeight: 300,
                          paddingTop: MediaQuery.of(context).padding.top,
                          coverImgUrl: imageUrl,
                          heroTag: heroTag,
                          startTime: videoModel.startTime,
                          endTime: videoModel.endTime,
                          shareBtnClick: _shareBtnClick,
                          favorBtnClick: _favorBtnClick,
                          isFavor: isFavor,
                        ),
                      ),
                      _getTitleWidget(),
                      _getCoachItem(),
                      _getLineView(),
                      _getTrainingEquipmentUi(),
                      _getActionUi(),
                      _getOtherUsersUi(),
                      _getLineView(),
                      _getCourseCommentUi(),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 15,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: AppColor.white,
            child: _getBottomBar(),
          ),
        ],
      ),
    );
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: widget,
    );
  }

  //训练器材界面
  Widget _getTrainingEquipmentUi() {
    var widgetList = <Widget>[];
    widgetList.add(Container(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        "训练器材",
        style: titleTextStyle,
      ),
    ));

    widgetList.add(Expanded(child: SizedBox()));

    if (videoModel.equipmentDtos == null || videoModel.equipmentDtos.length < 1) {
      widgetList.add(Container(
        padding: const EdgeInsets.only(right: 32),
        child: Text(
          "无",
          style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
        ),
      ));
    } else {
      for (int i = 0; i < videoModel.equipmentDtos.length; i++) {
        widgetList.add(Container(
          margin: const EdgeInsets.all(8),
          child: Image.network(
            videoModel.equipmentDtos[i]?.terminalPicUrl ?? "",
            width: 24,
            height: 24,
            fit: BoxFit.cover,
          ),
        ));
      }
    }

    return SliverToBoxAdapter(
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.only(right: 4),
                child: Row(
                  children: widgetList,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                margin: const EdgeInsets.only(left: 16, right: 16),
                color: AppColor.bgWhite,
              ),
            ],
          )),
    );
  }

  //获取训练数据ui
  Widget _getTitleWidget() {
    var widgetArray = <Widget>[];
    var titleArray = [
      (videoModel.times ~/ 60000).toString(),
      videoModel.calories.toString(),
      videoModel.levelDto?.ename
    ];
    var subTitleArray = ["分钟", "千卡", videoModel.levelDto?.name];
    var tagArray = ["时间", "消耗", "难度"];

    for (int i = 0; i < titleArray.length; i++) {
      widgetArray.add(Container(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: [
                  Text(
                    titleArray[i] ?? "",
                    style: TextStyle(fontSize: 23, color: AppColor.black, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Container(
                    child: Text(
                      subTitleArray[i] ?? "",
                      style: TextStyle(fontSize: 12, color: AppColor.textPrimary3),
                    ),
                    margin: const EdgeInsets.only(top: 4),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              tagArray[i],
              style: TextStyle(fontSize: 12, color: AppColor.textHint),
            ),
          ],
        ),
        width: (MediaQuery.of(context).size.width - 1) / 3,
      ));
      if (i < titleArray.length - 1) {
        widgetArray.add(Container(
          width: 0.5,
          height: 18,
          color: AppColor.textHint,
        ));
      }
    }
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        color: AppColor.white,
        padding: const EdgeInsets.only(top: 14, bottom: 14),
        child: Row(
          children: widgetArray,
        ),
      ),
    );
  }

  //获取教练的名字
  Widget _getCoachItem() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
          color: Colors.white,
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(width: 0.0, color: Colors.black),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    videoModel.coachDto?.avatarUri ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      // ignore: null_aware_before_operator
                      videoModel.coachDto?.nickName,
                      style: const TextStyle(fontSize: 14, color: AppColor.textPrimary2, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    color: videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3
                        ? AppColor.white
                        : AppColor.black,
                    child: InkWell(
                      splashColor: AppColor.textHint,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          border: Border.all(
                              width: videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3 ? 1 : 0.0,
                              color: AppColor.textHint),
                        ),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                        child: Text(
                          videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3 ? "已关注" : "关注",
                          style: TextStyle(
                              color: videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3
                                  ? AppColor.textHint
                                  : AppColor.white,
                              fontSize: 11),
                        ),
                      ),
                      onTap: () {
                        if (!(videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3)) {
                          _getAttention(videoModel.coachDto?.uid);
                        }
                      },
                    )),
              )
            ],
          ),
        ),
        onTap: () {
          AppRouter.navigateToMineDetail(context, videoModel.coachDto?.uid);
        },
      ),
    );
  }

  //获取横线
  Widget _getLineView() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 12,
        color: AppColor.bgWhite.withOpacity(0.65),
      ),
    );
  }

  //获取动作的ui
  Widget _getActionUi() {
    // ignore: null_aware_before_operator
    if (videoModel.coursewareDto?.actionMapList == null || videoModel.coursewareDto?.actionMapList?.length < 1) {
      return SliverToBoxAdapter();
    }
    var widgetArray = <Widget>[];
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 11.5),
      width: double.infinity,
      child: Text(
        "动作${videoModel.coursewareDto?.actionMapList?.length}个",
        style: titleTextStyle,
      ),
    ));

    widgetArray.add(Container(
      width: double.infinity,
      height: 1,
      margin: const EdgeInsets.only(left: 16, right: 16),
      color: AppColor.bgWhite,
    ));

    widgetArray.add(
      Container(
        width: double.infinity,
        height: 66,
        margin: const EdgeInsets.only(top: 18, bottom: 18),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videoModel.coursewareDto?.actionMapList?.length,
            itemBuilder: (context, index) {
              String timeString = "";
              int longTime = 0;
              try {
                longTime = videoModel.coursewareDto?.actionMapList[index]["endTime"] -
                    videoModel.coursewareDto?.actionMapList[index]["startTime"];
              } catch (e) {
                longTime = 0;
              }
              if (longTime > 0) {
                timeString = DateUtil.formatSecondToStringNum1(longTime ~/ 1000) + "'${((longTime % 1000) ~/ 10)}'";
              }
              return Container(
                width: 136,
                height: 66,
                padding: const EdgeInsets.all(12),
                margin: index == 0
                    ? const EdgeInsets.only(left: 15.5)
                    // ignore: null_aware_before_operator
                    : (index ==
                            // ignore: null_aware_before_operator
                            videoModel.coursewareDto?.actionMapList?.length - 1
                        ? const EdgeInsets.only(left: 8)
                        : const EdgeInsets.only(left: 8, right: 15.5)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColor.bgWhite,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        videoModel.coursewareDto?.actionMapList[index]["name"],
                        style: TextStyle(fontSize: 14, color: AppColor.textPrimary2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        child: Text(
                          timeString,
                          style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                        )),
                  ],
                ),
              );
            }),
      ),
    );

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgetArray,
        ),
      ),
    );
  }

  //其他人完成的训练ui
  Widget _getOtherUsersUi() {
    if (otherUsers != null && otherUsers.length > 0) {
      var imageArray = <Widget>[];
      for (int i = 0; i < otherUsers.length; i++) {
        imageArray.add(
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Image.network(
              otherUsers[i].avatarUri,
              fit: BoxFit.cover,
            ),
            width: (MediaQuery.of(context).size.width - 16 * 3) / 3,
            height: (MediaQuery.of(context).size.width - 16 * 3) / 3,
          ),
        );
      }

      return SliverToBoxAdapter(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 12,
              color: AppColor.bgWhite.withOpacity(0.65),
            ),
            SizedBox(
              height: 23,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "TA们刚刚完成训练",
                    style: titleTextStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColor.textHint,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 11,
            ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(left: 16, right: 16),
              color: AppColor.bgWhite,
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: imageArray,
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      );
    } else {
      return SliverToBoxAdapter();
    }
  }

  //课程评论的框架--头部的数据
  Widget _getCourseCommentUi() {
    List<Widget> widgetArray = <Widget>[];
    //评论头部title
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
      width: double.infinity,
      child: Text(
        "课程评论",
        style: titleTextStyle,
      ),
    ));
    //评论数量等等
    widgetArray.add(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16.5, right: 16, top: 8),
        child: Row(
          children: [
            Text(
              "${isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime?.totalCount)}评论",
              style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
            ),
            Expanded(child: SizedBox()),
            InkWell(
              child: Text(
                "按热度",
                style: TextStyle(
                  fontSize: 14,
                  color: isHotOrTime ? AppColor.textPrimary1 : AppColor.textSecondary,
                  fontWeight: isHotOrTime ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              splashColor: AppColor.textHint1,
              onTap: () {
                if (!isHotOrTime) {
                  _refreshController.loadComplete();
                  isHotOrTime = !isHotOrTime;
                  getDataAction(isFold: true);
                }
              },
            ),
            SizedBox(
              width: 7,
            ),
            Container(
              width: 0.5,
              height: 15.5,
              color: AppColor.textHint1,
            ),
            SizedBox(
              width: 7,
            ),
            InkWell(
              child: Text(
                "按时间",
                style: TextStyle(
                  fontSize: 14,
                  color: !isHotOrTime ? AppColor.textPrimary1 : AppColor.textSecondary,
                  fontWeight: !isHotOrTime ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              splashColor: AppColor.textHint1,
              onTap: () {
                if (isHotOrTime) {
                  _refreshController.loadComplete();
                  isHotOrTime = !isHotOrTime;
                  getDataAction(isFold: true);
                }
              },
            ),
          ],
        ),
      ),
    );
    widgetArray.add(SizedBox(
      height: 12,
    ));
    //点击写评论
    widgetArray.add(Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: NetworkImage(Application.profile.avatarUri), fit: BoxFit.cover)),
          ),
          GestureDetector(
            child: Container(
              width: ScreenUtil.instance.screenWidthDp - 32 - 40,
              height: 28,
              margin: EdgeInsets.only(left: 12),
              padding: EdgeInsets.only(left: 16),
              alignment: Alignment(-1, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                color: AppColor.bgWhite.withOpacity(0.65),
              ),
              child: Text("说点什么吧~", style: TextStyle(fontSize: 14, color: AppColor.textHint)),
            ),
            onTap: () {
              targetId = videoModel.id;
              targetType = 3;
              replyId = -1;
              replyCommentId = -1;

              openInputBottomSheet(
                buildContext: this.context,
                voidCallback: _publishComment,
              );
            },
          ),
        ],
      ),
    ));
    //评论主体
    widgetArray.add(_getCommentItemUi());

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          children: widgetArray,
        ),
      ),
    );
  }

  //评论列表的外层的评论
  Widget _getCommentItemUi() {
    var widgetArray = <Widget>[];

    widgetArray.add(SizedBox(
      height: 23,
    ));
    if (loadingStatusComment == LoadingStatus.STATUS_LOADING) {
      widgetArray.add(Container());
    } else {
      if ((isHotOrTime ? (courseCommentHot) : (courseCommentTime)) == null) {
        widgetArray.add(Container(
          child: Column(
            children: [
              Image.asset(
                "images/test/bg.png",
                fit: BoxFit.cover,
                width: 224,
                height: 224,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "偷偷逆袭中，还没有人来冒泡呢",
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              )
            ],
          ),
        ));
      } else {
        for (int i = 0; i < (isHotOrTime ? (courseCommentHot) : (courseCommentTime))?.list?.length; i++) {
          CommentDtoModel value = (isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list[i];
          var subCommentCompleteTitle =
              // ignore: null_aware_before_operator
              (value.replys?.length < value.replyCount + value.pullNumber
                  ? "查看"
                  : (commentListSubSettingList[i].isFold ? "查看" : "隐藏"));
          var subCommentComplete =
              // ignore: null_aware_before_operator
              subCommentCompleteTitle +
                  // ignore: null_aware_before_operator
                  "${value.replys?.length >= value.replyCount + value.pullNumber ? value.replyCount : (value.replyCount + value.pullNumber - value.replys?.length)}条回复";
          if (subCommentCompleteTitle == "隐藏") {
            subCommentComplete = "隐藏回复";
          }
          var subCommentLoading = "正在加载。。。";

          widgetArray.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                _getCommentUi(value, false, value.id),
                SizedBox(
                  height: 13,
                ),
                Offstage(
                  offstage: value.replyCount + value.pullNumber < 1,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        _getSubCommentItemUi(value, i),
                        Offstage(
                          offstage: value.replyCount < 1,
                          child: Container(
                            width: double.infinity,
                            child: GestureDetector(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 57,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 0.5,
                                    color: AppColor.textSecondary,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                    child: Text(
                                      commentLoadingStatusList[i] == LoadingStatus.STATUS_COMPLETED
                                          ? subCommentComplete
                                          : subCommentLoading,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // ignore: null_aware_before_operator
                                if (value.replys?.length >= value.replyCount + value.pullNumber) {
                                  (isHotOrTime ? courseCommentHot.list[i].replys : courseCommentTime.list[i].replys)
                                      .clear();
                                  if (isHotOrTime) {
                                    courseCommentHot.list[i].replyCount += courseCommentHot.list[i].pullNumber;
                                    courseCommentHot.list[i].pullNumber = 0;
                                  } else {
                                    courseCommentTime.list[i].replyCount += courseCommentTime.list[i].pullNumber;
                                    courseCommentTime.list[i].pullNumber = 0;
                                  }
                                  courseCommentPageHot = 1;
                                  courseCommentPageTime = 1;
                                  setState(() {});
                                } else {
                                  commentListSubSettingList[i].isFold = false;
                                  commentLoadingStatusList[i] = LoadingStatus.STATUS_LOADING;
                                  setState(() {});
                                  _getSubComment(value.id, value.replys?.length, value.replyCount, value.pullNumber, i);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        }
      }
    }

    return Container(
      width: double.infinity,
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //sub 子品评论
  Widget _getSubCommentItemUi(CommentDtoModel value, int index) {
    var widgetArray = <Widget>[];
    if (value.replys != null && value.replys.length > 0) {
      for (int i = 0; i < value.replys.length; i++) {
        widgetArray.add(_getCommentUi(value.replys[i], true, value.id));
        widgetArray.add(SizedBox(
          height: 13,
        ));
      }
    }

    Widget widget = Container(
      key: commentListSubSettingList[index].globalKey,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 55),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: widgetArray,
        ),
      ),
    );

    return Offstage(
      offstage: commentListSubSettingList[index].isFold,
      child: widget,
    );
    // if(commentListSubSettingList[index].subCommentAllHeight==null||commentListSubSettingList[index].subCommentAllHeight<0) {
    //   return Offstage(
    //     offstage: commentListSubSettingList[index].isFold,
    //     child: widget,
    //   );
    // }else{
    //   return AnimatedContainer(
    //     height: commentListSubSettingList[index].isFold?0.0:commentListSubSettingList[index].subCommentAllHeight,
    //     duration: Duration(milliseconds: animationTime),
    //     child: widget,
    //   );
    // }
  }

  //获取评论的item--每一个item
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment, int _targetId) {
    var textSpanList = <TextSpan>[];
    textSpanList.add(TextSpan(
      text: value.name + " ",
      style: TextStyle(
        fontSize: 15,
        color: AppColor.textPrimary1,
        fontWeight: FontWeight.bold,
      ),
    ));
    if (isSubComment) {
      if (value.replyId != null && value.replyId > 0) {
        textSpanList.add(TextSpan(
          text: "回复 ",
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textPrimary1,
          ),
        ));

        textSpanList.add(TextSpan(
          text: value.replyName + " ",
          style: TextStyle(
            fontSize: 15,
            color: AppColor.textPrimary1,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }
    if (value.atUsers != null && value.atUsers.length > 0) {
      textSpanList.addAll(getAtUserTextSpan(value));
    } else {
      textSpanList.add(TextSpan(
        text: value.content,
        style: TextStyle(
          fontSize: 14,
          color: AppColor.textPrimary1,
        ),
      ));
    }

    return IntrinsicHeight(
      child: Row(
        verticalDirection: VerticalDirection.up,
        children: [
          //头像
          Container(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    value.avatarUrl,
                    fit: BoxFit.cover,
                    width: 42,
                    height: 42,
                  ),
                )
              ],
            ),
          ),
          //间隔
          SizedBox(
            width: 15,
          ),
          // //中间信息
          Expanded(
              child: SizedBox(
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                color: AppColor.transparent,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: RichText(
                        text: TextSpan(
                          children: textSpanList,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                DateUtil.formatDateNoYearString(DateUtil.getDateTimeByMs(value.createTime)),
                                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Container(
                              child: Text(
                                "回复",
                                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Offstage(
                              // offstage: uId!=value.uid,
                              offstage: true,
                              child: InkWell(
                                child: Container(
                                  child: Text(
                                    "删除",
                                    style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                                  ),
                                ),
                                onTap: () {
                                  ToastShow.show(msg: "点击删除", context: context);
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: Text('删除评论'),
                                          content: Text('是否删除评论'),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              child: Text('不删除'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: Text('删除'),
                                              onPressed: () {
                                                _deleteComment(value.id);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              onTap: () {
                targetId = _targetId;
                targetType = 2;
                replyId = value.uid;
                replyCommentId = value.id;
                openInputBottomSheet(
                  buildContext: this.context,
                  hintText: "回复 " + value.name,
                  voidCallback: _publishComment,
                );
              },
            ),
          )),
          SizedBox(
            width: 16,
          ),
          //点赞
          Container(
            child: GestureDetector(
              child: Column(
                children: [
                  Icon(
                    value.isLaud == 1 ? Icons.favorite : Icons.favorite_border,
                    color: value.isLaud == 1 ? Colors.red : Colors.grey,
                    size: 18,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    IntegerUtil.formatIntegerEn(value.laudCount),
                    style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                  ),
                ],
              ),
              onTap: () {
                _laudComment(value.id, value.isLaud == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> getAtUserTextSpan(CommentDtoModel value) {
    var textSpanList = <TextSpan>[];
    var contentArray = <String>[];
    Map<String, int> userMap = Map();
    String content = value.content;
    int subLen = 0;
    for (int i = 0; i < value.atUsers.length; i++) {
      int index = value.atUsers[i].index - subLen;
      int end = value.atUsers[i].len - subLen;
      if (index < content.length) {
        String firstString = content.substring(0, index);
        String secondString = content.substring(index, end);
        String threeString = content.substring(end, content.length);
        contentArray.add(firstString);
        contentArray.add(secondString);
        userMap[(contentArray.length - 1).toString()] = value.atUsers[i].uid;
        content = threeString;
        subLen = subLen + firstString.length + secondString.length;
      }
    }
    contentArray.add(content);
    // print(contentArray.toString());
    for (int i = 0; i < contentArray.length; i++) {
      textSpanList.add(TextSpan(
        text: contentArray[i],
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            if (userMap[(i).toString()] != null) {
              ToastShow.show(msg: "点击了用户：${userMap[(i).toString()]}", context: context);
            }
          },
        style: TextStyle(
          fontSize: 14,
          color: userMap[(i).toString()] != null ? AppColor.mainBlue : AppColor.textPrimary1,
        ),
      ));
    }
    return textSpanList;
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

  //加载网络数据
  void getDataAction({bool isFold = false}) async {
    // //获取评论
    if (isHotOrTime) {
      if (courseCommentHot == null) {
        Map<String, dynamic> commentModel = await queryListByHot2(
            targetId: videoCourseId, targetType: 3, page: courseCommentPageHot, size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentHot = CommentModel.fromJson(commentModel);
          courseCommentPageHot++;
        }
      }
      setCommentListSubSetting(courseCommentHot, isFold: isFold);
    } else {
      if (courseCommentTime == null) {
        Map<String, dynamic> commentModel = await queryListByTime(
            targetId: videoCourseId, targetType: 3, page: courseCommentPageTime, size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentTime = CommentModel.fromJson(commentModel);
          courseCommentPageTime++;
        }
      }
      setCommentListSubSetting(courseCommentTime, isFold: isFold);
    }

    loadingStatusComment = LoadingStatus.STATUS_COMPLETED;

    //其他人完成训练
    if (otherUsers == null) {
      Map<String, dynamic> map = await getFinishedVideoCourse(videoCourseId, 3);
      if (map != null) {
        otherUsers = <UserModel>[];
        map["list"].forEach((v) {
          otherUsers.add(UserModel.fromJson(v));
        });
      }
    }

    //获取视频详情数据
    if (videoModel == null || videoModel.coursewareDto?.componentDtos == null) {
      //加载数据
      Map<String, dynamic> model = await getVideoCourseDetail(courseId: videoCourseId);
      if (model == null) {
        loadingStatus = LoadingStatus.STATUS_IDEL;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
      } else {
        videoModel = LiveVideoModel.fromJson(model);
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
        setState(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    }
  }

  //设置评论的动画类
  void setCommentListSubSetting(CommentModel commentModel, {bool isFold = false}) {
    commentListSubSettingList.clear();
    commentLoadingStatusList.clear();
    if (commentModel == null) {
      return;
    }
    for (int i = 0; i < commentModel?.list?.length; i++) {
      CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
      commentListSubSetting.commentId = commentModel.list[i].id;
      commentListSubSetting.isFold = isFold;
      commentListSubSettingList.add(commentListSubSetting);
      GlobalKey _globalKey = GlobalKey();
      commentListSubSetting.globalKey = _globalKey;

      //每一个加载评论的加载子评论的状态
      LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      commentLoadingStatusList.add(commentLoadingStatus);
    }
  }

  //发布评论
  _publishComment(String text, List<Rule> rules) async {
    List<AtUsersModel> atListModel = [];
    for (Rule rule in rules) {
      AtUsersModel atModel = new AtUsersModel();
      atModel.index = rule.startIndex;
      atModel.len = rule.endIndex;
      atModel.uid = rule.id;
      atListModel.add(atModel);
    }

    print("targetId:$targetId+++targetType:$targetType++++videoModel.id:${videoModel.id}");

    await postComments(
      targetId: targetId,
      targetType: targetType,
      contentext: text,
      atUsers: jsonEncode(atListModel),
      replyId: replyId > 0 ? replyId : null,
      replyCommentId: replyCommentId > 0 ? replyCommentId : null,
      commentModelCallback: (CommentDtoModel model) {
        if (model != null) {
          if (targetId == videoModel.id) {
            if (courseCommentHot != null) {
              courseCommentHot.list.insert(0, model);
              setCommentListSubSetting(courseCommentHot);
            }
            if (courseCommentTime != null) {
              courseCommentTime.list.insert(0, model);
              setCommentListSubSetting(courseCommentTime);
            }
          } else {
            if (courseCommentHot != null) {
              for (int i = 0; i < courseCommentHot.list.length; i++) {
                if (courseCommentHot.list[i].id == targetId) {
                  courseCommentHot.list[i].replys.insert(0, model);
                  courseCommentHot.list[i].pullNumber++;
                  commentListSubSettingList[i].subCommentAllHeight = null;
                }
              }
            }

            if (courseCommentTime != null) {
              for (int i = 0; i < courseCommentTime.list.length; i++) {
                if (courseCommentTime.list[i].id == targetId) {
                  courseCommentTime.list[i].replys.insert(0, model);
                  courseCommentTime.list[i].pullNumber++;
                  commentListSubSettingList[i].subCommentAllHeight = null;
                }
              }
            }
          }
          ToastShow.show(msg: "发布成功", context: context);
          setState(() {});
        } else {
          ToastShow.show(msg: "发布失败", context: context);
        }
      },
    );
  }

  //删除评论
  _deleteComment(int commentId) async {
    Map<String, dynamic> model = await deleteComment(commentId: commentId);
    print(model);
    if (model != null && model["state"] == true) {
      _deleteCommentData(courseCommentHot, commentId, true);
      _deleteCommentData(courseCommentTime, commentId, false);
      ToastShow.show(msg: "删除成功", context: context);
      setState(() {});
    } else {
      ToastShow.show(msg: "删除失败，只能删除自己的评论", context: context);
    }
  }

  _deleteCommentData(CommentModel commentModel, int commentId, bool isHotOrTime) {
    if (commentModel != null) {
      for (int i = 0; i < commentModel.list.length; i++) {
        if (commentModel.list[i].id == commentId) {
          commentModel.list.removeAt(i);
          break;
        }
        int judge = 0;
        for (int j = 0; j < commentModel.list[i].replys.length; j++) {
          if (commentModel.list[i].replys[j].id == commentId) {
            commentModel.list[i].replys.removeAt(j);
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].replyCount--;
            if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[i].pullNumber > 0) {
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].replyCount +=
                  (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].pullNumber;
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].pullNumber = 0;
            }
            commentListSubSettingList[i].subCommentAllHeight = null;
            judge = 1;
            break;
          }
        }
        if (judge == 1) {
          break;
        }
      }
    }
  }

  //todo 查询子评论会出现一个问题 当之前发布的子评论 个数过多会出现在下次请求中-去重导致感官-点击没有加载数据
  //获取子评论
  _getSubComment(int targetId, int replyLength, int replyCount, int pullNumber, int positionComment) async {
    int subCommentPageSize = 3;
    // int subCommentAllPage=replyCount%subCommentPageSize>0?(replyCount~/subCommentPageSize)+1:(replyCount~/subCommentPageSize);
    int nowSubCommentPage = (replyLength - pullNumber) % subCommentPageSize > 0
        ? ((replyLength - pullNumber) ~/ subCommentPageSize) + 1
        : ((replyLength - pullNumber) ~/ subCommentPageSize);
    int page = nowSubCommentPage + 1;

    try {
      Map<String, dynamic> commentModel = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId, targetType: 2, page: page, size: subCommentPageSize);

      if (commentModel != null) {
        List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
        commentDtoModelList.addAll(CommentModel.fromJson(commentModel).list);

        if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys != null) {
          if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber > 0) {
            for (int i = 0;
                i < (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys.length;
                i++) {
              for (int j = 0; j < commentDtoModelList.length; j++) {
                if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys[i].id ==
                    commentDtoModelList[j].id) {
                  commentDtoModelList.removeAt(j);
                  j--;
                  (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber--;
                  (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount++;
                }
              }
            }
          }
          commentDtoModelList.insertAll(
              0, (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys);
        }

        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys = commentDtoModelList;
        if (commentDtoModelList.length >
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount) {
          (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount =
              commentDtoModelList.length;
        }
      }
    } catch (e) {}

    commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
    setState(() {});
  }

  //加载更多的评论
  void _onLoading() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      Map<String, dynamic> mapModel = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: videoCourseId,
          targetType: 3,
          page: (isHotOrTime ? courseCommentPageHot : courseCommentPageTime),
          size: courseCommentPageSize);
      if (mapModel != null) {
        CommentModel commentModel = CommentModel.fromJson(mapModel);
        if (commentModel == null || commentModel.list == null || commentModel.list.length < 1) {
          _refreshController.loadNoData();
        } else {
          (isHotOrTime ? courseCommentHot : courseCommentTime)?.list?.addAll(commentModel.list);
          setCommentListSubSetting((isHotOrTime ? courseCommentHot : courseCommentTime));
          isHotOrTime ? courseCommentPageHot++ : courseCommentPageTime++;
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }
      setState(() {});
    });
  }

  //点赞-取消点赞
  _laudComment(int commentId, bool laud) async {
    Map<String, dynamic> model = await laudComment(commentId: commentId, laud: laud ? 1 : 0);
    if (model != null && model["state"]) {
      _laudCommentData(courseCommentHot, commentId, true, laud);
      _laudCommentData(courseCommentTime, commentId, false, laud);
      if (laud) {
        ToastShow.show(msg: "点赞成功", context: context);
      } else {
        ToastShow.show(msg: "取消点赞成功", context: context);
      }
      setState(() {});
    } else {
      if (laud) {
        ToastShow.show(msg: "点赞失败", context: context);
      } else {
        ToastShow.show(msg: "取消点赞失败", context: context);
      }
    }
  }

  //点赞
  _laudCommentData(CommentModel commentModel, int commentId, bool isHotOrTime, bool isLaud) {
    if (commentModel != null) {
      for (int i = 0; i < commentModel.list.length; i++) {
        if (commentModel.list[i].id == commentId) {
          isLaud
              ? (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].laudCount++
              : (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].laudCount--;
          (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].isLaud = isLaud ? 1 : 0;
          break;
        }
        int judge = 0;
        for (int j = 0; j < commentModel.list[i].replys.length; j++) {
          if (commentModel.list[i].replys[j].id == commentId) {
            isLaud
                ? (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].replys[j].laudCount++
                : (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].replys[j].laudCount--;
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].replys[j].isLaud = isLaud ? 1 : 0;
            judge = 1;
            break;
          }
        }
        if (judge == 1) {
          break;
        }
      }
    }
  }

  //分享的点击事件
  void _shareBtnClick() {
    print("分享点击事件视频课");
    openShareBottomSheet(
        context: context,sharedType: 1, map: videoModel.toJson(), chatTypeModel: ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE);
  }

  //分享的收藏按钮
  void _favorBtnClick() async {
    print("点击了${isFavor ? "取消收藏" : "收藏"}按钮");
    Map<String, dynamic> map = await (!isFavor ? addToMyCourse : deleteFromMyCourse)(videoModel.id);
    if (map != null && map["state"] != null && map["state"]) {
      isFavor = !isFavor;
      setState(() {

      });
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
      setState(() {});
    };
  }

  //没有登陆点击事件
  void onNoLoginClickListener() {
    toastShow("没有登陆，请先登陆app");
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

  ///这是关注的方法
  _getAttention(int userId) async {
    int attntionResult = await ProfileAddFollow(userId);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      videoModel.coachDto?.relation = 1;
      setState(() {});
    }
  }

  //获取底部按钮
  Widget _getBottomBar() {
    bool isLoggedIn;
    context.select((TokenNotifier notifier) => notifier.isLoggedIn ? isLoggedIn = true : isLoggedIn = false);

    //todo 判断是否链接了终端
    bool bindingTerminal = false;
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
}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  double subCommentAllHeight;
  GlobalKey globalKey;
}
