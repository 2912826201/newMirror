import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences
/// Created by yangjiayi on 2020/12/15.

String prefsKeyIsFirstLaunch = "isFirstLaunch";
// 发布动态本地插入数据
String publishFeedLocalInsertData = "publishFeedLocalInsertDataPrefs";

//直播间禁言状态
String prefsKeyIsLiveRoomMute ="liveRoomMute";

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

  // 设置发布动态本地插入数据
  static setPublishFeedLocalInsertData(String key,String releaseString) {
    return _instance.setString(key, releaseString);
  }
  // 获取发布动态本地插入数据
  static String getPublishFeedLocalInsertData(String key) {
    String value = _instance.getString(key);
    if(value == null) {
      value = null;
    }
   return  value;
  }


  static setLiveRoomMuteMessage(int liveRoomId)async {
    Map<String, dynamic> map = await queryMute(liveRoomId);
    if(null!=map["data"]&&null!=map["data"]["remainingMuteTime"]){
      print("--------------${map["data"]["remainingMuteTime"]}");
      if(map["data"]["remainingMuteTime"] is int && map["data"]["remainingMuteTime"]~/60~/1000>0){
        setLiveRoomMute(liveRoomId.toString(), map["data"]["remainingMuteTime"]~/1000, true);
      }else{
        setLiveRoomMute(liveRoomId.toString(), -1, false);
      }
    }
  }

  // 设置在直播间禁言状态
  static setLiveRoomMute(String liveRoomId,int seconds,bool isMute) {
    _instance.setBool("${prefsKeyIsLiveRoomMute}_isMute_$liveRoomId", isMute);
    _instance.setInt("${prefsKeyIsLiveRoomMute}_startTime_$liveRoomId", DateTime.now().millisecondsSinceEpoch);
    _instance.setInt("${prefsKeyIsLiveRoomMute}_second_$liveRoomId", seconds);
  }

  // 获取在直播间禁言状态
  static List getLiveRoomMute(String liveRoomId) {
    List list=[];
    bool isMute = _instance.getBool("${prefsKeyIsLiveRoomMute}_isMute_$liveRoomId");
    if (null == isMute) {
      isMute = false;
    }
    int startTime = _instance.getInt("${prefsKeyIsLiveRoomMute}_startTime_$liveRoomId");
    if (null == startTime) {
      startTime = DateTime.now().millisecondsSinceEpoch;
    }
    int second = _instance.getInt("${prefsKeyIsLiveRoomMute}_second_$liveRoomId");
    if (null == second) {
      second = -1;
    }
    list.add(isMute);
    list.add(startTime);
    list.add(second);
    return list;
  }
}