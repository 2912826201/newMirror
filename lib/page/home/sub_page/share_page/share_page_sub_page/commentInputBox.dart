// 隐藏评论的输入框
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class CommentInputBox extends StatefulWidget {
  CommentInputBox({Key key, this.type, this.isUnderline = false, this.feedModel, this.isFeedDetail = false})
      : super(key: key);
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
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: widget.isFeedDetail
          ? 48 + ScreenUtil.instance.bottomBarHeight
          : widget.isUnderline
              ? 48
              : (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.feedModel.id]) != null &&
                      context.select(
                              (FeedMapNotifier value) => value.value.feedMap[widget.feedModel.id].isShowInputBox) !=
                          true)
                  ? 48
                  : 0,
      width: ScreenUtil.instance.width,
      curve: Cubic(0.25, 0.25, 0.25, 0.25),
      duration: Duration(milliseconds: 250),
      child: Container(
        height: widget.isUnderline ? 48 + ScreenUtil.instance.bottomBarHeight : 48,
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
              onTap: () {},
              child: Container(
                margin: EdgeInsets.only(left: 16, top: widget.isFeedDetail ? 10 : 0),
                child: ClipOval(
                  child: CachedNetworkImage(
                    height: 28,
                    width: 28,
                    imageUrl: context.watch<ProfileNotifier>().profile.avatarUri != null
                        ? context.watch<ProfileNotifier>().profile.avatarUri
                        : "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      "images/test.png",
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "images/test.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                width: ScreenUtil.instance.screenWidthDp - 32 - 40,
                height: 28,
                margin: EdgeInsets.only(left: 12, top: widget.isFeedDetail ? 10 : 0),
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
                if (context.read<TokenNotifier>().isLoggedIn) {
                  // if (context.read<ReleaseProgressNotifier>().postFeedModel != null) {
                  //   // ToastShow.show(msg: "不响应", context: context);
                  // } else {
                  openInputBottomSheet(
                    buildContext: context,
                    hintText:
                        // widget.isUnderline ?
                        "说点什么吧~",
                    // : "喜欢就评论吧~",
                    voidCallback: (String text, List<Rule> rules) {
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
                          contentext: text,
                          atUsers: jsonEncode(atListModel),
                          commentModelCallback: (BaseResponseModel commentModel) {
                            CommentDtoModel comModel;
                            if (commentModel != null) {
                              if (commentModel.code == CODE_BLACKED) {
                                ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
                              } else if (commentModel.code == CODE_NO_DATA) {
                                String alertString = commentModel.message;
                                ToastShow.show(msg: alertString, context: context, gravity: Toast.CENTER);
                              } else {
                                if (commentModel.data != null) {
                                  comModel = (CommentDtoModel.fromJson(commentModel.data));
                                  print("发布成功：${comModel.toString()}");
                                  print("1111111");
                                  context.read<FeedMapNotifier>().feedPublishComment(comModel, widget.feedModel.id);

                                  print(
                                      '==========hotComment=====${context.read<FeedMapNotifier>().value.feedMap[widget.feedModel.id].hotComment.hashCode}');
                                  print(
                                      '=======comments========${context.read<FeedMapNotifier>().value.feedMap[widget.feedModel.id].comments.hashCode}');
                                  if (context
                                          .read<FeedMapNotifier>()
                                          .value
                                          .feedMap[widget.feedModel.id]
                                          .hotComment
                                          .length <
                                      2) {
                                    print("{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{小于二");
                                    context.read<FeedMapNotifier>().updateHotComment(widget.feedModel.id,
                                        commentDtoModel: comModel, isDelete: false);
                                  }
                                  print(
                                      '=======updateHotComment}}}}}}}}}}}}}}}}}}}}}}}}}${context.read<FeedMapNotifier>().value.feedMap[widget.feedModel.id].hotComment.toString()}');
                                }
                              }
                            }
                            // 关闭评论输入框
                            // Navigator.of(context).pop(1);
                          });
                    },
                  );
                  // }
                } else {
                  // 去登录
                  AppRouter.navigateToLoginPage(context);
                }
              },
            ),
          ],
        ),
        // ),
      ),
    );
  }
}
