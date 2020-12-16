import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// 类容评论排版
class CommentLayout extends StatelessWidget {
  CommentLayout({Key key, this.model, this.pc}) : super(key: key);
  final HomeFeedModel model;
  PanelController pc;

  setBaseRichText(CommentDtoModel model) {
    List<BaseRichText> richTexts = [];
    String contextText;
    if (model.replyId != null) {
      contextText = model.name + ": 回复 " + model.replyName + model.content;
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length + 1),
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.uid}");
        },
      ));
      richTexts.add(BaseRichText(
        contextText.substring(
            model.name.length + ": 回复 ".length, model.name.length + ": 回复 ".length + model.replyName.length),
        // "${model.name + model.replyName}:",
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.replyId}");
        },
      ));
    } else {
      contextText = "${model.name}: ${model.content}";
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length + 1),
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.uid}");
        },
      ));
    }
    return richTexts;
  }

  @override
  Widget build(BuildContext context) {
    // print(context.select((DynamicModelNotifier value) => value.dynamicModel.comments).length);
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
                  pc.open();
                  context.read<FeedMapNotifier>().changeFeeId(model.id);
                },
                child: Text("共${commentCount}条评论", style: AppStyle.textHintRegular12),
              );
            }, selector: (context, notifier) {
              return notifier.feedMap[model.id].commentCount;
            }),
            // Text("共${model.commentCount}条评论", style: AppStyle.textHintRegular12)
          ),
          GestureDetector(
            onTap: () {
              pc.open();
              context.read<FeedMapNotifier>().changeFeeId(model.id);
            },
              child: Container(
            child: model.comments.length > 0
                ? MyRichTextWidget(
                    Text(
                      "${context.select((FeedMapNotifier value) => value.feedMap[model.id].comments[0].name)}: ${context.select((FeedMapNotifier value) => value.feedMap[model.id].comments[0].content)}",
                      style: AppStyle.textHintRegular13,
                    ),
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                    richTexts:
                        setBaseRichText(context.select((FeedMapNotifier value) => value.feedMap[model.id].comments[0])
                            // model.comments[0]
                            ),
                  )
                : Container(),
          )),
          GestureDetector(
              onTap: () {
                pc.open();
                context.read<FeedMapNotifier>().changeFeeId(model.id);
              },
              child: Container(
            margin: EdgeInsets.only(top: 4, bottom: 4),
            child: model.comments.length > 1
                ? MyRichTextWidget(
                    Text(
                      "${context.select((FeedMapNotifier value) => value.feedMap[model.id].comments[1].name)}: ${context.select((FeedMapNotifier value) => value.feedMap[model.id].comments[1].content)}",
                      // "${model.comments[1].name}: ${model.comments[1].content}",
                      overflow: TextOverflow.visible,
                      style: AppStyle.textHintRegular13,
                    ),
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                    richTexts:
                        setBaseRichText(context.select((FeedMapNotifier value) => value.feedMap[model.id].comments[1])
                            //   model.comments[1]
                            ),
                  )
                : Container(),
          ))
        ],
      ),
    );
  }
}
