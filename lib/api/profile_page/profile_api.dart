import 'package:dio/dio.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/add_remarks_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/fitness_entry_model.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/data/model/query_msglist_model.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'package:mirror/data/model/user_model.dart';

import '../api.dart';

///关注接口
const String ATTENTION = "/appuser/web/user/follow/addFollow";

///取消关注
const String CANCEL_ATTENTION = "/appuser/web/user/follow/removeFollow";

///获取用户关注相关【粉丝数、关注数、动态数】
const String GET_FOLLOWCOUNT = "/appuser/web/user/getFollowCount";

///获取用户训练记录
const String GET_EXTRAINFO = "/appuser/web/user/getExtraInfo";

///获取用户基础信息
const String GET_USERBASEINFO = "/ucenter/web/user/getUserBaseInfo";

///添加备注，取消备注
const String ADD_REMARKS = "/appuser/web/user/addRemark";

///拉黑
const String ADD_BLACK = "/appuser/web/black/addBlack";

///取消拉黑
const String CANCEL_BLACK = "/appuser/web/black/removeBlack";

///检测拉黑关系
const String CHECK_BLACK = "/appuser/web/black/checkBlack";

///举报
const String DENOUNCE = "/appuser/web/report/sendReport";

///更新用户信息
const String UPDATA_USERINFO = "/ucenter/web/user/updateUserInfo";

///搜索用户
const String SEARCH_USER = "/appuser/web/user/searchUser";

///关注列表
const String FOLLOW_LIST = "/appuser/web/user/follow/QueryFollowingList";

///查询用户关系
const String RELATION = "/appuser/web/user/follow/relation";

///好友列表--互相关注列表
const String FOLLOW_BOTH_LIST = "/appuser/web/user/follow/queryBothFollowList";

///搜索关注用户
const String SEARCH_FOLLOW_USER = "/appuser/web/user/searchFollowUser";

///粉丝列表
const String FANS_LIST = "/appuser/web/user/follow/queryFansList";

///话题列表
const String TOPIC_LIST = "/appuser/web/topic/queryFollowTopicList";

///搜索关注话题
const String SEARCH_FOLLOW_TOPIC = "/appuser/web/topic/searchFollowTopic";

///健身信息录入
const String FITNESS_ENTRY = "/appuser/web/user/saveBasicFitnessInfo";

///用户推送列表
const String QUERY_MSG_LIST = "/appuser/web/message/queryMsgList";

///粉丝新增未读
const String FANS_UNREAD = "/appuser/web/user/follow/getUnReadAddFansCount";
//关注
//0-普通场景1-直播中关注教练
Future<int> ProfileAddFollow(int id, {int type = 0}) async {
  BaseResponseModel responseModel = await requestApi(ATTENTION, {"targetId": id, "type": type});
  int backCode;
  if (responseModel.isSuccess) {
    Map<String, dynamic> result = responseModel.data;
    if (null != result && result.isNotEmpty) {
      backCode = result["relation"];
      return backCode;
    }
  } else {
    return null;
  }
}

///取消关注
Future<int> ProfileCancelFollow(int id) async {
  BaseResponseModel responseModel = await requestApi(CANCEL_ATTENTION, {"targetId": id});
  Map<String, dynamic> result = responseModel.data;
  int backCode;
  if (responseModel.isSuccess) {
    if (result.isNotEmpty) {
      backCode = result["relation"];
      return backCode;
    }
  } else {
    return null;
  }
}

