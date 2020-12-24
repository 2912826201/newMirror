import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/util/string_util.dart';

class TextMsg extends StatelessWidget {
  final String text;
  final ChatDataModel model;

  TextMsg(this.text, this.model);

  @override
  Widget build(BuildContext context) {
    //todo 获取用户id 与消息里面的id进行对比 判断是不是我自己的消息

    bool isMyself =
        Application.profile.uid.toString() == model.msg.senderUserId;
    String imageUrl = "images/test/icon_white_message_bugle.png";
    if (isMyself) {
      imageUrl = "images/test/icon_black_message_bugle.png";
    }
    var body = [
      ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.network(
          model.msg.content.sendUserInfo.portraitUri,
          fit: BoxFit.cover,
          width: 38,
          height: 38,
        ),
      ),
      Container(
        margin: isMyself
            ? const EdgeInsets.only(right: 2.0)
            : const EdgeInsets.only(left: 2.0),
        child: Stack(
          alignment: isMyself
              ? AlignmentDirectional.topEnd
              : AlignmentDirectional.topStart,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 9.0),
              child: Image.asset(
                imageUrl,
                width: 10.5,
                height: 17,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              margin: isMyself
                  ? const EdgeInsets.only(right: 7.0)
                  : const EdgeInsets.only(left: 7.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - (16 + 7 + 38) * 2,
              ),
              padding:
                  const EdgeInsets.only(left: 11, right: 11, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: isMyself ? AppColor.textPrimary2 : AppColor.white,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: RichText(
                  maxLines: 100,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    children: getTextSpanArray(text, isMyself),
                  )),
            ),
          ],
        ),
      ),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9.0),
      child: Row(
        mainAxisAlignment:
            isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: body,
      ),
    );
  }

  List<TextSpan> getTextSpanArray(String content, bool isMyself) {
    var textSpanArray = <TextSpan>[];
    if (!StringUtil.strNoEmpty(content)) {
      textSpanArray.add(getNullContent("消息为空", isMyself));
    } else {
      var contentArray = content.split(" ");
      for (int i = 0; i < contentArray.length; i++) {
        textSpanArray.add(getNullContent(contentArray[i], isMyself,
            isUrl: StringUtil.isURL(contentArray[i])));
      }
    }
    return textSpanArray;
  }

  TextSpan getNullContent(String content, bool isMyself, {bool isUrl = false}) {
    return TextSpan(
        text: (" $content "),
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            if (isUrl) {
              print(content);
            } else {
              print("不是url链接");
            }
          },
        style: TextStyle(
          color: !isUrl
              ? (!isMyself ? AppColor.textPrimary2 : AppColor.white)
              : AppColor.urlText,
        ));
  }
}
