import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
// import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/message/chat_voice_setting.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:file/src/backends/local/local_file_system.dart';

import 'voice_dialog.dart';

///底部语音按钮
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

  bool isHide = true;
  int costTime = 0;
  List<String> records = [];

  ///默认隐藏状态
  bool voiceState = true;
  OverlayEntry overlayEntry;

  // FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();

  LocalFileSystem localFileSystem=LocalFileSystem();

  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  String _mPath;

  Timer _timer;

  bool automaticPost = false;

  @override
  void initState() {
    super.initState();
    init();
    // openTheRecorder().then((value) {});
  }

  init()async{
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "沒有权限";
    }
  }

  @override
  void dispose() {
    stopRecorder();
    // _mRecorder.closeAudioSession();
    // _mRecorder = null;
    if (_mPath != null) {
      var outputFile = File(_mPath);
      if (outputFile.existsSync()) {
        outputFile.delete();
      }
    }

    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
    super.dispose();
  }

  Future<void> stopRecorder() async {

    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = localFileSystem.file(result.path);
    print("File length: ${await file.length()}");



    // await _mRecorder.stopRecorder();
    //print(_mPath);
    if (context != null) {
      setState(() {
        isHide = true;
      });
    }
  }

  void startRecorder() async {
    _recorder = FlutterAudioRecorder(_mPath); // .wav .aac .m4a
    await _recorder.initialized;
    await _recorder.start();
    var recording = await _recorder.current(channel: 0);

    //
    // await _mRecorder.startRecorder(
    //   toFile: _mPath,
    //   codec: Codec.aacADTS,
    //   bitRate: 8000,
    //   numChannels: 1,
    //   sampleRate: 8000,
    // );
    initTimer();
    setState(() {});
  }

  showVoiceView() async {
    //print("55555555555555555");
    if (this.automaticPost) {
      return;
    }
    //print("444444444444444");
    costTime = 0;
    context.read<VoiceAlertData>().changeCallback(
        showDataTime: DateUtil.formatSecondToStringNumShowMinute(costTime),
        imageIconString: moveUpCancelPostImageString,
        alertText: "手指上滑,取消发送");

    _mPath = AppConfig.getAppVoiceFilePath();
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }

    isUp = false;
    int index;
    setState(() {
      textShow = "松开发送";
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

  hideVoiceView(bool automaticPost) async {
    if (this.automaticPost) {
      this.automaticPost = automaticPost;
      return;
    }
    this.automaticPost = automaticPost;
    // //print("hideVoiceView");
    setState(() {
      textShow = "按住说话";
      voiceState = true;
    });

    stopRecorder();

    if (_timer != null) {
      // costTime = _timer.tick + 1;
      _timer.cancel();
      _timer = null;
    }
    if (costTime < minRecordVoiceDuration + 1) {
      context.read<VoiceAlertData>().changeCallback(
            alertText: "说话时间太短",
            imageIconString: speckTimeTooShortImageString,
          );
      var outputFile = File(_mPath);
      if (outputFile.existsSync()) {
        await outputFile.delete();
      }
      Future.delayed(Duration(milliseconds: 600), () {
        if (overlayEntry != null) {
          overlayEntry.remove();
          overlayEntry = null;
        }
      });
    } else {
      if (overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
      }
      if (isUp) {
        //print("取消发送");
        if (records.length > 0) {
          records.removeLast();
        }
      } else {
        //print("进行发送");
        widget.voiceFile(_mPath, costTime);
        // //print("进行发送：_mPath：$_mPath");
      }
    }
    //print(records.toString());
  }

  moveVoiceView() {
    //print("moveVoiceView");
    String textShow;
    isUp = startY - offset > 80 ? true : false;
    if (this.automaticPost) {
      textShow = "按住说话";
    } else if (isUp) {
      textShow = "松开手指,取消发送";
    } else {
      textShow = "松开发送";
    }
    if (textShow != this.textShow) {
      setState(() {
        if (this.automaticPost) {
          this.textShow = "按住说话";
          toastShow = "手指上滑,取消发送";
          context.read<VoiceAlertData>().changeCallback(
                alertText: "手指上滑,取消发送",
                imageIconString: moveUpCancelPostImageString,
              );
        }
        if (isUp) {
          this.textShow = "松开手指,取消发送";
          toastShow = textShow;
          context.read<VoiceAlertData>().changeCallback(
                alertText: "松开手指,取消发送",
                imageIconString: letGoOfYourFingerCancelPostImageString,
              );
        } else {
          this.textShow = "松开发送";
          toastShow = "手指上滑,取消发送";
          context.read<VoiceAlertData>().changeCallback(
                alertText: "手指上滑,取消发送",
                imageIconString: moveUpCancelPostImageString,
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onVerticalDragStart: (details) {
        // startY = details.globalPosition.dy;
        // showVoiceView();
      },
      onVerticalDragDown: (details) async {
        context.read<VoiceSettingNotifier>().stop();
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw "没有权限录音权限";
        } else {
          if (ClickUtil.isFastClick()) {
            return;
          }
          startY = details.globalPosition.dy;
          showVoiceView();
        }
      },
      onVerticalDragCancel: () => hideVoiceView(false),
      onVerticalDragEnd: (details) => hideVoiceView(false),
      onVerticalDragUpdate: (details) {
        offset = details.globalPosition.dy;
        moveVoiceView();
      },
      child: new Container(
        height: 28.0,
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

  // Future<void> openTheRecorder() async {
  //   var status = await Permission.microphone.request();
  //   if (status != PermissionStatus.granted) {
  //     throw RecordingPermissionException('Microphone permission not granted');
  //   }
  //
  //   // var tempDir = await getTemporaryDirectory();
  //   // _mPath = '${tempDir.path}/flutter_sound_example.aac';
  //
  //   _mPath = AppConfig.getAppVoiceFilePath();
  //   var outputFile = File(_mPath);
  //   if (outputFile.existsSync()) {
  //     await outputFile.delete();
  //   }
  //   await _mRecorder.openAudioSession();
  // }

  void initTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    if (context == null) {
      return;
    }
    costTime = 0;
    context.read<VoiceAlertData>().changeCallback(
          showDataTime: DateUtil.formatSecondToStringNumShowMinute(costTime),
        );
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (costTime + 1 > maxRecordVoiceDuration) {
            _timer.cancel();
            context.read<VoiceAlertData>().changeCallback(showDataTime: DateUtil.formatSecondToStringNumShowMinute(costTime + 1));
            hideVoiceView(true);
          } else {
            costTime++;
            context.read<VoiceAlertData>().changeCallback(showDataTime: DateUtil.formatSecondToStringNumShowMinute(costTime));
          }
        });
      } else {
        if (_timer != null) {
          _timer.cancel();
          _timer = null;
        }
        return;
      }
    });
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
