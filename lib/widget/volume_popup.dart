import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:volume_watcher/volume_watcher.dart';

import 'seekbar.dart';

/// volume_popup
/// Created by yangjiayi on 2021/1/6.

showVolumePopup(BuildContext context) {
  showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return _VolumePopup();
      });
}

class _VolumePopup extends StatefulWidget {
  @override
  _VolumePopupState createState() => _VolumePopupState();
}

class _VolumePopupState extends State<_VolumePopup> {
  double maxVolume;
  double currentVolume;
  double volumeProgress = 0;

  int listenerId;

  @override
  void initState() {
    getVolume();
    super.initState();
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
  void dispose() {
    super.dispose();
    VolumeWatcher.hideVolumeView = false;
    VolumeWatcher.removeListener(listenerId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.white,
      ),
      height: 141 + ScreenUtil.instance.bottomBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 44,
            alignment: Alignment.center,
            child: Text(
              "设置",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary2),
            ),
          ),
          Container(
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
          )
        ],
      ),
    );
  }
}
