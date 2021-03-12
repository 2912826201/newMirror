
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';

import 'live_room_test_page_1.dart';

class LiveRoomTestPage extends StatefulWidget {
  @override
  _LiveRoomTestPageState createState() => _LiveRoomTestPageState();
}

class _LiveRoomTestPageState extends State<LiveRoomTestPage> {
  List<Widget> textArray=[];

  @override
  void initState() {
    super.initState();

    EventBus.getDefault().register(exit,"LiveRoomTestPage",registerName: "LiveRoomTestPage-exit");

    for(int i=0;i<100;i++){
      textArray.add(Text("$i"));
    }
  }

  void exit(name){
    Future.delayed(Duration(milliseconds: 100),(){
      EventBus.getDefault().unRegister(pageName:"LiveRoomTestPage",registerName: "LiveRoomTestPage-exit");
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        child: Stack(
          children: [
            getShowVideoUi(),
            getOccludeUi(),
            // getTopUi(),
          ],
        ),
      ),
    );
  }

  //展示直播的ui
  Widget getShowVideoUi(){
    return Container(
      color: Color(0xff14726F),
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: SingleChildScrollView(
        child: Column(
          children: textArray,
        ),
      ),
    );
  }


  Widget getTopUi(){
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight+8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          getTopInformationUi(),
          SizedBox(height: 16),
          otherUserUi(),
        ],
      ),
    );

  }


  //其他用户-一起运动
  Widget otherUserUi(){
    return Container(
      height: 36.0,
      width: 120.0,
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.06),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24),bottomLeft: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Container(
            width: 21.0*3-12.0,
            height: 21.0,
            child: Stack(
              children: [
                Positioned(
                  child: getUserImage(null,21,21),
                  right: 0,
                ),
                Positioned(
                  child: getUserImage(null,21,21),
                  right: 12,
                ),
                Positioned(
                  child: getUserImage(null,21,21),
                  right: 24,
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Text("一起运动",style: TextStyle(fontSize: 10,color: AppColor.white.withOpacity(0.85))),
          SizedBox(width: 16),
        ],
      ),
    );
  }
  Widget getTopInformationUi(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          getCoachNameUi(),
          Expanded(child: SizedBox()),
          trainingTimeUi(),
        ],
      ),
    );
  }


  Widget getCoachNameUi(){
    return UnconstrainedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11,vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getUserImage(null,28,28),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("洪荒少女我FaceJu",style: TextStyle(fontSize: 11,color: AppColor.white.withOpacity(0.85))),
                Text("在线人数8524.2万",style: TextStyle(fontSize: 9,color: AppColor.white.withOpacity(0.65))),
              ],
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 11,vertical: 2),
              child: Text("关注",style: TextStyle(fontSize: 10,color: AppColor.white)),
            )
          ],
        ),
      ),
    );
  }


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
  //训练
  Widget trainingTimeUi(){
    return Container(
      child: Column(
        children: [
          Text("120:23",style: TextStyle(fontSize: 18,color: AppColor.white.withOpacity(0.85))),
          Text("训练时长",style: TextStyle(fontSize: 10,color: AppColor.white.withOpacity(0.35))),
        ],
      ),
    );
  }


  //遮挡
  Widget getOccludeUi(){
    return Container(
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.35),
                  AppColor.textPrimary1.withOpacity(0.001),
                ],
              ),
            ),
          ),
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.001),
                  AppColor.textPrimary1.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
