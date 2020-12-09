/// user_model
/// Created by yangjiayi on 2020/10/29.

//直播课程
class LiveBroadcastModel {
  int id; //Id
  String startAndEndTime; //起始结束时间
  String title; //title
  String type; //类型
  int fat; // 燃烧多少卡
  String coachName; //教练名字
  int playType; //播放类型-0去上课  1预约  2回放 3已预约
  String imageUrl;


  String getGetType(){
    if(this.playType==1){
      return "预约";
    }else if(this.playType==2){
      return "回放";
    }else if(this.playType==3){
      return "已预约";
    }else{
      return "去上课";
    }
  }

  LiveBroadcastModel({
      this.id = 0, //默认给个uid为0
      this.startAndEndTime,
      this.title,
      this.type,
      this.fat=0,
      this.coachName,
      this.playType=0,
      this.imageUrl,
  });

  LiveBroadcastModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    startAndEndTime = json["startAndEndTime"];
    title = json["title"];
    type = json["type"];
    fat = json["fat"];
    coachName = json["coachName"];
    playType = json["playType"];
    imageUrl = json["imageUrl"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["startAndEndTime"] = startAndEndTime;
    map["title"] = title;
    map["type"] = type;
    map["fat"] = fat;
    map["coachName"] = coachName;
    map["playType"] = playType;
    map["imageUrl"] = imageUrl;
    return map;
  }

}