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
import 'package:mirror/page/test/animated_list_demo.dart';
import 'package:mirror/page/test/sliver_list_test_page.dart';
import 'package:mirror/page/test/verification_codeInput_demo_page.dart';
import 'package:mirror/page/test/verification_codeInput_demo_page2.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';


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
      curve: const Cubic(0.25, 0.25, 0.25, 0.25),
      duration: const Duration(milliseconds: 250),
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
              onTap: () {
                //第二种
                // Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                //     return SliverListDemoPage();

                // }));
                // Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                //   return VerificationCodeInputDemoPage2();
                // }));
              },
              child: Container(
                margin: EdgeInsets.only(left: 16, top: widget.isFeedDetail ? 10 : 0),
                child: ClipOval(
                  child: CachedNetworkImage(
                    height: 28,
                    width: 28,
                    useOldImageOnUrlChange: true,
                    // 调整磁盘缓存中图像大小
                    // maxHeightDiskCache: 150,
                    // maxWidthDiskCache: 150,
                    // 指定缓存宽高
                    memCacheWidth: 150,
                    memCacheHeight: 150,
                    imageUrl: context.watch<TokenNotifier>().isLoggedIn &&
                            context.watch<ProfileNotifier>().profile.avatarUri != null
                        ? FileUtil.getSmallImage(context.watch<ProfileNotifier>().profile.avatarUri)
                        : "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColor.bgWhite,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColor.bgWhite,
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
                padding: const EdgeInsets.only(left: 16),
                alignment: const Alignment(-1, 0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  color: AppColor.bgWhite.withOpacity(0.65),
                ),
                child: Text(widget.isUnderline ? "说点什么吧~" : "喜欢就评论吧~",
                    style: const TextStyle(fontSize: 14, color: AppColor.textHint)),
              ),
              onTap: () {
                if (context.read<TokenNotifier>().isLoggedIn) {
                  openInputBottomSheet(
                    buildContext: context,
                    hintText: "说点什么吧~",
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
                          contentext: StringUtil.replaceLineBlanks(text, rules),
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
                          });
                    },
                  );
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
