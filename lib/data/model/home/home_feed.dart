// 动态model
class HomeFeedModel {
  int id; //动态id
  int type; //动态类型 0-图文动态
  String content; //内容
  String cityCode; //城市码
  double longitude; //经度
  double latitude; //纬度
  int createTime; // 发布时间
  int pushId; //发布人id
  String name; //发布者name
  String avatarUrl; //用户头像地址
  int commentCount; //评论数
  int laudCount = 0; // 点赞数
  int shareCount; // 分享数
  int readCount; // 动态阅读数
  List<PicUrlsModel> picUrls = []; //图片json
  List<VideosModel> videos = []; //视频json
  List<AtUsersModel> atUsers = []; //@用户列表
  TopicDtoModel topicDto; //话题信息
  CourseDtoModel courseDto; //课程信息
  int isLaud = 0  ; // 是否点赞
  List<String>laudUserInfo = []; // 点赞头像
  List<CommentDtoModel> comments = [];
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
    this.isLaud,
    this.laudUserInfo,
    this.comments,
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
    if (json["picUrls"] != null) {
      json["picUrls"].forEach((v) {
        picUrls.add(PicUrlsModel.fromJson(v));
        print(picUrls[0].url);
      });
    }
    if(json["videos"] != null) {
      json["videos"].forEach((v) {
        videos.add(VideosModel.fromJson(v));
      });
    }
    if (json["comments"] != null) {
      json["comments"].forEach((v) {
        comments.add(CommentDtoModel.fromJson(v));
        print("评论赋值了");
        print(comments[0].name);
        print(v["name"]);
      });
    }
    if (json["atUsers"] != null) {
      json["atUsers"].forEach((v) {
        atUsers.add(AtUsersModel.fromJson(v));
      });
    }
    if (json["topicDto"] != null) {
      topicDto = TopicDtoModel.fromJson(json["topicDto"]);
    }
    if(json["courseDto"] != null) {
      courseDto = CourseDtoModel.fromJson(json["courseDto"]);
    }
    if (json["laudUserInfo"] != null) {
      json["laudUserInfo"].forEach((v) {
        laudUserInfo.add(v);
      });
    }
    isLaud = json["isLaud"];
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
    map["isLaud"] = isLaud;
    map["laudUserInfo"] = laudUserInfo;
    map["comments"] = comments;
    return map;
  }
}

// 图片model
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
   // size = json["size"];
  }
  Map<String, dynamic> toJson() {
   var map = <String, dynamic>{};
   map["url"] = url;
   map["width"] = width;
   map["height"] = height;
   // map["size"] = size;
   return  map;
  }
}

// 视频model
class VideosModel {
   String url;            //视频地址
   String hlsUrl;         //hls转码目录地址
   int duration;      //视频时长
   String coverUrl;          //视频封面
   int width;
   int height;
   VideosModel({this.url,this.hlsUrl,this.duration,this.coverUrl,this.height,this.width});
   VideosModel.fromJson(Map<String, dynamic> json) {
     url = json["url"];
     width = json["width"];
     height = json["height"];
     hlsUrl = json["hlsUrl"];
     duration = json["duration"];
     coverUrl = json["coverUrl"];
   }
   Map<String, dynamic> toJson() {
     var map = <String, dynamic>{};
     map["url"] = url;
     map["width"] = width;
     map["height"] = height;
     map["hlsUrl"] = hlsUrl;
     map["duration"] = duration;
     map["coverUrl"] = coverUrl;
     return  map;
   }
}

// Atmodel
class AtUsersModel {
  int uid;
  int index;
  int len;
  int type;
  AtUsersModel({this.uid,this.index,this.len,this.type});
  AtUsersModel.fromJson(Map<String, dynamic> json) {
   uid = json["uid"];
   index = json["index"];
   len = json["len"];
   type = json["type"];
  }
  Map<String, dynamic> toJson() {
   var map = <String, dynamic>{};
   map["uid"] = uid;
   map["index"] = index;
   map["len"] = len;
   map["type"] = type;
   return map;
  }
}

// 话题model
class TopicDtoModel {
   int id;
   String name;
   int creatorId;
   int isNew;
   int feedCount;
   int memberCount;
   int backgroundColorId; //话题背景颜色id
   int patternId; //话题背景形状id
   String backgroundColor;
   int dataState;
   int createTime;
   int updateTime;
   int isFollow;
   TopicDtoModel({this.id,this.name,this.creatorId,this.isNew,this.feedCount,this.memberCount,this.backgroundColorId,this.patternId,this.backgroundColor,this.dataState,this.createTime,this.updateTime,this.isFollow});
   TopicDtoModel.fromJson(Map<String, dynamic> json) {
     id = json["id"];
     name = json["name"];
     creatorId = json["creatorId"];
     isNew = json["isNew"];
     feedCount = json["feedCount"];
     memberCount = json["memberCount"];
     backgroundColorId = json["backgroundColorId"];
     patternId = json["patternId"];
     backgroundColor = json["backgroundColor"];
     dataState = json["dataState"];
     createTime = json["createTime"];
     updateTime = json["updateTime"];
     isFollow = json["isFollow"];
   }
   Map<String, dynamic> toJson() {
     var map = <String, dynamic>{};
     map["id"] = id;
     map["name"] = name;
     map["creatorId"] = creatorId;
     map["isNew"] = isNew;
     map["feedCount"] = feedCount;
     map["memberCount"] = memberCount;
     map["backgroundColorId"] = backgroundColorId;
     map["patternId"] = patternId;
     map["backgroundColor"] = backgroundColor;
     map["dataState"] = dataState;
     map["createTime"] = createTime;
     map["updateTime"] = updateTime;
     map["isFollow"] = isFollow;
     return map;
   }
}

