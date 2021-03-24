import 'package:mirror/data/model/home/home_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences
/// Created by yangjiayi on 2020/12/15.

String prefsKeyIsFirstLaunch = "isFirstLaunch";
// 发布动态本地插入数据
String publishFeedLocalInsertData = "publishFeedLocalInsertDataPrefs";

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
}