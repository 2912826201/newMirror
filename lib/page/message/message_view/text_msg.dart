import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'currency_msg.dart';

///文本消息
// ignore: must_be_immutable
class TextMsg extends StatelessWidget {
  final String text;
  final bool isMyself;
  final String userUrl;
  final String name;
  final int status;
  final int position;
  final MentionedInfo mentionedInfo;
  final String sendChatUserId;
  final bool isCanLongClick;
  final int sendTime;
  final bool isShowChatUserName;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  TextMsg(
      {this.text,
      this.isMyself,
      this.userUrl,
      this.isShowChatUserName = false,
      this.isCanLongClick = true,
      this.sendChatUserId,
        this.sendTime,
      this.name,
      this.status,
      this.mentionedInfo,
      this.position,
      this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack});

  TextStyle textStyle = const TextStyle(
    fontSize: 15,
  );

  //at了那些人
  List<String> atUserNameList = <String>[];

  @override
  Widget build(BuildContext context) {
    initAtUser();

    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
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
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status,position: position,voidMessageClickCallBack: voidMessageClickCallBack),
      ),
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
      GestureDetector(
        child: getUserImage(userUrl, 38, 38),
        onTap: () {
          if (isCanLongClick) {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_USER,
                map: new UserModel(uid: int.parse(sendChatUserId)).toJson());
          }
        },
      ),
      getNameAndContentUi(context),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //判断有没有名字
  Widget getNameAndContentUi(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: isMyself ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isShowChatUserName,
            child: Container(
              margin:
                  isMyself ? const EdgeInsets.only(right: 10, bottom: 4) : const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                name,
                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              ),
            ),
          ),
          textContentBoxUiLongClick(context),
        ],
      ),
    );
  }

  //获取长按事件
  Widget textContentBoxUiLongClick(BuildContext context) {
    List<String> longClickStringList =
        getLongClickStringList(
            isMySelf: isMyself,
            sendTime: sendTime,
            contentType: ChatTypeModel.MESSAGE_TYPE_TEXT);
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
            position: position,
            settingType: longClickStringList[value],
            contentType: ChatTypeModel.MESSAGE_TYPE_TEXT,
            content: text);
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text(longClickStringList[value]), duration: Duration(milliseconds: 500),));
      },
      isCanLongClick: isCanLongClick,
      contentType: ChatTypeModel.MESSAGE_TYPE_TEXT,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: getTextSize(text, textStyle, 10).width + 22.0,
      contentHeight: MessageItemHeightUtil.init().
        getTextMsgHeight(text, isShowChatUserName,isOnlyContentHeight: true),
      child: textContentBox(context),
    );
  }

  //文字的框架
  Widget textContentBox(BuildContext context) {
    String stateImg = "images/test/icon_white_message_bugle.png";
    if (isMyself) {
      stateImg = "images/test/icon_black_message_bugle.png";
    }
    return Container(
      margin: isMyself ? const EdgeInsets.only(right: 2.0) : const EdgeInsets.only(left: 2.0),
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
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: isMyself ? AppColor.textPrimary2 : AppColor.white,
                    child: new InkWell(
                      child: getRichTextBox(context),
                      splashColor: isMyself ? AppColor.textPrimary1 : AppColor
                          .textHint,
                      onTap: () {

                      },
                    )
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget getRichTextBox(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth:
        MediaQuery
            .of(context)
            .size
            .width - (16 + 7 + 38 + 2) * 2,
      ),
      padding:
      const EdgeInsets.only(left: 11, right: 11, top: 8, bottom: 8),
      child: RichText(
          maxLines: 100,
          text: TextSpan(
            style: textStyle,
            children: getTextSpanArray(text, isMyself),
          )),
    );
  }

  List<TextSpan> getTextSpanArray(String content, bool isMyself) {
    var textSpanArray = <TextSpan>[];
    if (!StringUtil.strNoEmpty(content)) {
      textSpanArray.addAll(judgeIsAtUser("消息为空", isMyself, 0));
    } else {
      var contentArray = content.split(" ");
      for (int i = 0; i < contentArray.length; i++) {
        if (contentArray[i] != null && contentArray[i].length > 0) {
          textSpanArray.addAll(judgeIsAtUser(contentArray[i], isMyself, i,
              isUrl: StringUtil.isURL(contentArray[i])));
        }
      }
    }
    return textSpanArray;
  }

  TextSpan getNullContent(String content, bool isMyself, int index, bool isUrl, {bool isUrlColor = false}) {
    return TextSpan(
        text: ("${index > 0 ? " " : ""}$content"),
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_TEXT,
                content: content,
                isUrl: isUrl);
          },
        style: TextStyle(
          color: isUrlColor ? AppColor.urlText :
          !isUrl ? (!isMyself ? AppColor.textPrimary2 : AppColor.white) : AppColor.urlText,
        ));
  }


//判断at用户的颜色
  List<TextSpan> judgeIsAtUser(String content, bool isMyself, int index, {bool isUrl = false}) {
    var textSpanArray = <TextSpan>[];
    if (atUserNameList == null || atUserNameList.length < 1) {
      textSpanArray.add(getNullContent(content, isMyself, index, isUrl));
    } else {
      int index = isHaveAtName(content);
      // print("有at的人-----------index:$index---content:$content");
      if (index < 0) {
        textSpanArray.add(getNullContent(content, isMyself, index, isUrl));
      } else if ("@" + atUserNameList[index] == content) {
        textSpanArray.add(getNullContent(content, isMyself, index, false, isUrlColor: true));
      } else {
        textSpanArray.add(getNullContent(
            content.replaceAll("@" + atUserNameList[index], ""), isMyself, index, false, isUrlColor: false));
        textSpanArray.add(getNullContent("@" + atUserNameList[index], isMyself, index, false, isUrlColor: true));
      }
    }
    return textSpanArray;
  }


  //判断要绘制的字符串 里面有没有 at的人名
  int isHaveAtName(String content) {
    for (int i = 0; i < atUserNameList.length; i++) {
      String userName = "@" + atUserNameList[i];
      if (content.contains(userName)) {
        return i;
      }
    }
    return -1;
  }


  //初始化那些人是at了
  void initAtUser() {
    atUserNameList.clear();
    if (mentionedInfo == null || mentionedInfo.userIdList.length < 1) {
      // print("---------------没有at人");
    } else if (mentionedInfo.mentionedContent == null || mentionedInfo.mentionedContent.length < 1) {
      // print("---------------at人了-但是没有名字-不处理");
    } else {
      // print("---------------at了：id:${mentionedInfo.userIdList.toString()}:---name:${mentionedInfo.mentionedContent}");
      atUserNameList = mentionedInfo.mentionedContent.split(",");
      atUserNameList.removeAt(atUserNameList.length - 1);
    }
  }


}
