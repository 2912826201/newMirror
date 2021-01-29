import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mirror/page/training/currency/currency_page.dart';

import '../../../widget/comment_input_bottom_bar.dart';
import 'sliver_custom_header_delegate.dart';
import 'package:provider/provider.dart';

/// 直播详情页
class LiveDetailPage extends StatefulWidget {
  const LiveDetailPage({Key key, this.heroTag,this.commentDtoModel,this.fatherComment, this.liveCourseId, this
      .liveModel, this
      .isHaveStartTime}) : super
      (key: key);

  final String heroTag;
  final int liveCourseId;
  final LiveVideoModel liveModel;
  final bool isHaveStartTime;
  final CommentDtoModel commentDtoModel;
  final CommentDtoModel fatherComment;
  @override
  createState() {
    return LiveDetailPageState(heroTag: heroTag, liveCourseId: liveCourseId, liveModel: liveModel,commentDtoModel:
    commentDtoModel,fatherComment: fatherComment);
  }
}

class LiveDetailPageState extends State<LiveDetailPage> {
  LiveDetailPageState({Key key,
    this.heroTag,
    this.liveCourseId,
    this.liveModel,
  this.commentDtoModel,
  this.fatherComment});
//互动通知列表带过来的评论内容
  CommentDtoModel commentDtoModel;

  //父评论内容
  CommentDtoModel fatherComment;
  //头部hero的标签
  String heroTag;

  //直播课程的id
  int liveCourseId;

  //当前直播的model
  LiveVideoModel liveModel;

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
  int courseCommentPageSize=20;

  //热门当前是第几页
  int courseCommentPageHot = 1;

  //时间排序当前是第几页
  int courseCommentPageTime = 1;

