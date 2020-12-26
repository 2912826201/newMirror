import 'package:flutter/cupertino.dart';

class VoiceAlertData extends ChangeNotifier {
  VoiceAlertData(
      {this.alertText = "手指上滑,取消发送",
      this.imageString = "images/chat/voice_volume_2.webp",
      this.showDataTime = "0:00"});

  String alertText = "手指上滑,取消发送";
  String imageString = "images/chat/voice_volume_2.webp";
  String showDataTime = "0:00";

  changeCallback({String alertText, String imageString, String showDataTime}) {
    if (alertText != null) {
      this.alertText = alertText;
    }
    if (imageString != null) {
      this.imageString = imageString;
    }
    if (showDataTime != null) {
      this.showDataTime = showDataTime;
    }
    notifyListeners();
  }
}
