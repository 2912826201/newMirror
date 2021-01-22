// 隐藏评论的输入框
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';
import 'package:mirror/api/home/home_feed_api.dart';

class CommentInputBox extends StatefulWidget {
  CommentInputBox({Key key,this.type, this.isUnderline = false, this.feedModel,this.isFeedDetail = false}) : super(key: key);
  bool isUnderline;
  int type;
  bool isFeedDetail;
  // 动态model
  HomeFeedModel feedModel;

  // 子评论model
  // commentDtoModel
  CommentInputBoxState createState() => CommentInputBoxState();
}

class CommentInputBoxState extends State<CommentInputBox> {
  var offstage = true;
  GlobalKey<NavigatorState> _key = GlobalKey();
  inputHide() {
    setState(() {
      offstage = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    // print("底部键盘高度${MediaQuery.of(context).viewInsets.bottom}");
    return Offstage(
      offstage: false,
      child: Container(
        height: widget.isFeedDetail ? 48 + ScreenUtil.instance.bottomBarHeight : 48,
        width: ScreenUtil.instance.width,
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(width: widget.isUnderline ? 0.5 : 0.000000001, color: Color(0xffe5e5e5))),
        ),
        // child: Center(
          child: Row(
            crossAxisAlignment: widget.isFeedDetail ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){

                },
                child: Container(
                margin: EdgeInsets.only(left: 16,top: widget.isFeedDetail ? 10 : 0),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        // ProfileNotifier value.profile.avatarUri
                        image: context.watch<TokenNotifier>().isLoggedIn
                            ? NetworkImage(context.select((ProfileNotifier value) => value.profile.avatarUri))
                            : AssetImage("images/test/yxlm1.jpeg"),
                        fit: BoxFit.cover)),
              ),),
              GestureDetector(
                child: Container(
                  width: ScreenUtil.instance.screenWidthDp - 32 - 40,
                  height: 28,
                  margin: EdgeInsets.only(left: 12,top: widget.isFeedDetail ? 10 : 0),
                  padding: EdgeInsets.only(left: 16),
                  alignment: Alignment(-1, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    color: AppColor.bgWhite.withOpacity(0.65),
                  ),
                  child: Text(widget.isUnderline ? "说点什么吧~" : "喜欢就评论吧~",
                      style: TextStyle(fontSize: 14, color: AppColor.textHint)),
                ),
                onTap: () {
                  openInputBottomSheet(
                    buildContext: this.context,
                    hintText: widget.isUnderline ? "说点什么吧~" : "喜欢就评论吧~",
                    voidCallback: (String text,List<Rule> rules) {
                      List<AtUsersModel> atListModel = [];
                      for (Rule rule in rules) {
                        AtUsersModel atModel = AtUsersModel();
                        atModel.index = rule.startIndex;
                        atModel.len = rule.endIndex;
                        atModel.uid = rule.id;
                        atListModel.add(atModel);
                      }
                      // 发布评论
                      postComments(
                          targetId: widget.feedModel.id,
                          targetType: 0,
                          content: text,
                          atUsers: jsonEncode(atListModel),
                          commentModelCallback: (CommentDtoModel commentModel) {
                            if (commentModel != null) {
                              print(commentModel.toString());
                              print(widget.feedModel.id);
                              print(context);
                              context.read<FeedMapNotifier>().feedPublishComment(commentModel, widget.feedModel.id);
                            }
                            // 关闭评论输入框
                            // Navigator.of(context).pop(1);
                          });
                    },
                  );
                },
              ),
            ],
          ),
        // ),
      ),
    );
  }
}
