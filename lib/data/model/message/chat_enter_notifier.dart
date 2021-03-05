// 输入框输入文字的监听
import 'package:flutter/cupertino.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';

class ChatEnterNotifier extends ChangeNotifier {
  ChatEnterNotifier({this.textFieldStr = ""});

  // 输入框输入文字
  String textFieldStr = "";

  // 监听输入框输入的值是否为@切换视图的
  String keyWord = "";

  // 记录@唤醒页面时光标的位置
  int atCursorIndex;

  // 记录规则
  List<Rule> rules = [];

  // @后的实时搜索文本
  String atSearchStr;

  changeCallback(String str) {
    this.textFieldStr = str;
    notifyListeners();
  }

  // 是否开启@视图
  openAtCallback(String str) {
    this.keyWord = str;
    print("keyWord：${str}");
    notifyListeners();
  }

  getAtCursorIndex(int atIndex) {
    this.atCursorIndex = atIndex;
    notifyListeners();
  }

  addRules(Rule role) {
    this.rules.add(role);
    notifyListeners();
  }

  clearRules() {
    this.rules.clear();
  }

  setAtSearchStr(String str) {
    this.atSearchStr = str;
    notifyListeners();
  }
}
