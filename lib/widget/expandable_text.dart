import 'package:flutter/material.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/widget/rich_text_widget.dart';
// 收起展开的文字
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;
  final bool expand;
  final HomeFeedModel model;
  const ExpandableText({Key key, this.text, this.maxLines, this.style, this.expand,this.model}) : super(key: key);

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

  setBaseRichText(String topicStr) {
    List<BaseRichText> richTexts = [];
    for ( AtUsersModel atModel in model.atUsers) {
      richTexts.add(BaseRichText(
        topicStr != "" ? (topicStr+text).substring(topicStr.length  + atModel.index,topicStr.length  + atModel.len) : text.substring(atModel.index,atModel.len),
        style: TextStyle(color: Color(0xFF9C7BFF), fontSize: 14),
        onTap: () {
          print("点击用户${atModel.uid}");
        },
      ));
    }
    richTexts.add(BaseRichText(
      (topicStr+text).substring(0,topicStr.length),
      style: TextStyle(color: Color(0xFF9C7BFF), fontSize: 14),
      onTap: () {
        print("点击用户${model.topicDto.id}");
      },
    ));
    return richTexts;
  }

  RichText() {
    var topicStr =  model.topicDto != null ? "#"+model.topicDto.name : "";
   // print("话题:topicStr:$topicStr");
   // print( "全文本：${topicStr+text}");
    if (model.atUsers.length > 0 ) {
        return MyRichTextWidget(
          Text(
            topicStr+text,
            style: style,
          ),
          maxLines: expand ? null : maxLines ,
          textOverflow: expand ?  TextOverflow.clip : TextOverflow.ellipsis ,
          richTexts:
            setBaseRichText(topicStr),
        );
    }  else {
      return Text(text ?? '', style: style);
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
                    color: Color.fromRGBO(48, 209, 139, 1))),
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