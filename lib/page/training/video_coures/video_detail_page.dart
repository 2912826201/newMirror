import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/training/live_broadcast/live_broadcast_page.dart';
import 'package:mirror/page/training/live_broadcast/sliver_custom_header_delegate.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/live_broadcast/live_api.dart';

import 'video_course_list_page.dart';

/// 直播详情页
class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage(
      {Key key, this.heroTag, this.liveCourseId, this.courseId})
      : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final int courseId;

  @override
  createState() {
    return VideoDetailPageState(
        heroTag: heroTag, liveCourseId: liveCourseId, courseId: courseId);
  }
}

class VideoDetailPageState extends State<VideoDetailPage> {
  VideoDetailPageState(
      {Key key, this.heroTag, this.liveCourseId, this.courseId});

  //头部hero的标签
  String heroTag;

  //直播课程的id
  int liveCourseId;

  //直播课程的大课程的id
  int courseId;

  //当前直播的model
  LiveModel liveModel;

  //加载状态
  LoadingStatus loadingStatus;

  //title文字的样式
  var titleTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  //用户的评论热度
  CommentModel courseCommentHot;

  //评论
  CommentModel courseCommentTime;

  //判断是热度还是评论
  bool isHotOrTime = true;

  //用户评论的的一些动画参数
  var commentListSubSettingList = <CommentListSubSetting>[];

  //每一个评论的高度
  var commentItemHeight = 65;

  //折叠动画的时间
  var animationTime = 300; //毫秒

