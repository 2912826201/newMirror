import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences
/// Created by yangjiayi on 2020/12/15.

String prefsKeyIsFirstLaunch = "isFirstLaunch";

class AppPrefs {
  static SharedPreferences _instance;

  static init() async {
    if(_instance == null){
      _instance = await SharedPreferences.getInstance();
    }
  }

  // 是否是第一次启动
  static bool isFirstLaunch() {
    bool value = _instance.getBool(prefsKeyIsFirstLaunch);
    if(value == null){
      value = true;
    }
    return value;
  }

  static setIsFirstLaunch(bool isFirstLaunch) {
    return _instance.setBool(prefsKeyIsFirstLaunch, isFirstLaunch);
  }
}