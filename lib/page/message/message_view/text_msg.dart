import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/string_util.dart';

import 'currency_msg.dart';

class TextMsg extends StatelessWidget {
  final String text;
  final bool isMyself;
  final String userUrl;
  final String name;
  final int status;

  TextMsg({this.text, this.isMyself, this.userUrl, this.name, this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9.0),
      child: Column(
        children: [
          getLongClickBox(),
          Row(
            mainAxisAlignment:
                isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: getBody(context),
          ),
        ],
      ),
    );
  }

  //最外层body 加载状态和消息结构
  List<Widget> getBody(BuildContext context) {
    var body = [
      Row(
        mainAxisAlignment:
            isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      getMessageState(status),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //里面的结构-头像和消息
  List<Widget> getSmallBody(BuildContext context) {
    var body = [
      getUserImage(userUrl, 38, 38),
      textContentBox(context),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //文字的框架
  Widget textContentBox(BuildContext context) {
    String stateImg = "images/test/icon_white_message_bugle.png";
    if (isMyself) {
      stateImg = "images/test/icon_black_message_bugle.png";
    }
    return Container(
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
              stateImg,
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
              maxWidth:
                  MediaQuery.of(context).size.width - (16 + 7 + 38 + 2) * 2,
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
    );
  }

  List<TextSpan> getTextSpanArray(String content, bool isMyself) {
    var textSpanArray = <TextSpan>[];
    if (!StringUtil.strNoEmpty(content)) {
      textSpanArray.add(getNullContent("消息为空", isMyself, 0));
    } else {
      var contentArray = content.split(" ");
      for (int i = 0; i < contentArray.length; i++) {
        textSpanArray.add(getNullContent(contentArray[i], isMyself, i,
            isUrl: StringUtil.isURL(contentArray[i])));
      }
    }
    return textSpanArray;
  }

  TextSpan getNullContent(String content, bool isMyself, int index,
      {bool isUrl = false}) {
    return TextSpan(
        text: ("${index > 0 ? " " : ""}$content"),
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
