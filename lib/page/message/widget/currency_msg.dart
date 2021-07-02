import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/user_avatar_image.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

///每一种消息 共用的方法 或者ui

//点击事件返回
typedef VoidMessageClickCallBack = void Function(
    {String contentType, String content, Map<String, dynamic> map, bool isUrl, String msgId, int position});
typedef VoidItemLongClickCallBack = void Function(
    {int position, String settingType, Map<String, dynamic> map, String contentType, String content});

//获取用户的头像
Widget getUserImageWidget(String imageUrl,String userId, double width,[double height] ) {

  return UserAvatarImageUtil.init().getUserImageWidget(imageUrl, userId, width);

}

//获取消息的状态
//   RCSentStatus
//   static const int Sending = 10; //发送中
//   static const int Failed = 20; //发送失败
//   static const int Sent = 30; //发送成功
//   static const int Received = 40; //对方已接收
//   static const int Read = 50; //对方已阅读
//isRead我是否阅读这个消息
Widget getMessageState(int status,
    {bool isRead = true, bool isMyself, int position, VoidMessageClickCallBack voidMessageClickCallBack}) {
  if (status == RCSentStatus.Sending) {
    //发送中
    return Container(
      width: 24.0,
      height: 24.0,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: CupertinoActivityIndicator(
        radius: 10,
      ),
    );
  } else if (status == RCSentStatus.Failed) {
    //发送失败
    return GestureDetector(
      child: Container(
        width: 28.0,
        height: 28.0,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: AppIcon.getAppIcon(AppIcon.message_send_error, 28),
      ),
      onTap: () {
        if (voidMessageClickCallBack != null && position != null) {
          voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_CLICK_ERROR_BTN, position: position);
        }
      },
    );
  } else if (!isRead && !isMyself) {
    //我没有阅读
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7 / 2.0),
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7 / 2.0),
            color: AppColor.mainRed,
          ),
        ),
      ),
    );
  } else if (status == RCSentStatus.Sent) {
    //发送成功
    return Container();
  } else if (status == RCSentStatus.Received) {
    //对方已接收
    return Container();
  } else if (status == RCSentStatus.Read) {
    //对方已阅读
    return Container();
  } else {
    //未知
    return Container();
  }
}

//获取长按操作的选项框
List<String> getLongClickStringList({
  @required bool isMySelf,
  @required int status,
  @required String contentType,
  @required int sendTime,
  String content="",
}) {
  List<String> longClickStringList = <String>[];
  longClickStringList.add("删除");
  // print("isMySelf:$isMySelf");
  if (isMySelf &&
      DateUtil.judgeTwoMinuteNewDateTime(DateUtil.getDateTimeByMs(sendTime)) &&(
      status==RCSentStatus.Sent||
      status==RCSentStatus.Read||
      status==RCSentStatus.Received
  )) {
    longClickStringList.insert(0, "撤回");
  }
  if (contentType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
    longClickStringList.insert(0, "复制");
  }
  if (contentType == ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON&&content!=null&&content.length>0) {
    longClickStringList.insert(0, "复制");
  }
  return longClickStringList;
}
