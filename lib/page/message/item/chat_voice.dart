import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
// import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/message/chat_voice_setting.dart';
import 'package:mirror/data/model/message/voice_alert_date_model.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:file/src/backends/local/local_file_system.dart';
import 'dart:io' as io;

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


  FlutterAudioRecorder2 _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  String _mPath;

  Timer _timer;

  bool automaticPost = false;

  bool isRecordering=false;

  @override
  void initState() {
    super.initState();
    init();
    // openTheRecorder().then((value) {});
  }

  init()async{
    try {
      bool hasPermission = await FlutterAudioRecorder2.hasPermissions ?? false;

      if (hasPermission) {

        _mPath = AppConfig.getAppVoiceFilePath();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder2(_mPath, audioFormat: AudioFormat.AAC);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
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
    await Future.delayed(Duration(milliseconds: 300), () {
      print("延时停止300毫秒");
    });


    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = localFileSystem.file(result.path);
    print("File length: ${await file.length()}");


    isRecordering = false;

    // await _mRecorder.stopRecorder();
    //print(_mPath);
    if (context != null) {
      setState(() {
        isHide = true;
        init();
      });
    }
  }

  void startRecorder() async {
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }

    await _recorder.start();
    var recording = await _recorder.current(channel: 0);

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

    // _mPath = AppConfig.getAppVoiceFilePath();


    if (overlayEntry == null) {
      overlayEntry = showVoiceDialog(context);
    }

    isUp = false;
    setState(() {
      textShow = "松开发送";
      voiceState = false;
    });

    startRecorder();

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


    await stopRecorder();

    if (_timer != null) {
      // costTime = _timer.tick + 1;
      _timer.cancel();
      _timer = null;
    }

    if (isUp) {
      if (overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
      }

      isRecordering=false;
      costTime=0;
      //print("取消发送");
      if (records.length > 0) {
        records.removeLast();
      }
    } else {
      if (costTime < minRecordVoiceDuration + 1) {
        isRecordering=false;
        costTime=0;
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
      }else{
        if (overlayEntry != null) {
          overlayEntry.remove();
          overlayEntry = null;
        }
        //print("进行发送");
        widget.voiceFile(_mPath, costTime);
        isRecordering=false;
        costTime=0;
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
      onVerticalDragStart: (details)async {
        if(isRecordering){
          return;
        }
        context.read<VoiceSettingNotifier>().stop();
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw "没有权限录音权限";
        } else {
          if (ClickUtil.isFastClick()) {
            return;
          }
          startY = details.globalPosition.dy;
          isRecordering=true;
          showVoiceView();
        }
      },
      onVerticalDragDown: (details) async {
        if(isRecordering){
          return;
        }
        isRecordering=true;
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


  void initTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    if (context == null) {
      stopRecorder();
      isRecordering=false;
      return;
    }
    costTime = 0;
    context.read<VoiceAlertData>().changeCallback(
          showDataTime: DateUtil.formatSecondToStringNumShowMinute(costTime),
        );
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(!isRecordering){
        if (_timer != null) {
          _timer.cancel();
          _timer = null;
        }
      }
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

}
