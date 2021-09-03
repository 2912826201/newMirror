class EquipmentData {
  static EquipmentData _data;

  static EquipmentData init() {
    if (_data == null) {
      _data = EquipmentData();
    }
    return _data;
  }

  List<String> equipmentList = ["参与人自带", "无需器材", "发起人准备"];

  String getDefaultString() {
    return equipmentList[2];
  }

  int getIndex(String value) {
    for (int i = 0; i < equipmentList.length; i++) {
      if (equipmentList[i] == value) {
        return i;
      }
    }
    return null;
  }

  String getString(int index) {
    if (index >= 0 && index < equipmentList.length) {
      return equipmentList[index];
    }
    return null;
  }
}
