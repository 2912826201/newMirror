import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'common_course_page.dart';

class CommonCommentPage extends StatefulWidget {
  final RefreshController refreshController;
  final int targetId;
  final int pushId;
  final int targetType;
  final int pageCommentSize;
  final int pageSubCommentSize;
  final bool isShowHotOrTime;

  //互动通知列表带过来的评论内容
  final CommentDtoModel commentDtoModel;
  final bool isShowAt;
  final CommentDtoModel fatherComment;
  final ScrollController scrollController;
  final int externalScrollHeight;
  final List<GlobalKey> globalKeyList;
  final double externalBoxHeight;

  CommonCommentPage({
    @required Key key,
    @required this.targetId,
    @required this.scrollController,
    @required this.refreshController,
    @required this.targetType,
    this.pushId = -1,
    this.globalKeyList,
    this.externalScrollHeight = 0,
    this.pageCommentSize = 20,
    this.pageSubCommentSize = 3,
    this.externalBoxHeight = 0,
    this.isShowHotOrTime = false,
    this.isShowAt = true,
    this.fatherComment,
    this.commentDtoModel,
  }) : super(key: key);

  @override
  CommonCommentPageState createState() => CommonCommentPageState();
}

class CommonCommentPageState extends State<CommonCommentPage> with TickerProviderStateMixin {
  //用户的评论热度-热度排序
  CommentModel courseCommentHot;
  List<int> screenOutHotIds = <int>[];

  //用户的评论时间-时间排序
  CommentModel courseCommentTime;

  List<int> screenOutTimeIds = <int>[];

  //判断是热度还是评论
  bool isHotOrTime;

  //防止滚动多次
  bool isFirstScroll = true;

  //选中评论是否在第一页
  bool choseItemInFirst = false;

  //选中的index
  int choseIndex = 0;

  //选中item之上的高度
  double itemTotalHeight = 0;

  //热门当前是第几页
  int courseCommentPageHot = 1;

  //时间排序当前是第几页
  int courseCommentPageTime = 1;

  //评论加载状态
  LoadingStatus loadingStatusComment;

