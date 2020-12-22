//表情
class EmojiModel {
  String code;
  String id;
  String emoji;

  EmojiModel({this.code, this.id, this.emoji});

  factory EmojiModel.fromJson(Map<String, dynamic> json) {
    return EmojiModel(code: json['code'], id: json['id'], emoji: json['emoji']);
  }
}
