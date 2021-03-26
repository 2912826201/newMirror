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

  // 设置高亮文本
  List<TextSpan> setHighlightTextSpan(HomeFeedModel value) {
    var textSpanList = <TextSpan>[];
    var contentArray = <AtuserOrTopicModel>[];
    // @和话题map：key为索引开始位置。
    Map<String, dynamic> maps = Map();
    // map 转keys数组
    List<String> keys = [];
    // 所有文本
    String content = value.content;
    // 记录跳转数据的map
    Map<String, int> userMap = Map();
    // 计算减去前一个高亮记录的索引
    int subLen = 0;
    // 高亮开始位置
    int index = 0;
    // 高亮结束位置
    int end = 0;
    if (value.topics != null && value.topics.length > 0) {
      for (int i = 0; i < value.topics.length; i++) {
        maps[value.topics[i].index.toString()] = value.topics[i];
      }
    }
    if (value.atUsers != null && value.atUsers.length > 0) {
      for (int i = 0; i < value.atUsers.length; i++) {
        maps[value.atUsers[i].index.toString()] = value.atUsers[i];
      }
    }
    keys = maps.keys.toList();
    // key排序
    keys.sort((left, right) => int.parse(left).compareTo(int.parse(right)));
    print("keys排序：：：${keys.toString()}");
    //通过重新排序keys的顺序将原先的map数据取出来。
    for (int i = 0; i < keys.length; i++) {
      // 话题或者@的model
      String element = keys[i];
      // 话题
      if (maps[element] is TopicDtoModel) {
        index = maps[element].index - subLen;
        end = maps[element].len - subLen;
        if (index < content.length && index >= 0) {
          AtuserOrTopicModel atuserOrTopicModel = AtuserOrTopicModel();
          AtuserOrTopicModel atuserOrTopicModel1 = AtuserOrTopicModel();
          String firstString = content.substring(0, index);
          String secondString = content.substring(index, end);
          String threeString = content.substring(end, content.length);
          atuserOrTopicModel.content = firstString;
          atuserOrTopicModel1.type = "#";
          atuserOrTopicModel1.content = secondString;
          contentArray.add(atuserOrTopicModel);
          contentArray.add(atuserOrTopicModel1);
          userMap[(contentArray.length - 1).toString()] = maps[element].id;
          content = threeString;
          subLen = subLen + firstString.length + secondString.length;
        }
      }
      // @
      if (maps[element] is AtUsersModel) {
        index = maps[element].index - subLen;
        end = maps[element].len - subLen;
        if (index < content.length && index >= 0) {
          AtuserOrTopicModel atuserOrTopicModel = AtuserOrTopicModel();
          AtuserOrTopicModel atuserOrTopicModel1 = AtuserOrTopicModel();
          String firstString = content.substring(0, index);
          String secondString = content.substring(index, end);
          String threeString = content.substring(end, content.length);
          atuserOrTopicModel.content = firstString;
          atuserOrTopicModel1.type = "@";
          atuserOrTopicModel1.content = secondString;
          contentArray.add(atuserOrTopicModel);
          contentArray.add(atuserOrTopicModel1);
          userMap[(contentArray.length - 1).toString()] = maps[element].uid;
          content = threeString;
          subLen = subLen + firstString.length + secondString.length;
        }
      }
    }
    for (int i = 0; i < contentArray.length; i++) {
      textSpanList.add(TextSpan(
        text: contentArray[i].content,
        recognizer: new TapGestureRecognizer()
          ..onTap = () async {
            if (userMap[(i).toString()] != null) {
              if (contentArray[i].type == "@") {
                AppRouter.navigateToMineDetail(context, userMap[i.toString()]);
              } else if (contentArray[i].type == "#") {
                if (widget.topicId == userMap[i.toString()]) {
                  return;
                }
                TopicDtoModel topicModel = await getTopicInfo(topicId: userMap[i.toString()]);
                AppRouter.navigateToTopicDetailPage(context, topicModel);
              }
            }
          },
        style: TextStyle(
          fontSize: 14,
          color: userMap[(i).toString()] != null ? AppColor.mainBlue : AppColor.textPrimary1,
        ),
      ));
    }
    return textSpanList;
  }

  // 富文本展示
  setBaseRichText() {
    var textSpanList = <TextSpan>[];
    if ((model.atUsers != null && model.atUsers.length > 0) || (model.topics != null && model.topics.length > 0)) {
      textSpanList.addAll(setHighlightTextSpan(model));
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
