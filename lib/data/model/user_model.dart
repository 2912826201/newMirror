/// user_model
/// Created by yangjiayi on 2020/10/29.

class UserModel {
  int uid; //账户Id
  String phone; //手机号
  int type; //类型 0-用户 1-教练 2-管理
  int subType; // 子类型 0-管理运营后台 1-app官方运营账号
  String nickName; //昵称
  String avatarUri; //头像
  String description; //个性签名
  String birthday; //生日
  int sex; //性别 0-未知 1-男 2-女
  String constellation; //星座
  String cityCode; //城市编码
  double longitude; //经度
  double latitude; //纬度
  String password; //密码
  String address; //详细地址
  String source; //已绑定的其他账号标识  数组
  int createTime; //创建时间
  int updateTime; //更新时间
  int deletedTime; //删除时间
  int status; //用户状态，0-删除，1-不可使用，2-正常
  int age; //年龄

  int isVip; // 是否是Vip 0-不是 1-是
  int isLiving; // 是否在直播 0-没有直播 1-正在直播

  int isPerfect; //0 未完善 1 完善
  int isPhone; // 是否绑定手机号 0-未绑定 1-已绑定

  int relation; //与用户关系 0-没关系 1-关注 2-粉丝 3-好友
  int mutualFriendCount; //共同好友数

  //活动内容的字段
  String message; //申请活动-的理由
  int id; //本条申请的id--申请活动
  int dataState; //2-待处理 1-已处理
  int isActivityTogether; //2-待处理 1-已处理
  String title; //活动名字

  UserModel({
    this.uid = -1, //默认给个uid为-1
    this.phone,
    this.type,
    this.subType,
    this.nickName,
    this.avatarUri,
    this.description,
    this.birthday,
    this.sex,
    this.constellation,
    this.cityCode,
    this.longitude,
    this.latitude,
    this.password,
    this.address,
    this.source,
    this.createTime,
    this.updateTime,
    this.deletedTime,
    this.status,
    this.age,
    this.isVip = 0,
    this.isLiving,
    this.isPerfect,
    this.isPhone,
    this.relation,
    this.mutualFriendCount,
    this.message,
    this.id,
    this.dataState,
    this.isActivityTogether,
    this.title,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"]!=null?json["uid"]:0;
    phone = json["phone"];
    type = json["type"];
    subType = json["subType"];
    nickName = json["nickName"];
    avatarUri = json["avatarUri"];
    description = json["description"];
    birthday = json["birthday"];
    sex = json["sex"];
    constellation = json["constellation"];
    cityCode = json["cityCode"];
    longitude = json["longitude"];
    latitude = json["latitude"];
    password = json["password"];
    address = json["address"];
    source = json["source"];
    createTime = json["createTime"];
    updateTime = json["updateTime"];
    deletedTime = json["deletedTime"];
    status = json["status"];
    age = json["age"];
    isVip = json["isVip"];
    isLiving = json["isLiving"];
    isPerfect = json["isPerfect"];
    isPhone = json["isPhone"];
    relation = json["relation"];
    mutualFriendCount = json["mutualFriendCount"];
    dataState = json["dataState"];
    id = json["id"];
    message = json["message"];
    isActivityTogether = json["isActivityTogether"];
    title = json["title"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["phone"] = phone;
    map["type"] = type;
    map["subType"] = subType;
    map["nickName"] = nickName;
    map["avatarUri"] = avatarUri;
    map["description"] = description;
    map["birthday"] = birthday;
    map["sex"] = sex;
    map["constellation"] = constellation;
    map["cityCode"] = cityCode;
    map["longitude"] = longitude;
    map["latitude"] = latitude;
    map["password"] = password;
    map["address"] = address;
    map["source"] = source;
    map["createTime"] = createTime;
    map["updateTime"] = updateTime;
    map["deletedTime"] = deletedTime;
    map["status"] = status;
    map["age"] = age;
    map["isVip"] = isVip;
    map["isLiving"] = isLiving;
    map["isPerfect"] = isPerfect;
    map["isPhone"] = isPhone;
    map["relation"] = relation;
    map["mutualFriendCount"] = mutualFriendCount;
    map["message"] = message;
    map["id"] = id;
    map["dataState"] = dataState;
    map["isActivityTogether"] = isActivityTogether;
    map["title"] = title;
    return map;
  }

}