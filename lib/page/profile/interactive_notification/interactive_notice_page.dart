import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/query_msglist_model.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/route/router.dart';

import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/overscroll_behavior.dart';
import '../profile_detail_page.dart';

///消息提醒列表
class InteractiveNoticePage extends StatefulWidget {
  int type;

  InteractiveNoticePage({this.type});

  @override
  _InteractiveNoticeState createState() {
    return _InteractiveNoticeState();
  }
}

class _InteractiveNoticeState extends State<InteractiveNoticePage> {
  RefreshController controller = RefreshController(initialRefresh: true);
  int lastTime;
  int listPage = 1;
  List<QueryModel> msgList = [];
  bool haveData = false;
  String hintText;
  int hasNext = 0;
  bool fristRequestIsOver = false;
  String defaultImage = DefaultImage.nodata;
  ScrollController scrollController = ScrollController();
  StreamController<List<QueryModel>> streamController = StreamController<List<QueryModel>>();

  GlobalKey globalKey = GlobalKey();
  bool showNoMore = true;

  ///获取互动通知列表
  _getMsgList(int type, {bool isRefreash = false}) async {
    if (listPage > 1 && lastTime == null) {
      controller.loadNoData();
      return;
    }
    QueryListModel model = await queryMsgList(type, 20, lastTime);
    if (listPage == 1) {
      controller.loadComplete();
      if (model != null) {
        MessageManager.unreadNoticeTimeStamp = DateTime.now().millisecondsSinceEpoch;
        hasNext = model.hasNext;
        lastTime = model.lastTime;
        msgList.clear();
        if (model.list != null) {
          haveData = true;
          model.list.forEach((element) {
            if (isRefreash) {
              element.isRead = 1;
            }
            msgList.add(element);
          });
        }
        controller.refreshCompleted();
      } else {
        haveData = false;
        hintText = "内容君在来的路上出了点状况...";
        defaultImage = DefaultImage.error;
        controller.refreshCompleted();
      }
      fristRequestIsOver = true;
    } else if (listPage > 1 && lastTime != null) {
      if (model != null && model.list != null) {
        lastTime = model.lastTime;
        hasNext = model.hasNext;
        model.list.forEach((element) {
          msgList.add(element);
        });
        controller.loadComplete();
      } else {
        controller.loadNoData();
      }
    }
    if (mounted) {
      setState(() {});
    }
    print('msglist.length========================${msgList.length}');
  }

  //刷新
  _onRefresh() {
    setState(() {
      listPage = 1;
      lastTime = null;
    });
    _getMsgList(widget.type, isRefreash: true);
  }

  //加载
  _onLoading() {
    setState(() {
      listPage += 1;
    });
    _getMsgList(widget.type);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void initState() {
    hintText = "这里什么都没有呢";
    EventBus.getDefault().registerSingleParameter(_commentOrFeedDetailCallBack, EVENTBUS_INTERACTIVE_NOTICE_PAGE,
        registerName: EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT);
    super.initState();
  }

  _commentOrFeedDetailCallBack(int deleteId) {
    msgList.removeWhere((element) {
      if (element.refType == 0 && element.refId == deleteId.toString()) {
        return;
      } else if (element.refType == 2) {
        if (element.refData != null) {
          CommentDtoModel fatherComment = CommentDtoModel.fromJson(element.refData);
          if (fatherComment.targetId != deleteId && fatherComment.id != deleteId) {
            return;
          }
        }
      }
      return;
    });
    if (msgList.length == 0 && hasNext == 0) {
      controller.requestRefresh();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        backgroundColor: AppColor.mainBlack,
        appBar: CustomAppBar(
          leadingOnTap: () {
            Navigator.pop(context);
          },
          titleString: widget.type == 0
              ? "评论"
              : widget.type == 1
                  ? "@我"
                  : "点赞",
        ),
        body: ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: /*SizeCacheWidget(
              estimateCount: 20,
                child:*/ SmartRefresher(
                    controller: controller,
                    enablePullUp: true,
                    enablePullDown: true,
                    footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: showNoMore),
                    header: SmartRefresherHeadFooter.init().getHeader(),
                    onRefresh: _onRefresh,
                    onLoading: () {
                      if (msgList.isNotEmpty) {
                        setState(() {
                          try{
                            showNoMore = IntegerUtil.showNoMore(globalKey, lastItemToTop: true);
                          }catch(e){
                            print(' onLoading:erorr::::::$e');
                          }
                        });
                      }
                      _onLoading();
                    },
                    child: msgList != null && msgList.isNotEmpty
                        ? ListView.builder(
                            controller: PrimaryScrollController.of(context),
                            shrinkWrap: true,
                            //解决无限高度问题
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: msgList.length,
                            itemBuilder: (context, index) {
                              return /*FrameSeparateWidget(
                                index: index,
                                placeHolder: Container(
                                  height: 85,
                                  width: width,
                                  color: AppColor.white,
                                ),
                                child:*/InteractiveNoticeItem(
                                  type: widget.type,
                                  msgModel: msgList[index],
                                  index: index,
                                  globalKey: index == msgList.length - 1 ? globalKey : null,
                                )/*,
                              )*/;
                            })
                        : fristRequestIsOver
                            ? Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: height * 0.22,
                                    ),
                                    Container(
                                      width: 285,
                                      height: 285,
                                      child: Image.asset(defaultImage),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      hintText,
                                      style: AppStyle.textPrimary3Regular14,
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                height: height,
                                width: width,
                                color: AppColor.white,
                              )))/*)*/);
  }
}

