import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/page/message/item/widget_ver.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

//点击事件返回
typedef VoidMessageClickCallBack = void Function(
    {String contentType,
    String content,
    Map<String, dynamic> map,
    bool isUrl,
    int position});
typedef VoidItemLongClickCallBack = void Function(
    {int position,
    String settingType,
    Map<String, dynamic> map,
    String contentType,
    String content});

//获取用户的头像
Widget getUserImage(String imageUrl, double height, double width) {
  if (imageUrl == null || imageUrl == "") {
    imageUrl =
        "http://pic.netbian.com/uploads/allimg/201220/220540-16084731404798.jpg";
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(height / 2),
    child: CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl == null ? "" : imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Image.asset(
        "images/test/bg.png",
        fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) => Image.asset(
        "images/test/bg.png",
        fit: BoxFit.cover,
      ),
    ),
  );
}

//获取消息的状态
//   RCSentStatus
//   static const int Sending = 10; //发送中
//   static const int Failed = 20; //发送失败
//   static const int Sent = 30; //发送成功
//   static const int Received = 40; //对方已接收
//   static const int Read = 50; //对方已阅读
//isRead我是否阅读这个消息
Widget getMessageState(int status, {bool isRead = true, bool isMyself}) {
  if (status == RCSentStatus.Sending) {
    //发送中
    return Container(
      width: 28.0,
      height: 28.0,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: CupertinoActivityIndicator(
        radius: 14,
      ),
    );
  } else if (status == RCSentStatus.Failed) {
    //发送失败
    return Container(
      width: 28.0,
      height: 28.0,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.sms_failed,
        size: 28,
        color: Colors.red,
      ),
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

//获取直播课标识动态效果
Widget getLiveStateUi() {
  return Container(
    height: 17,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xffFD868A),
          Color(0xffFE5668),
          Color(0xffFF4059),
        ],
      ),
      borderRadius: BorderRadius.circular(17 / 2),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 5,
        ),
        WidgetVer(),
        SizedBox(
          width: 3,
        ),
        Text(
          "LIVE",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        SizedBox(
          width: 5,
        ),
      ],
    ),
  );
}

//获取长按操作的选项框
List<String> getLongClickStringList(
    {@required bool isMySelf, @required String contentType}) {
  List<String> longClickStringList = <String>[];
  longClickStringList.add("删除");
  if (isMySelf) {
    longClickStringList.insert(0, "撤回");
  }
  if (contentType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
    longClickStringList.insert(0, "复制");
  }
  return longClickStringList;
}


