import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';

import 'package:mirror/util/click_util.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'common_course_page.dart';

class CommonCommentPage extends StatefulWidget {
  final RefreshController refreshController;
  final int targetId;
  final int pushId;
  final int targetType;
  final int pageCommentSize;
  final int pageSubCommentSize;
  final bool isShowHotOrTime;

  //??????????????????????????????????????????
  CommentDtoModel commentDtoModel;
  final bool isShowAt;
  final bool isVideoCoursePage;
  CommentDtoModel fatherComment;
  final ScrollController scrollController;
  final int externalScrollHeight;
  final List<GlobalKey> globalKeyList;
  final double externalBoxHeight;
  bool isBottomSheetAndHomePage;
  bool isInteractiveIn = false;
  bool isActivity = false;
  Function() activityMoreOnTap;

  CommonCommentPage(
      {@required Key key,
      @required this.targetId,
      @required this.scrollController,
      @required this.refreshController,
      @required this.targetType,
      this.pushId = -1,
      this.globalKeyList,
      this.externalScrollHeight = 0,
      this.pageCommentSize = 5,
      this.pageSubCommentSize = 3,
      this.externalBoxHeight = 0,
      this.isShowHotOrTime = false,
      this.activityMoreOnTap,
      this.isShowAt = true,
      this.fatherComment,
      this.isBottomSheetAndHomePage = false,
      this.isVideoCoursePage = false,
      this.isActivity = false,
      this.commentDtoModel,
      this.isInteractiveIn})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommonCommentPageState();
  }
}

class CommonCommentPageState extends State<CommonCommentPage> with TickerProviderStateMixin {
  //?????????????????????-????????????
  CommentModel courseCommentHot;
  List<int> screenOutHotIds = <int>[];

  bool isLaudCommentLoading = false;

  //?????????????????????-????????????
  CommentModel courseCommentTime;

  List<int> screenOutTimeIds = <int>[];

  //???????????????????????????
  bool isHotOrTime;

  //??????????????????
  bool isFirstScroll = true;

  //??????????????????????????????
  bool choseItemInFirst = false;

  //?????????index
  int choseIndex = 0;

  //??????item???????????????
  double itemTotalHeight = 0;

  //????????????????????????
  int courseCommentPageHot = 1;

  //??????????????????????????????
  int courseCommentPageTime = 1;

  //??????????????????
  LoadingStatus loadingStatusComment;

  //????????????????????????????????????
  var commentListSubSettingList = <CommentListSubSetting>[];

  //????????????--?????????
  var commentLoadingStatusList = <LoadingStatus>[];

  //?????????????????????????????????-?????????id
  int replyId = -1;

  //???????????????????????? ???????????????id
  int replyCommentId = -1;

  //??????????????????targetId
  int targetId;

  //??????????????????targetType
  int targetType;

  Map<String, int> subCommentLastIdHot = Map();
  Map<String, int> subCommentLastIdTime = Map();

  GlobalKey globalKey = new GlobalKey();

  double scrollHeightOld = 0;

  bool childFirstLoading = true;

