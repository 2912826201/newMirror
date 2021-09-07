import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/widget/long_click_popup_menu.dart';
import '../util/message_item_height_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';

import 'package:mirror/page/message/widget/currency_msg.dart';

///动态消息
// ignore: must_be_immutable
class ActivityInviteMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final ActivityModel activityModel;
  final int status;
  final int position;
  final int sendTime;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final bool isCanLongClick;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Function(void Function(), String longClickString) setCallRemoveOverlay;

  ActivityInviteMsg({
    this.userUrl,
    this.name,
    this.sendTime,
    this.isShowChatUserName = false,
    this.isCanLongClick = true,
    this.sendChatUserId,
    this.isMyself,
    this.activityModel,
    this.status,
    this.position,
    this.voidMessageClickCallBack,
    this.voidItemLongClickCallBack,
    this.setCallRemoveOverlay,
  });

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
        child: getUserImageWidget(userUrl, sendChatUserId, 38, 38),
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
                  isMyself ? const EdgeInsets.only(right: 10, bottom: 5) : const EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                name ?? "",
                style: AppStyle.text1Regular12,
              ),
            ),
          ),
          _getActivityInviteUiLongClickUi(),
        ],
      ),
    );
  }

  //获取动态的长按事件
  Widget _getActivityInviteUiLongClickUi() {
    List<String> longClickStringList = getLongClickStringList(
      isMySelf: isMyself,
      contentType: ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE,
      sendTime: sendTime,
      status: status,
    );
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
            position: position,
            settingType: longClickStringList[value],
            contentType: ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE);
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text(longClickStringList[value]), duration: Duration(milliseconds: 500),));
      },
      position: position,
      setCallRemoveOverlay: setCallRemoveOverlay,
      isCanLongClick: isCanLongClick,
      contentType: ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: 180.0,
      contentHeight: MessageItemHeightUtil.init()
          .getFeedMsgDataHeight(activityModel.toJson(), isShowChatUserName, isOnlyContentHeight: true),
      child: GestureDetector(
        child: _getActivityInviteUi(),
        onTap: () {
          voidMessageClickCallBack(
              contentType: ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE, map: activityModel.toJson());
        },
      ),
    );
  }

  //获取动态框
  Widget _getActivityInviteUi() {
    return Container(
      width: 180,
      height: 180.0 + 75.0,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: AppColor.layoutBgGrey,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          _getShowPic(),
          _getBottomText(),
        ],
      ),
    );
  }

  //获取显示的图片
  Widget _getShowPic() {
    String showUrl = FileUtil.getLargeImage(activityModel.pic);
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(topRight: Radius.circular(3), topLeft: Radius.circular(3)),
        child: CachedNetworkImage(
          height: double.infinity,
          width: double.infinity,
          imageUrl: showUrl == null ? "" : showUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColor.imageBgGrey,
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColor.imageBgGrey,
          ),
        ),
      ),
    );
  }

  //底部文字
  Widget _getBottomText() {
    return Container(
      width: double.infinity,
      height: 75.0,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: Center(
                child: Container(
                  width: double.infinity,
                  child: Text(activityModel.title ?? "",
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppStyle.whiteRegular14),
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Center(
                child: Container(
                  width: double.infinity,
                  child:
                      Text("快来和我一起参加吧!", maxLines: 1, overflow: TextOverflow.ellipsis, style: AppStyle.whiteRegular16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
