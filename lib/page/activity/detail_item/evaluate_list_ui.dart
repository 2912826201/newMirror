import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_evaluate_model.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/user_avatar_image.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'grade_start_ui.dart';

class EvaluateListUi extends StatefulWidget {
  final ActivityModel activityModel;
  final List<ActivityEvaluateModel> evaluateList;
  final RefreshController refreshController;

  final bool isFold;

  EvaluateListUi(Key key, this.activityModel, this.evaluateList, {this.refreshController, this.isFold = false})
      : super(key: key);

  @override
  EvaluateListUiState createState() => EvaluateListUiState();
}

class EvaluateListUiState extends State<EvaluateListUi> with TickerProviderStateMixin {
  //用户评论的的一些动画参数
  var commentListSubSettingList = <CommentListSubSetting>[];

  //加载状态--子评论
  var commentLoadingStatusList = <LoadingStatus>[];

  bool isLaudCommentLoading = false;

  Map<String, int> subCommentLastIdHot = Map();

  //回复第二级别人的评论时-别人的id
  int replyId = -1;

  //回复第二级别人时 别人评论的id
  int replyCommentId = -1;

  //发布评论时的targetId
  int targetId;

  //发布评论时的targetType
  int targetType;

  int evaluateLastTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("1111:${widget.evaluateList.length}");
    if (commentListSubSettingList.length != widget.evaluateList.length) {
      setCommentListSubSetting(isFold: widget.isFold);
    }
    var widgetArray = <Widget>[];
    widgetArray.addAll(_getCommentItemUi());
    return Container(
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //外层评价ui
  List<Widget> _getCommentItemUi() {
    var widgetArray = <Widget>[];
    if (widget.evaluateList.length < 1) {
      widgetArray.add(Container());
    } else {
      widgetArray.addAll(getBigCommentList());
    }
    return widgetArray;
  }

  //外部的item--for
  List<Widget> getBigCommentList() {
    var widgetArray = <Widget>[];
    for (int i = 0; i < widget.evaluateList.length; i++) {
      widgetArray.add(bigBoxItem(widget.evaluateList[i], i));
    }
    return widgetArray;
  }

  //外部的item
  Widget bigBoxItem(ActivityEvaluateModel value, int index) {
    return Container(
      width: double.infinity,
      key: commentListSubSettingList[index].globalKey,
      child: Column(
        children: [
          _getCommonUi(value, index, widget.evaluateList.length),
          getSubItemAll(value, index),
        ],
      ),
    );
  }

  //活动评价的item
  Widget _getCommonUi(ActivityEvaluateModel model, int index, int length) {
    return GestureDetector(
      child: Container(
        height: 82.0,
        margin: EdgeInsets.only(bottom: index + 1 == length ? 0 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatarImageUtil.init().getUserImageWidget(model.userInfo.avatarUri, model.userInfo.uid.toString(), 42),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 6),
                  Container(
                    height: 28,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Text(model.userInfo.nickName ?? "", style: AppStyle.whiteMedium15),
                        SizedBox(width: 17),
                        GradeStart(model.score, 5, isCanClick: false, size: 18, intervalWidth: 4),
                      ],
                    ),
                  ),
                  Text(model.content ?? "",
                      style: AppStyle.text1Regular14, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(width: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(DateUtil.getCommentShowData(DateUtil.getDateTimeByMs(model.createTime)),
                          style: AppStyle.text2Regular12),
                      SizedBox(width: 12),
                      GestureDetector(
                        child: Text("回复", style: AppStyle.text2Regular12),
                        onTap: () {
                          onPostComment(model.id, model.uid, model.id, hintText: "回复 " + model.userInfo.nickName);
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 6),
                ],
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
      ),
      onLongPress: () {
        if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
          ToastShow.show(msg: "请先登录app!", context: context);
          AppRouter.navigateToLoginPage(context);
          return;
        }
        List<String> list = [];
        if (context.read<TokenNotifier>().isLoggedIn && model.userInfo.uid == Application.profile.uid) {
          list.add("回复");
        } else {
          list.add("回复");
          list.add("举报");
        }
        list.add("复制");
        openMoreBottomSheet(
          context: context,
          lists: list,
          onItemClickListener: (index) {
            if (list[index] == "复制") {
              if (context != null && model.content != null) {
                Clipboard.setData(ClipboardData(text: model.content));
                ToastShow.show(msg: "已复制", context: context);
              }
            } else {
              if (list[index] == "举报") {
                _profileMoreDenounce(model.id, targetType: 5);
              } else if (list[index] == "回复") {
                onPostComment(model.id, model.uid, model.id, hintText: "回复 " + model.userInfo.nickName);
              }
            }
          },
        );
      },
    );
  }