  //title文字的样式
  var titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textPrimary1);

  //用户评论的的一些动画参数
  var commentListSubSettingList = <CommentListSubSetting>[];

  //加载状态--子评论
  var commentLoadingStatusList = <LoadingStatus>[];

  //回复第二级别人的评论时-别人的id
  int replyId = -1;

  //回复第二级别人时 别人评论的id
  int replyCommentId = -1;

  //发布评论时的targetId
  int targetId;

  //发布评论时的targetType
  int targetType;

  Map<String, int> subCommentLastIdHot = Map();
  Map<String, int> subCommentLastIdTime = Map();

  GlobalKey globalKey = new GlobalKey();

  double scrollHeightOld = 0;

  bool childFirstLoading = true;

  @override
  void initState() {
    super.initState();
    courseCommentHot = null;
    courseCommentTime = null;
    isHotOrTime = true;
    loadingStatusComment = LoadingStatus.STATUS_LOADING;
    getDataAction();
  }

  @override
  Widget build(BuildContext context) {
    if (courseCommentHot != null && isFirstScroll && widget.commentDtoModel != null) {
      Future.delayed(Duration(milliseconds: 100), () async {
        print("开始滚动------------------------------------------------------------------------");
        if (widget.commentDtoModel.type == 2) {
          startAnimationScroll(widget.commentDtoModel.targetId);
        } else {
          startAnimationScroll(widget.commentDtoModel.id);
        }
        isFirstScroll = false;
      });
    } else {
      print('========================条件不满足 --courseCommentHot${courseCommentHot != null}--isFirstScroll$isFirstScroll'
          '---widget.commentDtoModel${widget.commentDtoModel != null}');
    }
    if (!widget.isShowHotOrTime &&
        courseCommentHot != null &&
        context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments != null &&
        context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments.length > 0) {
      if (context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments.length != courseCommentHot.list.length ||
          courseCommentHot.list.length != commentListSubSettingList.length) {
        courseCommentHot.list = context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments;
        resetSubSetting(courseCommentHot);
      }
    }

    int count = isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime?.totalCount);
    if (count == null) {
      count = 0;
    }
    var widgetArray = <Widget>[];
    if (widget.isShowHotOrTime) {
      widgetArray.add(getCourseTopText(titleTextStyle));
      widgetArray.add(getCourseTopNumber(isHotOrTime, count, onHotCommentTitleClickBtn, onTimeCommentTitleClickBtn));
      widgetArray.add(SizedBox(height: 12));
      widgetArray.add(getCourseTopEdit(onEditBoxClickBtn));
    }
    widgetArray.add(_getCommentItemUi());
    return Container(
      color: AppColor.white,
      child: Column(
        children: widgetArray,
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
      key: commentListSubSettingList[index].globalKey,
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
            getCommentBottomAlertText(value, index),
            SizedBox(
              height: 13,
            ),
            _getSubCommentItemUi(value, index),
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
        widgetArray.add(judgeStartAnimation(value.replys[i], value.id));
      }
    }
    return Container(
      child: Offstage(
        offstage: commentListSubSettingList[index].isFold,
        child: Container(
          width: double.infinity,
          /*   padding: const EdgeInsets.only(left: 55),*/
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: widgetArray,
            ),
          ),
        ),
      ),
    );
  }

  //判断有没有动画
  Widget judgeStartAnimation(CommentDtoModel value, int _targetId) {
    if (value.isHaveAnimation) {
      AnimationController animationController = AnimationController(
        duration: new Duration(milliseconds: 100),
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: 100), () {
        animationController.forward();
      });
      value.isHaveAnimation = false;
      return SizeTransition(
          sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 13),
            child: _getCommentUi(value, true, _targetId),
          ));
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 13),
        child: _getCommentUi(value, true, _targetId),
      );
    }
  }

  //获取评论的item--每一个item
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment, int _targetId) {
    if (widget.commentDtoModel != null) {
      if (value.itemChose) {
        Future.delayed(Duration(milliseconds: 5000), () {
          print('-=-=-=-=-=-=-=-=-=-=-=-=-=-=倒计时结束，背景改变');
          value.itemChose = false;
          if (mounted) {
            setState(() {});
          }
        });
      }
    }

    return GestureDetector(
      child: Container(
        color: AppColor.transparent,
        child: IntrinsicHeight(
          child: AnimatedPhysicalModel(
              shape: BoxShape.rectangle,
              color: value.itemChose ? AppColor.bgWhite : AppColor.white,
              elevation: 0,
              shadowColor: !value.itemChose ? AppColor.bgWhite : AppColor.white,
              duration: Duration(seconds: 1),
              child: Container(
                padding: EdgeInsets.only(left: isSubComment ? 55 : 16, right: 16, top: 8, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: getUserImage(value.avatarUrl, isSubComment ? 32 : 42, isSubComment ? 32 : 42),
                      onTap: () {
                        AppRouter.navigateToMineDetail(context, value.uid);
                      },
                    ),
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
                                    children: getSubCommentText(value, isSubComment),
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
                          _laudComment(value.id, value.isLaud == 0,value.uid);
                        },
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
      onLongPress: () {
        List<String> list = [];

        if (value.uid == Application.profile.uid && context.read<TokenNotifier>().isLoggedIn) {
          list.add("删除");
        } else {
          if (widget.pushId == Application.profile.uid && context.read<TokenNotifier>().isLoggedIn) {
            list.add("删除");
          }
          list.add("回复");
          list.add("举报");
        }
        list.add("复制");
        openMoreBottomSheet(
          context: context,
          isFillet: true,
          lists: list,
          onItemClickListener: (index) {
            if (list[index] == "复制") {
              if (context != null && value.content != null) {
                Clipboard.setData(ClipboardData(text: value.content));
                ToastShow.show(msg: "复制成功", context: context);
              }
            } else {
              if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
                ToastShow.show(msg: "请先登陆app!", context: context);
                AppRouter.navigateToLoginPage(context);
                return;
              }
              if (list[index] == "删除") {
                showAppDialog(context,
                    title: "删除确认",
                    info: "该评论删除后不可恢复，是否确认删除?",
                    cancel: AppDialogButton("取消", () {
                      // print("点了取消");
                      return true;
                    }),
                    confirm: AppDialogButton("确定", () {
                      _deleteComment(value.id);
                      return true;
                    }));
              } else if (list[index] == "举报") {
                _profileMoreDenounce(value.id);
              } else if (list[index] == "回复") {
                onPostComment(_targetId, 2, value.uid, value.id, hintText: "回复 " + value.name);
              }
            }
          },
        );
      },
    );
  }

  //举报评论
  _profileMoreDenounce(int targetId) async {
    bool isSucess = await ProfileMoreDenounce(targetId, 2);
    print("举报：isSucess:$isSucess");
    if (isSucess) {
      ToastShow.show(msg: "举报成功", context: context);
    }
  }

  //删除评论
  _deleteComment(int commentId) async {
    Map<String, dynamic> model = await deleteComment(commentId: commentId);
    print(model);
    if (model != null && model["state"] == true) {
      _deleteCommentData(courseCommentHot, commentId, true);
      _deleteCommentData(courseCommentTime, commentId, false);
      if (courseCommentHot != null && !widget.isShowHotOrTime) {
        context
            .read<FeedMapNotifier>()
            .commensAssignment(widget.targetId, courseCommentHot.list, courseCommentHot.totalCount);
      }
      ToastShow.show(msg: "已删除", context: context);
      setState(() {});
    } else {
      ToastShow.show(msg: "删除失败!", context: context);
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

  //获取子评论的文字
  List<TextSpan> getSubCommentText(CommentDtoModel value, bool isSubComment) {
    var textSpanList = <TextSpan>[];
    textSpanList.add(TextSpan(
      text: "${value.name}  ",
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          AppRouter.navigateToMineDetail(context, value.uid);
        },
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
          text: "${value.replyName}  ",
          recognizer: new TapGestureRecognizer()
            ..onTap = () {
              AppRouter.navigateToMineDetail(context, value.replyId);
            },
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

    List<AtUsersModel> atUsers = [];
    atUsers.addAll(value.atUsers);
    atUsers.sort((left, right) => left.index.compareTo(right.index));

    for (int i = 0; i < atUsers.length; i++) {
      int index = atUsers[i].index - subLen;
      int end = atUsers[i].len - subLen;
      if (index < content.length && index >= 0) {
        String firstString = content.substring(0, index);
        String secondString = content.substring(index, end);
        String threeString = content.substring(end, content.length);
        contentArray.add(firstString);
        contentArray.add(secondString);
        userMap[(contentArray.length - 1).toString()] = atUsers[i].uid;
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
              AppRouter.navigateToMineDetail(context, userMap[(i).toString()]);
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

  //设置评论的动画类
  void setCommentListSubSetting(CommentModel commentModel, {bool isFold = false}) {
    var settingList = <CommentListSubSetting>[];
    var loadingStatusList = <LoadingStatus>[];
    if (commentModel == null) {
      return;
    }
    for (int i = 0; i < commentModel?.list?.length; i++) {
      CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
      commentListSubSetting.commentId = commentModel.list[i].id;
      commentListSubSetting.isFold = isFold;
      settingList.add(commentListSubSetting);
      GlobalKey _globalKey = GlobalKey();
      commentListSubSetting.globalKey = _globalKey;
      //每一个加载评论的加载子评论的状态
      LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      loadingStatusList.add(commentLoadingStatus);
    }
    commentListSubSettingList.addAll(settingList);
    commentLoadingStatusList.addAll(loadingStatusList);
  }

  //重置数据-但是需要以前的数据
  void resetSubSetting(CommentModel commentModel, {bool isFold = false}) {
    if (commentModel == null || commentModel.list == null || commentModel.list.length < 1) {
      commentListSubSettingList.clear();
      commentLoadingStatusList.clear();
      return;
    }
    var settingList = <CommentListSubSetting>[];
    var loadingStatusList = <LoadingStatus>[];
    for (int i = 0; i < commentModel.list.length; i++) {
      int isHaveIndex = -1;
      for (int j = 0; j < commentListSubSettingList.length; j++) {
        if (commentListSubSettingList[j].commentId == commentModel.list[i].id) {
          isHaveIndex = j;
          break;
        }
      }
      if (isHaveIndex >= 0) {
        CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
        commentListSubSetting.commentId = commentListSubSettingList[isHaveIndex].commentId;
        commentListSubSetting.isFold = commentListSubSettingList[isHaveIndex].isFold;
        commentListSubSetting.globalKey = GlobalKey();
        settingList.add(commentListSubSetting);
      } else {
        CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
        commentListSubSetting.commentId = commentModel.list[i].id;
        commentListSubSetting.isFold = isFold;
        commentListSubSetting.globalKey = GlobalKey();
        settingList.add(commentListSubSetting);
      }
      //每一个加载评论的加载子评论的状态
      LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      loadingStatusList.add(commentLoadingStatus);
    }
    commentListSubSettingList.clear();
    commentLoadingStatusList.clear();
    commentListSubSettingList.addAll(settingList);
    commentLoadingStatusList.addAll(loadingStatusList);
  }

  //设置评论的动画类
  void setCommentListSubSettingSingle(int commentId, {bool isFold = false}) {
    var settingList = <CommentListSubSetting>[];
    var loadingStatusList = <LoadingStatus>[];
    if (commentId == null) {
      return;
    }
    CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
    commentListSubSetting.commentId = commentId;
    commentListSubSetting.isFold = isFold;
    settingList.add(commentListSubSetting);
    GlobalKey _globalKey = GlobalKey();
    commentListSubSetting.globalKey = _globalKey;
    //每一个加载评论的加载子评论的状态
    LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
    loadingStatusList.add(commentLoadingStatus);

    commentListSubSettingList.addAll(settingList);
    commentLoadingStatusList.addAll(loadingStatusList);
  }

  //发布评论
  _publishComment(String text, List<Rule> rules,int commentUId) async {

    BlackModel blackModel = await ProfileCheckBlack(commentUId);
    String text = "";
    if (blackModel.inYouBlack == 1) {
      text = "发布失败，你已将对方加入黑名单";
      ToastShow.show(msg: text, context: context);
      return;
    } else if (blackModel.inThisBlack == 1) {
      text = "发布失败，你已被对方加入黑名单";
      ToastShow.show(msg: text, context: context);
      return;
    }


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
          if (targetId == widget.targetId) {
            if (isHotOrTime) {
              if (courseCommentHot != null) {
                courseCommentHot.list.insert(0, model);
              } else {
                courseCommentHot = new CommentModel();
                courseCommentHot.list = [];
                courseCommentHot.list.add(model);
              }
              screenOutHotIds.add(model.id);
              setCommentListSubSettingSingle(model.id);
            } else {
              if (courseCommentTime != null) {
                courseCommentTime.list.insert(0, model);
              } else {
                courseCommentTime = new CommentModel();
                courseCommentTime.list = [];
                courseCommentTime.list.add(model);
              }
              screenOutTimeIds.add(model.id);
              setCommentListSubSettingSingle(model.id);
            }
          } else {
            if (isHotOrTime) {
              if (courseCommentHot != null) {
                for (int i = 0; i < courseCommentHot.list.length; i++) {
                  if (courseCommentHot.list[i].id == targetId) {
                    courseCommentHot.list[i].replys.add(model);
                    courseCommentHot.list[i].screenOutIds.add(model.id);
                    courseCommentHot.list[i].pullNumber++;
                    if (isHotOrTime) {
                      commentListSubSettingList[i].isFold = false;
                    }
                    commentListSubSettingList[i].subCommentAllHeight = null;
                    if (!widget.isShowHotOrTime &&
                        context.read<FeedMapNotifier>().feedMap[widget.targetId].comments != null &&
                        context.read<FeedMapNotifier>().feedMap[widget.targetId].comments.length > 0) {
                      context.read<FeedMapNotifier>().feedMap[widget.targetId].comments[i].screenOutIds.add(model.id);
                    }
                  }
                }
              }
            } else {
              if (courseCommentTime != null) {
                for (int i = 0; i < courseCommentTime.list.length; i++) {
                  if (courseCommentTime.list[i].id == targetId) {
                    courseCommentTime.list[i].replys.add(model);
                    courseCommentTime.list[i].screenOutIds.add(model.id);
                    courseCommentTime.list[i].pullNumber++;
                    commentListSubSettingList[i].subCommentAllHeight = null;
                    if (!isHotOrTime) {
                      commentListSubSettingList[i].isFold = false;
                    }

                    if (!widget.isShowHotOrTime &&
                        context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments != null &&
                        context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments.length > 0) {
                      context.watch<FeedMapNotifier>().feedMap[widget.targetId].comments[i].screenOutIds.add(model.id);
                    }
                  }
                }
              }
            }
          }

          ToastShow.show(msg: "发布成功", context: context);
          if (mounted) {
            setState(() {});
            if (targetId != widget.targetId) {
              startAnimationScroll(targetId);
            }
          }
        } else {
          ToastShow.show(msg: "发布失败", context: context);
        }
      },
    );
  }

  //滚动界面到指定的item
  void startAnimationScroll(int targetId) {
    print("滚动界面到指定的item--targetId：$targetId------------------------------------------------------------------------");
    Future.delayed(Duration(milliseconds: 200), () {
      if (widget.scrollController != null) {
        double scrollHeight = 0;
        int index = 0;
        int count = 0;
        for (int i = 0; i < commentListSubSettingList.length; i++) {
          count++;
          scrollHeight += commentListSubSettingList[i].globalKey.currentContext.size.height;
          if (commentListSubSettingList[i].commentId == targetId) {
            index = i;
            break;
          }
        }
        print("globalKeyList*************************************${widget.globalKeyList}");
        if (widget.globalKeyList != null && widget.globalKeyList.length > 0) {
          widget.globalKeyList.forEach((element) {
            if (element.currentContext != null && element.currentContext.size != null) {
              scrollHeight += element.currentContext.size.height;
            }
          });
          scrollHeight += 24;
        }
        scrollHeight += widget.externalScrollHeight;
        scrollHeight += 180;

        print("targetId:$targetId, widget.targetId:${widget.targetId}," +
            "index:$index,count:$count,scrollHeight:$scrollHeight");

        if (widget.isShowHotOrTime) {
          print("111111111111111111111111111111111");
          scrollHeight += 300;
          scrollHeight -= MediaQuery.of(context).size.height;
          if (scrollHeight < scrollHeightOld) {
            print("22222222222222222222222222222scrollHeight:$scrollHeight, scrollHeightOld:$scrollHeightOld");
            scrollHeight = 0;
          }
        } else if (widget.externalBoxHeight > 0) {
          print("33333333333333333333");
          scrollHeight += 50;
          if (scrollHeight > widget.externalBoxHeight) {
            print("4444444444444:$scrollHeight, widget.externalBoxHeight:${widget.externalBoxHeight}");
            scrollHeight -= widget.externalBoxHeight;
          } else {
            print("5555555555555555:$scrollHeight, scrollHeightOld:$scrollHeightOld");
            scrollHeight = 0;
          }
          if (scrollHeight < scrollHeightOld) {
            print("666666666666666:$scrollHeight, scrollHeightOld:$scrollHeightOld");
            scrollHeight = 0;
          }
        } else {
          print("7777777777777777777");
          scrollHeight += 100;
          scrollHeight -= MediaQuery.of(context).size.height;
          if (scrollHeight < scrollHeightOld) {
            print("88888888888888888888:$scrollHeight, scrollHeightOld:$scrollHeightOld");
            scrollHeight = 0;
          }
        }

        print(
            "滚动界面到指定的item--scrollHeight：$scrollHeight------------------------------------------------------------------------");
        if (scrollHeight > 0) {
          widget.scrollController.animateTo(
            scrollHeight,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  //加载网络数据
  void getDataAction({bool isFold = false}) async {
    // //获取评论
    if (isHotOrTime) {
      Map<String, dynamic> commentModel = await queryListByHot2(
          targetId: widget.targetId,
          targetType: widget.targetType,
          lastId: courseCommentHot?.lastId ?? null,
          size: widget.pageCommentSize);
      if (commentModel != null) {
        courseCommentHot = CommentModel.fromJson(commentModel);
        if (widget.commentDtoModel != null && isFirstScroll) {
          for (int i = 0; i < courseCommentHot.list.length; i++) {
            if (courseCommentHot.list[i].id == widget.commentDtoModel.id) {
              print('=====================在第一页的父评论');
              choseItemInFirst = true;
              choseIndex = i;
              courseCommentHot.list[i].itemChose = true;
            } else if (courseCommentHot.list[i].id == widget.commentDtoModel.targetId) {
              print('=====================在第一页的子评论的父评论');
              choseItemInFirst = true;
              choseIndex = i;
            }
          }
          if (!choseItemInFirst) {
            if (widget.fatherComment != null) {
              print('=================不在第一页的子评论的父评论');
              courseCommentHot.list.insert(0, widget.fatherComment);
              courseCommentHot.list[0].pullNumber = 1;
            } else {
              print('=================不在第一页的父评论');
              widget.commentDtoModel.itemChose = true;
              courseCommentHot.list.insert(0, widget.commentDtoModel);
              screenOutHotIds.add(widget.fatherComment.id);
            }
          }
        }
        if (mounted) {
          setState(() {});
        }
        courseCommentPageHot++;

        if (!widget.isShowHotOrTime) {
          if (mounted) {
            context
                .read<FeedMapNotifier>()
                .commensAssignment(widget.targetId, courseCommentHot.list, courseCommentHot.totalCount);
          }
        }

        setCommentListSubSetting(courseCommentHot, isFold: isFold);
        if (widget.fatherComment != null && isFirstScroll && mounted) {
          onClickAddSubComment(courseCommentHot.list[choseIndex], choseIndex);
        }
        widget.refreshController.loadComplete();
      } else {
        widget.refreshController.loadNoData();
      }
    } else {
      Map<String, dynamic> commentModel = await queryListByTime(
          targetId: widget.targetId,
          targetType: widget.targetType,
          lastId: courseCommentTime?.lastId ?? null,
          size: widget.pageCommentSize);
      if (commentModel != null) {
        courseCommentTime = CommentModel.fromJson(commentModel);
        courseCommentPageTime++;
        setCommentListSubSetting(courseCommentTime, isFold: isFold);
        widget.refreshController.loadComplete();
      } else {
        widget.refreshController.loadNoData();
      }
    }

    loadingStatusComment = LoadingStatus.STATUS_COMPLETED;

    if (mounted) {
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
      if (mounted) {
        setState(() {});
      }
      return;
    }
    try {
      print(
          "加载子评论---isHotOrTime:$isHotOrTime,targetId:$targetId, lastId:$lastId, subCommentPageSize:$subCommentPageSize");
      print(
          "ids:${(isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].screenOutIds.toString()}");
      Map<String, dynamic> model = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId,
          targetType: 2,
          lastId: lastId,
          ids: (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].screenOutIds.toString(),
          size: subCommentPageSize);

      print("获取到了数据model:${model.toString()}");
      if (model != null) {
        print("获取到了数据不为空");
        // (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber=0;
        // (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount=model["totalCount"];

        CommentModel commentModel = CommentModel.fromJson(model);
        if (!(commentModel == null || commentModel.list == null || commentModel.list.length < 1)) {
          print("获取到了commentModel不为空");
          List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
          if (widget.commentDtoModel != null && targetId == widget.commentDtoModel.targetId && childFirstLoading) {
            print('===================第一次进初始化选中的评论');
            bool isFrist = false;
            for (int i = 0; i < commentModel.list.length; i++) {
              if (commentModel.list[i].id == widget.commentDtoModel.id) {
                print('=====================在第一页');
                isFrist = true;
                commentModel.list[i].itemChose = true;
              }
            }
            if (!isFrist) {
              print('==============================不在第一页$isFrist');
              widget.commentDtoModel.itemChose = true;
              commentDtoModelList.insert(0, widget.commentDtoModel);
              courseCommentHot.list[choseIndex].screenOutIds.add(widget.commentDtoModel.id);
            }
            childFirstLoading = false;
          }
          commentDtoModelList.addAll(commentModel.list);
          commentModel.list.forEach((element) {
            print('==================获取到的model的id===========${element.id}');
          });
          print("获取到了length:${commentDtoModelList.length}条数据， commentModel.lastId：${commentModel.lastId}");
          (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"] = commentModel.lastId;

          for (CommentDtoModel dtoModel in commentDtoModelList) {
            dtoModel.isHaveAnimation = true;
          }

          if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys != null) {
            commentDtoModelList
                .addAll((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys);
          }

          (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys = commentDtoModelList;
        }
      }
    } catch (e) {
      print("报错了");
    }

    commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
    if (mounted) {
      setState(() {
        print("加载子评论结束了");
      });
    }
  }

  //加载更多的评论
  void onLoading() async {
    if ((isHotOrTime ? courseCommentHot : courseCommentTime) == null) {
      getDataAction();
      return;
    }
    Future.delayed(Duration(milliseconds: 500), () async {
      if (isHotOrTime && courseCommentPageHot > 0 && courseCommentHot.lastId == null) {
        widget.refreshController.loadNoData();
        return;
      }
      if (!isHotOrTime && courseCommentPageTime > 0 && courseCommentTime.lastId == null) {
        widget.refreshController.loadNoData();
        return;
      }
      Map<String, dynamic> mapModel = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: widget.targetId,
          targetType: widget.targetType,
          ids: (isHotOrTime ? screenOutHotIds.toString() : screenOutTimeIds.toString()),
          lastId: (isHotOrTime ? courseCommentHot.lastId : courseCommentTime.lastId),
          size: widget.pageCommentSize);
      if (mapModel != null) {
        CommentModel commentModel = CommentModel.fromJson(mapModel);
        if (commentModel == null || commentModel.list == null || commentModel.list.length < 1) {
          widget.refreshController.loadNoData();
        } else {
          if (widget.fatherComment != null) {
            for (int i = 0; i < commentModel.list.length; i++) {
              if (commentModel.list[i].id == widget.fatherComment.id) {
                commentModel.list.removeAt(i);
                break;
              }
            }
          }
          setCommentListSubSetting(commentModel);
          (isHotOrTime ? courseCommentHot : courseCommentTime)?.list?.addAll(commentModel.list);
          (isHotOrTime ? courseCommentHot : courseCommentTime)?.lastId = commentModel.lastId;
          isHotOrTime ? courseCommentPageHot++ : courseCommentPageTime++;
          widget.refreshController.loadComplete();
        }
      } else {
        widget.refreshController.loadNoData();
      }
      if (mounted) {
        setState(() {});
      }
    });
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

  //判断加载子评论
  onClickAddSubComment(CommentDtoModel value, int index) {
    if (commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED) {
      // ignore: null_aware_before_operator
      if (value.replys?.length >= value.replyCount + value.pullNumber) {
        commentListSubSettingList[index].isFold = !commentListSubSettingList[index].isFold;
        if (mounted) {
          setState(() {});
        }
      } else {
        commentListSubSettingList[index].isFold = false;
        commentLoadingStatusList[index] = LoadingStatus.STATUS_LOADING;
        if (mounted) {
          setState(() {});
        }
        _getSubComment(value.id, value.replys?.length, value.replyCount, value.pullNumber, index);
      }
    }
  }

  //热门评论点击
  onHotCommentTitleClickBtn() {
    if (!isHotOrTime) {
      widget.refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }

  //时间评论点击
  onTimeCommentTitleClickBtn() {
    if (isHotOrTime) {
      widget.refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }

  //点赞-取消点赞
  _laudComment(int commentId, bool laud,int chatUserId) async {
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }

    BlackModel blackModel = await ProfileCheckBlack(chatUserId);
    String text = "";
    if (blackModel.inYouBlack == 1) {
      text = "发布失败，你已将对方加入黑名单";
      ToastShow.show(msg: text, context: context);
      return;
    } else if (blackModel.inThisBlack == 1) {
      text = "发布失败，你已被对方加入黑名单";
      ToastShow.show(msg: text, context: context);
      return;
    }

    Map<String, dynamic> model = await laudComment(commentId: commentId, laud: laud ? 1 : 0);
    if (model != null && model["state"]) {
      _laudCommentData(courseCommentHot, commentId, true, laud);
      _laudCommentData(courseCommentTime, commentId, false, laud);
      if (laud) {
        ToastShow.show(msg: "点赞成功", context: context);
      } else {
        ToastShow.show(msg: "取消点赞成功", context: context);
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      if (laud) {
        ToastShow.show(msg: "点赞失败", context: context);
      } else {
        ToastShow.show(msg: "取消点赞失败", context: context);
      }
    }
  }

  //输入框评论点击事件
  onEditBoxClickBtn() {
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }

    targetId = widget.targetId;
    targetType = widget.targetType;
    replyId = -1;
    replyCommentId = -1;

    openInputBottomSheet(
      buildContext: this.context,
      voidCallback: (String content, List<Rule> rules)=>_publishComment(content,rules,widget.pushId),
      isShowAt: widget.isShowAt,
    );
  }

  //输入框评论点击事件
  onPostComment(int targetId, int targetType, int replyId, int replyCommentId, {String hintText}) {
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    this.targetId = targetId;
    this.targetType = targetType;
    this.replyId = replyId;
    this.replyCommentId = replyCommentId;
    openInputBottomSheet(
      buildContext: this.context,
      hintText: hintText,
      voidCallback: (String content, List<Rule> rules)=>_publishComment(content,rules,replyId),
      isShowAt: widget.isShowAt,
    );
  }
}

class CommentListSubSetting {
  int commentId;
  int targetId;
  bool isFold;
  double subCommentAllHeight;
  GlobalKey globalKey;
}
