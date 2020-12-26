import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:provider/provider.dart';

showVoiceDialog(BuildContext context, {int index}) {
  OverlayEntry overlayEntry = new OverlayEntry(builder: (content) {
    return Positioned(
      child: new VoiceDialog(index),
    );
  });
  Overlay.of(context).insert(overlayEntry);

  return overlayEntry;
}

class VoiceDialog extends StatefulWidget {
  final int index;

  VoiceDialog(this.index);

  @override
  _VoiceDialogState createState() => _VoiceDialogState();
}

class _VoiceDialogState extends State<VoiceDialog> {
  String alertText = "手指上滑,取消发送";
  Duration duration;
  Timer timer;
  int costTime = 0;

  @override
  Widget build(BuildContext context) {
    int index = widget.index;

    String icon() {
      if (index > 0 && index <= 16) {
        return 'images/chat/voice_volume_2.webp';
      } else if (16 < index && index <= 32) {
        return 'images/chat/voice_volume_3.webp';
      } else if (32 < index && index <= 48) {
        return 'images/chat/voice_volume_4.webp';
      } else if (48 < index && index <= 64) {
        return 'images/chat/voice_volume_5.webp';
      } else if (64 < index && index <= 80) {
        return 'images/chat/voice_volume_6.webp';
      } else if (80 < index && index <= 99) {
        return 'images/chat/voice_volume_7.webp';
      } else {
        return 'images/chat/voice_volume_1.webp';
      }
    }

    return Material(
      type: MaterialType.transparency,
      child: Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Positioned(
              bottom: 100,
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.textPrimary1,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Image.asset(
                            context.watch<VoiceAlertData>().imageString,
                            width: 46,
                            height: 60),
                      ),
                      Text(
                        context.watch<VoiceAlertData>().showDataTime,
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        context.watch<VoiceAlertData>().alertText,
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    duration = Duration(milliseconds: 800);
    Timer.periodic(duration, (timer) {
      //1s 回调一次
      // print('定时任务时间：${DateTime.now().toString()}');
      // 刷新页面
      try {
        context.read<VoiceAlertData>().changeCallback(
              imageString: getVoiceImage(costTime++),
            );
      } catch (e) {
        // 取消定时器
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 取消定时器
    if (timer != null) {
      timer.cancel();
    }
  }

  String getVoiceImage(int index) {
    if (index % 7 == 0) {
      return 'images/chat/voice_volume_1.webp';
    } else if (index % 7 == 1) {
      return 'images/chat/voice_volume_2.webp';
    } else if (index % 7 == 2) {
      return 'images/chat/voice_volume_3.webp';
    } else if (index % 7 == 3) {
      return 'images/chat/voice_volume_4.webp';
    } else if (index % 7 == 4) {
      return 'images/chat/voice_volume_5.webp';
    } else if (index % 7 == 5) {
      return 'images/chat/voice_volume_6.webp';
    } else {
      return 'images/chat/voice_volume_7.webp';
    }
  }
}