///获取关注、粉丝、动态数
Future<ProfileModel> ProfileFollowCount({int id}) async {
  Map<String, dynamic> parmas = {};
  if (id != null) {
    parmas["uid"] = id;
  }
  BaseResponseModel responseModel = await requestApi(GET_FOLLOWCOUNT, parmas);
  if (responseModel.isSuccess) {
    return ProfileModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}

///获取用户训练信息
Future<UserExtraInfoModel> ProfileGetExtraInfo() async {
  BaseResponseModel responseModel = await requestApi(GET_EXTRAINFO, {});
  if (responseModel.isSuccess) {
    return UserExtraInfoModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}

///修改删除备注
Future<AddRemarksModel> ChangeAddRemarks(int toUid, {String remark}) async {
  Map<String, dynamic> parmas = {};
  if (remark != null) {
    parmas["remark"] = remark;
  }
  parmas["toUid"] = toUid;
  BaseResponseModel responseModel = await requestApi(ADD_REMARKS, parmas);
  if (responseModel.isSuccess) {
    return AddRemarksModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}

///添加黑名单
Future<bool> ProfileAddBlack(int blackId) async {
  BaseResponseModel responseModel = await requestApi(ADD_BLACK, {"blackId": blackId});
  bool backResult;
  if (responseModel.isSuccess) {
    Map<String, dynamic> parmas = responseModel.data;
    backResult = parmas["state"];
    return backResult;
  } else {
    return null;
  }
}

///取消拉黑
Future<bool> ProfileCancelBlack(int blackId) async {
  BaseResponseModel responseModel = await requestApi(CANCEL_BLACK, {"blackId": blackId});
  bool backResult;
  if (responseModel.isSuccess) {
    Map<String, dynamic> parmas = responseModel.data;
    backResult = parmas["state"];
    return backResult;
  } else {
    return null;
  }
}

///检测黑名单关系
Future<BlackModel> ProfileCheckBlack(int checkId) async {
  BaseResponseModel responseModel = await requestApi(CHECK_BLACK, {"checkId": checkId});
  if (responseModel.isSuccess && responseModel.data != null) {
    return BlackModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}

///举报
Future<bool> ProfileMoreDenounce(int targetId, int targetType) async {
  BaseResponseModel responseModel = await requestApi(DENOUNCE, {
    "targetId": targetId,
    "type": targetType,
  });
  if (responseModel.isSuccess && responseModel.data != null) {
    return responseModel.data["state"];
  } else {
    return null;
  }
}

///更改用户资料
Future<UserModel> ProfileUpdataUserInfo(String nickName, String avatarUri,
    {String description, int sex, String birthday, String cityCode, double longitude, String latitude}) async {
  Map<String, dynamic> map = Map();
  map["nickName"] = nickName;
  map["avatarUri"] = avatarUri;
  if (description != null) {
    map["description"] = description;
  }
  if (sex != null) {
    map["sex"] = sex;
  }
  if (birthday != null) {
    map["birthday"] = birthday;
  }
  if (cityCode != null) {
    map["cityCode"] = cityCode;
  }
  if (longitude != null) {
    map["longitude"] = longitude;
  }
  if (latitude != null) {
    map["latitude"] = latitude;
  }
  BaseResponseModel responseModel = await requestApi(UPDATA_USERINFO, map);
  if (responseModel.isSuccess) {
    UserModel model;
    if (responseModel.data != null) {
      model = UserModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    return null;
  }
}

///搜索用户
Future<SearchUserModel> ProfileSearchUser(String key, int size, {String uids, int lastTime, CancelToken token}) async {
  Map<String, dynamic> map = Map();
  if (uids != null) {
    map["uids"] = uids;
  }
  if (lastTime != null) {
    map["lastTime"] = lastTime;
  }
  map["key"] = key;
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(SEARCH_USER, map, token: token);
  if (responseModel.isSuccess) {
    print('查询用户接口请求成功=============================');
    SearchUserModel model;
    if (responseModel.data != null) {
      model = SearchUserModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    print('查询用户接口请求失败============================================');
    return null;
  }
}

///关注列表
Future<BuddyListModel> GetFollowList(int size, {String uid, int lastTime,CancelToken token}) async {
  Map<String, dynamic> map = Map();
  if (uid != null) {
    map["uid"] = uid;
  }
  if (lastTime != null) {
    map["lastTime"] = lastTime;
  }
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(FOLLOW_LIST, map,token: token);
  if (responseModel.isSuccess && responseModel.data != null) {
    print('用户关注列表请求接口=============================');
    BuddyListModel model;
    model = BuddyListModel.fromJson(responseModel.data);

    return model;
  } else {
    print('用户关注列表请求接口失败============================================');
    return null;
  }
}

///好友列表--互相关注列表
Future<BuddyListModel> getFollowBothList(int size, {String uid, int lastTime}) async {
  Map<String, dynamic> map = Map();
  if (uid != null) {
    map["uid"] = uid;
  }
  if (lastTime != null) {
    map["lastTime"] = lastTime;
  }
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(FOLLOW_BOTH_LIST, map);
  if (responseModel.isSuccess && responseModel.data != null) {
    print('用户互相关注列表请求接口=============================');
    BuddyListModel model;
    model = BuddyListModel.fromJson(responseModel.data);
    return model;
  } else {
    print('用户互相关注列表请求接口失败============================================');
    return null;
  }
}

///搜索关注用户
Future<SearchUserModel> searchFollowUser(String key, int size, {String uids, int lastTime}) async {
  Map<String, dynamic> map = Map();
  if (uids != null) {
    map["uids"] = uids;
  }
  if (lastTime != null) {
    map["lastTime"] = lastTime;
  }
  map["key"] = key;
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(SEARCH_FOLLOW_USER, map);
  if (responseModel.isSuccess) {
    print('搜索关注用户接口请求成功=============================');
    SearchUserModel model;
    if (responseModel.data != null) {
      model = SearchUserModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    print('搜索关注用户接口请求失败============================================');
    return null;
  }
}

///粉丝列表
Future<BuddyListModel> GetFansList(int LastTime, int size, {int uid}) async {
  Map<String, dynamic> map = Map();
  map["LastTime"] = LastTime;
  map["size"] = size;
  if (uid != null) {
    map["uid"] = uid;
  }
  BaseResponseModel responseModel = await requestApi(FANS_LIST, map);
  if (responseModel.isSuccess && responseModel.data != null) {
    print('用户粉丝列表请求接口=============================');
    BuddyListModel model;
    model = BuddyListModel.fromJson(responseModel.data);
    return model;
  } else {
    print('用户粉丝列表请求接口失败============================================');
    return null;
  }
}

///话题列表
Future<TopicListModel> GetTopicList(int lastTime, int size, {int uid}) async {
  Map<String, dynamic> map = Map();
  if (uid != null) {
    map["uid"] = uid;
  }
  map["lastTime"] = lastTime;
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(TOPIC_LIST, map);
  if (responseModel.isSuccess&&responseModel.data!=null) {
    print('用户关注话题列表请求接口成功=============================');
    TopicListModel model;
    model = TopicListModel.fromJson(responseModel.data);
    return model;
  } else {
    print('用户关注话题列表请求接口失败============================================');
    return null;
  }
}

///搜索关注话题
Future<TopicListModel> searchTopicUser(String key, int size, {double lastScore}) async {
  Map<String, dynamic> map = Map();
  if (lastScore != null) {
    map["lastScore"] = lastScore;
  }
  map["key"] = key;
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(SEARCH_FOLLOW_TOPIC, map);
  if (responseModel.isSuccess&&responseModel.data!=null) {
    print('搜索话题接口请求成功=============================');
    TopicListModel model;
    if (responseModel.data != null) {
      model = TopicListModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    print('搜索话题接口请求失败============================================');
    return null;
  }
}

///健身信息录入
Future<FitnessEntryModel> userFitnessEntry(
    {int height, int weight, int bodyType, int target, int level, String keyParts, int timesOfWeek}) async {
  Map<String, dynamic> map = Map();
  map["height"] = height;
  map["weight"] = weight;
  map["bodyType"] = bodyType;
  map["target"] = target;
  map["level"] = level;
  map["keyParts"] = keyParts;
  map["timesOfWeek"] = timesOfWeek;
  BaseResponseModel responseModel = await requestApi(FITNESS_ENTRY, map);
  if (responseModel.isSuccess) {
    print('健身信息录入接口请求成功=============================');
    FitnessEntryModel model;
    if (responseModel.data != null) {
      model = FitnessEntryModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    print('健身信息录入接口请求失败============================================');
    return null;
  }
}

Future<QueryListModel> queryMsgList(int type, int size, int lastTime) async {
  Map<String, dynamic> map = Map();
  if (lastTime != null) {
    map["lastTime"] = lastTime;
  }
  map["type"] = type;
  map["size"] = size;
  BaseResponseModel responseModel = await requestApi(QUERY_MSG_LIST, map);
  if (responseModel.isSuccess) {
    print('用户通知消息接口请求成功=============================');
    QueryListModel model;
    if (responseModel.data != null) {
      model = QueryListModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    print('用户通知消息接口请求失败============================================');
    return null;
  }
}

//查询用户关系
Future<Map> relation(int uid, int targetId) async {
  Map<String, dynamic> map = Map();
  map["uid"] = uid;
  map["targetId"] = targetId;
  BaseResponseModel responseModel = await requestApi(RELATION, map);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

//粉丝未读数
Future<int> fansUnread() async {
  BaseResponseModel responseModel = await requestApi(FANS_UNREAD, {});
  if (responseModel.isSuccess && responseModel.data != null) {
    return responseModel.data["amount"];
  } else {
    return null;
  }
}
