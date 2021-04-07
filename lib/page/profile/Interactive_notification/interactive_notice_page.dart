import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/query_msglist_model.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import '../../../widget/overscroll_behavior.dart';

///消息提醒列表
class InteractiveNoticePage extends StatefulWidget {
  int type;

  InteractiveNoticePage({this.type});

  @override
  State<StatefulWidget> createState() {
    return _InteractiveNoticeState();
  }
}

class _InteractiveNoticeState extends State<InteractiveNoticePage> {
  RefreshController controller = RefreshController();
  int lastTime;
  int listPage = 1;
  List<QueryModel> msgList = [];
  bool haveData = false;
  String hintText;
  int timeStamp;
  ScrollController scrollController  = ScrollController();
  String footerText = "没有更多了";
  StreamController<List<QueryModel>> streamController = StreamController<List<QueryModel>>();

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
        controller.refreshFailed();
      }
    } else if (listPage > 1 && lastTime != null) {
      if (model != null && model.list != null) {
        lastTime = model.lastTime;
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
  void initState() {
    hintText = "这里什么都没有呢";
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    EventBus.getDefault().registerSingleParameter(_commentOrFeedDetailCallBack, EVENTBUS_INTERACTIVE_NOTICE_PAGE,
        registerName: EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT);
    super.initState();
    _getMsgList(widget.type);
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox renderBox = refreshFooterKey.currentContext.findRenderObject();
      var offset =  renderBox.localToGlobal(Offset.zero);
      if(offset.dy>ScreenUtil.instance.height){
        showFooter  = true;
        setState(() {
        });
      }
    });*/
  }

  _commentOrFeedDetailCallBack(int deleteId) {
    List<QueryModel> list = [];
    for (int i = 0; i < msgList.length; i++) {
      if (msgList[i].refType == 0 && msgList[i].refId != deleteId.toString()) {
        list.add(msgList[i]);
      } else if (msgList[i].refType == 2) {
        if (msgList[i].refData != null) {
          CommentDtoModel fatherComment = CommentDtoModel.fromJson(msgList[i].refData);
          if (fatherComment.targetId != deleteId && fatherComment.id != deleteId) {
            list.add(msgList[i]);
          }
        }
      }
    }
    msgList.clear();
    msgList.addAll(list);
    streamController.sink.add(msgList);
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, timeStamp);
        return false;
      },
      child: StreamBuilder<List<QueryModel>>(
          initialData: msgList,
          stream: streamController.stream,
          builder: (BuildContext stramContext, AsyncSnapshot<List<QueryModel>> snapshot) {
            return Scaffold(
              backgroundColor: AppColor.white,
              appBar: CustomAppBar(
                leadingOnTap: () {
                  Navigator.pop(context, timeStamp);
                },
                titleString: widget.type == 0
                    ? "评论"
                    : widget.type == 1
                        ? "@我"
                        : "点赞",
              ),
              body: Container(
                width: width,
                height: height,
                child: snapshot.data.isNotEmpty
                    ? ScrollConfiguration(
                        behavior: OverScrollBehavior(),
                        child: SmartRefresher(
                          controller: controller,
                          enablePullUp: true,
                          enablePullDown: true,
                          footer: CustomFooter(
                            onOffsetChange: (offset){
                              print('---------------onOffsetChange${offset}');
                                print('-----------------------scrollController${scrollController.offset}');
                                if(footerText!=""&&scrollController.offset>0&&offset>=scrollController.offset){
                                  print('---------------------------页面数据不够多,不展示文字');
                                  setState(() {
                                    footerText = "";
                                  });
                                }
                            },
                            builder: (BuildContext context, LoadStatus mode) {
                              Widget body;
                              if (mode == LoadStatus.loading) {
                                body = CircularProgressIndicator();
                              } else if (mode == LoadStatus.noMore) {
                                body = Text("$footerText");
                              } else if (mode == LoadStatus.failed) {
                                body = Text("加载错误,请重试");
                              } else {
                                body = Text(" ");
                              }
                              return Container(
                                child: Center(
                                  child: body,
                                ),
                              );
                            },
                          ),
                          header: SmartRefresherHeadFooter.init().getHeader(),
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true, //解决无限高度问题
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return InteractiveNoticeItem(
                                  type: widget.type,
                                  msgModel: snapshot.data[index],
                                  index: index,
                                );
                              }),
                        ))
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: height * 0.22,
                            ),
                            Container(
                              height: width * 0.59,
                              width: width * 0.59,
                              color: AppColor.bgWhite,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "这里什么都没有呢",
                              style: AppStyle.textPrimary3Regular14,
                            )
                          ],
                        ),
                      ),
              ),
            );
          }),
    );
  }
}

