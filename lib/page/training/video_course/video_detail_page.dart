import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/download_video_course_db_helper.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/training/currency/currency_page.dart';
import 'package:mirror/page/training/video_course/sliver_custom_header_delegate_video.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
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
  const VideoDetailPage(
      {Key key, this.heroTag, this.commentDtoModel, this.fatherComment, this.liveCourseId, this.videoModel})
      : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final LiveVideoModel videoModel;
  final CommentDtoModel commentDtoModel;
  final CommentDtoModel fatherComment;

  @override
  createState() {
    return VideoDetailPageState(
        heroTag: heroTag,
        commentDtoModel: commentDtoModel,
        videoCourseId: liveCourseId,
        videoModel: videoModel,
        fatherComment: fatherComment);
  }
}

class VideoDetailPageState extends State<VideoDetailPage> {
  VideoDetailPageState(
      {Key key, this.commentDtoModel, this.fatherComment, this.heroTag, this.videoCourseId, this.videoModel});

  //互动通知列表带过来的评论内容
  CommentDtoModel commentDtoModel;

  //父评论内容
  CommentDtoModel fatherComment;

  //头部hero的标签
  String heroTag;

  //视频课程的id
  int videoCourseId;

  //当前视频课程的model
  LiveVideoModel videoModel;

  //其他用户的完成训练
  DataResponseModel dataResponseModel;
  List<HomeFeedModel> recommendTopicList = [];

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
  int courseCommentPageSize = 6;

  //热门当前是第几页
  int courseCommentPageHot = 1;

  //时间排序当前是第几页
  int courseCommentPageTime = 1;

  Map<String, int> subCommentLastIdHot = Map();
  Map<String, int> subCommentLastIdTime = Map();

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

  //粘合剂控件滚动控制
  ScrollController scrollController = ScrollController();

  //选中评论是否在第一页
  bool choseItemInFrist = false;

  //选中的index
  int choseIndex = 0;

  //选中item之上的高度
  double itemTotalHeight = 0;

  //防止滚动多次
  bool isFristScroll = true;

