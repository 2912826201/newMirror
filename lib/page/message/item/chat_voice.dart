import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'voice_dialog.dart';

typedef VoiceFile = void Function(String path, int time);

//语音界面
class ChatVoice extends StatefulWidget {
  final VoiceFile voiceFile;

  ChatVoice({this.voiceFile});

  @override
  _ChatVoiceWidgetState createState() => _ChatVoiceWidgetState();
}

class _ChatVoiceWidgetState extends State<ChatVoice> {
  double startY = 0.0;
  double offset = 0.0;
  int index;

  bool isUp = false;
  String textShow = "按住说话";
  var selectBoxUiStyle = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: AppColor.textPrimary1.withOpacity(0.5),
  );
  var noSelectBoxUiStyle = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: AppColor.textPrimary1,
  );
  String toastShow = "手指上滑,取消发送";
  String voiceIco = "images/voice_volume_1.png";

  bool isHide = true;
  int costTime = 0;
  List<String> records = [];

  ///默认隐藏状态
  bool voiceState = true;
  OverlayEntry overlayEntry;

  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath;

  @override
  void initState() {
    super.initState();

    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
  }


  @override
  void dispose() {
    stopPlayer();
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    if (_mPath != null) {
      var outputFile = File(_mPath);
      if (outputFile.existsSync()) {
        outputFile.delete();
      }
    }
    super.dispose();
  }

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    print(_mPath);
    _mplaybackReady = true;

    setState(() {
      isHide = true;
    });
  }


  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
  }

  void startRecorder() async {
    assert(_mRecorderIsInited && _mPlayer.isStopped);
    await _mRecorder.startRecorder(
      toFile: _mPath,
      codec: Codec.aacADTS,
    );
    setState(() {});
  }

  showVoiceView() {
    print("showVoiceView");
    isUp = false;
    int index;
    setState(() {
      textShow = "松开结束";
      voiceState = false;
      DateTime now = new DateTime.now();
      int date = now.millisecondsSinceEpoch;
      DateTime current = DateTime.fromMillisecondsSinceEpoch(date);
      String recordingTime = DateUtil.formatDateV(current, format: "ss:SS");
      index = int.parse(recordingTime.toString().substring(3, 5));
    });

    startRecorder();

    if (overlayEntry == null) {
      overlayEntry = showVoiceDialog(context, index: index);
    }
  }

  hideVoiceView() {
    print("hideVoiceView");
    setState(() {
      textShow = "按住说话";
      voiceState = true;
    });

    stopRecorder();

    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }

    if (isUp) {
      print("取消发送");
      records.removeLast();
    } else {
      print("进行发送");
      widget.voiceFile(AppConfig.getAppVoiceFilePath(), costTime);
    }
    print(records.toString());
  }

  moveVoiceView() {
    print("moveVoiceView");
    setState(() {
      isUp = startY - offset > 80 ? true : false;
      if (isUp) {
        textShow = "松开手指,取消发送";
        toastShow = textShow;
        context.read<VoiceAlertData>().changeCallback(alertText: "松开手指,取消发送");
      } else {
        textShow = "松开结束";
        toastShow = "手指上滑,取消发送";
        context.read<VoiceAlertData>().changeCallback(alertText: "手指上滑,取消发送");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onVerticalDragStart: (details) {
        startY = details.globalPosition.dy;
        showVoiceView();
      },
      onVerticalDragDown: (details) {
        startY = details.globalPosition.dy;
        showVoiceView();
      },
      onVerticalDragCancel: () => hideVoiceView(),
      onVerticalDragEnd: (details) => hideVoiceView(),
      onVerticalDragUpdate: (details) {
        offset = details.globalPosition.dy;
        moveVoiceView();
      },
      child: new Container(
        height: 32.0,
        alignment: Alignment.center,
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: textShow == "按住说话" ? noSelectBoxUiStyle : selectBoxUiStyle,
        child: Text(
          textShow,
          style: TextStyle(fontSize: 14, color: AppColor.white),
        ),
      ),
    );
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    // var tempDir = await getTemporaryDirectory();
    // _mPath = '${tempDir.path}/flutter_sound_example.aac';
    _mPath = AppConfig.getAppVoiceFilePath();
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }
}
