import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';

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

class AtuserOrTopicModel {
  String content;
  String type;

  AtuserOrTopicModel({this.type, this.content});
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


  // 富文本展示
  setBaseRichText() {
    var textSpanList = <TextSpan>[];
    if ((model.atUsers != null && model.atUsers.length > 0) || (model.topics != null && model.topics.length > 0)) {
      textSpanList.addAll(StringUtil.setHighlightTextSpan(context, model.content,topicId: widget.topicId,atUsers: model.atUsers,topics: model.topics));
    } else {
      textSpanList.add(TextSpan(
        text: model.content,
        style: TextStyle(
          fontSize: 14,
          color: AppColor.textPrimary1,
        ),
      ));
    }

    return textSpanList;
  }

  RichTexts() {
    if ((model.atUsers.isNotEmpty && model.atUsers.last.len <= model.content.length) ||
        (model.topics.isNotEmpty && model.topics.last.len <= model.content.length)) {
      return RichText(
        maxLines: expand ? null : maxLines,
        overflow: expand ? TextOverflow.clip : TextOverflow.ellipsis,
        text: TextSpan(children: setBaseRichText()),
      );
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
