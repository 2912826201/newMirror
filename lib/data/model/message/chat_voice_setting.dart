import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  bool isDownloadVoice = false;

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
      // isPlaying = true;
      // isPause = false;
      // showTime = event.inMilliseconds % 1000 > 0 ? (event.inMilliseconds ~/ 1000) + 1 : (event.inMilliseconds ~/ 1000);
      // notifyListeners();
    });
  }

  //获取一个音频播放器是否在播放
  bool getIsPlaying({String idMd5String}) {
    // print("======getIsPlaying:$isPlaying");
    if (idMd5String != null && idMd5String == this.idMd5String) {
      if (isPlaying) {
        if (Application.audioPlayer.state == PlayerState.PLAYING) {
          return true;
        } else {
          stop();
          return false;
        }
      }
      if (isDownloadVoice) {
        return true;
      }
    } else {
      isDownloadVoice = false;
      return false;
    }
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
  void judgePlayModel(String url, String filePath, BuildContext context, String urlMd5String) async {
    print("======judgePlayModel");
    if (urlMd5String == this.idMd5String) {
      if (isPlaying) {
        print("暂停");
        //本来应该是暂停-但是需求是暂停后再次点击要重新播放所以改为停止
        // pause();
        stop();
      } else if (isPause) {
        print("重播");
        resetPlay();
      } else {
        print("播放");
        startPlayer(url, filePath, context, urlMd5String);
      }
      this.idMd5String = urlMd5String;
    } else {
      if (this.isPlaying) {
        //本来应该是暂停-但是需求是暂停后再次点击要重新播放所以改为停止
        // await pause();
        await stop();
      }
      this.idMd5String = urlMd5String;
      startPlayer(url, filePath, context, urlMd5String);
    }
  }

  //播放录音
  Future<void> startPlayer(String netUrl, String filePath, BuildContext context, String urlMd5String) async {
    print("======startPlayer");
    showTime = 0;
    String url;
    if (File(filePath).existsSync()) {
      url = filePath;
    } else {
      url = netUrl;
    }
    if (url == null) {
      ToastShow.show(msg: "音频损坏,无法播放", context: context);
      return;
    } else {
      // url="https://downsc.chinaz.net/Files/DownLoad/sound1/202003/12632.mp3";
      print('开始下载$url');
      isDownloadVoice = true;
      url = await _downloadVoice(url);
      if (url == null) {
        isDownloadVoice = false;
        if (await isOffline()) {
          ToastShow.show(msg: "播放失败,请检查网络", context: context);
        }
        url = netUrl;
      }
      print('开始播放$url');
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

  //停止
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
        this.idMd5String = "";
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
      isPlaying = true;
      isPause = false;
    } else {
      print('resume failed');
    }
  }

  Future<String> _downloadVoice(String url) async {
    if (!StringUtil.isURL(url)) {
      return url;
    }
    if (isDownloadFile(url)) {
      isDownloadVoice = false;
      return _getVoiceFilePath(url);
    } else {
      if (await _saveNetworkVoiceCache(url)) {
        isDownloadVoice = false;
        return _getVoiceFilePath(url);
      } else {
        isDownloadVoice = false;
        return null;
      }
    }
  }

  Future<bool> _saveNetworkVoiceCache(String url) async {
    if (!StringUtil.isURL(url)) {
      return false;
    }

    if (await isOffline()) {
      return false;
    }

    DefaultCacheManager manager = DefaultCacheManager();
    File file = await manager.getSingleFile(url);

    Uint8List bytes = file.readAsBytesSync();

    return _writeVoiceFile(bytes, _getVoiceFilePath(url)) != null;
  }

  Future<File> _writeVoiceFile(Uint8List data, String filePath) async {
    if (data != null && filePath != null) {
      File file = File(filePath);
      file.writeAsBytesSync(data);
      return file;
    }
    return null;
  }

  bool isDownloadFile(String url) {
    String path = _getVoiceFilePath(url);
    if (path == null || path.length < 1) {
      return false;
    }
    File file = File(path);
    return file.existsSync();
  }

  _getVoiceFilePath(String url) {
    return AppConfig.getAppVoiceDir() + "/" + StringUtil.generateMd5(url) + ".aac";
  }

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return false;
    } else {
      return true;
    }
  }
}
