import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/page/message/item/widget_ver.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

//获取用户的头像
Widget getUserImage(String imageUrl, double height, double width) {
  imageUrl =
      "http://pic.netbian.com/uploads/allimg/201220/220540-16084731404798.jpg";
  return ClipRRect(
    borderRadius: BorderRadius.circular(height / 2),
    child: CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl == null ? "" : imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Image.asset(
        "images/test.png",
        fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) => Image.asset(
        "images/test.png",
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
Widget getMessageState(int status) {
  if (status == RCSentStatus.Sending) {
    //发送中
    return Container(
      width: 28.0,
      height: 28.0,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Icon(
        Icons.cloud_circle,
        size: 28,
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