class InteractiveNoticeItem extends StatefulWidget {
  int type;
  QueryModel msgModel;
  bool isFrist = true;
  int index;

  GlobalKey globalKey;

  InteractiveNoticeItem({this.type, this.msgModel, this.index, this.globalKey});

  @override
  InteractiveNoticeItemState createState() {
    return InteractiveNoticeItemState();
  }
}

class InteractiveNoticeItemState extends State<InteractiveNoticeItem> {
  final double avatarWidth = 38;

  final double imageWidth = 38;

  double contentWidth;

  //评论内容：@和评论拿接口内容，点赞给固定内容
  String comment = "";

  //文字的高度
  double textHeight;

  //评论状态
  String noticeState = "";

  String receiverName = "";

  String senderName;
  String senderAvatarUrl;
  CommentDtoModel fatherCommentModel;
  HomeFeedModel feedModel;
  CourseModel liveVideoModel;
  List<AtUsersModel> atUserList = [];
  String coverImage;
  bool feedIsDelete = false;
  bool commentIsDelete = false;
  String commentState;
  CommentDtoModel feedData;
  bool requestOver = true;

  _getRefData(BuildContext context) {
    print('=======================${widget.msgModel.refType}');
    if (widget.type == 0) {
      if (widget.msgModel.commentData == null) {
        commentIsDelete = true;
      } else {
        atUserList = widget.msgModel.commentData.atUsers;
        comment = widget.msgModel.commentData.content;
      }
    } else if (widget.type == 2) {
      if (widget.msgModel.commentData != null) {
        comment = "赞了你的评论";
      } else {
        comment = "赞了你的动态";
      }
    } else {
      if (widget.msgModel.commentData != null) {
        atUserList = widget.msgModel.commentData.atUsers;
        comment = widget.msgModel.commentData.content;
      } else if (widget.msgModel.refData != null) {
        atUserList = HomeFeedModel.fromJson(widget.msgModel.refData).atUsers;
        comment = HomeFeedModel.fromJson(widget.msgModel.refData).content;
      } else {
        commentIsDelete = true;
      }
    }
    if (widget.msgModel.refData != null) {
      print('-----------------------widget.msgModel.refData != null');
      if (widget.msgModel.refType == 0) {
        feedModel = HomeFeedModel.fromJson(widget.msgModel.refData);
        print('------------feedModel.');
      } else if (widget.msgModel.refType == 2) {
        fatherCommentModel = CommentDtoModel.fromJson(widget.msgModel.refData);
      } else if (widget.msgModel.refType == 1 || widget.msgModel.refType == 3) {
        liveVideoModel = CourseModel.fromJson(widget.msgModel.refData);
      }
      if (widget.isFrist) {
        widget.isFrist = false;
      }
    } else {
      feedIsDelete = true;
    }
  }

