import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/rich_text_widget.dart';

// 收起展开的文字
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;
  final bool expand;
  final HomeFeedModel model;
  final int topicId;

  const ExpandableText({Key key, this.text, this.maxLines, this.style, this.expand, this.model, this.topicId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState(text, maxLines, style, expand, model);
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  final String text;
  final int maxLines;
  final TextStyle style;
  bool expand;
  HomeFeedModel model;

  _ExpandableTextState(this.text, this.maxLines, this.style, this.expand, this.model) {
    if (expand == null) {
      expand = false;
    }
  }

  setBaseRichText() {
    var textSpanList = <TextSpan>[];
    if (model.atUsers != null && model.atUsers.length > 0) {
      var textSpanList = <TextSpan>[];
      var contentArray = <String>[];
      Map<String, int> userMap = Map();
      String content = model.content;
      int subLen = 0;

      List<AtUsersModel> atUsers = [];
      atUsers.addAll(model.atUsers);
      atUsers.sort((left, right) => left.index.compareTo(right.index));

      for (int i = 0; i < atUsers.length; i++) {
        int index = atUsers[i].index - subLen;
        int end = atUsers[i].len - subLen;
        if (index < content.length && index >= 0) {
          String firstString = content.substring(0, index);
          String secondString = content.substring(index, end);
          String threeString = content.substring(end, content.length);
          contentArray.add(firstString);
          contentArray.add(secondString);
          userMap[(contentArray.length - 1).toString()] = atUsers[i].uid;
          content = threeString;
          subLen = subLen + firstString.length + secondString.length;
        }
      }
      contentArray.add(content);
      for (int i = 0; i < contentArray.length; i++) {
        textSpanList.add(TextSpan(
          text: contentArray[i],
          recognizer: new TapGestureRecognizer()
            ..onTap = () {
              if (userMap[(i).toString()] != null) {
                AppRouter.navigateToMineDetail(context, userMap[(i).toString()]);
              }
            },
          style: TextStyle(
            fontSize: 14,
            color: userMap[(i).toString()] != null ? AppColor.mainBlue : AppColor.textPrimary1,
          ),
        ));
      }
    } else {
      textSpanList.add(TextSpan(
        text: model.content,
        style: TextStyle(
          fontSize: 14,
          color: AppColor.textPrimary1,
        ),
      ));
    }

    // List<BaseRichText> richTexts = [];
    // // at高亮
    // for ( AtUsersModel atModel in model.atUsers) {
    //   richTexts.add(BaseRichText(
    //       text.substring(atModel.index,atModel.len),
    //     style: TextStyle(color:  AppColor.mainBlue, fontSize: 14),
    //     onTap: () {
    //       AppRouter.navigateToMineDetail(context, atModel.uid);
    //       print("点击用户${atModel.uid}");
    //     },
    //   ));
    // }
    // // 话题高亮
    // for (TopicDtoModel toModel in model.topics){
    //   print("我看看文本内容：：：：：：：：：：$text");
    //   richTexts.add(BaseRichText(
    //     text.substring(toModel.index, toModel.len),
    //     style: TextStyle(color:  AppColor.mainBlue, fontSize: 14),
    //     onTap: () async{
    //       if(widget.topicId == toModel.id) {
    //         return;
    //       }
    //       TopicDtoModel topicModel = await getTopicInfo(topicId: toModel.id);
    //       AppRouter.navigateToTopicDetailPage(context, topicModel);
    //       print("点击话题${toModel.id}");
    //     },
    //   ));
    // }
    return textSpanList;
  }

  RichTexts() {
    // var topicStr =  model.topicDto != null ? "#"+model.topicDto.name : "";
    // print("话题:topicStr:$topicStr");
    // print( "全文本：${topicStr+text}");
    if ((model.atUsers.isNotEmpty && model.atUsers.last.len <= model.content.length) ||
        (model.topics.isNotEmpty && model.topics.last.len <= model.content.length)) {
      return
          RichText(
        maxLines: expand ? null : maxLines,
        overflow: expand ? TextOverflow.clip : TextOverflow.ellipsis,
        text: TextSpan(children: setBaseRichText()),
      );

      // MyRichTextWidget(
      //   Text(
      //     text,
      //     style: style,
      //   ),
      //   maxLines: expand ? null : maxLines,
      //   textOverflow: expand ? TextOverflow.clip : TextOverflow.ellipsis,
      //   richTexts: setBaseRichText(),
      // );
    } else {
      return Text(
        text ?? '',
        style: style,
        maxLines: expand ? null : maxLines,
        overflow: expand ? TextOverflow.clip : TextOverflow.ellipsis,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: text ?? '', style: style);
      final tp = TextPainter(text: span, maxLines: maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichTexts(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  expand = !expand;
                });
              },
              child: Container(
                padding: EdgeInsets.only(top: 6),
                child: Text(expand ? '收起' : '展开',
                    style: TextStyle(fontSize: style != null ? style.fontSize : null, color: AppColor.textSecondary)),
              ),
            ),
          ],
        );
      } else {
        return RichTexts();
      }
    });
  }
}
