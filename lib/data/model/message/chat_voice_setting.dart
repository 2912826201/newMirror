import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/util/toast_util.dart';

class VoiceSettingNotifier extends ChangeNotifier {
  VoiceSettingNotifier() {
    isPlaying = false;
    isPause = false;
    showTime = 0;
  }

  bool isPlaying;
  bool isPause;
  String idMd5String;
  int showTime;

  onPlayerCompletion() {
    Application.audioPlayer.onPlayerCompletion.listen((event) {
      print("======onPlayerCompletion");
      isPlaying = false;
      isPause = false;
      idMd5String = "";
      Application.audioPlayer.stop();
      notifyListeners();
    });
  }

  onPlayerError() {
    Application.audioPlayer.onPlayerError.listen((msg) {
      print("======onPlayerError");
      isPlaying = false;
      isPause = false;
      idMd5String = "";
      Application.audioPlayer.stop();
      notifyListeners();
    });
  }

  onAudioPositionChanged() {
    Application.audioPlayer.onAudioPositionChanged.listen((event) {
      // print("======onAudioPositionChanged");
      isPlaying = true;
      isPause = false;
      showTime = event.inMilliseconds % 1000 > 0 ? (event.inMilliseconds ~/ 1000) + 1 : (event.inMilliseconds ~/ 1000);
      notifyListeners();
    });
  }

  //获取一个音频播放器是否在播放
  bool getIsPlaying({String idMd5String}) {
    // print("======getIsPlaying");
    if (isPlaying) {
      if (idMd5String != null && idMd5String == this.idMd5String) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  //设置一个音频播放器是否在播放
  setIsPlaying(bool isPlaying) {
    print("======setIsPlaying");
    this.isPlaying = isPlaying;
  }

  //设置路径
  setIdMd5String(String idMd5String) {
    print("======setIdMd5String");
    this.idMd5String = idMd5String;
  }

  //获取一个音频播放器是否是暂停状态
  bool getIsPause() {
    print("======getIsPause");
    return isPause;
  }

  //获取一个音频播放器是否是暂停状态
  int getShowTime(int showTime, String urlMd5String) {
    // print("======getShowTime");
    if (this.idMd5String == urlMd5String && isPlaying) {
      return this.showTime;
    } else {
      return showTime;
    }
  }

  //设置一个音频播放器是否是暂停状态
  setIsPause(bool isPause) {
    print("======setIsPause");
    this.isPause = isPause;
  }

  //判断播放模式
  void judgePlayModel(
      String url, BuildContext context, String urlMd5String) async {
    print("======judgePlayModel");
    if (urlMd5String == this.idMd5String) {
      if (isPlaying) {
        print("暂停");
        pause();
      } else if (isPause) {
        print("重播");
        resetPlay();
      } else {
        print("播放");
        startPlayer(url, context, urlMd5String);
      }
      this.idMd5String = urlMd5String;
    } else {
      if (this.isPlaying) {
        await pause();
      }
      this.idMd5String = urlMd5String;
      startPlayer(url, context, urlMd5String);
    }
  }

  //播放录音
  Future<void> startPlayer(
      String url, BuildContext context, String urlMd5String) async {
    print("======startPlayer");
    showTime = 0;
    if (url == null) {
      ToastShow.show(msg: "音频损坏,无法播放", context: context);
      return;
    } else {
      print('开始');
      int result = await Application.audioPlayer.play(url);
      if (result == 1) {
        // success
        this.idMd5String = urlMd5String;
        isPlaying = true;
        isPause = false;
        print('play success');
      } else {
        print('play failed');
      }
    }
  }

  //暂停
  pause() async {
    print("======pause");
    int result = await Application.audioPlayer.pause();
    if (result == 1) {
      // success
      print('pause success');
      isPlaying = false;
      isPause = true;
    } else {
      print('pause failed');
    }
  }

  //暂停
  stop() async {
    print("---------isPlaying:${isPlaying}");
    if (isPlaying || isPause) {
      print("======stop");
      int result = await Application.audioPlayer.stop();
      if (result == 1) {
        // success
        print('stop success');
        isPlaying = false;
        isPause = false;
      } else {
        print('stop failed');
      }
    }
  }

  //重新播放
  resetPlay() async {
    print("======resetPlay");
    int result = await Application.audioPlayer.resume();
    if (result == 1) {
      // success
      print('resume success');
    } else {
      print('resume failed');
    }
  }
}
