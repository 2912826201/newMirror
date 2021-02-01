
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/query_msglist_model.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

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
  bool haveData = true;

  int timeStamp;

  ///获取互动通知列表
  _getMsgList(int type) async {
    if (listPage > 1 && lastTime == null) {
      controller.loadNoData();
      return;
    }
    QueryListModel model = await queryMsgList(type, 20, lastTime);

      if (listPage == 1) {
        if (model.list != null) {
          haveData = true;
          msgList.clear();
          controller.loadComplete();
          lastTime = model.lastTime;
          model.list.forEach((element) {
            msgList.add(element);
          });
          controller.refreshCompleted();
        } else {
          haveData = false;
          controller.resetNoData();
        }
      } else if (listPage > 1 && lastTime != null) {
        if (model.list != null) {
          lastTime = model.lastTime;
          model.list.forEach((element) {
            msgList.add(element);
          });
          controller.loadComplete();
        } else {
          controller.loadNoData();
        }
      }
      if(mounted) {
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
    _getMsgList(widget.type);
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
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    super.initState();
    _getMsgList(widget.type);
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
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.white,
          leading: InkWell(
            child: Container(
              margin: EdgeInsets.only(left: 16),
              child: Image.asset("images/resource/2.0x/return2x.png"),
            ),
            onTap: () {
              Navigator.pop(context, timeStamp);
            },
          ),
          leadingWidth: 44,
          title: Text(
            widget.type == 0
                ? "评论"
                : widget.type == 1
                    ? "@我"
                    : "点赞",
            style: AppStyle.textMedium18,
          ),
        ),
        body: Container(
          width: width,
          height: height,
          child: haveData
              ? SmartRefresher(
                  controller: controller,
                  enablePullUp: true,
                  enablePullDown: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.loading) {
                        body = CircularProgressIndicator();
                      } else if (mode == LoadStatus.noMore) {
                        body = Text("没有更多了");
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
                  header: WaterDropHeader(
                    complete: Text("刷新完成"),
                    failed: Text(" "),
                  ),
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView.builder(
                      shrinkWrap: true, //解决无限高度问题
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: msgList.length,
                      itemBuilder: (context, index) {
                        return InkWell(onTap: () {}, child: InteractiveNoticeItemState(widget.type, msgList[index]));
                      }),
                )
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
                        "没有找到你要的东西",
                        style: AppStyle.textPrimary3Regular14,
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class InteractiveNoticeItemState extends StatelessWidget {
  int type;
  QueryModel msgModel;

  InteractiveNoticeItemState(this.type, this.msgModel);

  //评论内容：@和评论拿接口内容，点赞给固定内容
  String comment = "";

  //文字的高度
  double textHeight;

  //评论状态
  String noticeState = "";

  String receiverName = "";

  String senderName;
  String senderAvatarUrl;
  int index;
  CommentDtoModel fatherCommentModel;
  HomeFeedModel feedModel;
  LiveVideoModel liveVideoModel;
  List<AtUsersModel> atUserList = [];
  String coverImage;
  bool feedIsDelete = false;
  bool commentIsDelete = false;
  String commentState;

  _getRefData(BuildContext context){
    if (type == 0 || type == 1) {
      atUserList = msgModel.commentData.atUsers;
      if(msgModel.commentData==null){
        commentIsDelete = true;
      }else{
        comment = msgModel.commentData.content;
      }
    } else {
      if (msgModel.refType == 0) {
        comment = "赞了你的动态";
      } else if (msgModel.refType == 1) {
        comment = "赞了你的课程";
      } else if (msgModel.refType == 2) {
        comment = "赞了你的评论";
      }
    }
    if(msgModel.refData==null){
      feedIsDelete = true;
    }
    if(msgModel.refType==0){
      feedModel = HomeFeedModel.fromJson(msgModel.refData);
    } else if(msgModel.refType == 2){
     fatherCommentModel = CommentDtoModel.fromJson(msgModel.refData);
   }else if(msgModel.refType==1||msgModel.refType==3){
      liveVideoModel = LiveVideoModel.fromJson(msgModel.refData);
    }
  }

  List<BaseRichText> _atText(BuildContext context) {
    List<BaseRichText> richList = [];
    atUserList.forEach((element) {
      richList.add(BaseRichText(
        comment.substring(element.index, element.len),
        style: type == 0 ? AppStyle.textMedium13 : AppStyle.textMediumBlue13,
        onTap: () {
          AppRouter.navigateToMineDetail(context, element.uid);
        },
      ));
    });
    return richList;
  }

  @override
  Widget build(BuildContext context) {
    print('-====================消息互动列表页Item  biuld');
    senderAvatarUrl = msgModel.senderAvatarUrl;
    senderName = msgModel.senderName;
    if(type==0){
      msgModel.commentData.name = senderName;
      msgModel.commentData.replyName = context.watch<ProfileNotifier>().profile.nickName;
    }
    coverImage = msgModel.coverUrl;
    _getRefData(context);
    if (type == 0) {
      if (msgModel.refType == 2) {
        commentState = "回复了  ";
      } else {
        commentState = "";
      }
      ///判断文字的高度，动态改变
      TextPainter testSize = calculateTextWidth(
          "$commentState$comment", AppStyle.textRegular13, ScreenUtil.instance.screenWidthDp * 0.64, 3);
      textHeight = testSize.height;
    } else {
      TextPainter testSize =
          calculateTextWidth("$comment", AppStyle.textRegular13, ScreenUtil.instance.screenWidthDp * 0.64, 3);
      textHeight = testSize.height;
    }
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      height: 59.5 + textHeight + 16,
      color: AppColor.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              AppRouter.navigateToMineDetail(context, msgModel.senderId);
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
                  msgModel.isRead == 0
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
              )),),
          Spacer(),
          InkWell(
            onTap: (){
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
                    ? MyRichTextWidget(
                        Text(
                          "$comment",
                          style: AppStyle.textRegular13,
                        ),
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                        richTexts: _atText(context),
                        headText: commentState,
                        headStyle: AppStyle.textMedium13,
                      )
                    : Text(
                        "该评论已删除",
                        style: AppStyle.textHintRegular13,
                      ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  DateUtil.generateFormatDate(msgModel.createTime),
                  style: AppStyle.textHintRegular12,
                )
              ],
            ),
          ),),
          Spacer(),
          !feedIsDelete
              ? InkWell(
                  onTap: () {
                    print('========================点击了${msgModel.refId}');
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
  _jumpToDetailPage(BuildContext context){
    if (msgModel.refType == 0) {
      print('=====================动态');
      getFeedDetail(context,feedModel.id, comment:type==0?msgModel.commentData:null);
    }else if(msgModel.refType == 2){
      if(fatherCommentModel.type==0){
        getFeedDetail(context, fatherCommentModel.targetId, comment: type==0?msgModel.commentData:null,fatherModel: fatherCommentModel);
      }else if(fatherCommentModel.type==1){
        AppRouter.navigateToLiveDetail(context, fatherCommentModel.targetId,isHaveStartTime: false,commentDtoModel:
        type==0?msgModel.commentData:null,fatherComment: fatherCommentModel);
      }else if(fatherCommentModel.type==3){
        AppRouter.navigateToVideoDetail(context, fatherCommentModel.targetId,commentDtoModel:
        type==0?msgModel.commentData:null,fatherComment: fatherCommentModel);
      }
    }else if(msgModel.refType==1){
      AppRouter.navigateToLiveDetail(context, liveVideoModel.id,isHaveStartTime: false,commentDtoModel:
      msgModel.commentData);
    }else{
      AppRouter.navigateToVideoDetail(context, liveVideoModel.id,commentDtoModel:
      msgModel.commentData);
    }
  }
  getFeedDetail(BuildContext context, int feedId, {CommentDtoModel comment,CommentDtoModel fatherModel}) async {
    HomeFeedModel feedModel = await feedDetail(id: feedId);
    List<HomeFeedModel> list = [];
    list.add(feedModel);
    context.read<FeedMapNotifier>().updateFeedMap(list);
    // print("----------feedModel:${feedModel.toJson().toString()}");
    // 跳转动态详情页
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => FeedDetailPage(
                model: feedModel,
                comment: comment,
                type: 2,
                fatherModel: fatherModel,
              )),
    );
  }
}
