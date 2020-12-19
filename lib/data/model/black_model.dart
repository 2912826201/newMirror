

class BlackModel{
  int inThisBlack;
  int inYouBlack;
  BlackModel({this.inThisBlack,this.inYouBlack});
  BlackModel.fromJson(Map<String, dynamic> json) {
    inYouBlack = json["inYouBlack"];
    inThisBlack = json["inThisBlack"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["inYouBlack"] = inYouBlack;
    map["inThisBlack"] = inThisBlack;
    return map;
  }
}