import 'package:flutter/cupertino.dart';
import 'package:mirror/widget/icon.dart';

//手指上滑-取消发送
String moveUpCancelPostImageString=AppIcon.voice_microphone;

//说话时间太短
String speckTimeTooShortImageString=AppIcon.voice_error;

//松开手指-取消发送
String letGoOfYourFingerCancelPostImageString=AppIcon.voice_cancel;

class VoiceAlertData extends ChangeNotifier {

  VoiceAlertData();

  String alertText = "手指上滑,取消发送";
  Widget imageIconWidget = AppIconButton(
    svgName: AppIcon.like_24,
    iconSize: 48,
    onTap: () {},
  );
  String showDataTime = "0:00";

  changeCallback({String alertText, String imageIconString, String showDataTime}) {
    if (alertText != null) {
      this.alertText = alertText;
    }
    if (imageIconString != null) {
      this.imageIconWidget = AppIconButton(
        svgName: imageIconString,
        iconSize: 48,
        onTap: () {},
      );
    }
    if (showDataTime != null) {
      this.showDataTime = showDataTime;
    }
    notifyListeners();
  }
}
