import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

//语音的dialog
showVoiceDialog(BuildContext context) {
  OverlayEntry overlayEntry = new OverlayEntry(builder: (content) {
    return Positioned(
      child: new VoiceDialog(),
    );
  });
  Overlay.of(context).insert(overlayEntry);

  return overlayEntry;
}

class VoiceDialog extends StatefulWidget {

  @override
  _VoiceDialogState createState() => _VoiceDialogState();
}

class _VoiceDialogState extends State<VoiceDialog> {
  String alertText = "手指上滑,取消发送";

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        child: Container(
          color: Colors.transparent,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Positioned(
                bottom: 100,
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.layoutBgGrey,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 60,
                        child: context.watch<VoiceAlertData>().imageIconWidget,
                      ),
                      Text(
                        context.watch<VoiceAlertData>().showDataTime,
                        style: AppStyle.whiteRegular14,
                      ),
                      Text(
                        context.watch<VoiceAlertData>().alertText,
                        style: context.watch<VoiceAlertData>().alertText.contains("松开")
                            ? AppStyle.redRegular14
                            : AppStyle.whiteRegular14,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
