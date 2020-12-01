import 'package:mirror/data/model/user_model.dart';

/// profile_dto
/// Created by yangjiayi on 2020/11/3.

const String TABLE_NAME_PROFILE = "profile";
const String COLUMN_NAME_PROFILE_UID = 'uid';
const String COLUMN_NAME_PROFILE_PHONE = 'phone';
const String COLUMN_NAME_PROFILE_TYPE = 'type';
const String COLUMN_NAME_PROFILE_SUBTYPE = 'subType';
const String COLUMN_NAME_PROFILE_NICKNAME = 'nickName';
const String COLUMN_NAME_PROFILE_AVATARURI = 'avatarUri';
const String COLUMN_NAME_PROFILE_DESCRIPTION = 'description';
const String COLUMN_NAME_PROFILE_BIRTHDAY = 'birthday';
const String COLUMN_NAME_PROFILE_SEX = 'sex';
const String COLUMN_NAME_PROFILE_CONSTELLATION = 'constellation';
const String COLUMN_NAME_PROFILE_CITYCODE = 'cityCode';
const String COLUMN_NAME_PROFILE_LONGITUDE = 'longitude';
const String COLUMN_NAME_PROFILE_LATITUDE = 'latitude';
const String COLUMN_NAME_PROFILE_PASSWORD = 'password';
const String COLUMN_NAME_PROFILE_ADDRESS = 'address';
const String COLUMN_NAME_PROFILE_SOURCE = 'source';
const String COLUMN_NAME_PROFILE_CREATETIME = 'createTime';
const String COLUMN_NAME_PROFILE_UPDATETIME = 'updateTime';
const String COLUMN_NAME_PROFILE_DELETEDTIME = 'deletedTime';
const String COLUMN_NAME_PROFILE_STATUS = 'status';
const String COLUMN_NAME_PROFILE_AGE = 'age';
const String COLUMN_NAME_PROFILE_ISPERFECT = 'isPerfect';
const String COLUMN_NAME_PROFILE_ISPHONE = 'isPhone';
const String COLUMN_NAME_PROFILE_FOLLOWINGCOUNT = 'followingCount';
const String COLUMN_NAME_PROFILE_FOLLOWERCOUNT = 'followerCount';
const String COLUMN_NAME_PROFILE_FEEDCOUNT = 'feedCount';
const String COLUMN_NAME_PROFILE_RELATION = 'relation';
const String COLUMN_NAME_PROFILE_MUTUALFRIENDCOUNT = 'mutualFriendCount';
// 这个表是用来存放当前已登录用户信息的表

class ProfileDto {
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