  List<TextSpan> _atText(BuildContext context) {
    var textSpanList = <TextSpan>[];
    if ((atUserList != null && atUserList.length > 0)) {
      try{
        textSpanList.addAll(StringUtil.setHighlightTextSpan(context, comment, atUsers: atUserList));
      }catch(e){
        print('------------------------------$e');
      }
    } else {
      textSpanList.add(TextSpan(
        text: comment,
        style: AppStyle.textRegular14,
      ));
    }
    return textSpanList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('===============================itemInit   index${widget.index}');
    contentWidth = ScreenUtil.instance.screenWidthDp - (avatarWidth + imageWidth + 32 + 27);
    Future.delayed(Duration.zero, () {
      if (widget.msgModel.refData != null) {
        if (widget.msgModel.refType == 0 || widget.msgModel.refType == 1 || widget.msgModel.refType == 3) {
          getCommentFristPage(int.parse(widget.msgModel.refId), widget.msgModel.refType);
        } else if (widget.msgModel.refType == 2 && CommentDtoModel.fromJson(widget.msgModel.refData) != null) {
          getCommentFristPage(CommentDtoModel.fromJson(widget.msgModel.refData).targetId,
              CommentDtoModel.fromJson(widget.msgModel.refData).type);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('-====================消息互动列表页Item  biuld');
    senderAvatarUrl = widget.msgModel.senderAvatarUrl;
    senderName = widget.msgModel.senderName;
    coverImage = widget.msgModel.coverUrl.coverUrl;
    print('-coverImage-------coverImage-----------coverImage-------$coverImage-----');
    _getRefData(context);
    if (widget.type == 0 && widget.msgModel.commentData != null) {
      if (widget.msgModel.refType == 2) {
        commentState = "回复了 ${widget.msgModel.commentData.replyName}: ";
      } else {
        commentState = "";
      }

      ///判断文字的高度，动态改变
      TextPainter testSize = calculateTextWidth("$commentState$comment", AppStyle.textRegular14, contentWidth);
      textHeight = testSize.height;
    } else {
      TextPainter testSize = calculateTextWidth("$comment", AppStyle.textRegular14, contentWidth);
      textHeight = testSize.height;
    }
    print('-----------------------textHeight---$textHeight');
    return Container(
      key: widget.globalKey != null ? widget.globalKey : null,
      width: ScreenUtil.instance.screenWidthDp,
      height: 59.5 + textHeight + 16,
      color: AppColor.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              jumpToUserProfilePage(context, widget.msgModel.senderId,
                  avatarUrl: widget.msgModel.senderAvatarUrl, userName: widget.msgModel.senderName);
            },
            child: Container(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        height: avatarWidth,
                        width: avatarWidth,
                        memCacheWidth: 150,
                        memCacheHeight: 150,
                        imageUrl: senderAvatarUrl != null ? FileUtil.getSmallImage(senderAvatarUrl) : " ",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColor.bgWhite,
                        ),
                      ),
                    ),
                    widget.msgModel.isRead == 0
                        ? Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                  color: AppColor.mainRed,
                                  borderRadius: BorderRadius.all(Radius.circular(18.5)),
                                  border: Border.all(width: 0.5, color: AppColor.white)),
                            ),
                          )
                        : Container()
                  ],
                )),
          ),
          SizedBox(
            width: 11,
          ),
          InkWell(
            onTap: () {
              _jumpToDetailPage(context);
            },
            child: Container(
              alignment: Alignment.centerLeft,
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$senderName",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.textMedium15,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  !commentIsDelete
                      ? RichText(text: TextSpan(children: _atText(context)))
                      : Text(
                          "该评论已删除",
                          style: AppStyle.textHintRegular13,
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    DateUtil.getCommentShowData(DateUtil.getDateTimeByMs(widget.msgModel.createTime)),
                    style: AppStyle.textHintRegular12,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          !feedIsDelete&&coverImage!=null
              ? InkWell(
                  onTap: () {
                    print('========================点击了${widget.msgModel.refId}');
                    _jumpToDetailPage(context);
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    child: ClipRect(
                      child: CachedNetworkImage(
                        height: imageWidth,
                        width: imageWidth,
                        imageUrl: coverImage != null ? FileUtil.getSmallImage(coverImage) : "",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColor.bgWhite,
                        ),
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    Toast.show("该内容已删除", context);
                  },

                  child: Container(
                    height: 38,
                    width: 38,
                    alignment: Alignment.topRight,
                    color: AppColor.bgWhite,
                    child: Center(
                      child: Text(
                        "已删除",
                        style: AppStyle.textHintRegular10,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  //跳转判断
  _jumpToDetailPage(BuildContext context) {
    if (feedIsDelete || commentIsDelete) {
      Toast.show("该内容已删除", context);
      return;
    }
    try {
      if (widget.msgModel.commentData != null &&
          context.read<FeedMapNotifier>().value.courseCommentHot[widget.msgModel.commentData.id].list != null) {
        context.read<FeedMapNotifier>().value.courseCommentHot[widget.msgModel.commentData.id].list.forEach((element) {
          if (element.replys.isNotEmpty) {
            element.replys.clear();
          }
        });
      }
      if (widget.msgModel.refType == 0 || (widget.type == 3 && widget.msgModel.commentData == null)) {
        if (!requestOver) {
          return;
        }
        requestOver = false;
        getFeedDetail(context, feedModel.id, comment: widget.msgModel.commentData);
      } else if (widget.msgModel.refType == 2) {
        if (fatherCommentModel.type == 0) {
          if (!requestOver) {
            return;
          }
          requestOver = false;
          getFeedDetail(context, fatherCommentModel.targetId,
              comment: widget.msgModel.commentData, fatherModel: fatherCommentModel);
        } else if (fatherCommentModel.type == 1) {
          AppRouter.navigateToLiveDetail(context, fatherCommentModel.targetId,
              isHaveStartTime: false,
              commentDtoModel: widget.msgModel.commentData,
              fatherComment: fatherCommentModel,
              isInteractiveIn: true);
        } else if (fatherCommentModel.type == 3) {
          AppRouter.navigateToVideoDetail(context, fatherCommentModel.targetId,
              commentDtoModel: widget.msgModel.commentData, fatherComment: fatherCommentModel, isInteractive: true);
        }
      } else if (widget.msgModel.refType == 1 && liveVideoModel != null && liveVideoModel.id != null) {
        AppRouter.navigateToLiveDetail(context, liveVideoModel.id,
            isHaveStartTime: false, commentDtoModel: widget.msgModel.commentData, isInteractiveIn: true);
      } else {
        if (liveVideoModel != null && liveVideoModel.id != null) {
          AppRouter.navigateToVideoDetail(context, liveVideoModel.id,
              commentDtoModel: widget.msgModel.commentData, isInteractive: true);
        }
      }
      widget.msgModel.isRead = 1;
      setState(() {});
    } catch (e) {
      print('==================$e');
    }
  }

  ///获取对应内容第一页评论
  getCommentFristPage(int targetId, int targetType) async {
    queryListByHot2(targetId: targetId, targetType: targetType, lastId: null, size: 15).then((commentModel) {
      if (commentModel != null && widget.msgModel.commentData != null) {
        context.read<FeedMapNotifier>().interacticeNoticeChange(
            courseCommentHots: CommentModel.fromJson(commentModel), commentId: widget.msgModel.commentData.id);
      }
    });
  }

  getFeedDetail(BuildContext context, int feedId, {CommentDtoModel comment, CommentDtoModel fatherModel}) async {
    BaseResponseModel feedModel = await feedDetail(id: feedId);
    requestOver = true;
    if (feedModel != null && feedModel.data != null) {
      List<HomeFeedModel> list = [];
      list.add(HomeFeedModel.fromJson(feedModel.data));
      context.read<FeedMapNotifier>().updateFeedMap(list);
    }
    // 跳转动态详情页
    if (feedModel.code == CODE_SUCCESS || feedModel.code == CODE_NO_DATA) {
      AppRouter.navigateFeedDetailPage(
        context: context,
        model: feedModel.data != null ? HomeFeedModel.fromJson(feedModel.data) : null,
        comment: comment,
        type: 2,
        fatherModel: fatherModel,
        errorCode: feedModel.code,
        isInteractive: true,
      );
    }
  }
}