  @override
  void initState() {
    super.initState();
    courseCommentHot = null;
    courseCommentTime = null;
    itemTotalHeight = 68 + 300 + 62 + 34 + 211 + (ScreenUtil.instance.screenWidthDp - 16 * 3) / 3 + 124;
    if (commentDtoModel != null) {
      Future.delayed(Duration(milliseconds: 4500), () {
        try {
          if (courseCommentHot.list[choseIndex].id == commentDtoModel.id) {
            print('==================父评论倒计时结束');
            courseCommentHot.list[choseIndex].itemChose = false;
            setState(() {});
          } else if (courseCommentHot.list[choseIndex].id == commentDtoModel.targetId) {
            print('==================子评论倒计时结束');
            courseCommentHot.list[choseIndex].replys[0].itemChose = false;
            setState(() {});
          }
        } catch (e) {}
      });
    }
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
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      if (commentDtoModel != null) {
        if (isFristScroll) {
          List<CommentDtoModel> model = courseCommentHot.list;
          for (int i = 0; i < model.length; i++) {
            if (i < choseIndex) {
              itemTotalHeight +=
                  calculateTextWidth(model[i].content, AppStyle.textMedium18, ScreenUtil.instance.screenWidthDp - 76, 3)
                          .height
                          .toDouble() +
                      30;
            } else {
              Future.delayed(Duration(milliseconds: 500), () {
                try {
                  scrollController.animateTo(itemTotalHeight,
                      duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
                } catch (e) {}
              });
            }
          }
          isFristScroll = false;
        }
      }
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
              height: MediaQuery.of(context).size.height - 50,
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
              height: 50,
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
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: footerWidget(),
      controller: _refreshController,
      onLoading: _onLoading,
      child: CustomScrollView(
        controller: scrollController,
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
              coverImgUrl: getCourseShowImage(videoModel),
              heroTag: heroTag,
              startTime: videoModel.startTime,
              endTime: videoModel.endTime,
              shareBtnClick: _shareBtnClick,
              favorBtnClick: _favorBtnClick,
              isFavor: isFavor,
            ),
          ),
          getTitleWidget(videoModel, context),
          getCoachItem(videoModel, context, onClickAttention, onClickCoach),
          getLineView(),
          getTrainingEquipmentUi(videoModel, context, titleTextStyle),
          getActionUi(videoModel, context, titleTextStyle),
          getOtherUsersUi(recommendTopicList, context, titleTextStyle, onClickOtherComplete),
          getLineView(),
          _getCourseCommentUi(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          )
        ],
      ),
    );
  }

  //课程评论的框架--头部的数据
  Widget _getCourseCommentUi() {
    int count = isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime?.totalCount);
    if (count == null) {
      count = 0;
    }
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            getCourseTopText(titleTextStyle),
            getCourseTopNumber(isHotOrTime, count, onHotCommentTitleClickBtn, onTimeCommentTitleClickBtn),
            SizedBox(height: 12),
            getCourseTopEdit(onEditBoxClickBtn),
            _getCommentItemUi(),
          ],
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
        widgetArray.add(getCommentNoData());
      } else {
        widgetArray.addAll(getBigCommentList());
      }
    }
    return Container(
      width: double.infinity,
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //外部的item--for
  List<Widget> getBigCommentList() {
    var widgetArray = <Widget>[];
    for (int i = 0; i < (isHotOrTime ? (courseCommentHot) : (courseCommentTime))?.list?.length; i++) {
      widgetArray.add(bigBoxItem((isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list[i], i));
    }
    return widgetArray;
  }

  //外部的item
  Widget bigBoxItem(CommentDtoModel value, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          _getCommentUi(value, false, value.id),
          SizedBox(
            height: 13,
          ),
          getSubItemAll(value, index),
        ],
      ),
    );
  }

  //每一个item的子item
  Widget getSubItemAll(CommentDtoModel value, int index) {
    return Offstage(
      offstage: value.replyCount + value.pullNumber < 1,
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            _getSubCommentItemUi(value, index),
            getCommentBottomAlertText(value, index),
            SizedBox(
              height: 13,
            ),
          ],
        ),
      ),
    );
  }

  //每一个评论的item底部提示文字
  Widget getCommentBottomAlertText(CommentDtoModel value, int index) {
    var subComplete = getSubCommentComplete(value, commentListSubSettingList[index].isFold);
    var subLoading = "正在加载。。。";
    String alertText = commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED ? subComplete : subLoading;
    return Offstage(
      offstage: value.replyCount < 1,
      child: Container(
        width: double.infinity,
        child: GestureDetector(
          child: Row(
            children: [
              SizedBox(
                width: 57,
              ),
              Container(width: 40, height: 0.5, color: AppColor.textSecondary),
              SizedBox(
                width: 4,
              ),
              Container(child: Text(alertText, style: TextStyle(color: Colors.grey))),
            ],
          ),
          onTap: () => onClickAddSubComment(value, index),
        ),
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
    return Offstage(
      offstage: commentListSubSettingList[index].isFold,
      child: Container(
        key: commentListSubSettingList[index].globalKey,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 55),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: widgetArray,
          ),
        ),
      ),
    );
  }

  //获取评论的item--每一个item
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment, int _targetId) {
    return IntrinsicHeight(
      child: AnimatedPhysicalModel(
          shape: BoxShape.rectangle,
          color: value.itemChose ? AppColor.bgWhite : AppColor.white,
          elevation: 0,
          shadowColor: !value.itemChose ? AppColor.bgWhite : AppColor.white,
          duration: Duration(seconds: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getUserImage(value.avatarUrl, 42, 42),
              SizedBox(width: 15),
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
                              children: getSubCommentText(value, isSubComment, _targetId),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
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
                                SizedBox(width: 12),
                                Container(
                                  child: Text(
                                    "回复",
                                    style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  onTap: () => onPostComment(_targetId, 2, value.uid, value.id, hintText: "回复 " + value.name),
                ),
              )),
              SizedBox(width: 16),
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
          )),
    );
  }

  //获取子评论的文字
  List<TextSpan> getSubCommentText(CommentDtoModel value, bool isSubComment, int _targetId) {
    var textSpanList = <TextSpan>[];
    print("value：${value}");
    textSpanList.add(TextSpan(
      text: value.name ?? " ",
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
          text: value.replyName ?? " ",
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
    return textSpanList;
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

  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
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
        context: context,
        sharedType: 1,
        map: videoModel.toJson(),
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE);
  }

  //分享的收藏按钮
  void _favorBtnClick() async {
    print("点击了${isFavor ? "取消收藏" : "收藏"}按钮");
    Map<String, dynamic> map = await (!isFavor ? addToMyCourse : deleteFromMyCourse)(videoModel.id);
    if (map != null && map["state"] != null && map["state"]) {
      isFavor = !isFavor;
      setState(() {});
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

  //加载网络数据
  void getDataAction({bool isFold = false}) async {
    // //获取评论
    if (isHotOrTime) {
      if (courseCommentHot == null) {
        Map<String, dynamic> commentModel = await queryListByHot2(
            targetId: videoCourseId,
            targetType: 3,
            lastId: courseCommentHot?.lastId ?? null,
            size: courseCommentPageSize);
        courseCommentHot = CommentModel.fromJson(commentModel);
        if (commentModel != null) {
          if (commentDtoModel != null&&isFristScroll) {
            for (int i = 0; i < courseCommentHot.list.length; i++) {
              if (courseCommentHot.list[i].id == commentDtoModel.id) {
                print('=====================在第一页的父评论');
                choseItemInFrist = true;
                choseIndex = i;
                courseCommentHot.list[i].itemChose = true;
              } else if (courseCommentHot.list[i].id == commentDtoModel.targetId) {
                print('=====================在第一页的子评论');
                choseItemInFrist = true;
                choseIndex = i;
                commentDtoModel.itemChose = true;
                courseCommentHot.list[i].replys.insert(0, commentDtoModel);
                courseCommentHot.list[i].pullNumber = 1;
              }
            }
            if (!choseItemInFrist) {
              if (fatherComment != null) {
                print('=================不在第一页的子评论');
                courseCommentHot.list.insert(0, fatherComment);
                commentDtoModel.itemChose = true;
                courseCommentHot.list[0].replys.insert(0, commentDtoModel);
                courseCommentHot.list[0].pullNumber = 1;
              } else {
                print('=================不在第一页的父评论');
                commentDtoModel.itemChose = true;
                courseCommentHot.list.insert(0, commentDtoModel);
              }
            }
          }
          setState(() {});
          courseCommentPageHot++;
        }
      }
      setCommentListSubSetting(courseCommentHot, isFold: isFold);
      if(commentDtoModel != null&&isFristScroll){
      onClickAddSubComment(courseCommentHot.list[choseIndex], choseIndex);
      }
    } else {
      if (courseCommentTime == null) {
        Map<String, dynamic> commentModel = await queryListByTime(
            targetId: videoCourseId,
            targetType: 3,
            lastId: courseCommentTime?.lastId ?? null,
            size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentTime = CommentModel.fromJson(commentModel);
          courseCommentPageTime++;
        }
      }
      setCommentListSubSetting(courseCommentTime, isFold: isFold);
    }

    loadingStatusComment = LoadingStatus.STATUS_COMPLETED;

    //其他人完成训练
    if (recommendTopicList == null || recommendTopicList.length < 1) {
      dataResponseModel = await getPullList(
        type: 7,
        size: 3,
        targetId: widget.liveCourseId,
      );
      if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
        dataResponseModel.list.forEach((v) {
          recommendTopicList.add(HomeFeedModel.fromJson(v));
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

  //获取子评论
  _getSubComment(int targetId, int replyLength, int replyCount, int pullNumber, int positionComment) async {
    int subCommentPageSize = 3;
    if (replyLength == 0) {
      (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"] = null;
    }
    int lastId = (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"];
    print("刚开始加载子评论");
    if (replyLength > 0 &&
        lastId == null &&
        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber <= 0) {
      print("有数量，但是null为空，表示没有数据了");
      commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
      return;
    }
    try {
      print(
          "加载子评论---isHotOrTime:$isHotOrTime,targetId:$targetId, lastId:$lastId, subCommentPageSize:$subCommentPageSize");
      Map<String, dynamic> model = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId, targetType: 2, lastId: lastId, size: subCommentPageSize);

      print("获取到了数据model:${model.toString()}");
      if (model != null) {
        print("获取到了数据不为空");

        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber=0;
        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount=model["totalCount"];

        CommentModel commentModel = CommentModel.fromJson(model);
        if (!(commentModel == null || commentModel.list == null || commentModel.list.length < 1)) {
          print("获取到了commentModel不为空");
          List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
          commentDtoModelList.addAll(commentModel.list);

          print("获取到了length:${commentDtoModelList.length}条数据， commentModel.lastId：${commentModel.lastId}");
          (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"] = commentModel.lastId;
          int subCount = 0;
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
                    subCount++;
                  }
                }
              }
            }

            if (subCount > 0) {
              print("填补删除的条数");
              commentDtoModelList.addAll(await getSubCommentOne(subCount, positionComment));
            } else {
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber -=
                  subCommentPageSize;
              if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber < 0) {
                (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber = 0;
              }
            }
            print("加上以前的数据");
            commentDtoModelList.insertAll(
                0, (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys);
            print("commentDtoModelList。length:${commentDtoModelList.length}");
          }

          (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys = commentDtoModelList;

          if (commentDtoModelList.length >
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount) {
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount =
                commentDtoModelList.length;
          }
        }
      }
    } catch (e) {
      print("报错了");
    }

    commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
    setState(() {
      print("加载子评论结束了");
    });
  }

  //获取了一条数据子评论
  Future<List<CommentDtoModel>> getSubCommentOne(int count, int positionComment) async {
    int lastId = (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"];
    List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
    try {
      Map<String, dynamic> model = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId, targetType: 2, lastId: lastId, size: count);
      if (model != null) {

        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber=0;
        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount=model["totalCount"];
        CommentModel commentModel = CommentModel.fromJson(model);
        if (!(commentModel == null || commentModel.list == null || commentModel.list.length < 1)) {
          commentDtoModelList.addAll(commentModel.list);
          int subCount = 0;
          (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"] = commentModel.lastId;
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
                    subCount++;
                  }
                }
              }
            }
          }
          if (subCount > 0) {
            commentDtoModelList.addAll(await getSubCommentOne(subCount, positionComment));
          }
        }
      }
    } catch (e) {}
    return commentDtoModelList;
  }

  //加载更多的评论
  void _onLoading() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      if (isHotOrTime && courseCommentPageHot > 0 && courseCommentHot.lastId == null) {
        _refreshController.loadNoData();
        return;
      }
      if (!isHotOrTime && courseCommentPageTime > 0 && courseCommentTime.lastId == null) {
        _refreshController.loadNoData();
        return;
      }
      Map<String, dynamic> mapModel = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: videoCourseId,
          targetType: 3,
          lastId: (isHotOrTime ? courseCommentHot.lastId : courseCommentTime.lastId),
          size: courseCommentPageSize);
      if (mapModel != null) {
        CommentModel commentModel = CommentModel.fromJson(mapModel);
        if (commentModel == null || commentModel.list == null || commentModel.list.length < 1) {
          _refreshController.loadNoData();
        } else {
          if(fatherComment!=null){
            for(int i=0;i<commentModel.list.length;i++) {
              if(commentModel.list[i].id==fatherComment.id){
                commentModel.list.removeAt(i);
                break;
              }
            }
          }
          (isHotOrTime ? courseCommentHot : courseCommentTime)?.list?.addAll(commentModel.list);
          (isHotOrTime ? courseCommentHot : courseCommentTime)?.lastId = commentModel.lastId;
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

  ///这是关注的方法
  onClickAttention() {
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
      setState(() {});
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

  //热门评论点击
  onHotCommentTitleClickBtn() {
    if (!isHotOrTime) {
      _refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }

  //时间评论点击
  onTimeCommentTitleClickBtn() {
    if (isHotOrTime) {
      _refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }

  //输入框评论点击事件
  onEditBoxClickBtn() {
    targetId = videoModel.id;
    targetType = 3;
    replyId = -1;
    replyCommentId = -1;

    openInputBottomSheet(
      buildContext: this.context,
      voidCallback: _publishComment,
      isShowAt: false,
    );
  }

  //输入框评论点击事件
  onPostComment(int targetId, int targetType, int replyId, int replyCommentId, {String hintText}) {
    this.targetId = targetId;
    this.targetType = targetType;
    this.replyId = replyId;
    this.replyCommentId = replyCommentId;
    openInputBottomSheet(
      buildContext: this.context,
      hintText: hintText,
      voidCallback: _publishComment,
      isShowAt: false,
    );
  }

  //判断加载子评论
  onClickAddSubComment(CommentDtoModel value, int index) {
    if (commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED) {
      // ignore: null_aware_before_operator
      if (value.replys?.length >= value.replyCount + value.pullNumber) {
        (isHotOrTime ? courseCommentHot.list[index].replys : courseCommentTime.list[index].replys).clear();
        if (isHotOrTime) {
          courseCommentHot.list[index].replyCount += courseCommentHot.list[index].pullNumber;
          courseCommentHot.list[index].pullNumber = 0;
        } else {
          courseCommentTime.list[index].replyCount += courseCommentTime.list[index].pullNumber;
          courseCommentTime.list[index].pullNumber = 0;
        }
        courseCommentPageHot = 1;
        courseCommentPageTime = 1;
        setState(() {});
      } else {
        commentListSubSettingList[index].isFold = false;
        commentLoadingStatusList[index] = LoadingStatus.STATUS_LOADING;
        setState(() {});
        _getSubComment(value.id, value.replys?.length, value.replyCount, value.pullNumber, index);
      }
    }
  }
}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  double subCommentAllHeight;
  GlobalKey globalKey;
}