  Map<String,int> subCommentLastIdHot=Map();
  Map<String,int> subCommentLastIdTime=Map();

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //提前多久提醒---15分钟
  var howEarlyToRemind = 15;

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
    itemTotalHeight = 68 + 300 + 62 + 34 + (ScreenUtil.instance.screenWidthDp - 16 * 3) / 3 + 124;
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
                print('====================倒计时结束，滚动开始');
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
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(height: 40));
      widgetArray.add(getNoCompleteTitle(context,"直播课程详情页"));
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
                  child:getSmartRefresher(),
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
  Widget getSmartRefresher(){
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: footerWidget(),
      controller: _refreshController,
      onLoading: _onLoading,
      child: CustomScrollView(
        controller: scrollController,
        physics: isBouncingScrollPhysics?BouncingScrollPhysics():ClampingScrollPhysics(),
        slivers: <Widget>[
          // header,
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverCustomHeaderDelegate(
              title: liveModel.title ?? "",
              collapsedHeight: 40,
              expandedHeight: 300,
              paddingTop: MediaQuery.of(context).padding.top,
              coverImgUrl: getCourseShowImage(liveModel),
              heroTag: heroTag,
              startTime: liveModel.startTime,
              endTime: liveModel.endTime,
              shareBtnClick: _shareBtnClick,
            ),
          ),
          getTitleWidget(liveModel,context),
          getCoachItem(liveModel,context,onClickAttention,onClickCoach),
          getLineView(),
          getActionUi(liveModel,context,titleTextStyle),
          getLineView(),
          _getCourseCommentUi(),
          SliverToBoxAdapter(
            child: SizedBox(height: 15,),
          )
        ],
      ),
    );
  }


  //课程评论的框架--头部的数据
  Widget _getCourseCommentUi() {
    int count=isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime?.totalCount);
    if(count==null){
      count=0;
    }
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            getCourseTopText(titleTextStyle),
            getCourseTopNumber(isHotOrTime,count,onHotCommentTitleClickBtn,onTimeCommentTitleClickBtn),
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
    widgetArray.add(SizedBox(height: 23,));
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
  List<Widget> getBigCommentList(){
    var widgetArray = <Widget>[];
    for (int i = 0; i < (isHotOrTime ? (courseCommentHot) : (courseCommentTime))?.list?.length; i++) {
      widgetArray.add(bigBoxItem((isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list[i],i));
    }
    return widgetArray;
  }

  //外部的item
  Widget bigBoxItem(CommentDtoModel value,int index){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          _getCommentUi(value, false, value.id),
          SizedBox(height: 13,),
          getSubItemAll(value,index),
        ],
      ),
    );
  }
  //每一个item的子item
  Widget getSubItemAll(CommentDtoModel value,int index){
    return Offstage(
      offstage: value.replyCount + value.pullNumber < 1,
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            _getSubCommentItemUi(value, index),
            getCommentBottomAlertText(value,index),
            SizedBox(
              height: 13,
            ),
          ],
        ),
      ),
    );
  }

  //每一个评论的item底部提示文字
  Widget getCommentBottomAlertText(CommentDtoModel value,int index){
    var subComplete = getSubCommentComplete(value,commentListSubSettingList[index].isFold);
    var subLoading = "正在加载。。。";
    String alertText= commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED ? subComplete : subLoading;
    return Offstage(
      offstage: value.replyCount < 1,
      child: Container(
        width: double.infinity,
        child: GestureDetector(
          child: Row(
            children: [
              SizedBox(width: 57,),
              Container(width: 40, height: 0.5, color: AppColor.textSecondary),
              SizedBox(width: 4,),
              Container(child: Text(alertText,style: TextStyle(color: Colors.grey))),
            ],
          ),
          onTap: ()=>onClickAddSubComment(value,index),
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
        verticalDirection: VerticalDirection.up,
        children: [
          getUserImage(value.avatarUrl, 42, 42),
          SizedBox(width: 15),
          // //中间信息
          Expanded(child: SizedBox(
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
                          children: getSubCommentText(value,isSubComment,_targetId),
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
                        )
                    ),
                  ],
                ),
              ),
              onTap: ()=>onPostComment(_targetId,2,value.uid, value.id,hintText: "回复 " + value.name),
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
  List<TextSpan> getSubCommentText(CommentDtoModel value, bool isSubComment, int _targetId){
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

  //获取底部按钮
  Widget _getBottomBar() {
    bool isLoggedIn;
    context.select((TokenNotifier notifier) => notifier.isLoggedIn ? isLoggedIn = true : isLoggedIn = false);

    //todo 判断是否绑定了终端
    bool bindingTerminal = false;
    //todo 判断用户是不是vip
    bool isVip = false;

    var textStyle = const TextStyle(color: AppColor.white, fontSize: 16);
    var textStyleVip = const TextStyle(color: AppColor.textVipPrimary1, fontSize: 16);
    var margin_32 = const EdgeInsets.only(left: 32, right: 32);
    var marginLeft32Right16 = const EdgeInsets.only(left: 32, right: 16);
    var marginLeft26Right20 = const EdgeInsets.only(left: 26, right: 20);
    var marginRight32 = const EdgeInsets.only(right: 32);
    var marginRight16 = const EdgeInsets.only(right: 16);


    Widget widget3 = Container(
      width: 60,
      color: AppColor.transparent,
      height: double.infinity,
      margin: marginLeft26Right20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headset),
          Text((liveModel.playType == 3 ? liveModel.getGetPlayType() : "试听")),
        ],
      ),
    );

    EdgeInsetsGeometry tempEd = (liveModel.getGetPlayType() == "回放" ? marginRight32 : marginRight16);
    Widget widget1 = getBtnUi(false, "使用终端训练", textStyle, double.infinity, 40, tempEd);
    Widget widget2 = getBtnUi(false, "登陆终端使用终端播放", textStyle, double.infinity, 40, tempEd);
    Widget widget4 = getBtnUi(false, "回放", textStyle, 94, 40, marginLeft32Right16);
    Widget widget5 = getBtnUi(true, "开通vip使用终端播放", textStyleVip, double.infinity, 40, tempEd);
    Widget widget6 = getBtnUi(false, liveModel.getGetPlayType(), textStyle, double.infinity, 40, margin_32);
    Widget widget7 = getBtnUi(false, "已结束", textStyle, double.infinity, 40, margin_32);

    var childrenArray = <Widget>[];

    if(liveModel.endState!=null&&liveModel.endState==0){
      //已结束
      childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget7, onTap: _login))));
    }else {
      if (!isLoggedIn) {
        //没有登录
        childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget6, onTap: _login))));
      } else {
        //登录了

        //判断是不是需要预约或者是已预约的课程
        if (liveModel.playType == 2 || liveModel.playType == 4) {
          //判断是不是需要预约
          childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget6, onTap:
              () => _judgeBookOrCancelBook(bindingTerminal: bindingTerminal, isVip: isVip)))));
        } else {
          if (liveModel.playType == 3) {
            //回放
            childrenArray.add(GestureDetector(child: widget4, onTap: _seeVideo));
          } else {
            //试听
            childrenArray.add(GestureDetector(child: widget3, onTap: _seeVideo));
          }
          //判断绑定设备没有
          if (bindingTerminal) {
            //绑定了终端

            //判断我是不是需要开通vip才能观看
            //todo 判断这个课程是不是vip直播
            if (liveModel.playType == 1) {
              if (isVip) {
                //不再需要开通vip
                childrenArray.add(
                    Expanded(child: SizedBox(child: GestureDetector(child: widget1, onTap: _useTerminal))));
              } else {
                //需要开通vip
                childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget5, onTap: _openVip))));
              }
            } else if (liveModel.playType == 2) {
              //todo 付费课程--目前写的是开通vip
              childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget5, onTap: _openVip))));
            } else {
              //不再需要开通vip
              childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget1, onTap: _useTerminal))));
            }
          } else {
            //没有绑定终端
            childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget2, onTap: _loginTerminal))));
          }
        }
      }
    }

    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 50,
      child: Row(
        children: childrenArray,
      ),
    );
  }


  Widget getBtnUi(bool isVip, String text, var textStyle, double width1, double height1, var marginData) {
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
        child: Text(text == "去上课" ? "试听" : text, style: textStyle,),
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
  _publishComment(String text, List<Rule> rules) async {
    List<AtUsersModel> atListModel = [];
    for (Rule rule in rules) {
      AtUsersModel atModel = new AtUsersModel();
      atModel.index = rule.startIndex;
      atModel.len = rule.endIndex;
      atModel.uid = rule.id;
      atListModel.add(atModel);
    }
    await postComments(
      targetId: targetId,
      targetType: targetType,
      contentext: text,
      atUsers: jsonEncode(atListModel),
      replyId: replyId > 0 ? replyId : null,
      replyCommentId: replyCommentId > 0 ? replyCommentId : null,
      commentModelCallback: (CommentDtoModel model) {
        if (model != null) {
          if (targetId == liveModel.id) {
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
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE,
    sharedType: 1);
  }




  ///预约流程
  ///

  Future<void> _bookLiveCourse(LiveVideoModel value, int index, bool isAddCalendar,{bool bindingTerminal=false}) async {
    Map<String, dynamic> mapBook = await bookLiveCourse(
        courseId: value.id, startTime: value.startTime, isBook: value.playType == 2);

    if(mapBook!=null&&mapBook["code"]==200) {
      if (isAddCalendar) {
        onClickMakeAnAppointment(value, "", value.playType == 2);
      }

      if (mapBook["state"] != null) {
        if (value.playType == 2) {
          value.playType = 4;
        } else {
          value.playType = 2;
        }
        if(mapBook["state"]&&bindingTerminal){
          showAppDialog(context,
              title: "报名",
              info: "使用终端观看有机会加入直播小屏，获得教练实时指导，是否报名",
              cancel: AppDialogButton("仅上课", () {
                return true;
              }),
              confirm: AppDialogButton("我要报名", () {
                applyTerminalTrainingPr();
                return true;
              }));
        }
        setState(() {

        });
      }
    }else if(mapBook!=null){
      getDataAction();
    }

    return;
  }

  //点击预约后-查询是否有创建提醒的空间id
  void onClickMakeAnAppointment(LiveVideoModel value, String alert, bool isBook) async {
    //todo android 添加日历提醒 测试没有问题-虽然没有全机型测试------ios还未测试
    await [Permission.calendar].request();
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars == null || _calendars.length < 1) {
      var result = await _deviceCalendarPlugin.createCalendar("mirror", localAccountName: "mirror——1",);
      if (result.isSuccess) {
        if (isBook) {
          createEvent(result.data, _deviceCalendarPlugin, value, alert);
        } else {
          _deleteAlertEvents(result.data, alert, value);
        }
      }
    } else {
      if (isBook) {
        createEvent(_calendars[0].id, _deviceCalendarPlugin, value, alert);
      } else {
        _deleteAlertEvents(_calendars[0].id, alert, value);
      }
    }
  }

  //创建提醒
  void createEvent(String calendarId, DeviceCalendarPlugin _deviceCalendarPlugin,
      LiveVideoModel value, String alert) async {
    Event _event = new Event(calendarId);
    DateTime startTime = DateUtil.stringToDateTime(value.startTime);
    _event.start = startTime;
    var endTime = DateUtil.stringToDateTime(value.endTime);
    List<Reminder> _reminders = <Reminder>[];
    _reminders.add(new Reminder(minutes: howEarlyToRemind));
    _event.end = endTime;
    _event.title = value.title ?? "直播课程预约";
    _event.description = value.coursewareDto?.name;
    _event.reminders = _reminders;
    await _deviceCalendarPlugin.createOrUpdateEvent(_event);
  }

//  删除日历提醒
  Future _deleteAlertEvents(String calendarId, String alert, LiveVideoModel value) async {
    var calendarEvents = <Event>[];
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(Duration(days: 7));
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars != null && _calendars.length > 0) {
      var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
          _calendars[0].id,
          RetrieveEventsParams(startDate: startDate, endDate: endDate));
      calendarEvents = calendarEventsResult?.data;
    }
    if (calendarEvents.length > 0) {
      DateTime startTime = DateUtil.stringToDateTime(value.startTime);
      for (Event event in calendarEvents) {
        if (event.calendarId == calendarId && event.start == startTime) {
          await _deviceCalendarPlugin.deleteEvent(calendarId, event.eventId);
          return;
        }
      }
    }
  }


  ///------------------------------底部按钮的所有点击事件  start --------------------------------------------------------

  //去登陆
  void _login() {
    ToastShow.show(msg: "请先登陆app!", context: context);
    // 去登录
    AppRouter.navigateToLoginPage(context);
  }


  //判断是预约还是取消预约
  void _judgeBookOrCancelBook({bool bindingTerminal, bool isVip}) {
    if (liveModel.playType == 2) {
      _bookLiveCourse(liveModel, 0, true,bindingTerminal: bindingTerminal);
    } else {
      _bookLiveCourse(liveModel, 0, true);
    }
  }

  //回放和试听--看视频
  void _seeVideo() {
    if (liveModel.playType == 3) {
      ToastShow.show(msg: "回放", context: context);
    } else {
      ToastShow.show(msg: "试听", context: context);
    }
  }

  //使用终端进行训练
  void _useTerminal() {
    ToastShow.show(msg: "使用终端进行训练", context: context);
  }

  //登陆终端进行训练
  void _loginTerminal() {
    ToastShow.show(msg: "登陆终端进行训练", context: context);
  }

  //开通vip
  void _openVip() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VipNotOpenPage(
        type: VipState.NOTOPEN,
      );
    }));
  }

  //报名终端
  void applyTerminalTrainingPr() async {
    applyTerminalTraining(courseId: liveModel.id, startTime: liveModel.startTime);
    ToastShow.show(msg: "已报名，若中选将收到系统消息", context: context);
  }



  ///这是关注的方法
  onClickAttention() {
    if (!(liveModel.coachDto?.relation == 1 || liveModel.coachDto?.relation == 3)) {
      _getAttention(liveModel.coachDto?.uid);
    }
  }

  ///这是关注的方法
  _getAttention(int userId) async {
    int attntionResult = await ProfileAddFollow(userId);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      liveModel.coachDto?.relation = 1;
      setState(() {

      });
    }
  }

  ///点击了教练
  onClickCoach() {
    AppRouter.navigateToMineDetail(context, liveModel.coachDto?.uid);
  }
  ///点击了他人刚刚训练完成
  onClickOtherComplete() {
    AppRouter.navigateToOtherCompleteCoursePage(context,liveModel.id);
  }
  //热门评论点击
  onHotCommentTitleClickBtn(){
    if (!isHotOrTime) {
      _refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }
  //时间评论点击
  onTimeCommentTitleClickBtn(){
    if (isHotOrTime) {
      _refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }
  //输入框评论点击事件
  onEditBoxClickBtn(){
    targetId = liveModel.id;
    targetType = 1;
    replyId = -1;
    replyCommentId = -1;

    openInputBottomSheet(
      buildContext: this.context,
      voidCallback: _publishComment,
    );
  }

  //输入框评论点击事件
  onPostComment(int targetId,int targetType,int replyId,int replyCommentId,{String hintText}){
    this.targetId = targetId;
    this.targetType = targetType;
    this.replyId = replyId;
    this.replyCommentId = replyCommentId;
    openInputBottomSheet(
      buildContext: this.context,
      hintText: hintText,
      voidCallback: _publishComment,
    );
  }

  //判断加载子评论
  onClickAddSubComment(CommentDtoModel value,int index){
    if(commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED) {
      // ignore: null_aware_before_operator
      if (value.replys?.length >= value.replyCount + value.pullNumber) {
        (isHotOrTime ? courseCommentHot.list[index].replys : courseCommentTime.list[index].replys)
            .clear();
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


  //加载网络数据
  void getDataAction({bool isFold = false}) async {
    //获取评论
    if (isHotOrTime) {
      if (courseCommentHot == null) {
        Map<String, dynamic> commentModel = await queryListByHot2(
            targetId: liveCourseId, targetType: 1, lastId: courseCommentHot?.lastId??null, size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentHot = CommentModel.fromJson(commentModel);
          if (commentDtoModel != null) {
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
          courseCommentPageHot++;
        }
      }
      setCommentListSubSetting(courseCommentHot, isFold: isFold);
      onClickAddSubComment(courseCommentHot.list[choseIndex], choseIndex);
    } else {
      if (courseCommentTime == null) {
        Map<String, dynamic> commentModel = await queryListByTime(
            targetId: liveCourseId,
            targetType: 1,
            lastId: courseCommentTime?.lastId??null,
            size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentTime = CommentModel.fromJson(commentModel);
          courseCommentPageTime++;
        }
      }
      setCommentListSubSetting(courseCommentTime, isFold: isFold);
    }
    loadingStatusComment = LoadingStatus.STATUS_COMPLETED;

    String startTime="";
    if(liveModel!=null){
      startTime=liveModel.startTime;
    }
    //加载数据
    Map<String, dynamic> model = await (widget.isHaveStartTime?liveCourseDetail:getLatestLiveById)(courseId: liveCourseId, startTime: startTime);
    if (model == null) {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {});
      });
    } else {
      liveModel = LiveVideoModel.fromJson(model);
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    }
  }

  //todo 查询子评论会出现一个问题 当之前发布的子评论 个数过多会出现在下次请求中-去重导致感官-点击没有加载数据
  //获取子评论
  _getSubComment(int targetId, int replyLength, int replyCount, int pullNumber,
      int positionComment) async {
    int subCommentPageSize = 3;
    if(replyLength==0){
      (isHotOrTime?subCommentLastIdHot:subCommentLastIdTime)["$targetId"]=null;
    }
    int lastId=(isHotOrTime?subCommentLastIdHot:subCommentLastIdTime)["$targetId"];
    print("刚开始加载子评论");
    if(replyLength>0&&lastId==null&&(isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber<=0){
      print("有数量，但是null为空，表示没有数据了");
      commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
      return;
    }

    try {
      print("加载子评论---isHotOrTime:$isHotOrTime,targetId:$targetId, lastId:$lastId, subCommentPageSize:$subCommentPageSize");
      Map<String, dynamic> model = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId, targetType: 2, lastId: lastId, size: subCommentPageSize);

      print("获取到了数据model:${model.toString()}");
      if (model != null) {
        print("获取到了数据不为空");
        CommentModel commentModel = CommentModel.fromJson(model);
        if (!(commentModel == null || commentModel.list == null || commentModel.list.length < 1)) {

          print("获取到了commentModel不为空");
          List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
          commentDtoModelList.addAll(commentModel.list);

          print("获取到了length:${commentDtoModelList.length}条数据， commentModel.lastId：${commentModel.lastId}");
          (isHotOrTime?subCommentLastIdHot:subCommentLastIdTime)["$targetId"]=commentModel.lastId;
          int subCount=0;
          if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys != null) {
            if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber > 0) {
              for (int i = 0; i < (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys.length; i++) {
                for (int j = 0; j < commentDtoModelList.length; j++) {
                  if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys[i].id ==
                      commentDtoModelList[j].id) {
                    commentDtoModelList.removeAt(j);

                    j--;
                    subCount++;
                    print("删除了$subCount条重复记录");
                    (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber--;
                    print("-pullNumber:${(isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber}");
                    // (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount++;
                  }
                }
              }
            }

            if(subCount>0) {
              print("填补删除的条数");
              commentDtoModelList.addAll(await getSubCommentOne(subCount, positionComment));
            }else{
              (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber-=subCommentPageSize;
              if((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber<0){
                (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber=0;
              }
            }
            print("加上以前的数据");
            commentDtoModelList.insertAll(0, (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys);
            print("commentDtoModelList。length:${commentDtoModelList.length}");
          }

          (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys = commentDtoModelList;

          if (commentDtoModelList.length > (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount) {
            (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount = commentDtoModelList.length;
          }
        }
      }
    }catch(e){

    }

    commentLoadingStatusList[positionComment]=LoadingStatus.STATUS_COMPLETED;
    setState(() {

    });
  }
  //获取了一条数据子评论
  Future<List<CommentDtoModel>> getSubCommentOne(int count,int positionComment)async{
    int lastId=(isHotOrTime?subCommentLastIdHot:subCommentLastIdTime)["$targetId"];
    List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
    try {
      Map<String, dynamic> model = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId, targetType: 2, lastId: lastId, size: count);
      if (model != null) {
        CommentModel commentModel = CommentModel.fromJson(model);
        if (!(commentModel == null || commentModel.list == null || commentModel.list.length < 1)) {
          commentDtoModelList.addAll(commentModel.list);
          int subCount=0;
          (isHotOrTime?subCommentLastIdHot:subCommentLastIdTime)["$targetId"]=commentModel.lastId;
          if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys != null) {
            if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber > 0) {
              for (int i = 0; i < (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys.length; i++) {
                for (int j = 0; j < commentDtoModelList.length; j++) {
                  if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys[i].id ==
                      commentDtoModelList[j].id) {
                    commentDtoModelList.removeAt(j);
                    j--;
                    subCount++;
                    (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber--;
                    print("-pullNumber:${(isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber}");
                    // (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount++;
                  }
                }
              }
            }
          }
          if(subCount>0) {
            commentDtoModelList.addAll(await getSubCommentOne(subCount, positionComment));
          }
        }
      }
    } catch (e) {}
    return commentDtoModelList;
  }


  //加载更多的评论
  void _onLoading() async {
    Future.delayed(Duration(milliseconds: 500), () async{
      if(isHotOrTime&&courseCommentPageHot>0&&courseCommentHot.lastId==null){
        _refreshController.loadNoData();
        return;
      }
      if(!isHotOrTime&&courseCommentPageTime>0&&courseCommentTime.lastId==null){
        _refreshController.loadNoData();
        return;
      }
      Map<String, dynamic> mapModel = await (isHotOrTime
          ? queryListByHot2
          : queryListByTime)(targetId: liveCourseId,
          targetType: 1,
          lastId: (isHotOrTime ? courseCommentHot.lastId : courseCommentTime.lastId),
          size: courseCommentPageSize);
      if (mapModel != null) {
        CommentModel commentModel = CommentModel.fromJson(mapModel);
        if (commentModel == null || commentModel.list == null ||
            commentModel.list.length < 1) {
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

}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  double subCommentAllHeight;
  GlobalKey globalKey;
}
