import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/widget/rich_text_widget.dart';

// 类容评论排版
class CommentLayout extends StatelessWidget {
  CommentLayout({Key key, this.commenNum}) : super(key: key);
  var userName = ["张珊", "李思", "王武", "赵柳"];
  final commenNum;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: EdgeInsets.only(left: 16, right: 16,top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 6),
              child: Text(
                "共${commenNum}条评论",
                style: TextStyle(fontSize: 12, color: Color.fromRGBO(153, 153, 153, 1)),
              )),
          MyRichTextWidget(
            Text(
              "${userName[0]}: 这是评论的内容，如果很长最多只显示一行。",
              style: TextStyle(fontSize: 13, color: Color.fromRGBO(151, 151, 151, 1)),
            ),
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            richTexts: [
              BaseRichText(
                "${userName[0]}:",
                style: TextStyle(color: Colors.black, fontSize: 14),
                onTap: () {
                  print("点击用户${userName[0]}");
                },
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 4, bottom: 4),
            child: MyRichTextWidget(
              Text(
                "${userName[1]}: 回复 ${userName[2]} 回复的其他人的评论内容超过这是评论的内容，如果很长最多只显示一行。",
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 12, color: Color.fromRGBO(151, 151, 151, 1)),
              ),
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              richTexts: [
                BaseRichText(
                  "${userName[1]}: 回复",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  onTap: () {
                    print("点击用户${userName[1]}");
                  },
                ),
                BaseRichText(
                  userName[2],
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  onTap: () {
                    print("点击用户${userName[2]}");
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}