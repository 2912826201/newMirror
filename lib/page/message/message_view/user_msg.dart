import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/file_util.dart';

import 'currency_msg.dart';

///用户名片消息
// ignore: must_be_immutable
class UserMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final UserModel userModel;
  final int status;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final bool isCanLongClick;
  final int sendTime;
  final int position;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Function(void Function(),String longClickString) setCallRemoveOverlay;

  UserMsg(
      {this.userModel,
      this.isMyself,
      this.userUrl,
      this.name,
      this.status,
      this.sendTime,
      this.isShowChatUserName = false,
      this.isCanLongClick = true,
      this.sendChatUserId,
      this.position,
      this.voidMessageClickCallBack,
      this.setCallRemoveOverlay,
      this.voidItemLongClickCallBack});

  @override
  Widget build(BuildContext context) {
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
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
        mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status, position: position, voidMessageClickCallBack: voidMessageClickCallBack),
      ),
      Spacer(),
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
      SizedBox(
        width: 7,
      ),
      getNameAndContentUi(),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //判断有没有名字
  Widget getNameAndContentUi() {
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
          _getUserUiLongClick(),
        ],
      ),
    );
  }

//长按事件
  Widget _getUserUiLongClick() {
    List<String> longClickStringList =
        getLongClickStringList(isMySelf: isMyself,
            status: status, sendTime: sendTime, contentType: ChatTypeModel.MESSAGE_TYPE_USER);
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
            position: position, settingType: longClickStringList[value], contentType: ChatTypeModel.MESSAGE_TYPE_USER);
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text(longClickStringList[value]), duration: Duration(milliseconds: 500),));
      },
      setCallRemoveOverlay:setCallRemoveOverlay,
      position:position,
      isCanLongClick: isCanLongClick,
      contentType: ChatTypeModel.MESSAGE_TYPE_USER,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: 180.0,
      contentHeight: MessageItemHeightUtil.init().getUserMsgDataHeight(isShowChatUserName, isOnlyContentHeight: true),
      child: GestureDetector(
        child: _getUserUi(),
        onTap: () {
          voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_USER, map: userModel.toJson());
          // ToastShow.show(msg: "点击了名片-该跳转", context: context);
        },
      ),
    );
  }

  //获取动态框
  Widget _getUserUi() {
    return Container(
      width: 180,
      height: 150,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          _getShowPicBg(),
          SizedBox(
            height: 8,
          ),
          _getBottomText(),
        ],
      ),
    );
  }

  //获取背景图片
  Widget _getShowPicBg() {
    return Container(
      width: double.infinity,
      height: 83.5,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(3), topLeft: Radius.circular(3)),
                  child: Container(
                    child:  Stack(
                      children: [
                        Container(
                          color: Colors.white.withOpacity(0.1),
                          width:double.infinity,
                          height: double.infinity,
                          child: Image.network(
                            FileUtil.getSmallImage(userModel.avatarUri),
                            fit: BoxFit.cover,
                          ),
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.white.withOpacity(0.1),
                            width:double.infinity,
                            height: double.infinity,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 13.5,
                color: AppColor.white,
              ),
            ],
          ),
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(47.0 / 2),
              border: Border.all(color: AppColor.white, width: 2),
            ),
            child: getUserImage(FileUtil.getSmallImage(userModel.avatarUri), 47, 47),
          ),
        ],
      ),
    );
  }

  //底部文字
  Widget _getBottomText() {
    return Expanded(
      child: SizedBox(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Column(
            children: [
              Text(
                userModel.nickName != null ? userModel.nickName : "",
                style: AppStyle.textPrimary2Medium15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                userModel.description != null ? userModel.description : "",
                style: AppStyle.textSecondaryRegular13,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
