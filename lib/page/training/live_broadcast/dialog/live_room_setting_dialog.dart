

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/seekbar.dart';
import 'package:volume_watcher/volume_watcher.dart';

//底部设置面板
Future openBottomSetDialog({
  @required BuildContext buildContext,
  @required Function(bool isCleaningMode) voidCallback,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: buildContext,
      enableDrag: false,
      backgroundColor: AppColor.transparent,
      builder: (BuildContext context) {
        return BottomSettingPanel(voidCallback:voidCallback);
      });
}

class BottomSettingPanel extends StatefulWidget {
  final Function(bool isCleaningMode) voidCallback;


  const BottomSettingPanel({
    Key key,
    @required this.voidCallback,}) : super(key: key);
  @override
  _BottomSettingPanelState createState() => _BottomSettingPanelState();
}

class _BottomSettingPanelState extends State<BottomSettingPanel> {

  double maxVolume;
  double currentVolume;
  double volumeProgress = 0;

  int listenerId;

  bool isOpen=false;

  @override
  void initState() {
    getVolume();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(isOpen&&widget.voidCallback!=null){
      widget.voidCallback(isOpen);
    }
    VolumeWatcher.hideVolumeView = false;
    VolumeWatcher.removeListener(listenerId);
  }
  Future<void> getVolume() async {
    VolumeWatcher.hideVolumeView = true;

    currentVolume = await VolumeWatcher.getCurrentVolume;
    maxVolume = await VolumeWatcher.getMaxVolume;

    volumeProgress = 100 * currentVolume / maxVolume;

    listenerId = VolumeWatcher.addListener((volume) {
      print("音量：$volume");
      setState(() {
        currentVolume = volume;
        volumeProgress = 100 * currentVolume / maxVolume;
      });
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.white,
      ),
      height: 141 +87.0+10+ScreenUtil.instance.bottomBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getSettingTitle(),
          getVolumeUi(),
          ClearScreenBtn(),
          getMeTerminalBtn(),
        ],
      ),
    );
  }


  Widget getSettingTitle(){
    return Container(
      height: 44,
      alignment: Alignment.center,
      child: Text(
        "设置",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary2),
      ),
    );
  }

  Widget getVolumeUi(){
    return Container(
      height: 48,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "音量",
            style: AppStyle.textRegular16,
          ),
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: AppSeekBar(100, 0, volumeProgress, false, (handlerIndex, lowerValue, upperValue) {
              VolumeWatcher.setVolume(maxVolume * lowerValue / 100);
            }, (handlerIndex, lowerValue, upperValue) {}),
          ),
          SizedBox(
            width: 32,
          ),
          Container(
            width: 42,
            alignment: Alignment.center,
            child: Text(
              "${volumeProgress.toInt()}%",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textPrimary2),
            ),
          ),
        ],
      ),
    );
  }

  //清屏
  Widget ClearScreenBtn(){
    return Container(
      height: 87.0,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: SizedBox(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("清屏", style: AppStyle.textRegular16),
              SizedBox(height: 12),
              Text(
                  "只展示直播画面，其他隐藏，点击屏幕可恢复",
                  style: AppStyle.textSecondaryRegular12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ))),
          Container(
            width: 50,
            height: 60,
            child: Container(
              child: Transform.scale(
                scale: 0.75,
                child: CupertinoSwitch(
                  activeColor: AppColor.mainRed,
                  value: isOpen,
                  onChanged: (bool value) {
                    setState(() {
                      isOpen=!isOpen;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  //我的终端设备按钮
  Widget getMeTerminalBtn(){
    return Container(
      height: 48.0,
      child: GestureDetector(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32.5,vertical: 5),
          color: AppColor.textPrimary1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: Icon(Icons.phone_android,size: 16,color: AppColor.white),
              ),
              SizedBox(width: 9),
              Text("我的终端设备",style: TextStyle(fontSize: 16,color: AppColor.white)),
            ],
          ),
        ),
        onTap: (){
          ToastShow.show(msg: "我的终端设备", context: context);
        },
      ),
    );
  }

}





