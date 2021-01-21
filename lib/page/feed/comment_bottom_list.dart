import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:provider/provider.dart';

import 'bottom_listview_subcomment.dart';
/*class CommentBottomListView extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CommentBottomListState();
  }
}*/
class CommentBottomListView extends StatelessWidget {
  CommentDtoModel model;
  int index;
  int feedId;
  int type;
  CommentDtoModel comment;
  CommentBottomListView({this.model,this.type, this.index, this.feedId,this.comment});
  @override
  // 点赞
  setUpLuad(BuildContext context) async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否点赞了￥${context.read<FeedMapNotifier>().feedMap[this.feedId].comments[this.feedId].isLaud}");
    if (isLoggedIn) {
      Map<String, dynamic> model = await laudComment(commentId: this.model.id, laud: this.model.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<FeedMapNotifier>().mainCommentLaud(this.model.isLaud, this.feedId, this.index);
      } else {
        // 失败
        print("shib ");
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(this.model.targetId);
    print('======================父评论build');
    if(context.watch<FeedMapNotifier>().feedMap[this.feedId].comments[this.index].itemChose){
      Future.delayed(Duration(milliseconds: 2000), () {
        try {
          print('=========================父评论背景改变');
          context.read<FeedMapNotifier>().changeItemChose(this.feedId, this.index);
        } catch (e) {
        }
      });
    }
    // 头像
    var avatar = Container(
      child: Container(
        height: 42,
        width: 42,
        child: ClipOval(
          child: this.model.avatarUrl != null
            ? Image.network(this.model.avatarUrl, fit: BoxFit.cover)
            : Image.asset("images/test/yxlm1.jpeg", fit: BoxFit.cover),
        ),
      ),
    );

    // 评论
    Widget info = Container(
      margin: EdgeInsets.only(left: 15, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MyRichTextWidget(
            Text(
              this.model.name + " " + this.model.content,
              overflow: TextOverflow.visible,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
            ),
            maxLines: 2,
            textOverflow: TextOverflow.ellipsis,
            richTexts: [
              BaseRichText(
                (this.model.name + " " + this.model.content).substring(0, this.model.name.length),
                style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
                onTap: () {
                  print(this.model.uid);
                },
              ),
            ],
          ),
          Container(height: 6),
          Container(
            child: Text(
              "${DateUtil.generateFormatDate(this.model.createTime)} 回复",
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
          ),
        ],
      ));

    // 点赞
    Widget right = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setUpLuad(context);
          },
          child: Icon(
            Icons.favorite,
            color: context.watch<FeedMapNotifier>().feedMap[this.feedId].comments[this.index].isLaud == 0
              ? Colors.grey
              : context.watch<FeedMapNotifier>().feedMap[this.feedId].comments[this.index].isLaud == null
              ? Colors.grey
              : Colors.red,
          ),
        ),
        Container(
          height: 4,
        ),
        Offstage(
          offstage: context.watch<FeedMapNotifier>().feedMap[this.feedId].comments[this.index].laudCount == 0,
          child: Text(
            "${StringUtil.getNumber(context.select((FeedMapNotifier value) => value.feedMap[this.feedId].comments[this.index].laudCount))}",
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
        )
      ],
    );

    return Container(
      margin: EdgeInsets.only(top: 12),
      // color: AppColor.mainRed,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              openInputBottomSheet(
                context: context,
                hintText: "回复 ${this.model.name}",
                voidCallback: (String text, List<Rule> rules, BuildContext context) {
                  List<AtUsersModel> atListModel = [];
                  for (Rule rule in rules) {
                    AtUsersModel atModel;
                    atModel.index = rule.startIndex;
                    atModel.len = rule.endIndex;
                    atModel.uid = 1008611;
                    atListModel.add(atModel);
                  }
                  // 评论父评论
                  postComments(
                    targetId: this.model.id,
                    targetType: 2,
                    content: text,
                    atUsers: jsonEncode(atListModel),
                    replyId: this.model.uid,
                    replyCommentId: this.model.id,
                    commentModelCallback: (CommentDtoModel commentModel) {
                      context.read<FeedMapNotifier>().commentFeedCom(this.feedId, this.index, commentModel);
                      print('${model.replys[0].content}');
                      print('${context.read<FeedMapNotifier>().feedMap[feedId].comments[index].replys[0]}');
                        // 关闭评论输入框
                      // Navigator.of(context).pop(1);
                    });
                },
              );
            },
            child:  AnimatedPhysicalModel(
              shape: BoxShape.rectangle,
              color: context.watch<FeedMapNotifier>().feedMap[feedId].comments[index].itemChose ? AppColor.bgWhite: AppColor.white,
              elevation:0,
              shadowColor: !context.watch<FeedMapNotifier>().feedMap[feedId].comments[index].itemChose ?AppColor.bgWhite: AppColor.white,
              duration: Duration(seconds: 2),
              child: Container(
                padding: EdgeInsets.only(left: 16,right: 16,top: 9,bottom: 8),
                child: Row(
                  // 横轴距定对齐
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    avatar,
                    Expanded(child: info),
                    right,
                  ],
                ),) ,
            ),
          ),
          // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replyCount)  != 0
          this.model.replyCount != 0
            ? BottomListViewSubComment(
            comment: this.comment,
            type: this.type,
            replys:
            // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replys),
            this.model.replys,
            commentDtoModel: this.model,
            // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index]),
            listIndex: this.index, feedId: this.feedId,
          )
            : Container(),
        ],
      ),
    );
  }
}