// 课程model
class CourseDtoModel {
   int id;
   int courseId;
   String name;            // 课程名
   int creatorId;       // 创建人Id
   int coachId;
   // UserBaseInfoDto coachDto;           // 教练dto
   int coursewareId;
   // CoursewareDto coursewareDto;      // 课件dto
   String videoUrl;
   String startTime;       // 开始时间
   String endTime;         // 结束时间
   int videoSeconds;      // 视频时长（秒）
   int isBooked;       // 是否预约  Constant.YesNo.FALSE.ordinal()
   int totalTrainingTime;
   int totalTrainingAmount;
   int totalCalories;
   int finishAmount;
   int dataState;
   int createTime;
   int updateTime;
   CourseDtoModel({this.id,this.courseId,this.name,this.creatorId,this.coachId,this.coursewareId,this.videoUrl,this.startTime,this.endTime,this.videoSeconds,this.isBooked,this.totalTrainingTime,
   this.totalTrainingAmount,this.totalCalories,this.finishAmount,this.dataState,this.createTime,this.updateTime
   });
   CourseDtoModel.fromJson(Map<String, dynamic> json) {
     id = json["id"];
     courseId = json['courseId'];
     name = json["name"];
     creatorId = json["creatorId"];
     coachId = json["coachId"];
     coursewareId = json["coursewareId"];
     videoUrl = json["videoUrl"];
     startTime = json["startTime"];
     endTime = json["endTime"];
     videoSeconds = json["videoSeconds"];
     isBooked = json["isBooked"];
     totalTrainingTime = json["totalTrainingTime"];
     totalTrainingAmount = json["totalTrainingAmount"];
     totalCalories = json["totalCalories"];
     finishAmount = json["finishAmount"];
     dataState = json["dataState"];
     createTime = json["createTime"];
     updateTime = json["updateTime"];
   }
   Map<String, dynamic> toJson() {
     var map = <String, dynamic>{};
     map["id"] = id;
     map["courseId"] = courseId;
     map["name"] = name;
     map["creatorId"] = creatorId;
     map["coachId"] = coachId;
     map["coursewareId"] = coursewareId;
     map["videoUrl"] = videoUrl;
     map["startTime"] = startTime;
     map["endTime"] = endTime;
     map["videoSeconds"] = videoSeconds;
     map["isBooked"] = isBooked;
     map["totalTrainingTime"] = totalTrainingTime;
     map["totalTrainingAmount"] = totalTrainingAmount;
     map["totalCalories"] = totalCalories;
     map["dataState"] = dataState;
     map["createTime"] = createTime;
     map["updateTime"] = updateTime;
     map["finishAmount"] = finishAmount;
     return map;
   }
}
class CommentDtoModel{
  int id;
  int targetId;
  int type;
  String content;
  // picUrls
int createTime;
  // atUsers
int uid;
String name;
String avatarUrl;
  // replys
int replyCount;
int laudCount;
int isLaud;
int top;
int replyId;
String replyName;
int delete;

  CommentDtoModel({this.id,this.targetId,this.type,this.content,this.createTime,this.uid,this.name,this.avatarUrl,this.replyCount,this.laudCount,this.isLaud,this.top,
  this.replyId,this.replyName,this.delete});
  CommentDtoModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    targetId = json["targetId"];
    type = json["type"] ;
    content = json["content"] ;
    createTime = json["createTime"] ;
    uid = json["uid"];
    name = json["name"];
    avatarUrl = json["avatarUrl"];
    replyCount = json["replyCount"];
    laudCount = json["laudCount"];
    isLaud = json["isLaud"];
    top = json["top"];
    replyId = json["replyId"];
    replyName = json["replyName"];
    delete = json["delete"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["targetId"] = targetId;
    map["type"] = type;
    map["content"] = content;
    map["createTime"] = createTime;
    map["uid"] = uid;
    map["name"] = name;
    map["avatarUrl"] = avatarUrl;
    map["replyCount"] = replyCount;
    map["laudCount"] = laudCount;
    map["isLaud"] = isLaud;
    map["top"] = top;
    map["replyId"] = replyId;
    map["replyName"] = replyName;
    map["delete"] = delete;
    return map;
  }
}