  @override
  void initState() {
    super.initState();
    print('======================??????init');
    courseCommentHot = null;
    courseCommentTime = null;
    isHotOrTime = true;
    if (widget.isBottomSheetAndHomePage && widget.commentDtoModel != null) {
      print(
          '----isBottomSheetAndHomePage---${widget.commentDtoModel.id}---------------isBottomSheetAndHomePage-------${widget.commentDtoModel.content}');
      bottomCommentInit();
    } else {
      print(
          '============77777777777======isBottomSheet${widget.isBottomSheetAndHomePage}   commentDtoModel${widget.commentDtoModel != null}');
    }
    loadingStatusComment = LoadingStatus.STATUS_LOADING;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!widget.isShowHotOrTime) {
        getDataAction();
      } else if(widget.isBottomSheetAndHomePage){
        Future.delayed(Duration(milliseconds: 300),(){
          getDataAction();
        });
      }else{
        getDataAction();
      }
    });
  }

  void bottomCommentInit() async {
    print('=========?????????????????????????????????????????????==============???????????????');
    widget.commentDtoModel.itemChose = true;
    if (widget.commentDtoModel.type == 2) {
      getComment(widget.commentDtoModel.targetId).then((model) {
        if (model != null) {
          print('============================@@@@@?????????????????????');
          widget.fatherComment = model;
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (courseCommentHot != null &&
        isFirstScroll &&
        widget.commentDtoModel != null &&
        !widget.isBottomSheetAndHomePage) {
      Future.delayed(Duration.zero, () async {
        print("????????????------------------------------------------------------------------------");
        if (widget.commentDtoModel.type == 2) {
          startAnimationScroll(widget.commentDtoModel.targetId);
        } else {
          startAnimationScroll(widget.commentDtoModel.id);
        }
        isFirstScroll = false;
      });
    }
    if (!widget.isShowHotOrTime &&
        courseCommentHot != null &&
        context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].comments != null &&
        context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].comments.length > 0) {
      if (context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].comments.length !=
              courseCommentHot.list.length ||
          courseCommentHot.list.length != commentListSubSettingList.length) {
        List<CommentDtoModel> list = <CommentDtoModel>[];
        list.addAll(context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].comments);
        courseCommentHot.list = list;
        courseCommentHot.totalCount = context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].totalCount;
        resetSubSetting(courseCommentHot);
      }
    }

    int count = isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime?.totalCount);
    if (count == null) {
      count = 0;
    }
    var widgetArray = <Widget>[];

    if (widget.isActivity) {
      if (!widget.isBottomSheetAndHomePage) {
        widgetArray.add(getTopActivityCommentUi(
            courseCommentHot != null && courseCommentHot.list != null && courseCommentHot.list.length > 0,
            widget.activityMoreOnTap));
      }
    } else if (widget.isShowHotOrTime) {
      widgetArray.add(getCourseTopText(AppStyle.textMedium18));
      widgetArray.add(getCourseTopNumber(isHotOrTime, count, onHotCommentTitleClickBtn, onTimeCommentTitleClickBtn));
      widgetArray.add(SizedBox(height: 12));
      widgetArray.add(getCourseTopEdit(onEditBoxClickBtn, false));
    }
    widgetArray.add(_getCommentItemUi());
    if (widget.isActivity && !widget.isBottomSheetAndHomePage) {
      widgetArray.add(SizedBox(height: 20));
      widgetArray.add(getCourseTopEdit(onEditBoxClickBtn, true));
    }
    return Container(
      // color: AppColor.,
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //??????????????????????????????
  Widget _getCommentItemUi() {
    var widgetArray = <Widget>[];
    widgetArray.add(SizedBox(
      height: 23,
    ));
    print("loadingStatusComment:$loadingStatusComment");
    if (loadingStatusComment == LoadingStatus.STATUS_LOADING) {
      widgetArray.add(Container());
    } else if (loadingStatusComment == LoadingStatus.STATUS_COMPLETED) {
      if ((isHotOrTime ? (courseCommentHot) : (courseCommentTime)) == null ||
          (isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list == null ||
          (isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list.length < 1) {
        widgetArray.add(getCommentNoData());
      } else {
        widgetArray.addAll(getBigCommentList());
      }
    } else {
      widgetArray.add(getCommentNoData());
    }
    return Container(
      width: double.infinity,
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //?????????item--for
  List<Widget> getBigCommentList() {
    var widgetArray = <Widget>[];
    for (int i = 0; i < (isHotOrTime ? (courseCommentHot) : (courseCommentTime))?.list?.length; i++) {
      widgetArray.add(bigBoxItem((isHotOrTime ? (courseCommentHot) : (courseCommentTime)).list[i], i));
    }
    return widgetArray;
  }

  //?????????item
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

  //?????????item??????item
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

  //??????????????????item??????????????????
  Widget getCommentBottomAlertText(CommentDtoModel value, int index) {
    var subComplete = Container(
        child: Text(getSubCommentComplete(value, commentListSubSettingList[index].isFold),
            style: TextStyle(color: Colors.grey)));
    var subLoading = Container(
        height: 17,
        width: 17,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.white), backgroundColor: AppColor.black, strokeWidth: 1.5));
    Widget alertWidget = commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED ? subComplete : subLoading;
    return Offstage(
      offstage: value.replyCount + value.pullNumber < 1,
      child: Container(
        width: double.infinity,
        child: GestureDetector(
          child: Row(
            children: [
              SizedBox(
                width: 72,
              ),
              Container(width: 40, height: 0.5, color: AppColor.textSecondary),
              SizedBox(
                width: 4,
              ),
              alertWidget
            ],
          ),
          onTap: () => onClickAddSubComment(value, index, true),
        ),
      ),
    );
  }

  //sub ????????????
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

  //?????????????????????
  Widget judgeStartAnimation(CommentDtoModel value, int _targetId) {
    if (value.isHaveAnimation) {
      AnimationController animationController = AnimationController(
        duration: new Duration(milliseconds: 100),
        vsync: this,
      );
      Future.delayed(Duration.zero, () {
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

  //???????????????item--?????????item
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment, int _targetId) {
    print('----_getCommentUi-----${value.itemChose}----${value.content}');
    if (widget.commentDtoModel != null && value.itemChose) {
      print('-----value.itemChose--------value.itemChose--------value.itemChose--${value.content}');
      int milliseconds = 3000;
      if (value.itemChose) {
        Future.delayed(Duration(milliseconds: milliseconds), () {
          print('-=-=-=-=-=-=-=-=-=-=-=-=-=-=??????????????????????????????');
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
            color: value.itemChose ? AppColor.white.withOpacity(0.1) : AppColor.mainBlack,
            elevation: 0,
            shadowColor: !value.itemChose ? AppColor.white.withOpacity(0.1) : AppColor.mainBlack,
            duration: Duration(seconds: 1),
            child: Container(
              padding: EdgeInsets.only(left: isSubComment ? 70 : 16, right: 0, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: getUserImage(value.avatarUrl, isSubComment ? 32 : 42, isSubComment ? 32 : 42),
                    onTap: () {
                      jumpToUserProfilePage(context, value.uid, avatarUrl: value.avatarUrl, userName: value.name);
                    },
                  ),
                  SizedBox(width: 15),
                  // //????????????
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
                                          //todo ?????????????????????????????????????????????????????????0.3??????--????????????
                                          DateUtil.getCommentShowData(DateUtil.getDateTimeByMs(value.createTime)),
                                          style: TextStyle(fontSize: 12, color: AppColor.textWhite40),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        child: Text(
                                          "??????",
                                          style: TextStyle(fontSize: 12, color: AppColor.textWhite40),
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
                        onTap: () => onPostComment(_targetId, 2, value.uid, value.id, hintText: "?????? " + value.name),
                      ),
                    ),
                  ),
                  Container(
                    child: GestureDetector(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            AppIcon.getAppIcon(value.isLaud == 1 ? AppIcon.like_red_18 : AppIcon.like_18, 18),
                            SizedBox(
                              height: 7,
                            ),
                            Text(
                              IntegerUtil.formatIntegerEn(value.laudCount),
                              style: TextStyle(fontSize: 12, color: AppColor.textWhite40),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (isLaudCommentLoading) {
                          return;
                        }
                        isLaudCommentLoading = true;
                        _laudComment(value.id, value.isLaud == 0, value.uid);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onLongPress: () {
        if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
          ToastShow.show(msg: "????????????app!", context: context);
          AppRouter.navigateToLoginPage(context);
          return;
        }
        List<String> list = [];
        if (value.uid == Application.profile.uid && context.read<TokenNotifier>().isLoggedIn) {
          list.add("??????");
          list.add("??????");
        } else {
          if (widget.pushId == Application.profile.uid && context.read<TokenNotifier>().isLoggedIn) {
            list.add("??????");
          }
          list.add("??????");
          list.add("??????");
        }
        list.add("??????");
        openMoreBottomSheet(
          context: context,
          lists: list,
          onItemClickListener: (index) {
            if (list[index] == "??????") {
              if (context != null && value.content != null) {
                Clipboard.setData(ClipboardData(text: value.content));
                ToastShow.show(msg: "?????????", context: context);
              }
            } else {
              if (list[index] == "??????") {
                showAppDialog(context,
                    title: "????????????",
                    info: "????????????????????????????????????????????????????",
                    cancel: AppDialogButton("??????", () {
                      // print("????????????");
                      return true;
                    }),
                    confirm: AppDialogButton("??????", () {
                      _deleteComment(value.id, value);
                      return true;
                    }));
              } else if (list[index] == "??????") {
                _profileMoreDenounce(value.id);
              } else if (list[index] == "??????") {
                onPostComment(_targetId, 2, value.uid, value.id, hintText: "?????? " + value.name);
              }
            }
          },
        );
      },
    );
  }

  //????????????
  _profileMoreDenounce(int targetId) async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return false;
    }
    bool isSucess = await ProfileMoreDenounce(targetId, 2);
    print("?????????isSucess:$isSucess");
    if (isSucess != null && isSucess) {
      ToastShow.show(msg: "??????????????????,?????????????????????!", context: context);
    }
  }

  //????????????
  _deleteComment(int commentId, CommentDtoModel commentDtoModel) async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return false;
    }
    Map<String, dynamic> model = await deleteComment(commentId: commentId);
    print(model);
    if (model != null && model["state"] == true) {
      _deleteCommentData(courseCommentHot, commentId, true);
      _deleteCommentData(courseCommentTime, commentId, false);
      if (!widget.isVideoCoursePage && courseCommentHot != null && !widget.isShowHotOrTime) {
        context
            .read<FeedMapNotifier>()
            .commensAssignment(widget.targetId, courseCommentHot.list, courseCommentHot.totalCount);
      }
      if (!widget.isVideoCoursePage)
        context.read<FeedMapNotifier>().deleteCommentCount(widget.targetId, commentDtoModel);

      ///TODO ?????????????????????????????????eventbus
      EventBus.init().post(msg: commentId, registerName: EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT);
      if (context.read<FeedMapNotifier>().value.feedMap[widget.targetId] != null &&
          !widget.isShowHotOrTime &&
          context.read<FeedMapNotifier>().value.feedMap[widget.targetId].hotComment.isNotEmpty) {
        for (int i = 0; i < context.read<FeedMapNotifier>().value.feedMap[widget.targetId].hotComment.length; i++) {
          if (context.read<FeedMapNotifier>().value.feedMap[widget.targetId].hotComment[i].id == commentId) {
            context
                .read<FeedMapNotifier>()
                .updateHotComment(widget.targetId, commentDtoModel: commentDtoModel, isDelete: true);
          }
        }
      }

      ToastShow.show(msg: "?????????", context: context);
      setState(() {});
    } else {
      ToastShow.show(msg: "????????????!", context: context);
    }
  }

  _deleteCommentData(CommentModel commentModel, int commentId, bool isHotOrTime) {
    if (commentModel != null) {
      for (int i = 0; i < commentModel.list.length; i++) {
        if (commentModel.list[i].id == commentId) {
          commentModel.list.removeAt(i);
          if(widget.isVideoCoursePage)commentModel.totalCount--;
          break;
        }
        int judge = 0;
        for (int j = 0; j < commentModel.list[i].replys.length; j++) {
          if (commentModel.list[i].replys[j].id == commentId) {
            commentModel.list[i].replys.removeAt(j);
            if(widget.isVideoCoursePage)commentModel.totalCount--;
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

  //????????????????????????
  List<TextSpan> getSubCommentText(CommentDtoModel value, bool isSubComment) {
    var textSpanList = <TextSpan>[];
    textSpanList.add(TextSpan(
        text: "${value.name}  ",
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            jumpToUserProfilePage(context, value.uid, avatarUrl: value.avatarUrl, userName: value.name);
          },
        style: AppStyle.whiteMedium15));
    if (isSubComment) {
      if (value.replyId != null && value.replyId > 0) {
        textSpanList.add(TextSpan(
          text: "?????? ",
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textWhite60,
          ),
        ));

        textSpanList.add(TextSpan(
          text: "${value.replyName}  ",
          recognizer: new TapGestureRecognizer()
            ..onTap = () {
              jumpToUserProfilePage(context, value.replyId, avatarUrl: value.avatarUrl, userName: value.replyName);
            },
          style: AppStyle.whiteMedium15,
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
          color: AppColor.textWhite60,
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
      if (end <= index) {
        continue;
      }
      if (index < content.length && index >= 0) {
        String firstString = content.substring(0, index);
        if (end > content.length) {
          end = content.length;
        }
        String secondString = "";
        try {
          secondString = content.substring(index, end);
        } catch (e) {
          print("content:$content,$index,$end,:$e,$i,${content.length}");
          print("${atUsers.toString()}");
        }
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
          ..onTap = () async {
            if (userMap[(i).toString()] != null) {
              print('--------------------------userMap[(i).toString()]----${userMap[(i).toString()]}-');
              getUserInfo(uid: userMap[(i).toString()]).then((value) {
                jumpToUserProfilePage(context, value.uid, avatarUrl: value.avatarUri, userName: value.nickName);
              });
            }
          },
        style: TextStyle(
          fontSize: 14,
          color: userMap[(i).toString()] != null ? AppColor.mainBlue : AppColor.textWhite60,
        ),
      ));
    }
    return textSpanList;
  }

  //????????????????????????
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
      //????????????????????????????????????????????????
      LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      loadingStatusList.add(commentLoadingStatus);
    }
    commentListSubSettingList.addAll(settingList);
    commentLoadingStatusList.addAll(loadingStatusList);
  }

  //????????????-???????????????????????????
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
      //????????????????????????????????????????????????
      LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      loadingStatusList.add(commentLoadingStatus);
    }
    commentListSubSettingList.clear();
    commentLoadingStatusList.clear();
    commentListSubSettingList.addAll(settingList);
    commentLoadingStatusList.addAll(loadingStatusList);
  }

  //????????????????????????
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
    //????????????????????????????????????????????????
    LoadingStatus commentLoadingStatus = LoadingStatus.STATUS_COMPLETED;
    loadingStatusList.add(commentLoadingStatus);

    commentListSubSettingList.addAll(settingList);
    commentLoadingStatusList.addAll(loadingStatusList);
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

  //????????????
  _publishComment(String text, List<Rule> rules, int commentUId) async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return false;
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
      contentext: StringUtil.replaceLineBlanks(text, rules),
      atUsers: jsonEncode(atListModel),
      replyId: replyId > 0 ? replyId : null,
      replyCommentId: replyCommentId > 0 ? replyCommentId : null,
      commentModelCallback: (BaseResponseModel baseResponseModel) {
        if (baseResponseModel.code == CODE_BLACKED) {
          ToastShow.show(msg: baseResponseModel.message, context: context, gravity: Toast.CENTER);
        } else if (baseResponseModel.code == CODE_NO_DATA) {
          ToastShow.show(msg: baseResponseModel.message, context: context, gravity: Toast.CENTER);
        } else {
          if (baseResponseModel.data != null) {
            CommentDtoModel model;
            model = (CommentDtoModel.fromJson(baseResponseModel.data));
            if (targetId == widget.targetId) {
              if (isHotOrTime) {
                if (courseCommentHot != null) {
                  courseCommentHot.list.insert(0, model);
                  courseCommentHot.totalCount++;
                } else {
                  courseCommentHot = new CommentModel();
                  courseCommentHot.list = [];
                  courseCommentHot.list.add(model);
                  courseCommentHot.totalCount = 1;
                }
                screenOutHotIds.add(model.id);
                setCommentListSubSettingSingle(model.id);
              } else {
                if (courseCommentTime != null) {
                  courseCommentTime.list.insert(0, model);
                  courseCommentTime.totalCount++;
                } else {
                  courseCommentTime = new CommentModel();
                  courseCommentTime.list = [];
                  courseCommentTime.list.add(model);
                  courseCommentTime.totalCount = 1;
                }
                screenOutTimeIds.add(model.id);
                setCommentListSubSettingSingle(model.id);
              }
              print("5555555555555555555555");
            } else {
              if (isHotOrTime) {
                if (courseCommentHot != null) {
                  for (int i = 0; i < courseCommentHot.list.length; i++) {
                    if (courseCommentHot.list[i].id == targetId) {
                      courseCommentHot.list[i].replys.add(model);
                      courseCommentHot.list[i].screenOutIds.add(model.id);
                      courseCommentHot.list[i].pullNumber++;
                      courseCommentHot.totalCount++;
                      if (isHotOrTime) {
                        commentListSubSettingList[i].isFold = false;
                      }
                      commentListSubSettingList[i].subCommentAllHeight = null;

                      if (!widget.isShowHotOrTime &&
                          context.read<FeedMapNotifier>().value.feedMap[widget.targetId].comments != null &&
                          context.read<FeedMapNotifier>().value.feedMap[widget.targetId].comments.length > 0) {
                        context
                            .read<FeedMapNotifier>()
                            .value
                            .feedMap[widget.targetId]
                            .comments[i]
                            .screenOutIds
                            .add(model.id);

                        print("courseCommentHot.totalCount${courseCommentHot.totalCount}");
                        if(!widget.isVideoCoursePage)context.read<FeedMapNotifier>().updateTotalCount(courseCommentHot.totalCount, widget.targetId);
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
                      courseCommentTime.totalCount++;
                      commentListSubSettingList[i].subCommentAllHeight = null;
                      if (!isHotOrTime) {
                        commentListSubSettingList[i].isFold = false;
                      }

                      if (!widget.isShowHotOrTime &&
                          context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].comments != null &&
                          context.watch<FeedMapNotifier>().value.feedMap[widget.targetId].comments.length > 0) {
                        context
                            .watch<FeedMapNotifier>()
                            .value
                            .feedMap[widget.targetId]
                            .comments[i]
                            .screenOutIds
                            .add(model.id);
                        if(!widget.isVideoCoursePage)context.read<FeedMapNotifier>().updateTotalCount(courseCommentTime.totalCount, widget.targetId);
                      }
                    }
                  }
                }
              }
            }
            if (widget.isBottomSheetAndHomePage &&
                !widget.isActivity&&
                context.read<FeedMapNotifier>().value.feedMap[widget.targetId].hotComment.length < 2) {
              context
                  .read<FeedMapNotifier>()
                  .updateHotComment(widget.targetId, commentDtoModel: model, isDelete: false);
            }
            ToastShow.show(msg: "????????????", context: context);
            if (mounted) {
              setState(() {});
              if (targetId != widget.targetId) {
                startAnimationScroll(targetId);
              }
            }
          } else {
            ToastShow.show(msg: "????????????", context: context);
          }
        }
      },
    );
  }

  //????????????????????????item
  void startAnimationScroll(int targetId) {
    print("????????????????????????item--targetId???$targetId------------------------------------------------------------------------");
    Future.delayed(Duration(milliseconds: 300), () {
      if (widget.scrollController != null) {
        double scrollHeight = 0;
        int index = 0;
        int count = 0;
        for (int i = 0; i < commentListSubSettingList.length; i++) {
          count++;
          scrollHeight += commentListSubSettingList[i].globalKey.currentContext.size.height;
          if (commentListSubSettingList[i].commentId == targetId) {
            index = i;
            print('---index---------index-----index----$index');
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
          if (widget.isVideoCoursePage) {
            scrollHeight += 160;
          }
          scrollHeight += 24;
        }
        scrollHeight += widget.externalScrollHeight;
        scrollHeight += 180;

        print("targetId:$targetId, widget.targetId:${widget.targetId}," +
            "index:$index,count:$count,scrollHeight:$scrollHeight");

        if (widget.isShowHotOrTime) {
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
            "????????????????????????item--scrollHeight???$scrollHeight------------------------------------------------------------------------");
        if (widget.fatherComment != null) {
          double childCommentHeight = calculateTextWidth(
                      "${widget.commentDtoModel.name} ?????? ${widget.commentDtoModel.replyName}${widget.commentDtoModel.content}",
                      AppStyle.textRegular14,
                      ScreenUtil.instance.screenWidthDp - 149,
                      10)
                  .height +
              34;
          scrollHeight += childCommentHeight;
        }
        if (scrollHeight > 0) {
          if(widget.isBottomSheetAndHomePage||widget.isVideoCoursePage){
            widget.scrollController.animateTo(
              scrollHeight,
              duration: Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }else{
            PrimaryScrollController.of(context).animateTo(
              scrollHeight,
              duration: Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        }
      }
    });
  }

  //??????????????????
  void getDataAction({bool isFold = false, bool isRefresh = false}) async {
    if (await isOffline()) {
      loadingStatusComment = LoadingStatus.STATUS_IDEL;
      if (isRefresh) {
        widget.refreshController.refreshCompleted();
      } else {
        widget.refreshController.loadNoData();
      }
      courseCommentHot = null;
      courseCommentTime = null;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    if (isRefresh) {
      courseCommentHot = null;
      courseCommentTime = null;
    }
    try {
      print("courseCommentHot???${courseCommentHot.list.length}");
    } catch (e) {
      print("courseCommentHot???null");
      print(e);
    }
    // //????????????
    if (isHotOrTime) {
      Map<String, dynamic> commentModel;
      if (widget.isInteractiveIn != null &&
          widget.isInteractiveIn &&
          widget.commentDtoModel != null &&
          context.read<FeedMapNotifier>().value.courseCommentHot[widget.commentDtoModel.id] != null) {
        courseCommentHot = CommentModel();
        courseCommentHot.list = [];
        context.read<FeedMapNotifier>().value.courseCommentHot[widget.commentDtoModel.id].list.forEach((element) {
          courseCommentHot.list.add(element);
        });
        courseCommentHot.lastId =
            context.read<FeedMapNotifier>().value.courseCommentHot[widget.commentDtoModel.id].lastId;
        courseCommentHot.totalCount =
            context.read<FeedMapNotifier>().value.courseCommentHot[widget.commentDtoModel.id].totalCount;
      } else {
        commentModel = await queryListByHot2(
            targetId: widget.targetId,
            targetType: widget.targetType,
            lastId: courseCommentHot?.lastId ?? null,
            size: widget.pageCommentSize);
        if (commentModel != null) {
          courseCommentHot = CommentModel.fromJson(commentModel);
        }
      }
      if (courseCommentHot != null) {
        if (widget.commentDtoModel != null && isFirstScroll) {
          for (int i = 0; i < courseCommentHot.list.length; i++) {
            if (courseCommentHot.list[i].id == widget.commentDtoModel.id) {
              print('=====================????????????????????????');
              choseItemInFirst = true;
              if (widget.isBottomSheetAndHomePage) {
                widget.commentDtoModel = courseCommentHot.list[i];
                widget.commentDtoModel.itemChose = true;
                courseCommentHot.list.removeAt(i);
                courseCommentHot.list.insert(0, widget.commentDtoModel);
                screenOutHotIds.add(widget.commentDtoModel.id);
              } else {
                choseIndex = i;
                courseCommentHot.list[i].itemChose = true;
              }
            } else if (courseCommentHot.list[i].id == widget.commentDtoModel.targetId) {
              print('=====================????????????????????????????????????');
              choseItemInFirst = true;
              if (widget.isBottomSheetAndHomePage) {
                if (i != 0) {
                  courseCommentHot.list.remove(courseCommentHot.list[i]);
                  courseCommentHot.list.insert(0, widget.fatherComment);
                  screenOutHotIds.add(widget.fatherComment.id);
                }
                /*courseCommentHot.list[0].replys.insert(0, widget.commentDtoModel);
                courseCommentHot.list[0].screenOutIds.add(widget.commentDtoModel.id);
                courseCommentHot.list[0].pullNumber = 1;
                courseCommentHot.list[0].replyCount -= 1;*/
              } else {
                choseIndex = i;
              }
            }
          }
          if (!choseItemInFirst) {
            if (widget.fatherComment != null) {
              print('=================???????????????????????????????????????');
              courseCommentHot.list.insert(0, widget.fatherComment);
              screenOutHotIds.add(widget.fatherComment.id);
              /*if (widget.isBottomSheetAndHomePage) {
                courseCommentHot.list[0].replys.insert(0, widget.commentDtoModel);
                courseCommentHot.list[0].screenOutIds.add(widget.commentDtoModel.id);
                courseCommentHot.list[0].replyCount -= 1;
                courseCommentHot.list[0].pullNumber = 1;
              }*/
            } else {
              print('=================???????????????????????????');
              widget.commentDtoModel.itemChose = true;
              courseCommentHot.list.insert(0, widget.commentDtoModel);
              screenOutHotIds.add(widget.commentDtoModel.id);
            }
          }
        }
        if (mounted) {
          setState(() {});
        }
        courseCommentPageHot++;

        if (!widget.isShowHotOrTime) {
          print('=================totalCount----------${courseCommentHot.totalCount}');
          if (mounted) {
            context
                .read<FeedMapNotifier>()
                .commensAssignment(widget.targetId, courseCommentHot.list, courseCommentHot.totalCount);
          }
        }

        setCommentListSubSetting(courseCommentHot, isFold: isFold);
        if (widget.commentDtoModel != null && widget.fatherComment != null && isFirstScroll && mounted) {
          /*   _getSubComment(courseCommentHot.list[choseIndex].id, courseCommentHot.list[choseIndex].replys?.length, courseCommentHot.list[choseIndex].replyCount, courseCommentHot.list[choseIndex].pullNumber, choseIndex);*/
          onClickAddSubComment(courseCommentHot.list[choseIndex], choseIndex, false);
        }

        if (isRefresh) {
          widget.refreshController.refreshCompleted();
        } else {
          widget.refreshController.loadComplete();
        }
      } else {
        if (isRefresh) {
          widget.refreshController.refreshCompleted();
        } else {
          widget.refreshController.loadNoData();
        }
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

        if (isRefresh) {
          widget.refreshController.loadComplete();
        } else {
          widget.refreshController.loadNoData();
        }
      } else {
        if (isRefresh) {
          widget.refreshController.refreshCompleted();
        } else {
          widget.refreshController.loadNoData();
        }
      }
    }

    loadingStatusComment = LoadingStatus.STATUS_COMPLETED;

    if (mounted) {
      setState(() {});
    }
  }

  //???????????????
  _getSubComment(
      int targetId, int replyLength, int replyCount, int pullNumber, int positionComment, bool isOnClick) async {
    int subCommentPageSize = 3;
    if (replyLength == 0) {
      (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"] = null;
    }
    int lastId = (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"];
    print("????????????????????????");
    if (replyLength > 0 &&
        lastId == null &&
        (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber <= 0) {
      print(
          "??????????????????null??????????????????????????????---lastId${lastId == null}----replyLength${replyLength > 0}---isHotOrTime${(isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber <= 0}");
      commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    try {
      print(
          "???????????????---isHotOrTime:$isHotOrTime,targetId:$targetId, lastId:$lastId, subCommentPageSize:$subCommentPageSize");
      print(
          "ids:${(isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].screenOutIds.toString()}");
      Map<String, dynamic> model = await (isHotOrTime ? queryListByHot2 : queryListByTime)(
          targetId: targetId,
          targetType: 2,
          lastId: lastId,
          ids: (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].screenOutIds.toString(),
          size: subCommentPageSize);

      print("??????????????????model:${model.toString()}");
      if (model != null) {
        print("???????????????????????????");
        // (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].pullNumber=0;
        // (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replyCount=model["totalCount"];

        CommentModel commentModel = CommentModel.fromJson(model);
        if (!(commentModel == null || commentModel.list == null || commentModel.list.length < 1)) {
          print("????????????commentModel?????????");
          List<CommentDtoModel> commentDtoModelList = <CommentDtoModel>[];
          if (widget.commentDtoModel != null && targetId == widget.commentDtoModel.targetId && childFirstLoading) {
            print('===================????????????????????????????????????');
            bool isFrist = false;
            for (int i = 0; i < commentModel.list.length; i++) {
              if (commentModel.list[i].id == widget.commentDtoModel.id) {
                print('=====================????????????');
                isFrist = true;
                commentModel.list[i].itemChose = true;
              }
            }
            if (!isFrist) {
              print('==============================???????????????$isFrist');
              widget.commentDtoModel.itemChose = true;
              commentDtoModelList.insert(0, widget.commentDtoModel);
              courseCommentHot.list[choseIndex].screenOutIds.add(widget.commentDtoModel.id);
            }
            childFirstLoading = false;
          }
          commentDtoModelList.addAll(commentModel.list.reversed.toList());
          commentModel.list.forEach((element) {
            print('==================????????????model???id===========${element.id}');
          });
          print("????????????length:${commentDtoModelList.length}???????????? commentModel.lastId???${commentModel.lastId}");
          (isHotOrTime ? subCommentLastIdHot : subCommentLastIdTime)["$targetId"] = commentModel.lastId;

          for (CommentDtoModel dtoModel in commentDtoModelList) {
            dtoModel.isHaveAnimation = isOnClick ? true : false;
          }

          if ((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys != null) {
            commentDtoModelList
                .addAll((isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys);
          }

          (isHotOrTime ? courseCommentHot : courseCommentTime).list[positionComment].replys = commentDtoModelList;
        }
      }
    } catch (e) {
      print("?????????");
    }

    commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
    if (mounted) {
      setState(() {
        print("????????????????????????");
      });
    }
  }

  void onRefresh() {
    widget.commentDtoModel = null;
    onLoading(isRefresh: true);
  }

  //?????????????????????
  void onLoading({bool isRefresh = false}) async {
    if ((isHotOrTime ? courseCommentHot : courseCommentTime) == null || isRefresh) {
      getDataAction(isRefresh: isRefresh);
      return;
    }
    Future.delayed(Duration.zero, () async {
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
          (isHotOrTime ? courseCommentHot : courseCommentTime).list.addAll(commentModel.list);
          (isHotOrTime ? courseCommentHot : courseCommentTime).lastId = commentModel.lastId;
          isHotOrTime ? courseCommentPageHot++ : courseCommentPageTime++;
          widget.refreshController.loadComplete();
          if (!widget.isShowHotOrTime) {
            context
                .read<FeedMapNotifier>()
                .commensAssignment(widget.targetId, courseCommentHot.list, courseCommentHot.totalCount);
          }
        }
      } else {
        widget.refreshController.loadNoData();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  //??????
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

  //?????????????????????
  onClickAddSubComment(CommentDtoModel value, int index, bool isOnClickListener) {
    if (commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED) {
      // ignore: null_aware_before_operator
      if (value.replys?.length >= value.replyCount + value.pullNumber && !widget.isBottomSheetAndHomePage) {
        commentListSubSettingList[index].isFold = !commentListSubSettingList[index].isFold;
        if (mounted) {
          setState(() {});
        }
      } else if (value.replys.length >= value.replyCount + value.pullNumber && isOnClickListener) {
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
        _getSubComment(value.id, value.replys?.length, value.replyCount, value.pullNumber, index, isOnClickListener);
      }
    }
  }

  //??????????????????
  onHotCommentTitleClickBtn() async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    if (!isHotOrTime) {
      widget.refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }

  //??????????????????
  onTimeCommentTitleClickBtn() async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    if (isHotOrTime) {
      widget.refreshController.loadComplete();
      isHotOrTime = !isHotOrTime;
      getDataAction(isFold: true);
    }
  }

  //??????-????????????
  _laudComment(int commentId, bool laud, int chatUserId) async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      isLaudCommentLoading = false;
      return;
    }
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "????????????app!", context: context);
      AppRouter.navigateToLoginPage(context);
      isLaudCommentLoading = false;
      return;
    }

    BlackModel blackModel = await ProfileCheckBlack(chatUserId);
    String text = "";
    if (blackModel.inYouBlack == 1) {
      text = "?????????????????????????????????????????????";
      ToastShow.show(msg: text, context: context);
      isLaudCommentLoading = false;
      return;
    } else if (blackModel.inThisBlack == 1) {
      text = "?????????????????????????????????????????????";
      ToastShow.show(msg: text, context: context);
      isLaudCommentLoading = false;
      return;
    }

    int code = await laudComment(commentId: commentId, laud: laud ? 1 : 0);
    if (code != null && code == 200) {
      _laudCommentData(courseCommentHot, commentId, true, laud);
      _laudCommentData(courseCommentTime, commentId, false, laud);
      if (laud) {
        print("????????????:laud:$laud,commentId:$commentId");
      } else {
        print("??????????????????:laud:$laud,commentId:$commentId");
      }
      if (mounted) {
        setState(() {
          isLaudCommentLoading = false;
        });
      }
    } else {
      if (laud) {
        print("????????????:laud:$laud,commentId:$commentId");
      } else {
        print("??????????????????:laud:$laud,commentId:$commentId");
      }
      isLaudCommentLoading = false;
    }
  }

  //???????????????????????????
  onEditBoxClickBtn() async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return false;
    }
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "????????????app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }

    targetId = widget.targetId;
    targetType = widget.targetType;
    replyId = -1;
    replyCommentId = -1;

    openInputBottomSheet(
      buildContext: this.context,
      voidCallback: (String content, List<Rule> rules) => _publishComment(content, rules, widget.pushId),
      isShowAt: widget.isShowAt,
    );
  }

  //???????????????????????????
  onPostComment(int targetId, int targetType, int replyId, int replyCommentId, {String hintText}) async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return false;
    }
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "????????????app!", context: context);
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
      voidCallback: (String content, List<Rule> rules) => _publishComment(content, rules, replyId),
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