  //每一个item的子item
  Widget getSubItemAll(ActivityEvaluateModel value, int index) {
    return Offstage(
      offstage: value.commentCount + value.pullNumber < 1,
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            getCommentBottomAlertText(value, index),
            SizedBox(
              height: 12,
            ),
            _getSubCommentItemUi(value, index),
          ],
        ),
      ),
    );
  }

  //每一个评论的item底部提示文字
  Widget getCommentBottomAlertText(ActivityEvaluateModel value, int index) {
    var subComplete = Container(
        child: Text(
            getSubCommentCompleteString(value.commentList.length, value.commentCount, value.pullNumber,
                commentListSubSettingList[index].isFold),
            style: TextStyle(color: Colors.grey)));
    var subLoading = Container(
        height: 17,
        width: 17,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.white), backgroundColor: AppColor.black, strokeWidth: 1.5));
    Widget alertWidget = commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED ? subComplete : subLoading;
    return Offstage(
      offstage: value.commentCount + value.pullNumber < 1,
      child: Container(
        width: double.infinity,
        child: GestureDetector(
          child: Row(
            children: [
              SizedBox(
                width: 47 + 15.0,
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

  //sub 子品评论
  Widget _getSubCommentItemUi(ActivityEvaluateModel value, int index) {
    var widgetArray = <Widget>[];
    if (value.commentList != null && value.commentList.length > 0) {
      for (int i = 0; i < value.commentList.length; i++) {
        widgetArray.add(judgeStartAnimation(value.commentList[i], value.id, value.uid));
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
  Widget judgeStartAnimation(CommentDtoModel value, int _targetId, int pushId) {
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
            child: _getCommentUi(value, true, _targetId, pushId),
          ));
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 13),
        child: _getCommentUi(value, true, _targetId, pushId),
      );
    }
  }

  //获取评论的item--每一个item
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment, int _targetId, int pushId) {
    return GestureDetector(
      child: Container(
        color: AppColor.transparent,
        child: IntrinsicHeight(
          child: AnimatedPhysicalModel(
            shape: BoxShape.rectangle,
            color: value.itemChose ? AppColor.white.withOpacity(0.1) : AppColor.transparent,
            elevation: 0,
            shadowColor: !value.itemChose ? AppColor.white.withOpacity(0.1) : AppColor.transparent,
            duration: Duration(seconds: 1),
            child: Container(
              padding: EdgeInsets.only(left: 47 + 15.0, right: 0, top: 8, bottom: 8),
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
                                          //todo 刚发的评论日期会出现比现在获取的日期大0.3毫秒--原因未知
                                          DateUtil.getCommentShowData(DateUtil.getDateTimeByMs(value.createTime)),
                                          style: TextStyle(fontSize: 12, color: AppColor.textWhite40),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        child: Text(
                                          "回复",
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
                        onTap: () => onPostComment(_targetId, value.uid, value.id, hintText: "回复 " + value.name),
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
                        _laudComment(value.id, value.isLaud == 0, value.uid, value);
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
          ToastShow.show(msg: "请先登录app!", context: context);
          AppRouter.navigateToLoginPage(context);
          return;
        }
        List<String> list = [];
        if (context.read<TokenNotifier>().isLoggedIn && value.uid == Application.profile.uid) {
          list.add("删除");
          list.add("回复");
        } else {
          if (context.read<TokenNotifier>().isLoggedIn && pushId == Application.profile.uid) {
            list.add("删除");
          }
          list.add("回复");
          list.add("举报");
        }
        list.add("复制");
        openMoreBottomSheet(
          context: context,
          lists: list,
          onItemClickListener: (index) {
            if (list[index] == "复制") {
              if (context != null && value.content != null) {
                Clipboard.setData(ClipboardData(text: value.content));
                ToastShow.show(msg: "已复制", context: context);
              }
            } else {
              if (list[index] == "删除") {
                showAppDialog(context,
                    title: "删除确认",
                    info: "该评论删除后不可恢复，是否确认删除?",
                    cancel: AppDialogButton("取消", () {
                      // print("点了取消");
                      return true;
                    }),
                    confirm: AppDialogButton("确定", () {
                      Future.delayed(Duration(microseconds: 100), () {
                        _deleteComment(value.id, value);
                      });
                      return true;
                    }));
              } else if (list[index] == "举报") {
                _profileMoreDenounce(value.id);
              } else if (list[index] == "回复") {
                onPostComment(_targetId, value.uid, value.id, hintText: "回复 " + value.name);
              }
            }
          },
        );
      },
    );
  }

  //获取子评论的文字
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
          text: "回复 ",
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

  //设置评论的动画类
  void setCommentListSubSetting({bool isFold = false}) {
    if (widget.evaluateList.length < 1) {
      return;
    }
    var settingList = <CommentListSubSetting>[];
    var loadingStatusList = <LoadingStatus>[];
    commentListSubSettingList.clear();
    commentLoadingStatusList.clear();
    for (int i = 0; i < widget.evaluateList.length; i++) {
      CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
      commentListSubSetting.commentId = widget.evaluateList[i].id;
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

  //判断加载子评论
  onClickAddSubComment(ActivityEvaluateModel value, int index, bool isOnClickListener) {
    print("11111");
    if (commentLoadingStatusList[index] == LoadingStatus.STATUS_COMPLETED) {
      // ignore: null_aware_before_operator
      if (value.commentList?.length >= value.commentCount + value.pullNumber) {
        commentListSubSettingList[index].isFold = !commentListSubSettingList[index].isFold;
        if (mounted) {
          setState(() {});
        }
      } else if (value.commentList.length >= value.commentCount + value.pullNumber && isOnClickListener) {
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
        _getSubComment(
            value.id, value.commentList?.length, value.commentCount, value.pullNumber, index, isOnClickListener);
      }
    }
  }

  //获取子评论
  _getSubComment(
      int targetId, int replyLength, int replyCount, int pullNumber, int positionComment, bool isOnClick) async {
    int subCommentPageSize = 3;
    if (replyLength == 0) {
      subCommentLastIdHot["$targetId"] = null;
    }
    int lastId = subCommentLastIdHot["$targetId"];
    print("刚开始加载子评论");
    if (replyLength > 0 && lastId == null && widget.evaluateList[positionComment].pullNumber <= 0) {
      print(
          "有数量，但是null为空，表示没有数据了---lastId${lastId == null}----replyLength${replyLength > 0}---isHotOrTime${widget.evaluateList[positionComment].pullNumber <= 0}");
      commentLoadingStatusList[positionComment] = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    try {
      print("加载子评论---targetId:$targetId, lastId:$lastId, subCommentPageSize:$subCommentPageSize");
      print("ids:${widget.evaluateList[positionComment].screenOutIds.toString()}");
      Map<String, dynamic> model = await queryListByHot2(
          targetId: targetId,
          targetType: 5,
          lastId: lastId,
          ids: widget.evaluateList[positionComment].screenOutIds.toString(),
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
          commentDtoModelList.addAll(commentModel.list.reversed.toList());
          commentModel.list.forEach((element) {
            print('==================获取到的model的id===========${element.id}');
          });
          print("获取到了length:${commentDtoModelList.length}条数据， commentModel.lastId：${commentModel.lastId}");
          subCommentLastIdHot["$targetId"] = commentModel.lastId;

          for (CommentDtoModel dtoModel in commentDtoModelList) {
            dtoModel.isHaveAnimation = isOnClick ? true : false;
          }

          if (widget.evaluateList[positionComment].commentList != null) {
            commentDtoModelList.addAll(widget.evaluateList[positionComment].commentList);
          }
          widget.evaluateList[positionComment].commentList = commentDtoModelList;
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

  onRefresh() async {
    DataResponseModel dataResponseModel = await getEvaluateList(widget.activityModel.id, size: 20);
    if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
      widget.evaluateList.clear();
      dataResponseModel.list.forEach((element) {
        widget.evaluateList.add(ActivityEvaluateModel.fromJson(element));
      });
      evaluateLastTime = dataResponseModel.lastTime;
    }
    widget.evaluateList.forEach((element) {
      element.commentList?.clear();
    });
    if (widget.refreshController != null) {
      widget.refreshController.refreshCompleted();
    }
    setState(() {});
  }

  onLoading() async {
    DataResponseModel dataResponseModel =
        await getEvaluateList(widget.activityModel.id, size: 20, lastTime: evaluateLastTime);
    if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
      dataResponseModel.list.forEach((element) {
        widget.evaluateList.add(ActivityEvaluateModel.fromJson(element));
      });
    }
    if (widget.refreshController != null) {
      widget.refreshController.loadComplete();
    }
    setState(() {});
  }

  bool isOfflineBool = false;

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (isOfflineBool) {
        isOfflineBool = false;
      }
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (isOfflineBool) {
        isOfflineBool = false;
      }
      return false;
    } else {
      isOfflineBool = true;
      return true;
    }
  }

  //输入框评论点击事件
  onPostComment(int targetId, int replyId, int replyCommentId, {String hintText}) async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return false;
    }
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "请先登录app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    this.targetId = targetId;
    this.targetType = 5;
    this.replyId = replyId;
    this.replyCommentId = replyCommentId;
    openInputBottomSheet(
      buildContext: this.context,
      hintText: hintText,
      voidCallback: _publishComment,
      isShowAt: false,
    );
  }

  //发布评论
  _publishComment(String text, List<Rule> rules) async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
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
        if (baseResponseModel == null) {
          ToastShow.show(msg: "发布失败", context: context);
          return;
        }
        if (baseResponseModel.code == CODE_BLACKED) {
          ToastShow.show(msg: baseResponseModel.message, context: context, gravity: Toast.CENTER);
        } else if (baseResponseModel.code == CODE_NO_DATA) {
          ToastShow.show(msg: baseResponseModel.message, context: context, gravity: Toast.CENTER);
        } else {
          if (baseResponseModel.data != null) {
            CommentDtoModel model;
            model = (CommentDtoModel.fromJson(baseResponseModel.data));
            for (int i = 0; i < widget.evaluateList.length; i++) {
              if (widget.evaluateList[i].id == targetId) {
                widget.evaluateList[i].commentList.add(model);
                widget.evaluateList[i].screenOutIds.add(model.id);
                widget.evaluateList[i].pullNumber++;
                commentListSubSettingList[i].isFold = false;
                commentListSubSettingList[i].subCommentAllHeight = null;
              }
            }
            ToastShow.show(msg: "发布成功", context: context);
            if (mounted) {
              setState(() {});
              //todo 动画
              // startAnimationScroll(targetId);
            }
          } else {
            ToastShow.show(msg: "发布失败", context: context);
          }
        }
      },
    );
  }

  //点赞-取消点赞
  _laudComment(int commentId, bool laud, int chatUserId, CommentDtoModel dto) async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      isLaudCommentLoading = false;
      return;
    }
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "请先登录app!", context: context);
      AppRouter.navigateToLoginPage(context);
      isLaudCommentLoading = false;
      return;
    }

    BlackModel blackModel = await ProfileCheckBlack(chatUserId);
    String text = "";
    if (blackModel.inYouBlack == 1) {
      text = "发布失败，你已将对方加入黑名单";
      ToastShow.show(msg: text, context: context);
      isLaudCommentLoading = false;
      return;
    } else if (blackModel.inThisBlack == 1) {
      text = "发布失败，你已被对方加入黑名单";
      ToastShow.show(msg: text, context: context);
      isLaudCommentLoading = false;
      return;
    }

    int code = await laudComment(commentId: commentId, laud: laud ? 1 : 0);
    if (code != null && code == 200) {
      laud ? dto.laudCount++ : dto.laudCount--;
      dto.isLaud = laud ? 1 : 0;

      if (laud) {
        print("点赞成功:laud:$laud,commentId:$commentId");
      } else {
        print("取消点赞成功:laud:$laud,commentId:$commentId");
      }
      if (mounted) {
        setState(() {
          isLaudCommentLoading = false;
        });
      }
    } else {
      if (laud) {
        print("点赞失败:laud:$laud,commentId:$commentId");
      } else {
        print("取消点赞失败:laud:$laud,commentId:$commentId");
      }
      isLaudCommentLoading = false;
    }
  }

  //删除评论
  _deleteComment(int commentId, CommentDtoModel commentDtoModel) async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return false;
    }
    Map<String, dynamic> model = await deleteComment(commentId: commentId);
    print(model);
    if (model != null && model["state"] == true) {
      _deleteCommentData(commentId);

      ///TODO 这里是修改的删除评论的eventbus
      EventBus.getDefault().post(msg: commentId, registerName: EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT);

      ToastShow.show(msg: "已删除", context: context);
      setState(() {});
    } else {
      ToastShow.show(msg: "删除失败!", context: context);
    }
  }

  _deleteCommentData(int commentId) {
    for (int i = 0; i < widget.evaluateList.length; i++) {
      for (int j = 0; j < widget.evaluateList[i].commentList.length; j++) {
        if (widget.evaluateList[i].commentList[i].id == commentId) {
          widget.evaluateList[i].commentList.removeAt(i);
          widget.evaluateList[i].commentCount--;
          break;
        }
      }
    }
  }

  //举报评论
  _profileMoreDenounce(int targetId, {int targetType = 2}) async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return false;
    }
    bool isSucess = await ProfileMoreDenounce(targetId, targetType);
    print("举报：isSucess:$isSucess");
    if (isSucess != null && isSucess) {
      ToastShow.show(msg: "感谢你的反馈,我们会尽快处理!", context: context);
    }
  }
}