  @override
  void initState() {
    super.initState();

    //todo 先这样实现---以后再改为路由
    liveModel = VideoCourseListPage.videoModel;
    VideoCourseListPage.videoModel = null;
    courseCommentHot = null;
    courseCommentTime = null;
    if (liveModel == null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
      getDataAction();
      return;
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      getDataAction();
    }
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
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(
        height: 40,
      ));
      widgetArray.add(_getNoCompleteTitle());
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        widgetArray.add(Expanded(
            child: SizedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )));
      } else {
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
    print(heroTag);
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: NoBlueEffectBehavior(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverCustomHeaderDelegate(
                  title: liveModel.name,
                  collapsedHeight: 40,
                  expandedHeight: 300,
                  paddingTop: MediaQuery.of(context).padding.top,
                  valueArray: [
                    liveModel.totalTrainingTime.toString(),
                    liveModel.totalCalories.toString(),
                    liveModel.coursewareDto?.levelDto?.name
                  ],
                  titleArray: ["分钟", "千卡", "难度"],
                  coverImgUrl: 'images/test/bg.png',
                  heroTag: heroTag,
                ),
              ),
              _getCoachItem(),
              _getLineView(),
              _getActionUi(),
              _getLineView(),
              _getCourseCommentUi(),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: Container(
            color: Colors.lightBlueAccent,
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: _getBottomBar(),
          ),
          bottom: 0,
        ),
      ],
    );
  }

  //获取教练的名字
  Widget _getCoachItem() {
    return SliverToBoxAdapter(
      child: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        color: Colors.white,
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0.5, color: Colors.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  liveModel.coachDto?.avatarUri,
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
                    liveModel.coachDto?.nickName + "教练",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            Container(
              padding:
                  const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text("关注"),
            )
          ],
        ),
      ),
    );
  }

  //获取横线
  Widget _getLineView() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 10,
        color: Colors.grey,
      ),
    );
  }

  //获取动作的ui
  Widget _getActionUi() {
    var widgetArray = <Widget>[];
    var titleStyle = TextStyle(fontSize: 20);
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      width: double.infinity,
      child: Text(
        "动作  1个",
        style: titleTextStyle,
      ),
    ));

    // widgetArray.add(Container(
    //   width: double.infinity,
    //   height: 0.3,
    //   margin: const EdgeInsets.only(left: 20, right: 20),
    //   color: Colors.grey,
    // ));
    widgetArray.add(
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 30, right: 20),
        padding: const EdgeInsets.only(top: 13, bottom: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              liveModel.coursewareDto?.partDto.name,
              style: titleStyle,
            ),
            Text(
              liveModel.coursewareDto?.partDto?.updateTime?.toString(),
              style: titleStyle,
            ),
          ],
        ),
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

  //课程评论的框架--头部的数据
  Widget _getCourseCommentUi() {
    List<Widget> widgetArray = <Widget>[];
    //评论头部title
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
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
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime?.totalCount)}评论",
              style: TextStyle(fontSize: 20),
            ),
            GestureDetector(
              child: Text(
                "按热度/按时间",
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                isHotOrTime = !isHotOrTime;
                getDataAction();
              },
            ),
          ],
        ),
      ),
    );
    widgetArray.add(SizedBox(
      height: 16,
    ));
    //点击写评论
    widgetArray.add(Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 20),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage("images/test/yxlm1.jpeg"),
                    fit: BoxFit.cover)),
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
                color: AppColor.bgWhite_65,
              ),
              child: Text("说点什么吧~",
                  style: TextStyle(fontSize: 14, color: AppColor.textHint)),
            ),
            onTap: () {
              ToastShow.show("点击了添加评论", context);
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
      height: 10,
    ));

    if ((isHotOrTime ? (courseCommentHot) : (courseCommentTime)) == null) {
      widgetArray.add(Container(
        child: Text("暂无评论"),
      ));
    } else {
      for (int i = 0;
          i <
              (isHotOrTime ? (courseCommentHot) : (courseCommentTime))
                  ?.list
                  ?.length;
          i++) {
        CommentDtoModel value =
            (isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list[i];

        widgetArray.add(Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              _getCommentUi(value, false),
              Offstage(
                offstage: value.replyCount < 1,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Container(
                          child: Text(
                            "—— " +
                                (commentListSubSettingList[i].isFold
                                    ? "查看"
                                    : "隐藏") +
                                "${value.replys?.length}条回复",
                            style: TextStyle(color: Colors.grey),
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 55),
                        ),
                        onTap: () {
                          commentListSubSettingList[i].isFold =
                              !commentListSubSettingList[i].isFold;
                          setState(() {});
                        },
                      ),
                      _getSubCommentItemUi(value, i),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
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
        widgetArray.add(_getCommentUi(value.replys[i], true));
      }
    }
    return AnimatedContainer(
      height: double.parse((commentListSubSettingList[index].isFold
              ? 0.0
              : commentListSubSettingList[index].subCommentAllHeight)
          .toString()),
      duration: Duration(milliseconds: animationTime),
      child: Container(
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
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      height: commentItemHeight.toDouble(),
      width: double.infinity,
      child: Row(
        children: [
          //头像
          Container(
            width: 45,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(width: 0.5, color: Colors.black),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                value.avatarUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          //间隔
          SizedBox(
            width: 10,
          ),
          //中间信息
          Expanded(
              child: SizedBox(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    value.name + "   " + value.content,
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    value.createTime.toString() +
                        "  " +
                        (value.laudCount.toString()) +
                        "次赞   回复",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          )),
          //点赞
          Container(
            height: double.infinity,
            child: Center(
              child: GestureDetector(
                child: Icon(
                  Icons.favorite_border,
                  color: value.isLaud == 1 ? Colors.red : Colors.grey,
                ),
                onTap: () {
                  if (value.isLaud == 1) {
                    return;
                  }
                  value.isLaud = 1;
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //获取底部按钮
  Widget _getBottomBar() {
    var textStyle = TextStyle(fontSize: 20, color: Colors.white);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text(
          "预览视频",
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  //加载网络数据
  void getDataAction() async {
    print("getDataAction");
    if (isHotOrTime) {
      print("courseCommentHot");
      //todo 加载评论-*--没有分页加载只有第一页的
      if (courseCommentHot == null) {
        Map<String, dynamic> commentModel = await queryListByHot(
            targetId: courseId, targetType: 1, page: 1, size: 10);
        if (commentModel != null) {
          courseCommentHot = CommentModel.fromJson(commentModel);
        }
      }
      print("courseCommentHot--${courseCommentHot?.totalCount}");
      setCommentListSubSetting(courseCommentHot);
    } else {
      print("courseCommentTime");
      if (courseCommentTime == null) {
        Map<String, dynamic> commentModel = await queryListByTime(
            targetId: courseId, targetType: 1, page: 1, size: 10);
        if (commentModel != null) {
          courseCommentTime = CommentModel.fromJson(commentModel);
        }
      }
      print("courseCommentTime--${courseCommentTime?.totalCount}");
      setCommentListSubSetting(courseCommentTime);
    }
    if (liveModel == null) {
      //加载数据
      Map<String, dynamic> model =
          await liveCourseDetail(courseId: liveCourseId);
      if (model == null) {
        loadingStatus = LoadingStatus.STATUS_IDEL;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
      } else {
        liveModel = LiveModel.fromJson(model);
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
        setState(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    }
  }

  //设置评论的动画类
  void setCommentListSubSetting(CommentModel commentModel) {
    commentListSubSettingList.clear();
    if (commentModel == null) {
      return;
    }
    for (int i = 0; i < commentModel?.list?.length; i++) {
      CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
      commentListSubSetting.commentId = commentModel.list[i].id;
      commentListSubSetting.isFold = true;
      commentListSubSetting.subCommentAllHeight =
          // ignore: null_aware_before_operator
          commentModel.list[i]?.replys?.length * commentItemHeight;
      commentListSubSettingList.add(commentListSubSetting);
    }
  }
}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  int subCommentAllHeight;
}
