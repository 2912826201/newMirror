
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';

import 'live_room_test_page_1.dart';

class LiveRoomTestPage extends StatefulWidget {
  @override
  _LiveRoomTestPageState createState() => _LiveRoomTestPageState();
}

class _LiveRoomTestPageState extends XCState {
  final String url = "rtmp://58.200.131.2:1935/livetv/cctv13";
  List<Widget> textArray=[];
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();

    player.setDataSource(url, autoPlay: true);
    EventBus.getDefault().register(exit,EVENTBUS_LIVEROOM_TESTPAGE,registerName: EVENTBUS_LIVEROOM_EXIT);

    for(int i=0;i<100;i++){
      textArray.add(Text("$i"));
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }

  void exit(name){
    Future.delayed(Duration(milliseconds: 100),(){
      EventBus.getDefault().unRegister(pageName:EVENTBUS_LIVEROOM_TESTPAGE,registerName: EVENTBUS_LIVEROOM_EXIT);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        child: Stack(
          children: [
            getShowVideoUi(),
            getOccludeUi(),
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
            children: [
              Container(
                width: ScreenUtil.instance.width,
                height: ScreenUtil.instance.height,
                child: FijkView(
                  player: player,
                  color: AppColor.bgBlack,
                  fit: FijkFit.cover,
                  fsFit: FijkFit.cover,
                  cover: AssetImage("images/test.png"),
                ),
              )
            ],
          )
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
