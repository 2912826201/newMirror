import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/feed/feed_comment_popups.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../if_page.dart';

// 类容评论排版
class CommentLayout extends StatelessWidget {
  CommentLayout({
    Key key,
    this.model,
  }) : super(key: key);
  HomeFeedModel model;

  setBaseRichText(CommentDtoModel model, BuildContext context) {
    List<BaseRichText> richTexts = [];
    String contextText;
    if (model.replyName != null) {
      contextText = model.name + ": 回复 " + model.replyName+" " + model.content;
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length + 1),
        style: AppStyle.textMedium14,
        onTap: () {
          AppRouter.navigateToMineDetail(context, model.uid);
        },
      ));
      richTexts.add(BaseRichText(
        contextText.substring(
            model.name.length + ": 回复".length, model.name.length + ": 回复 ".length  + model.replyName.length),
        // "${model.name + model.replyName}:",
        style: AppStyle.textMedium14,
        onTap: () {
          AppRouter.navigateToMineDetail(context, model.replyId);
        },
      ));
    } else {
      contextText = "${model.name}: ${model.content}";
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length + 1 ),
        style: AppStyle.textMedium14,
        onTap: () {
          AppRouter.navigateToMineDetail(context, model.uid);
        },
      ));
    }
    return richTexts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 6),
            child: Selector<FeedMapNotifier, int>(builder: (context, commentCount, child) {
              return GestureDetector(
                onTap: () {
                  openFeedCommentBottomSheet(context: context, feedId: model.id);
                },
                child: Text("共${StringUtil.getNumber(commentCount)}条评论", style: AppStyle.textSecondaryRegular12),
              );
            }, selector: (context, notifier) {
              return notifier.feedMap[model.id].commentCount;
            }),
            // Text("共${model.commentCount}条评论", style: AppStyle.textHintRegular12)
          ),
          for (CommentDtoModel item in context.select((FeedMapNotifier value) => value.feedMap[model.id].comments))
            GestureDetector(
                onTap: () {
                  openFeedCommentBottomSheet(context: context, feedId: model.id);
                },
                child: Container(
                  child: model.comments.length > 0
                      ? MyRichTextWidget(
                          Text(
                            item.replyName != null
                                ? "${item.name + ": 回复 " + item.replyName+" " + item.content}"
                                : "${item.name}: ${item.content}",
                            style: AppStyle.textPrimary3Regular13,
                          ),
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                          richTexts: setBaseRichText(
                              item, context
                              ),
                        )
                      : Container(),
                )),
        ],
      ),
    );
  }
}
