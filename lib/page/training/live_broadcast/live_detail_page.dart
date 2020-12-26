import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/live_broadcast/live_api.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/comment_input_bottom_bar.dart';
import 'sliver_custom_header_delegate.dart';
import 'package:provider/provider.dart';

/// 直播详情页
class LiveDetailPage extends StatefulWidget {
  const LiveDetailPage(
      {Key key, this.heroTag, this.liveCourseId, this.courseId, this.liveModel})
      : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final int courseId;
  final LiveModel liveModel;

  @override
  createState() {
    return LiveDetailPageState(
        heroTag: heroTag,
        liveCourseId: liveCourseId,
        courseId: courseId,
        liveModel: liveModel);
  }
}

class LiveDetailPageState extends State<LiveDetailPage> {
  LiveDetailPageState(
      {Key key,
      this.heroTag,
      this.liveCourseId,
      this.courseId,
      this.liveModel});

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

  //评论加载状态
  LoadingStatus loadingStatusComment;

  //加载状态--子评论
  var commentLoadingStatusList = <LoadingStatus>[];

  //title文字的样式
  var titleTextStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textPrimary1);

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
  bool isBouncingScrollPhysics=false;
  //每次请求的评论个数
  int courseCommentPageSize=3;
  //热门当前是第几页
  int courseCommentPageHot=1;
  //时间排序当前是第几页
  int courseCommentPageTime=1;
  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    courseCommentHot = null;
    courseCommentTime = null;
    loadingStatusComment = LoadingStatus.STATUS_LOADING;
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

  //
  // //加载数据成功时的布局
  // Widget _buildSuggestionsComplete1() {
  //   return GestureDetector(
  //     child: Container(
  //       width: MediaQuery.of(context).size.width,
  //       height: MediaQuery.of(context).size.height,
  //       child: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //
  //             Container(
  //               width: double.infinity,
  //               height: MediaQuery.of(context).size.height-50,
  //               color: Colors.redAccent,
  //             ),
  //
  //             Container(
  //               width: double.infinity,
  //               height: 50,
  //               color: AppColor.white,
  //               child:_getBottomBar(),
  //             ),
  //
  //           ],
  //         ),
  //       ),
  //     ),
  //     onTap: (){
  //       openInputBottomSheet(
  //         context: this.context,
  //         hintText: "回复 ",
  //         voidCallback: (String text,
  //             BuildContext context) {
  //         },
  //       );
  //     },
  //   );
  // }

  //加载数据成功时的布局
  Widget _buildSuggestionsComplete() {
    String imageUrl;
    if (liveModel.playBackUrl != null) {
      imageUrl = liveModel.playBackUrl;
    } else if (liveModel.videoUrl != null) {
      imageUrl = FileUtil.getVideoFirstPhoto(liveModel.videoUrl);
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
                    if(isBouncingScrollPhysics) {
                      isBouncingScrollPhysics = false;
                      setState(() {

                      });
                    }
                  } else {
                    if(!isBouncingScrollPhysics) {
                      isBouncingScrollPhysics = true;
                      setState(() {

                      });
                    }
                  }
                  return false;
                },
                child:SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("");
                      } else if (mode == LoadStatus.loading) {
                        body = CircularProgressIndicator();
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
                    physics: isBouncingScrollPhysics?BouncingScrollPhysics():ClampingScrollPhysics(),
                    slivers: <Widget>[
                      // header,
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverCustomHeaderDelegate(
                          title: liveModel.name,
                          collapsedHeight: 40,
                          expandedHeight: 300,
                          paddingTop: MediaQuery.of(context).padding.top,
                          coverImgUrl: imageUrl,
                          heroTag: heroTag,
                          startTime: liveModel.startTime,
                          endTime: liveModel.endTime,
                          shareBtnClick: _shareBtnClick,
                        ),
                      ),
                      _getTitleWidget(),
                      _getCoachItem(),
                      _getLineView(),
                      _getActionUi(),
                      _getLineView(),
                      _getCourseCommentUi(),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 50,),
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


  //获取训练数据ui
  Widget _getTitleWidget() {
    var widgetArray = <Widget>[];
    var titleArray=[liveModel.totalTrainingTime.toString(),liveModel.totalCalories.toString(),liveModel.coursewareDto?.levelDto?.ename];
    var subTitleArray=["分钟","千卡",liveModel.coursewareDto?.levelDto?.name];
    var tagArray=["时间","消耗","难度"];

    for(int i=0;i<titleArray.length;i++){
      widgetArray.add(
          Container(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Text(titleArray[i],
                        style: TextStyle(fontSize: 23,color: AppColor.black,fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 2,),
                      Container(
                        child: Text(subTitleArray[i], style:  TextStyle(fontSize: 12,color: AppColor.textPrimary3),),
                        margin: const EdgeInsets.only(top: 4),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 6,),
                Text(tagArray[i], style:  TextStyle(fontSize: 12,color: AppColor.textHint),),
              ],
            ),
            width: (MediaQuery.of(context).size.width-1)/3,
          )
      );
      if(i<titleArray.length-1){
        widgetArray.add(
            Container(
              width: 0.5,
              height: 18,
              color: AppColor.textHint,
            )
        );
      }
    }
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        color: AppColor.white,
        padding: const EdgeInsets.only(top: 14,bottom: 14),
        child: Row(
          children: widgetArray,
        ),
      ),
    );
  }

  //获取教练的名字
  Widget _getCoachItem() {
    return SliverToBoxAdapter(
      child: Container(
        padding:
        const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
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
                child: Image.asset(
                  "images/test/yxlm1.jpeg",
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
                    liveModel.coachDto?.nickName,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.textPrimary2,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            InkWell(
              child: Container(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "关注",
                  style: TextStyle(color: AppColor.white, fontSize: 11),
                ),
              ),
              onTap: () {
                ToastShow.show(msg: "点击了关注教练", context: context);
              },
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
        height: 12,
        color: AppColor.bgWhite.withOpacity(0.65),
      ),
    );
  }

  //获取动作的ui
  Widget _getActionUi() {
    // ignore: null_aware_before_operator
    if (liveModel.coursewareDto?.movementDtos == null ||
        // ignore: null_aware_before_operator
        liveModel.coursewareDto?.movementDtos?.length < 1) {
      return SliverToBoxAdapter();
    }
    var widgetArray = <Widget>[];
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 11.5),
      width: double.infinity,
      child: Text(
        "动作${liveModel.coursewareDto?.movementDtos?.length}个",
        style: titleTextStyle,
      ),
    ));

    for (int i = 0; i < liveModel.coursewareDto?.movementDtos?.length; i++) {
      widgetArray.add(Container(
        width: double.infinity,
        height: 0.5,
        margin: const EdgeInsets.only(left: 16, right: 16),
        color: AppColor.bgWhite,
      ));

      widgetArray.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 16, right: 16),
          padding: const EdgeInsets.only(top: 13.5, bottom: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                liveModel.coursewareDto?.movementDtos[i].name,
                style: TextStyle(fontSize: 16, color: AppColor.textPrimary2),
              ),
              Text(
                liveModel.coursewareDto?.movementDtos[i].amount.toString() +
                    liveModel.coursewareDto?.movementDtos[i].unit.toString(),
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

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
    widgetArray.add(Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16.5, right: 16, top: 8),
      child: Row(
        children: [
          Text(
            "${isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime
                ?.totalCount)}评论",
            style: TextStyle(fontSize: 16,color: AppColor.textPrimary1),
          ),
          Expanded(child: SizedBox()),
          InkWell(
            child: Text(
              "按热度",
              style: TextStyle(
                fontSize: 14,
                color: isHotOrTime?AppColor.textPrimary1:AppColor.textSecondary,
                fontWeight: isHotOrTime?FontWeight.bold:FontWeight.normal,
              ),
            ),
            splashColor: AppColor.textHint1,
            onTap: () {
              if(!isHotOrTime) {
                _refreshController.loadComplete();
                  isHotOrTime = !isHotOrTime;
                  getDataAction(isFold: true);
                }
            },
          ),
          SizedBox(width: 7,),
          Container(
            width: 0.5,
            height: 15.5,
            color: AppColor.textHint1,
          ),
          SizedBox(width: 7,),
          InkWell(
            child: Text(
              "按时间",
              style: TextStyle(
                fontSize: 14,
                color: !isHotOrTime?AppColor.textPrimary1:AppColor.textSecondary,
                fontWeight: !isHotOrTime?FontWeight.bold:FontWeight.normal,
              ),
            ),
            splashColor: AppColor.textHint1,
            onTap: () {
              if(isHotOrTime) {
                _refreshController.loadComplete();
                isHotOrTime = !isHotOrTime;
                getDataAction(isFold: true);
              }
            },
          ),

        ],
      ),
    ),);
    widgetArray.add(SizedBox(height: 12,));
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
                color: AppColor.bgWhite.withOpacity(0.65),
              ),
              child: Text("说点什么吧~",
                  style: TextStyle(
                      fontSize: 14, color: AppColor.textHint)),
            ),
            onTap: () {
              targetId=liveModel.courseId;
              targetType=1;
              replyId = -1;
              replyCommentId = -1;

              openInputBottomSheet(
                context: this.context,
                voidCallback:(String text,List<Rule> rules,BuildContext context) {
                  _publishComment(text);
                  print("发表评论----" + text);
                },
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

    widgetArray.add(SizedBox(height: 23,));
    if (loadingStatusComment == LoadingStatus.STATUS_LOADING) {
      widgetArray.add(Container());
    } else {
      if ((isHotOrTime ? (courseCommentHot) : (courseCommentTime)) == null) {
        widgetArray.add(Container(
          child: Column(
            children: [
              Image.asset("images/test/bg.png", fit: BoxFit.cover,
                width: 224,
                height: 224,),
              SizedBox(height: 16,),
              Text("偷偷逆袭中，还没有人来冒泡呢",
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),)
            ],
          ),
        ));
      } else {
        for (int i = 0; i <
            (isHotOrTime ? (courseCommentHot) : (courseCommentTime))?.list
                ?.length; i++) {
          CommentDtoModel value = (isHotOrTime
              ? (courseCommentHot)
              : (courseCommentTime)).list[i];
          var subCommentCompleteTitle =
          // ignore: null_aware_before_operator
          (value.replys?.length < value.replyCount + value.pullNumber
              ? "查看"
              : (commentListSubSettingList[i].isFold ? "查看" : "隐藏"));
          var subCommentComplete =
          // ignore: null_aware_before_operator
          subCommentCompleteTitle +
              // ignore: null_aware_before_operator
              "${value.replys?.length >= value.replyCount + value.pullNumber
                  ? value.replyCount
                  : (value.replyCount + value.pullNumber -
                  value.replys?.length)}条回复";
          if (subCommentCompleteTitle == "隐藏") {
            subCommentComplete = "隐藏回复";
          }
          var subCommentLoading = "正在加载。。。";


          widgetArray.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                _getCommentUi(value, false, value.id),
                SizedBox(height: 13,),
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
                                  SizedBox(width: 57,),
                                  Container(
                                    width: 40,
                                    height: 0.5,
                                    color: AppColor.textSecondary,
                                  ),
                                  SizedBox(width: 4,),
                                  Container(
                                    child: Text(commentLoadingStatusList[i] ==
                                        LoadingStatus.STATUS_COMPLETED
                                        ? subCommentComplete
                                        : subCommentLoading,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // ignore: null_aware_before_operator
                                if (value.replys?.length >=
                                    value.replyCount + value.pullNumber) {
                                  (isHotOrTime
                                      ? courseCommentHot.list[i].replys
                                      : courseCommentTime.list[i].replys)
                                      .clear();
                                  if (isHotOrTime) {
                                    courseCommentHot.list[i].replyCount +=
                                        courseCommentHot.list[i].pullNumber;
                                    courseCommentHot.list[i].pullNumber = 0;
                                  } else {
                                    courseCommentTime.list[i].replyCount +=
                                        courseCommentTime.list[i].pullNumber;
                                    courseCommentTime.list[i].pullNumber = 0;
                                  }
                                  courseCommentPageHot = 1;
                                  courseCommentPageTime = 1;
                                  setState(() {});
                                  // if (commentListSubSettingList[i].subCommentAllHeight == null) {
                                  //   commentListSubSettingList[i]
                                  //       .subCommentAllHeight =
                                  //       commentListSubSettingList[i].globalKey
                                  //           .currentContext.size.height;
                                  //   setState(() {
                                  //
                                  //   });
                                  //   Future.delayed(Duration(milliseconds: 100), () {
                                  //     commentListSubSettingList[i].isFold =
                                  //     !commentListSubSettingList[i].isFold;
                                  //     setState(() {});
                                  //   });
                                  // } else {
                                  //   commentListSubSettingList[i].isFold = !commentListSubSettingList[i].isFold;
                                  //   setState(() {});
                                  // }
                                } else {
                                  commentListSubSettingList[i].isFold = false;
                                  commentLoadingStatusList[i] =
                                      LoadingStatus.STATUS_LOADING;
                                  setState(() {

                                  });
                                  _getSubComment(value.id, value.replys?.length,
                                      value.replyCount, value.pullNumber, i);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 13,),
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
        widgetArray.add(_getCommentUi(value.replys[i], true,value.id));
        widgetArray.add(SizedBox(height: 13,));
      }
    }

    Widget widget=Container(
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
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment,int _targetId) {
    var textSpanList=<TextSpan>[];
    textSpanList.add(TextSpan(
      text: value.name+" ",
      style: TextStyle(
        fontSize: 15,
        color: AppColor.textPrimary1,
        fontWeight: FontWeight.bold,
      ),
    ));
    if(isSubComment){
      if(value.replyId!=null&&value.replyId>0){
        textSpanList.add(TextSpan(
          text: "回复 ",
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textPrimary1,
          ),
        ));

        textSpanList.add(TextSpan(
          text: value.replyName+" ",
          style: TextStyle(
            fontSize: 15,
            color: AppColor.textPrimary1,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }
    textSpanList.add(TextSpan(
      text: value.content,
      style: TextStyle(
        fontSize: 14,
        color: AppColor.textPrimary1,
      ),
    ));


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
                  child: Image.asset(
                    "images/test/bg.png",
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
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
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
                                        DateUtil.formatDateNoYearString(
                                            DateUtil.getDateTimeByMs(
                                                value.createTime)),
                                        style: TextStyle(fontSize: 12,
                                            color: AppColor.textSecondary),
                                      ),
                                    ),
                                    SizedBox(width: 12,),
                                    Container(
                                      child: Text("回复",
                                        style: TextStyle(fontSize: 12,
                                            color: AppColor.textSecondary),
                                      ),
                                    ),
                                    SizedBox(width: 12,),
                                    Offstage(
                                      // offstage: uId!=value.uid,
                                      offstage: true,
                                      child: InkWell(
                                        child: Container(
                                          child: Text("删除",
                                            style: TextStyle(fontSize: 12,
                                                color: AppColor.textSecondary),
                                          ),
                                        ),
                                        onTap: () {
                                          ToastShow.show(
                                              msg: "点击删除", context: context);
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
                                                        _deleteComment(
                                                            value.id);
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
                                )
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        child: Container(
                          width: double.infinity,
                          color: AppColor.transparent,
                          height: double.infinity,
                        ),
                        onTap: () {
                          targetId = _targetId;
                          targetType = 2;
                          if (isSubComment) {
                            replyId = value.uid;
                            replyCommentId = value.id;
                          } else {
                            replyId = -1;
                            replyCommentId = -1;
                          }
                          openInputBottomSheet(
                            context: this.context,
                            hintText: "回复 " + value.name,
                            voidCallback: (String text,List<Rule> rules,
                                BuildContext context) {
                              // publishComment(text);
                              _publishComment(text);
                              print("回复评论----" + text);
                            },
                          );
                        },
                      ),
                    ],
                  )
              )
          ),
          SizedBox(width: 16,),
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
                  SizedBox(height: 7,),
                  Text(
                    IntegerUtil.formatIntegerEn(value.laudCount),
                    style: TextStyle(
                        fontSize: 12, color: AppColor.textSecondary),
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

  //获取底部按钮
  Widget _getBottomBar() {
    Widget containerWidget;
    bool isLoggedIn;
    context.select((TokenNotifier notifier) => notifier.isLoggedIn ? isLoggedIn=true : isLoggedIn=false);

    //todo 判断是否绑定了终端
    bool bindingTerminal = false;
    //todo 判断用户是不是vip
    bool isVip = false;
    //todo 判断这个课程是不是vip直播
    bool courseVip = false;

    TextStyle textStyle = const TextStyle(color: AppColor.white, fontSize: 16);
    TextStyle textStyleVip = const TextStyle(
        color: AppColor.textVipPrimary1, fontSize: 16);
    EdgeInsetsGeometry margin_32 = const EdgeInsets.only(left: 32, right: 32);
    EdgeInsetsGeometry marginLeft32Right16 = const EdgeInsets.only(
        left: 32, right: 16);
    EdgeInsetsGeometry marginLeft26Right20 = const EdgeInsets.only(
        left: 26, right: 20);
    EdgeInsetsGeometry marginRight32 = const EdgeInsets.only(right: 32);
    EdgeInsetsGeometry marginRight16 = const EdgeInsets.only(right: 16);


    Widget widget3 = Container(
      width: 60,
      height: double.infinity,
      margin: marginLeft26Right20,
      child: Column(
        children: [
          Icon(Icons.headset),
          Text((liveModel.playType == 3 ? liveModel.getGetPlayType() : "试听")),
        ],
      ),
    );
    Widget widget4 = getBtnUi(
        false, "回放", textStyle, 94, 40, marginLeft32Right16);
    Widget widget5 = getBtnUi(
        true, "开通vip使用终端播放", textStyleVip, double.infinity, 40,
        (liveModel.getGetPlayType() == "回放" ? marginRight32 : marginRight16));
    Widget widget2 = getBtnUi(
        false, "登陆终端使用终端播放", textStyle, double.infinity, 40,
        (liveModel.getGetPlayType() == "回放" ? marginRight32 : marginRight16));
    Widget widget1 = getBtnUi(false, "使用终端训练", textStyle, double.infinity, 40,
        (liveModel.getGetPlayType() == "回放" ? marginRight32 : marginRight16));
    Widget widget6 = getBtnUi(
        false, liveModel.getGetPlayType(), textStyle, double.infinity, 40,
        margin_32);

    var childrenArray = <Widget>[];

    if (!isLoggedIn) {
      print("没有登陆");
      childrenArray.add(widget6);
      containerWidget = GestureDetector(
        child: Container(
          width: double.infinity,
          child: Row(
            children: childrenArray,
          ),
        ),
        onTap: (){
          ToastShow.show(msg: "去登陆", context: context);
          // 去登录
          AppRouter.navigateToLoginPage(context);
        },
      );
    }else{
      print("登陆了");
      //todo 取绑定了终端没有

      if (liveModel.playType == 3) {
        childrenArray.add(
          GestureDetector(
            child: widget4,
            onTap: (){
              print("回放");
              ToastShow.show(msg: liveModel.getGetPlayType(), context: context);
            },
          ),
        );
      } else {
        childrenArray.add(
            GestureDetector(
              child: widget3,
              onTap: (){
                print("试听");
                ToastShow.show(msg: liveModel.getGetPlayType(), context: context);
              },
            )
        );
      }

      if(!courseVip||isVip) {
        if (bindingTerminal) {
          childrenArray.add(
            Expanded(child: SizedBox(
              child: GestureDetector(
                child: widget1,
                onTap: (){
                  print("绑定了终端");
                  ToastShow.show(msg: "使用终端训练", context: context);
                },
              ),
            ))
          );
        } else {
          childrenArray.add(
            Expanded(child: SizedBox(
                child: GestureDetector(
                child: widget2,
                onTap: (){
                  print("没有绑定终端");
                  ToastShow.show(msg: "登陆终端使用终端播放", context: context);
                },
              )
            ))
          );
        }
      }else{
        childrenArray.add(
          Expanded(child: SizedBox(
              child: GestureDetector(
              child: widget5,
              onTap: (){
                print("vip课程");
                ToastShow.show(msg: "开通vip使用终端播放", context: context);
              },
            )
          ))
        );
      }

      containerWidget = Container(
        width: double.infinity,
        child: Row(
          children: childrenArray,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: containerWidget,
    );
  }


  Widget getBtnUi(bool isVip,String text,TextStyle textStyle,double width1,double height1,EdgeInsetsGeometry marginData){
    var colors=<Color>[];
    if(isVip){
      colors.add(AppColor.bgVip1);
      colors.add(AppColor.bgVip2);
    }else{
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
        child: Text(text, style: textStyle,),
      ),
    );
  }


  //加载网络数据
  void getDataAction({bool isFold = false}) async {
    //获取评论
    if (isHotOrTime) {
      if (courseCommentHot == null) {
        Map<String, dynamic> commentModel = await queryListByHot2(
            targetId: courseId,
            targetType: 1,
            page: courseCommentPageHot,
            size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentHot = CommentModel.fromJson(commentModel);
          courseCommentPageHot++;
        }
      }
      setCommentListSubSetting(courseCommentHot, isFold: isFold);
    } else {
      if (courseCommentTime == null) {
        Map<String, dynamic> commentModel = await queryListByTime(
            targetId: courseId,
            targetType: 1,
            page: courseCommentPageTime,
            size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentTime = CommentModel.fromJson(commentModel);
          courseCommentPageTime++;
        }
      }
      setCommentListSubSetting(courseCommentTime, isFold: isFold);
    }
    loadingStatusComment = LoadingStatus.STATUS_COMPLETED;

    //获取直播详情数据
    if (liveModel == null || liveModel.coursewareDto?.movementDtos == null) {
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
  void setCommentListSubSetting(CommentModel commentModel,
      {bool isFold = false}) {
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
  _publishComment(String content) async {
    await postComments(
      targetId: targetId,
      targetType: targetType,
      content: content,
      replyId: replyId > 0 ? replyId : null,
      replyCommentId: replyCommentId > 0 ? replyCommentId : null,
      commentModelCallback: (CommentDtoModel model) {
        if (model != null) {
          if (targetId == liveModel.courseId) {
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
          setState(() {

          });
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
      setState(() {

      });
    } else {
      ToastShow.show(msg: "删除失败，只能删除自己的评论", context: context);
    }
  }

  _deleteCommentData(CommentModel commentModel, int commentId,
      bool isHotOrTime) {
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
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
                .replyCount--;
            if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
                .pullNumber > 0) {
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
                  .replyCount +=
                  (isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
                      .pullNumber;
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
                  .pullNumber = 0;
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

  //获取子评论
  _getSubComment(int targetId, int replyLength, int replyCount, int pullNumber,
      int positionComment) async {
    int subCommentPageSize = 3;
    // int subCommentAllPage=replyCount%subCommentPageSize>0?(replyCount~/subCommentPageSize)+1:(replyCount~/subCommentPageSize);
    int nowSubCommentPage = (replyLength - pullNumber) % subCommentPageSize > 0
        ? ((replyLength - pullNumber) ~/ subCommentPageSize) + 1
        : ((replyLength - pullNumber) ~/ subCommentPageSize);
    int page = nowSubCommentPage + 1;

    try {
      Map<String, dynamic> commentModel = await (isHotOrTime ? queryListByHot2 : queryListByTime)(targetId: targetId,
          targetType: 2,
          page: page,
          size: subCommentPageSize);

      if (commentModel != null) {
        List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
        commentDtoModelList.addAll(CommentModel
            .fromJson(commentModel)
            .list);

        if ((isHotOrTime ? courseCommentHot : courseCommentTime)
            .list[positionComment].replys != null) {
          if ((isHotOrTime ? courseCommentHot : courseCommentTime)
              .list[positionComment].pullNumber > 0) {
            for (int i = 0; i <
                (isHotOrTime ? courseCommentHot : courseCommentTime)
                    .list[positionComment].replys.length; i++) {
              for (int j = 0; j < commentDtoModelList.length; j++) {
                if ((isHotOrTime ? courseCommentHot : courseCommentTime)
                    .list[positionComment].replys[i].id ==
                    commentDtoModelList[j].id) {
                  commentDtoModelList.removeAt(j);
                  j--;
                  (isHotOrTime ? courseCommentHot : courseCommentTime)
                      .list[positionComment].pullNumber--;
                }
              }
            }
          }
          commentDtoModelList.insertAll(0,
              (isHotOrTime ? courseCommentHot : courseCommentTime)
                  .list[positionComment].replys);
        }

        (isHotOrTime ? courseCommentHot : courseCommentTime)
            .list[positionComment].replys = commentDtoModelList;
        if (commentDtoModelList.length >
            (isHotOrTime ? courseCommentHot : courseCommentTime)
                .list[positionComment].replyCount) {
          (isHotOrTime ? courseCommentHot : courseCommentTime)
              .list[positionComment].replyCount = commentDtoModelList.length;
        }
      }
      }catch(e){

      }

      commentLoadingStatusList[positionComment]=LoadingStatus.STATUS_COMPLETED;
      setState(() {

      });
  }

  //加载更多的评论
  void _onLoading() async {
    Future.delayed(Duration(milliseconds: 500), () async{
      Map<String, dynamic> mapModel = await (isHotOrTime
          ? queryListByHot2
          : queryListByTime)(targetId: courseId,
          targetType: 1,
          page: (isHotOrTime ? courseCommentPageHot : courseCommentPageTime),
          size: courseCommentPageSize);
      if (mapModel != null) {
        CommentModel commentModel = CommentModel.fromJson(mapModel);
        if (commentModel == null || commentModel.list == null ||
            commentModel.list.length < 1) {
          _refreshController.loadNoData();
        } else {
          (isHotOrTime ? courseCommentHot : courseCommentTime).list.addAll(
              commentModel.list);
          setCommentListSubSetting(
              (isHotOrTime ? courseCommentHot : courseCommentTime));
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
    Map<String, dynamic> model = await laudComment(
        commentId: commentId, laud: laud ? 1 : 0);
    if (model != null && model["state"]) {
      _laudCommentData(courseCommentHot, commentId, true, laud);
      _laudCommentData(courseCommentTime, commentId, false, laud);
      if (laud) {
        ToastShow.show(msg: "点赞成功", context: context);
      } else {
        ToastShow.show(msg: "取消点赞成功", context: context);
      }
      setState(() {

      });
    } else {
      if (laud) {
        ToastShow.show(msg: "点赞失败", context: context);
      } else {
        ToastShow.show(msg: "取消点赞失败", context: context);
      }
    }
  }

  //点赞
  _laudCommentData(CommentModel commentModel, int commentId, bool isHotOrTime,
      bool isLaud) {
    if (commentModel != null) {
      for (int i = 0; i < commentModel.list.length; i++) {
        if (commentModel.list[i].id == commentId) {
          isLaud ? (isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
              .laudCount++ : (isHotOrTime
              ? courseCommentHot
              : courseCommentTime).list[i].laudCount--;
          (isHotOrTime ? courseCommentHot : courseCommentTime).list[i].isLaud =
          isLaud ? 1 : 0;
          break;
        }
        int judge = 0;
        for (int j = 0; j < commentModel.list[i].replys.length; j++) {
          if (commentModel.list[i].replys[j].id == commentId) {
            isLaud ? (isHotOrTime ? courseCommentHot : courseCommentTime)
                .list[i].replys[j].laudCount++ : (isHotOrTime
                ? courseCommentHot
                : courseCommentTime).list[i].replys[j].laudCount--;
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[i]
                .replys[j].isLaud = isLaud ? 1 : 0;
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
    print("分享点击事件直播课");
    openShareBottomSheet(
        context: context,
        map: liveModel.toJson(),
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE);
  }
}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  double subCommentAllHeight;
  GlobalKey globalKey;
}
