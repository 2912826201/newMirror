import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/feed/feed_comment_popups.dart';
import 'package:provider/provider.dart';

// 类容评论排版
class CommentLayout extends StatelessWidget {
  CommentLayout({
    Key key,
    this.model,
  }) : super(key: key);
  HomeFeedModel model;

  //获取子评论的文字
  List<TextSpan> getSubCommentText(CommentDtoModel value, BuildContext context) {
    var textSpanList = <TextSpan>[];
    if (value.replyId != null && value.replyId > 0) {
      textSpanList.add(TextSpan(
        text: "${value.name + ":"}",
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            jumpToUserProfilePage(context, value.uid,avatarUrl:value.avatarUrl,userName:value.name);
          },
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.white),
      ));
      textSpanList.add(TextSpan(text: " 回复 ", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.white)));

      textSpanList.add(TextSpan(
        text: "${value.replyName}  ",
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            jumpToUserProfilePage(context, value.replyId,avatarUrl:value.avatarUrl,userName:value.name);
          },
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.white),
      ));
      textSpanList.add(TextSpan(
        text: "${value.content}",
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
      ));
    } else {
      textSpanList.add(TextSpan(
        text: "${value.name + ":"}",
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            jumpToUserProfilePage(context, value.uid,avatarUrl:value.avatarUrl,userName:value.name);
          },
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.white),
      ));
      textSpanList.add(TextSpan(
        text: " ${value.content}",
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
      ));
    }
    return textSpanList;
  }

  @override
  Widget build(BuildContext context) {
    return context.watch<FeedMapNotifier>().value.feedMap[model.id] != null
        ? Container(
            // color: AppColor.white,
            width: ScreenUtil.instance.width,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: ScreenUtil.instance.width,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Selector<FeedMapNotifier, int>(builder: (context, commentCount, child) {
                    return GestureDetector(
                      onTap: () {
                        if (context.read<TokenNotifier>().isLoggedIn) {
                          openFeedCommentBottomSheet(context: context, feedId: model.id);
                        } else {
                          // 去登录
                          AppRouter.navigateToLoginPage(context);
                        }
                      },
                      child: Text("共${StringUtil.getNumber(commentCount)}条评论", style: AppStyle.text1Regular12),
                    );
                  }, selector: (context, notifier) {
                    return notifier.value.feedMap[model.id].commentCount;
                  }),
                  // Text("共${model.commentCount}条评论", style: AppStyle.textHintRegular12)
                ),
                for (CommentDtoModel item
                    in context.select((FeedMapNotifier value) => value.value.feedMap[model.id].hotComment))
                  Container(
                    width: ScreenUtil.instance.width,
                    child: GestureDetector(
                        onTap: () {
                          if (context.read<TokenNotifier>().isLoggedIn) {
                            openFeedCommentBottomSheet(context: context, feedId: model.id, commentDtoModel: item);
                          } else {
                            // 去登录
                            AppRouter.navigateToLoginPage(context);
                          }
                        },
                        child: Container(
                          child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(children: getSubCommentText(item, context)),
                                ),
                        )),
                  ),
              ],
            ),
          )
        : Container();
  }
}
