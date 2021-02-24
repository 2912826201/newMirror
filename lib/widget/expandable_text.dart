import 'package:flutter/material.dart';
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
  const ExpandableText({Key key, this.text, this.maxLines, this.style, this.expand,this.model,this.topicId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState(text, maxLines, style, expand,model);
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  final String text;
  final int maxLines;
  final TextStyle style;
  bool expand;
  HomeFeedModel model;

  _ExpandableTextState(this.text, this.maxLines, this.style, this.expand,this.model) {
    if (expand == null) {
      expand = false;
    }
  }

  setBaseRichText() {
    List<BaseRichText> richTexts = [];
    // at高亮
    for ( AtUsersModel atModel in model.atUsers) {
      richTexts.add(BaseRichText(
          text.substring(atModel.index,atModel.len),
        style: TextStyle(color:  AppColor.mainBlue, fontSize: 14),
        onTap: () {
          AppRouter.navigateToMineDetail(context, atModel.uid);
          print("点击用户${atModel.uid}");
        },
      ));
    }
    // 话题高亮
    for (TopicDtoModel toModel in model.topics){
      print("我看看文本内容：：：：：：：：：：$text");
      richTexts.add(BaseRichText(
        text.substring(toModel.index, toModel.len),
        style: TextStyle(color:  AppColor.mainBlue, fontSize: 14),
        onTap: () {
          if(widget.topicId == toModel.id) {
            return;
          }
          AppRouter.navigateToTopicDetailPage(context, toModel.id);
          print("点击用户${toModel.id}");
        },
      ));
    }
    return richTexts;
  }

  RichText() {
    // var topicStr =  model.topicDto != null ? "#"+model.topicDto.name : "";
   // print("话题:topicStr:$topicStr");
   // print( "全文本：${topicStr+text}");
    if ((model.atUsers.isNotEmpty && model.atUsers.last.len <= model.content.length) || (model.topics.isNotEmpty && model.topics.last.len <= model.content.length)) {
        return MyRichTextWidget(
          Text(
            text,
            style: style,
          ),
          maxLines: expand ? null : maxLines ,
          textOverflow: expand ?  TextOverflow.clip : TextOverflow.ellipsis ,
          richTexts:
            setBaseRichText(),
        );
    }  else {
      return Text(text ?? '', style: style,maxLines: expand ? null : maxLines, overflow: expand ?  TextOverflow.clip : TextOverflow.ellipsis ,);
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: text ?? '', style: style);
      final tp = TextPainter(
          text: span, maxLines: maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  expand = !expand;
                });
              },
              child: Container(
                padding: EdgeInsets.only(top: 6),
                child: Text(expand ? '收起' : '展开', style: TextStyle(
                    fontSize: style != null ? style.fontSize : null,
                    color: AppColor.textSecondary)),
              ),
            ),
          ],
        );
      } else {
        return
          RichText();
      }
    });
  }
}