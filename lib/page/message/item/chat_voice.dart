import 'dart:io';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:path_provider/path_provider.dart';
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

  FlutterSoundPlayer playerModule;
  FlutterSoundRecorder recorderModule;
  bool isHide = true;
  int costTime = 0;
  t_CODEC _codec = t_CODEC.CODEC_AAC;
  List<String> records = [];

  ///默认隐藏状态
  bool voiceState = true;
  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    playerModule = await FlutterSoundPlayer().initialize();
    recorderModule = await FlutterSoundRecorder().initialize();
  }

  void start() async {
    costTime = 0;
    print('开始拉。当前路径');
    context.read<VoiceAlertData>().changeCallback(
        alertText: "手指上滑,取消发送",
        imageString: "images/chat/voice_volume_2.webp",
        showDataTime: "0:00");
    Directory tempDir = await getTemporaryDirectory();
    String path = await recorderModule.startRecorder(
      uri:
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}-${Platform.isAndroid ? "aac" : "m4a"}',
      codec: _codec,
    );
    records.add(path);
    print(path);
    recorderModule.onRecorderStateChanged.listen((e) {
      if (e != null && e.currentPosition != null) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        context.read<VoiceAlertData>().changeCallback(
            showDataTime: DateUtil.formatSecondToStringNum(costTime));
        setState(() {
          costTime = date.second;
        });
      }
    });
  }

  void stop() async {
    print('结束了。当前路径');
    await recorderModule.stopRecorder();
    setState(() {
      isHide = true;
    });
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

    start();

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

    stop();

    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }

    if (isUp) {
      print("取消发送");
      records.removeLast();
    } else {
      print("进行发送");
      widget.voiceFile(records[records.length - 1], costTime);
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
        width: MediaQuery.of(context).size.width,
        decoration: textShow == "按住说话" ? noSelectBoxUiStyle : selectBoxUiStyle,
        child: Text(
          textShow,
          style: TextStyle(fontSize: 14, color: AppColor.white),
        ),
      ),
    );
  }
}
