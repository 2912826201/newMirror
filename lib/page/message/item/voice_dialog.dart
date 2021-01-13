import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:provider/provider.dart';

//语音的dialog
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

  @override
  Widget build(BuildContext context) {
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

}
