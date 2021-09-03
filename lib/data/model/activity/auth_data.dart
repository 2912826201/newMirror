class AuthData {
  static AuthData _data;

  static AuthData init() {
    if (_data == null) {
      _data = AuthData();
    }
    return _data;
  }

  List<String> authList = ["所有人", "需要验证信息由我确认", "受到邀请的人"];

  String getDefaultString() {
    return authList[0];
  }

  int getIndex(String value) {
    for (int i = 0; i < authList.length; i++) {
      if (authList[i] == value) {
        return i;
      }
    }
    return null;
  }

  String getString(int index) {
    if (index >= 0 && index < authList.length) {
      return authList[index];
    }
    return null;
  }
}
