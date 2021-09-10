import 'package:mirror/widget/icon.dart';

class ActivityTypeData {
  static ActivityTypeData _data;

  Map<String, List<String>> activityTypeMap = Map();
  List<String> activityTypeList = [];

  static ActivityTypeData init() {
    if (_data == null) {
      _data = ActivityTypeData();
      _data._initData();
    }
    return _data;
  }
  _initData() {
    activityTypeMap["篮球"] = ["assets/png/activity_kind_basketball.png", "assets/png/activity_kind_basketball_no.png"];
    activityTypeMap["足球"] = ["assets/png/activity_kind_football.png", "assets/png/activity_kind_football_no.png"];
    activityTypeMap["羽毛球"] = ["assets/png/activity_kind_badminton.png", "assets/png/activity_kind_badminton_no.png"];
    activityTypeMap["乒乓球"] = ["assets/png/activity_kind_pingpong.png", "assets/png/activity_kind_pingpong_no.png"];
    activityTypeMap["网球"] = ["assets/png/activity_kind_tennis.png", "assets/png/activity_kind_tennis_no.png"];
    activityTypeMap["跑步"] = ["assets/png/activity_kind_run.png", "assets/png/activity_kind_run_no.png"];
    activityTypeMap.forEach((key, value) {
      activityTypeList.add(key);
    });
  }

  int getIndex(String value) {
    for (int i = 0; i < activityTypeList.length; i++) {
      if (activityTypeList[i] == value) {
        return i;
      }
    }
    return null;
  }

  String getString(int index) {
    if (index >= 0 && index < activityTypeList.length) {
      return activityTypeList[index];
    }
    return null;
  }

  //传入 运动项目的名字
  //两个路径 - 0是有白色背景透明度的 图片
  //1是 没有背景 只有运动项目的icon 图片
  //请使用 Image.asset
  List<String> getIconString(String string) {
    return activityTypeMap[string];
  }

  //传入 第几个运动项目 index
  //两个路径 - 0是有白色背景透明度的 图片
  //1是 没有背景 只有运动项目的icon 图片
  //请使用 Image.asset
  List<String> getIconStringIndex(int index) {
    return getIconString(getString(index));
  }
}