class InteractiveNoticeItem extends StatefulWidget {
  int type;
  QueryModel msgModel;
  bool isFrist = true;
  int index;
  GlobalKey globalKey;
  InteractiveNoticeItem({this.type, this.msgModel, this.index,this.globalKey});

  @override
  State<StatefulWidget> createState() {
    return InteractiveNoticeItemState();
  }
}

class InteractiveNoticeItemState extends State<InteractiveNoticeItem> {
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
  LiveVideoModel liveVideoModel;
  List<AtUsersModel> atUserList = [];
  String coverImage;
  bool feedIsDelete = false;
  bool commentIsDelete = false;
  String commentState;
  CommentDtoModel feedData;

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
      if (widget.msgModel.refType == 0) {
        feedModel = HomeFeedModel.fromJson(widget.msgModel.refData);
      } else if (widget.msgModel.refType == 2) {
        fatherCommentModel = CommentDtoModel.fromJson(widget.msgModel.refData);
      } else if (widget.msgModel.refType == 1 || widget.msgModel.refType == 3) {
        liveVideoModel = LiveVideoModel.fromJson(widget.msgModel.refData);
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
      textSpanList.addAll(StringUtil.setHighlightTextSpan(context, comment,atUsers: atUserList));
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
    coverImage = widget.msgModel.coverUrl;
    _getRefData(context);
    if (widget.type == 0 && widget.msgModel.commentData != null) {
      if (widget.msgModel.refType == 2) {
        commentState = "回复了 ${widget.msgModel.commentData.replyName}: ";
      } else {
        commentState = "";
      }

      ///判断文字的高度，动态改变
      TextPainter testSize = calculateTextWidth(
          "$commentState$comment", AppStyle.textRegular14, ScreenUtil.instance.screenWidthDp * 0.64, 3);
      textHeight = testSize.height;
    } else {
      TextPainter testSize =
          calculateTextWidth("$comment", AppStyle.textRegular14, ScreenUtil.instance.screenWidthDp * 0.64, 3);
      textHeight = testSize.height;
    }
    return Container(
      key: widget.globalKey,
      width: ScreenUtil.instance.screenWidthDp,
      height: 59.5 + textHeight + 16,
      color: AppColor.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              AppRouter.navigateToMineDetail(context, widget.msgModel.senderId);
            },
            child: Container(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        height: 38,
                        width: 38,
                        imageUrl: senderAvatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
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
          Spacer(),
          InkWell(
            onTap: () {
              _jumpToDetailPage(context);
            },
            child: Container(
              alignment: Alignment.centerLeft,
              width: ScreenUtil.instance.screenWidthDp * 0.64,
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
                  // MyRichTextWidget(
                  //         Text(
                  //           "$comment",
                  //           style: AppStyle.textRegular13,
                  //         ),
                  //         maxLines: 3,
                  //         textOverflow: TextOverflow.ellipsis,
                  //         richTexts: _atText(context),
                  //         headText: commentState,
                  //         headStyle: AppStyle.textMedium13,
                  //       )
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
          Spacer(),
          !feedIsDelete
              ? InkWell(
                  onTap: () {
                    print('========================点击了${widget.msgModel.refId}');
                    _jumpToDetailPage(context);
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    child: ClipRect(
                      child: CachedNetworkImage(
                        height: 38,
                        width: 38,
                        imageUrl: coverImage != null ? coverImage : "",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
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
        getFeedDetail(context, feedModel.id, comment: widget.msgModel.commentData);
      } else if (widget.msgModel.refType == 2) {
        if (fatherCommentModel.type == 0) {
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
    Map<String, dynamic> commentModel =
        await queryListByHot2(targetId: targetId, targetType: targetType, lastId: null, size: 15);
    if (commentModel != null && widget.msgModel.commentData != null) {
      context.read<FeedMapNotifier>().interacticeNoticeChange(
          courseCommentHots: CommentModel.fromJson(commentModel), commentId: widget.msgModel.commentData.id);
    }
  }

  getFeedDetail(BuildContext context, int feedId, {CommentDtoModel comment, CommentDtoModel fatherModel}) async {
    BaseResponseModel feedModel = await feedDetail(id: feedId);
    if (feedModel.data != null) {
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
