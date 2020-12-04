class HomeFeedModel {
  int id;
  int type;
  String content;
  String cityCode;
  double longitude;
  double latitude;
  int createTime;
  int pushId;
  String name;
  String avatarUrl;
  int commentCount;
  int laudCount;
  int shareCount;
  int readCount;
  List<PicUrlsModel> picUrls = [];
  VideosModel videos;
  List<AtUsersModel> atUsers = [];
  TopicDtoModel topicDto;
  CourseDtoModel courseDto;

  HomeFeedModel({
    this.id,
    this.type,
    this.content,
    this.cityCode,
    this.longitude,
    this.latitude,
    this.createTime,
    this.pushId,
    this.name,
    this.avatarUrl,
    this.commentCount,
    this.laudCount,
    this.shareCount,
    this.readCount,
    this.picUrls,
    this.videos,
    this.atUsers,
    this.topicDto,
    this.courseDto,
  });

  HomeFeedModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    type = json["type"];
    content = json["content"];
    cityCode = json["cityCode"];
    longitude = json["longitude"];
    latitude = json["latitude"];
    createTime = json["createTime"];
    pushId = json["pushId"];
    name = json["name"];
    avatarUrl = json["avatarUrl"];
    commentCount = json["commentCount"];
    laudCount = json["laudCount"];
    shareCount = json["shareCount"];
    readCount = json["readCount"];
    // picUrls = json["picUrls"];
    if (json["picUrls"] != null) {
      // List<PicUrlsModel> picUrls = [];
      print("解析————————————+——————————————++————————————");
      print("${json["picUrls"]}");
      json["picUrls"].forEach((v) {
        print(v);
        print("wwwwwwwwwwwwww");
        print(picUrls);
        var urls = PicUrlsModel();
        urls.url = v["url"];
        urls.width = v["width"];
        urls.height = v["height"];
        // urls.size = v["size"];
        this.picUrls.add(urls);
      });
    }
    videos = json["videos"];
    if (json["atUsers"] != null) {
      json["atUsers"].forEach((v) {
        atUsers.add(AtUsersModel.fromJson(v));
      });
    }
    topicDto = json["topicDto"];
    courseDto = json["courseDto"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["type"] = type;
    map["content"] = content;
    map["cityCode"] = cityCode;
    map["longitude"] = longitude;
    map["latitude"] = latitude;
    map["createTime"] = createTime;
    map["pushId"] = pushId;
    map["name"] = name;
    map["avatarUrl"] = avatarUrl;
    map["commentCount"] = commentCount;
    map["laudCount"] = laudCount;
    map["shareCount"] = shareCount;
    map["readCount"] = readCount;
    map["picUrls"] = picUrls;
    map["videos"] = videos;
    map["atUsers"] = atUsers;
    map["topicDto"] = topicDto;
    map["courseDto"] = courseDto;
    return map;
  }
}

class PicUrlsModel {
  String url;
  int width;
  int height;
  double size;
  PicUrlsModel({this.height,this.width,this.url,this.size});
  PicUrlsModel.fromJson(Map<String, dynamic> json) {
   url = json["url"];
   width = json["width"];
   height = json["height"];
   size = json["size"];
  }
  Map<String, dynamic> toJson() {
   var map = <String, dynamic>{};
   map["url"] = url;
   map["width"] = width;
   map["height"] = height;
   map["size"] = size;
   return  map;
  }
}

class VideosModel {}

class AtUsersModel {
  int uid;
  int index;
  int len;
  AtUsersModel.fromJson(Map<String, dynamic> json) {
   uid = json["uid"];
   index = json["index"];
   len = json["len"];
  }
  Map<String, dynamic> toJson() {
   var map = <String, dynamic>{};
   map["uid"] = uid;
   map["index"] = index;
   map["len"] = len;
   return map;
  }
}

class TopicDtoModel {}

class CourseDtoModel {}