  int isPerfect; //0 未完善 1 完善
  int isPhone; // 是否绑定手机号 0-未绑定 1-已绑定
  int followingCount; //关注数
  int followerCount; //粉丝数
  int feedCount; //动态数
  int relation; //与用户关系 0-没关系 1-关注 2-粉丝 3-好友
  int mutualFriendCount; //共同好友数

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
    COLUMN_NAME_PROFILE_UID : uid,
    COLUMN_NAME_PROFILE_PHONE : phone,
    COLUMN_NAME_PROFILE_TYPE : type,
    COLUMN_NAME_PROFILE_SUBTYPE : subType,
    COLUMN_NAME_PROFILE_NICKNAME : nickName,
    COLUMN_NAME_PROFILE_AVATARURI : avatarUri,
    COLUMN_NAME_PROFILE_DESCRIPTION : description,
    COLUMN_NAME_PROFILE_BIRTHDAY : birthday,
    COLUMN_NAME_PROFILE_SEX : sex,
    COLUMN_NAME_PROFILE_CONSTELLATION : constellation,
    COLUMN_NAME_PROFILE_CITYCODE : cityCode,
    COLUMN_NAME_PROFILE_LONGITUDE : longitude,
    COLUMN_NAME_PROFILE_LATITUDE : latitude,
    COLUMN_NAME_PROFILE_PASSWORD : password,
    COLUMN_NAME_PROFILE_ADDRESS : address,
    COLUMN_NAME_PROFILE_SOURCE : source,
    COLUMN_NAME_PROFILE_CREATETIME : createTime,
    COLUMN_NAME_PROFILE_UPDATETIME : updateTime,
    COLUMN_NAME_PROFILE_DELETEDTIME : deletedTime,
    COLUMN_NAME_PROFILE_STATUS : status,
    COLUMN_NAME_PROFILE_AGE : age,
    COLUMN_NAME_PROFILE_ISPERFECT : isPerfect,
    COLUMN_NAME_PROFILE_ISPHONE : isPhone,
    COLUMN_NAME_PROFILE_FOLLOWINGCOUNT : followingCount,
    COLUMN_NAME_PROFILE_FOLLOWERCOUNT : followerCount,
    COLUMN_NAME_PROFILE_FEEDCOUNT : feedCount,
    COLUMN_NAME_PROFILE_RELATION : relation,
    COLUMN_NAME_PROFILE_MUTUALFRIENDCOUNT : mutualFriendCount
    };
    return map;
  }

  ProfileDto.fromMap(Map<String, dynamic> map) {
    uid = map[COLUMN_NAME_PROFILE_UID];
    phone = map[COLUMN_NAME_PROFILE_PHONE];
    type = map[COLUMN_NAME_PROFILE_TYPE];
    subType = map[COLUMN_NAME_PROFILE_SUBTYPE];
    nickName = map[COLUMN_NAME_PROFILE_NICKNAME];
    avatarUri = map[COLUMN_NAME_PROFILE_AVATARURI];
    description = map[COLUMN_NAME_PROFILE_DESCRIPTION];
    birthday = map[COLUMN_NAME_PROFILE_BIRTHDAY];
    sex = map[COLUMN_NAME_PROFILE_SEX];
    constellation = map[COLUMN_NAME_PROFILE_CONSTELLATION];
    cityCode = map[COLUMN_NAME_PROFILE_CITYCODE];
    longitude = map[COLUMN_NAME_PROFILE_LONGITUDE];
    latitude = map[COLUMN_NAME_PROFILE_LATITUDE];
    password = map[COLUMN_NAME_PROFILE_PASSWORD];
    address = map[COLUMN_NAME_PROFILE_ADDRESS];
    source = map[COLUMN_NAME_PROFILE_SOURCE];
    createTime = map[COLUMN_NAME_PROFILE_CREATETIME];
    updateTime = map[COLUMN_NAME_PROFILE_UPDATETIME];
    deletedTime = map[COLUMN_NAME_PROFILE_DELETEDTIME];
    status = map[COLUMN_NAME_PROFILE_STATUS];
    age = map[COLUMN_NAME_PROFILE_AGE];
    isPerfect = map[COLUMN_NAME_PROFILE_ISPERFECT];
    isPhone = map[COLUMN_NAME_PROFILE_ISPHONE];
    followingCount = map[COLUMN_NAME_PROFILE_FOLLOWINGCOUNT];
    followerCount = map[COLUMN_NAME_PROFILE_FOLLOWERCOUNT];
    feedCount = map[COLUMN_NAME_PROFILE_FEEDCOUNT];
    relation = map[COLUMN_NAME_PROFILE_RELATION];
    mutualFriendCount = map[COLUMN_NAME_PROFILE_MUTUALFRIENDCOUNT];
  }

  UserModel toUserModel() {
    var model = UserModel(
      uid: uid,
      phone: phone,
      type: type,
      subType: subType,
      nickName: nickName,
      avatarUri: avatarUri,
      description: description,
      birthday: birthday,
      sex: sex,
      constellation: constellation,
      cityCode: cityCode,
      longitude: longitude,
      latitude: latitude,
      password: password,
      address: address,
      source: source,
      createTime: createTime,
      updateTime: updateTime,
      deletedTime: deletedTime,
      status: status,
      age: age,
      isPerfect: isPerfect,
      isPhone: isPhone,
      followingCount: followingCount,
      followerCount: followerCount,
      feedCount: feedCount,
      relation: relation,
      mutualFriendCount: mutualFriendCount,
    );
    return model;
  }

  ProfileDto.fromUserModel(UserModel model) {
    uid = model.uid;
    phone = model.phone;
    type = model.type;
    subType = model.subType;
    nickName = model.nickName;
    avatarUri = model.avatarUri;
    description = model.description;
    birthday = model.birthday;
    sex = model.sex;
    constellation = model.constellation;
    cityCode = model.cityCode;
    longitude = model.longitude;
    latitude = model.latitude;
    password = model.password;
    address = model.address;
    source = model.source;
    createTime = model.createTime;
    updateTime = model.updateTime;
    deletedTime = model.deletedTime;
    status = model.status;
    age = model.age;
    isPerfect = model.isPerfect;
    isPhone = model.isPhone;
    followingCount = model.followingCount;
    followerCount = model.followerCount;
    feedCount = model.feedCount;
    relation = model.relation;
    mutualFriendCount = model.mutualFriendCount;
  }
}
