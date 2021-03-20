

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/seekbar.dart';
import 'package:volume_watcher/volume_watcher.dart';

//底部设置面板
Future openBottomOnlineManNumberDialog({
  @required BuildContext buildContext,
  @required List<BuddyModel> onlineManList,
  @required int liveRoomId,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: buildContext,
      enableDrag: false,
      backgroundColor: AppColor.transparent,
      builder: (BuildContext context) {
        return BottomUserPanel(
            onlineManList:onlineManList,
            liveRoomId:liveRoomId);
      });
}

class BottomUserPanel extends StatefulWidget {
  final List<BuddyModel> onlineManList;
  final int liveRoomId;


  const BottomUserPanel({
    Key key,
    @required this.onlineManList,@required this.liveRoomId,}) : super(key: key);
  @override
  _BottomUserPanelState createState() => _BottomUserPanelState();
}

class _BottomUserPanelState extends State<BottomUserPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.white,
      ),
      constraints: BoxConstraints(
        maxHeight: 48.0*max(1, min(7, widget.onlineManList.length))+44+10+ScreenUtil.instance.bottomBarHeight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getSettingTitle(),
          getListView(),
        ],
      ),
    );
  }


  Widget getSettingTitle(){
    return Container(
      height: 44,
      child: Row(
        children: [
          Expanded(child: SizedBox(child: Container(
            height: 44,
            margin: const EdgeInsets.only(left: 44.0),
            alignment: Alignment.center,
            child: Text(
              "在线用户",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary2),
            ),
          ),)),
          GestureDetector(
            child: Container(
              height: 44,
              width: 44,
              child: Icon(Icons.close,size: 16,color: AppColor.textPrimary2),
            ),
            onTap: ()=>Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  //list
  Widget getListView(){
    return Container(
      constraints: BoxConstraints(
        maxHeight: 48.0*max(1, min(7, widget.onlineManList.length)),
      ),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context,index){
          return getListViewItem(widget.onlineManList[index],index);
        },
        itemCount:widget.onlineManList.length,
      ),
    );
  }

  //item
  Widget getListViewItem(BuddyModel buddyModel,int index){
    return Container(
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      child: Row(
        children: [
          getUserImage(buddyModel.avatarUri,28,28),
          SizedBox(width: 12),
          Expanded(child: SizedBox(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                buddyModel.nickName,
                style: TextStyle(fontSize: 14,color: AppColor.textPrimary1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateUtil.formatTimeString(DateUtil.getDateTimeByMs(buddyModel.time))+
                "进入了直播间",
                style: TextStyle(fontSize: 10,color: AppColor.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),)),
        ],
      ),
    );
  }
}





