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
    activityTypeMap["篮球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["足球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["羽毛球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["乒乓球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["网球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["跑步"] = [AppIcon.input_gallery, AppIcon.message_emotion];
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

  List<String> getIconString(String string) {
    return activityTypeMap[string];
  }
}
