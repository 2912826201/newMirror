import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mirror/data/model/message/emoji_model.dart';

//获取表情的控制器
class EmojiManager {
// 读取 assets 文件夹中的 person.json 文件
  static Future<String> _loadPersonJson() async {
    return await rootBundle.loadString('assets/emoji.json');
  }

  //获取json的表情
  static Future<List<EmojiModel>> getEmojiModelList() async {
    List<EmojiModel> emojiModelList = <EmojiModel>[];
    // 获取本地的 json 字符串
    String emojiJson = await _loadPersonJson();

    // 解析 json 字符串，返回的是 Map<String, dynamic> 类型
    final jsonMap = json.decode(emojiJson);

    if (jsonMap["list"] != null) {
      jsonMap["list"].forEach((v) {
        emojiModelList.add(EmojiModel.fromJson(v));
      });
    }
    return emojiModelList;
  }
}
