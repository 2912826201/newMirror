import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/query_msglist_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
///消息提醒列表
class InteractiveNoticePage extends StatefulWidget {
  int type;

  InteractiveNoticePage({this.type});

  @override
  State<StatefulWidget> createState() {
    return _interactiveNoticeState();
  }
}

class _interactiveNoticeState extends State<InteractiveNoticePage> {
  RefreshController controller = RefreshController();
  int lastTime;
  int listPage = 1;
  List<QueryModel> msgList = [];
  bool haveData = true;

  ///获取互动通知列表
  _getMsgList(int type) async {
    if (listPage > 1 && lastTime == null) {
      controller.loadNoData();
      return;
    }
    QueryListModel model = await queryMsgList(type, 20, lastTime);
    setState(() {
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
    });
    print('msglist.length========================${msgList.length}');
  }

  _refreashUnReadMsg({int id})async{
    var state = await refreashUnReadMsg(widget.type,msgIds:id);
    if(state!=null){
      if(state){
        print('============================已读成功');
      }else{
        print('============================已读失败');
      }
    }
  }

  //刷新
  __onRefresh() {
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
    super.initState();
    _getMsgList(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
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
            _refreashUnReadMsg();
            Navigator.pop(context);
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
                onRefresh: __onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                    shrinkWrap: true, //解决无限高度问题
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: msgList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){

                        },
                        child: InteractiveNoticeItem(widget.type, msgList[index]));
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
    );
  }
}

class InteractiveNoticeItem extends StatefulWidget {
  int type = 1;
  QueryModel model;

  InteractiveNoticeItem(this.type, this.model);

  @override
  State<StatefulWidget> createState() {
    return _interactiveNoticeItemState();
  }
}

class _interactiveNoticeItemState extends State<InteractiveNoticeItem> {
  //评论内容：@和评论拿接口内容，点赞给固定内容
  String comment = "";

  //文字的高度
  double textHeight;

  //评论状态
  String noticeState = "";
  String receiverName = "";

  String senderName;
  String senderAvatarUrl;
  QueryModel msgModel;
  int index;
  CommentDtoModel commentModel;
  List<AtUsersModel> atUserList = [];
  String coverImage;
  bool feedIsDelete = false;
  bool commentIsDelete = false;
  String commentState;
  @override
  void initState() {
    super.initState();
    msgModel = widget.model;
    senderAvatarUrl = msgModel.senderAvatarUrl;
    senderName = msgModel.senderName;
    commentModel = msgModel.commentData;
    coverImage = msgModel.coverUrl;
    if(widget.type==0){
      if(msgModel.refType==2){
        commentState = "回复了  ";
      }else{
        commentState = "";
      }
    }
    _textSpanAdd();
  }

  List<BaseRichText> _atText() {
    List<BaseRichText> richList = [];
    atUserList.forEach((element) {
      richList.add(BaseRichText(
        comment.substring(element.index, element.len),
        style: widget.type == 0 ? AppStyle.textMedium13 : AppStyle.textMediumBlue13,
        onTap: () {},
      ));
    });
    return richList;
  }

  _textSpanAdd() {
    if (widget.type == 0 || widget.type == 1) {
      if(commentModel.content==null){
        commentIsDelete = true;
      }else{
        commentIsDelete = false;
        comment = commentModel.content;
      }
      atUserList = commentModel.atUsers;
    } else {
      if (msgModel.refType == 0) {
        comment = "赞了你的动态";
      } else if (msgModel.refType == 1) {
        comment = "赞了你的课程";
      } else if (msgModel.refType == 2) {
        comment = "赞了你的评论";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 0) {
      ///判断文字的高度，动态改变
      TextPainter testSize = calculateTextWidth(
          "$commentState$comment", AppStyle.textRegular13, ScreenUtil.instance.screenWidthDp * 0.64, 3);
      textHeight = testSize.height;
      print('textHeight==============================$textHeight');
    } else {
      TextPainter testSize =
          calculateTextWidth("$comment", AppStyle.textRegular13, ScreenUtil.instance.screenWidthDp * 0.64, 3);
      textHeight = testSize.height;
      print('textHeight==============================$textHeight');
    }
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      height: 59.5 + textHeight + 16,
      color: AppColor.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
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
              )),
          Spacer(),
          Container(
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
                !commentIsDelete?MyRichTextWidget(
                  Text(
                    "$comment",
                    style: AppStyle.textRegular13,
                  ),
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                  richTexts: _atText(),
                  headText: commentState,
                  headStyle: AppStyle.textMedium13,
                ):Text("该评论已删除",style:AppStyle.textHintRegular13,),
                SizedBox(
                  height: 7,
                ),
                Text(
                  DateUtil.generateFormatDate(msgModel.createTime),
                  style: AppStyle.textHintRegular12,
                )
              ],
            ),
          ),
          Spacer(),
          !feedIsDelete
              ? Container(
                  alignment: Alignment.topRight,
                  child: ClipRect(
                    child: CachedNetworkImage(
                      height: 38,
                      width: 38,
                      imageUrl: coverImage!=null?coverImage:"",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        "images/test.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 38,
                  width: 38,
                  color: AppColor.bgWhite,
                  child: Center(
                    child: Text(
                      "已删除",
                      style: AppStyle.textHintRegular10,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}