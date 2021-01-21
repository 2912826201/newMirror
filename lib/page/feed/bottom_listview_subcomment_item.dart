import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:provider/provider.dart';
class BottomListViewSubCommentListItem extends StatefulWidget{
  BottomListViewSubCommentListItem({this.model, this.subIndex, this.mainIndex, this.feedId, this.commentDtoModel,this.comment});
  CommentDtoModel comment;
  CommentDtoModel model;
  int subIndex;
  int mainIndex;
  int feedId;
  CommentDtoModel commentDtoModel;
  @override
  State<StatefulWidget> createState() {
    return BottomListViewSubCommentListItemState();
  }

}
class BottomListViewSubCommentListItemState extends State<BottomListViewSubCommentListItem> {
  CommentDtoModel model;
  int subIndex;
  int mainIndex;
  int feedId;
  CommentDtoModel commentDtoModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.model;
    subIndex = widget.subIndex;
    mainIndex = widget.mainIndex;
    commentDtoModel = widget.commentDtoModel;
    feedId = widget.feedId;
    if(widget.comment!=null){
      if(widget.comment.id==model.id){
        Future.delayed(Duration(milliseconds: 2000), () {
          try {
            model.itemChose = false;
            setState(() {
            });
          } catch (e) {
          }
        });
      }
    }

  }
  @override
  // 点赞
  setUpLuad(BuildContext context, int subIndex, CommentDtoModel models) async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否点赞了￥${context.read<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys[subIndex].isLaud}");
    if (isLoggedIn) {
      Map<String, dynamic> model = await laudComment(commentId: models.id, laud: models.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<FeedMapNotifier>().subCommentLaud(models.isLaud, feedId, mainIndex, subIndex);
      } else {
        // 失败
        print("shib ");
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        openInputBottomSheet(
          context: context,
          hintText: "回复 ${model.name}",
          voidCallback: (String text, List<Rule> rules, BuildContext context) {
            List<AtUsersModel> atListModel = [];
            for (Rule rule in rules) {
              AtUsersModel atModel;
              atModel.index = rule.startIndex;
              atModel.len = rule.endIndex;
              atModel.uid = rule.id;
              atListModel.add(atModel);
            }
            // 评论子评论
            postComments(
              targetId: commentDtoModel.id,
              targetType: 2,
              content: text,
              atUsers: jsonEncode(atListModel),
              replyId: model.uid,
              replyCommentId: model.id,
              commentModelCallback: (CommentDtoModel commentModel) {
                context.read<FeedMapNotifier>().commentFeedCom(feedId, mainIndex, commentModel);
                print("查看一下+++++++++++++++++++++");
                print(commentDtoModel.replys.toString());
                print(context.read<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys.toString());
                // 关闭评论输入框
                // Navigator.of(context).pop(1);
              });
          },
        );
      },
      child: AnimatedPhysicalModel(
        shape: BoxShape.rectangle,
        color: widget.model.itemChose ? AppColor.bgWhite: AppColor.white,
        elevation:0,
        shadowColor: !widget.model.itemChose ?AppColor.bgWhite: AppColor.white,
        duration: Duration(seconds: 1),
        child: Container(
          padding: EdgeInsets.only(left: 16,right: 16,top: 9,bottom: 8),
          child: Row(
            //   // 横轴距定对齐
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // child: Container(
              Container(
                height: 32,
                width: 32,
                child: ClipOval(
                  child: Image.network(
                    model.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 12, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MyRichTextWidget(
                        Text(
                          model.replyName != null
                            ? model.name + " 回复 " + model.replyName + " " + model.content
                            : model.name + " " + model.content,
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
                        ),
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                        richTexts: setBaseRichText(model),
                      ),
                      Container(height: 6),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Text(
                          "${DateUtil.generateFormatDate(model.createTime)} 回复",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  )),
              ),
              // 点赞
              GestureDetector(
                onTap: () {
                  setUpLuad(context, subIndex, model);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.favorite,
                      color:
                      context.watch<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys[subIndex].isLaud == 0
                        ? Colors.grey
                        : Colors.red,
                    ),
                    Container(
                      height: 4,
                    ),
                    Offstage(
                      offstage:
                      context.watch<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys[subIndex].laudCount ==
                        0,
                      child: Text(
                        "${StringUtil.getNumber(context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[mainIndex].replys[subIndex].laudCount))}",
                        style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),))
      // ),
    );
  }

  setBaseRichText(CommentDtoModel model) {
    List<BaseRichText> richTexts = [];
    String contextText;
    if (model.replyName != null) {
      contextText = model.name + " 回复 " + model.replyName + model.content;
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length),
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.uid}");
        },
      ));
      richTexts.add(BaseRichText(
        contextText.substring(model.name.length + 4, model.name.length + 4 + model.replyName.length),
        // "${model.name + model.replyName}:",
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.replyId}");
        },
      ));
    } else {
      contextText = "${model.name} ${model.content}";
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length),
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.uid}");
        },
      ));
    }
    return richTexts;
  }
}
