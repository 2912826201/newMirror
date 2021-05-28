import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/dotted_line.dart';

import 'currency_msg.dart';

///能选择的列表 消息
// ignore: must_be_immutable
class SelectMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final String selectListString;
  final int status;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final bool isCanLongClick;
  final int sendTime;
  final int position;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Function(void Function(),String longClickString) setCallRemoveOverlay;

  SelectMsg({
    this.userUrl,
    this.name,
    this.isShowChatUserName = false,
    this.isCanLongClick = true,
    this.sendChatUserId,
    this.isMyself,
    this.selectListString,
    this.status,
    this.position,
    this.sendTime,
    this.voidMessageClickCallBack,
    this.voidItemLongClickCallBack,
    this.setCallRemoveOverlay,
  });

  String text = "选择适合你的难度";
  TextStyle textStyle = const TextStyle(
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          getMainBox(context),
          getSelectListBox(),
        ],
      ),
    );
  }

//选择难度的box
  Widget getMainBox(BuildContext context) {
    return Row(
      mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: getBody(context),
    );
  }

//选项的列表
  Widget getSelectListBox() {
    List<String> selectList = selectListString.split(",");
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 18, right: 16),
      width: double.infinity,
      // color: Colors.redAccent,
      alignment: isMyself ? Alignment.topRight : Alignment.topLeft,
      child: UnconstrainedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 298.0,
            color: AppColor.white,
            child: Column(
              children: itemList(selectList),
            ),
          ),
        ),
      ),
    );
  }

//选择的列表
  List<Widget> itemList(List<String> selectList) {
    var containerList = <Widget>[];
    for (int i = 0; i < selectList.length; i++) {
      if (i != 0) {
        containerList.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: DottedLine(
            height: 1.0,
            color: Colors.grey,
          ),
        ));
      }
      containerList.add(Material(
          color: i % 2 != 0 ? AppColor.bgWhite : AppColor.white,
          child: new InkWell(
            child: Container(
              padding: const EdgeInsets.all(13),
              child: Text(
                selectList[i] * 20,
                style: TextStyle(fontSize: 13, color: AppColor.black),
              ),
            ),
            splashColor: i % 2 != 0 ? AppColor.white : AppColor.bgWhite,
            onTap: () {
              voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_SELECT,
                content: selectList[i],
              );
            },
          )));
    }
    return containerList;
  }

  //最外层body 加载状态和消息结构
  List<Widget> getBody(BuildContext context) {
    var body = [
      Row(
        mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status, position: position, voidMessageClickCallBack: voidMessageClickCallBack),
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
      getUserImage(userUrl, 38, 38),
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
          textContentBoxLongClick(context),
        ],
      ),
    );
  }

  //长按事件
  Widget textContentBoxLongClick(BuildContext context) {
    List<String> longClickStringList =
        getLongClickStringList(isMySelf: isMyself,
            status: status,sendTime: sendTime, contentType: ChatTypeModel.MESSAGE_TYPE_SELECT);
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
            position: position,
            settingType: longClickStringList[value],
            contentType: ChatTypeModel.MESSAGE_TYPE_SELECT,
            content: text);
      },
      setCallRemoveOverlay:setCallRemoveOverlay,
      position:position,
      isCanLongClick: isCanLongClick,
      contentType: ChatTypeModel.MESSAGE_TYPE_SELECT,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: getTextSize(text, textStyle, 10).width + 22.0,
      contentHeight: MessageItemHeightUtil.init()
          .getSelectMsgDataHeight(selectListString, isShowChatUserName, isOnlyContentHeight: true),
      child: textContentBox(context),
    );
  }

  //文字的框架
  Widget textContentBox(BuildContext context) {
    String stateImg = "assets/png/message_bubble_arrow_white.png";
    if (isMyself) {
      stateImg = "assets/png/message_bubble_arrow_black.png";
    }
    return Container(
      margin: isMyself ? const EdgeInsets.only(right: 2.0) : const EdgeInsets.only(left: 2.0),
      child: Stack(
        alignment: isMyself ? AlignmentDirectional.topEnd : AlignmentDirectional.topStart,
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
              margin: isMyself ? const EdgeInsets.only(right: 7.0) : const EdgeInsets.only(left: 7.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: isMyself ? AppColor.textPrimary2 : AppColor.white,
                    child: new InkWell(
                      child: getRichTextBox(context),
                      splashColor: isMyself ? AppColor.textPrimary1 : AppColor.textHint,
                      onTap: () {},
                    )),
              )),
        ],
      ),
    );
  }

  Widget getRichTextBox(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - (16 + 7 + 38 + 2) * 2,
      ),
      padding: const EdgeInsets.only(left: 11, right: 11, top: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: !isMyself ? AppColor.textPrimary2 : AppColor.white, fontSize: 15),
      ),
    );
  }
}
