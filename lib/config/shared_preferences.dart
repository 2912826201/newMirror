import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/util/date_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences
/// Created by yangjiayi on 2020/12/15.

String prefsKeyIsFirstLaunch = "isFirstLaunch";

String prefsKeyIsFirstLaunchToDay = "isFirstLaunchToDay";
// 发布动态本地插入数据
String publishFeedLocalInsertData = "publishFeedLocalInsertDataPrefs";

String downLoadKeyList = "downLoadKeyList";

//直播间禁言状态
String prefsKeyIsLiveRoomMute = "liveRoomMute";

//app图标上的小红点个数
String prefsKeyFlutterAppBadgerCount = "flutterAppBadgerCount";

// 视频声音开关
String videoSoundSwitch = "videoSoundSwitchPrefs";

//是否第一次获取通知权限
String isFristGetNotification = "isFristGetNotification";
class AppPrefs {
  static SharedPreferences _instance;

  static init() async {
    if (_instance == null) {
      _instance = await SharedPreferences.getInstance();
    }
  }

  // 是否是第一次启动
  static bool isFirstLaunch() {
    bool value = _instance.getBool(prefsKeyIsFirstLaunch);
    if (value == null) {
      value = true;
    }
    return value;
  }

  static setIsFirstLaunch(bool isFirstLaunch) {
    return _instance.setBool(prefsKeyIsFirstLaunch, isFirstLaunch);
  }

  static setFristGetNotification(bool isFrist) {
    return _instance.setBool(isFristGetNotification, isFrist);
  }
  // 是否是第一获取通知权限
  static bool isFirstGetNotification() {
    bool value = _instance.getBool(isFristGetNotification);
    if (value == null) {
      value = true;
    }
    return value;
  }
  static bool isFirstLaunchToDay() {
    bool value = _instance.getBool(getFirstLaunchToDayString());
    if (value == null) {
      value = true;
      setIsFirstLaunchToDay();
    }
    return value;
  }

  static String getFirstLaunchToDayString() {
    return "${prefsKeyIsFirstLaunchToDay}_${Application.profile.uid}_${DateUtil.formatToDayDateString()}";
  }

  static setIsFirstLaunchToDay() {
    return _instance.setBool(getFirstLaunchToDayString(), false);
  }

  ///存分段下载数据
  static setDownLoadChunkData(String url, String downLoadDetailData) {
    if (AppPrefs.getDownLoadKeyList() == null) {
      _instance.setStringList(downLoadKeyList, []);
    }
    if (!AppPrefs.getDownLoadKeyList().contains(url)) {
      List<String> keyList = AppPrefs.getDownLoadKeyList();
      keyList.add(url);
      _instance.setStringList(downLoadKeyList, keyList);
    }
    return _instance.setString(url, downLoadDetailData);
  }

  ///移除下载任务
  static removeDownLadTask(String url) {
    _instance.remove(url);
    List<String> keyList = AppPrefs.getDownLoadKeyList();
    keyList.remove(url);
    _instance.setStringList(downLoadKeyList, keyList);
    return;
  }

  ///清空下载任务
  static clearDownLadTask() {
    if (AppPrefs.getDownLoadKeyList() != null) {
      AppPrefs.getDownLoadKeyList().forEach((element) {
        _instance.remove(element);
      });
    }
    _instance.setStringList(downLoadKeyList, []);
    return;
  }

  ///获取下载任务队列(url)
  static List<String> getDownLoadKeyList() {
    if (_instance.getStringList(downLoadKeyList) != null) {
      return _instance.getStringList(downLoadKeyList);
    }
    return null;
  }

  ///获取分段下载数据
  static getDwonLaodChunkData(String url) {
    String data = _instance.getString(url);
    if (data == null) {
      return null;
    }
    return data;
  }

  // 设置发布动态本地插入数据
  static setPublishFeedLocalInsertData(String key, String releaseString) {
    return _instance.setString(key, releaseString);
  }

  // 获取发布动态本地插入数据
  static String getPublishFeedLocalInsertData(String key) {
    String value = _instance.getString(key);
    if (value == null) {
      value = null;
    }
    return value;
  }

  // 删除发布动态本地数据key
  static removePublishFeed(String key) {
    _instance.remove(key);
  }

  static setLiveRoomMuteMessage(int liveRoomId) async {
    Map<String, dynamic> map = await queryMute(liveRoomId);
    if (null != map["data"] && null != map["data"]["remainingMuteTime"]) {
      print("--------------${map["data"]["remainingMuteTime"]}");
      if (map["data"]["remainingMuteTime"] is int && map["data"]["remainingMuteTime"] ~/ 60 ~/ 1000 > 0) {
        setLiveRoomMute(liveRoomId.toString(), map["data"]["remainingMuteTime"] ~/ 1000, true);
      } else {
        setLiveRoomMute(liveRoomId.toString(), -1, false);
      }
    }
  }

  // 设置在直播间禁言状态
  static setLiveRoomMute(String liveRoomId, int seconds, bool isMute) {
    _instance.setBool("${prefsKeyIsLiveRoomMute}_isMute_${Application.profile?.uid}_$liveRoomId", isMute);
    _instance.setInt("${prefsKeyIsLiveRoomMute}_startTime_${Application.profile?.uid}_$liveRoomId",
        DateTime.now().millisecondsSinceEpoch);
    _instance.setInt("${prefsKeyIsLiveRoomMute}_second_${Application.profile?.uid}_$liveRoomId", seconds);
  }

  // 获取在直播间禁言状态
  static List getLiveRoomMute(String liveRoomId) {
    List list = [];
    bool isMute = _instance.getBool("${prefsKeyIsLiveRoomMute}_isMute_${Application.profile?.uid}_$liveRoomId");
    if (null == isMute) {
      isMute = false;
    }
    int startTime = _instance.getInt("${prefsKeyIsLiveRoomMute}_startTime_${Application.profile?.uid}_$liveRoomId");
    if (null == startTime) {
      startTime = DateTime.now().millisecondsSinceEpoch;
    }
    int second = _instance.getInt("${prefsKeyIsLiveRoomMute}_second_${Application.profile?.uid}_$liveRoomId");
    if (null == second) {
      second = -1;
    }
    list.add(isMute);
    list.add(startTime);
    list.add(second);
    return list;
  }

  //设置app图标上的小红点个数
  static setFlutterAppBadgerCount(int count) {
    _instance.setInt("${prefsKeyFlutterAppBadgerCount}_${Application.profile?.uid}", count);
  }

  //设置app图标上的小红点个数
  static getFlutterAppBadgerCount() {
    int count = _instance.getInt("${prefsKeyFlutterAppBadgerCount}_${Application.profile?.uid}");
    if (null == count) {
      count = 0;
    }
    return count;
  }

  // 设置视频声音
  static setVideoSoundSwitch(bool isSwitch) {
    _instance.setBool(videoSoundSwitch, isSwitch);
  }

  // 获取视频声音
  static getVideoSoundSwitch() {
    bool isSwitch = _instance.getBool(videoSoundSwitch);
    if (null == isSwitch) {
      isSwitch = false;
    }
    return isSwitch;
  }
}
