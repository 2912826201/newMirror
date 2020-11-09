class TestModel {
  int hasNext;
  Data data;
  List<Item> list;

  TestModel({
      this.hasNext, 
      this.data, 
      this.list});

  TestModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    data = json["data"] != null ? Data.fromJson(json["data"]) : null;
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["hasNext"] = hasNext;
    if (data != null) {
      map["data"] = data.toJson();
    }
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Item {
  int uid;
  String phone;
  String nickName;
  String avatarUri;
  String birthday;
  int sex;
  String constellation;
  int createdAt;
  int updatedAt;
  int status;
  int age;
  int isPerfect;
  int isProhibit;
  int relation;

  Item({
      this.uid, 
      this.phone, 
      this.nickName, 
      this.avatarUri, 
      this.birthday, 
      this.sex, 
      this.constellation, 
      this.createdAt, 
      this.updatedAt, 
      this.status, 
      this.age, 
      this.isPerfect, 
      this.isProhibit, 
      this.relation});

  Item.fromJson(dynamic json) {
    uid = json["uid"];
    phone = json["phone"];
    nickName = json["nickName"];
    avatarUri = json["avatarUri"];
    birthday = json["birthday"];
    sex = json["sex"];
    constellation = json["constellation"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    status = json["status"];
    age = json["age"];
    isPerfect = json["isPerfect"];
    isProhibit = json["isProhibit"];
    relation = json["relation"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["phone"] = phone;
    map["nickName"] = nickName;
    map["avatarUri"] = avatarUri;
    map["birthday"] = birthday;
    map["sex"] = sex;
    map["constellation"] = constellation;
    map["createdAt"] = createdAt;
    map["updatedAt"] = updatedAt;
    map["status"] = status;
    map["age"] = age;
    map["isPerfect"] = isPerfect;
    map["isProhibit"] = isProhibit;
    map["relation"] = relation;
    return map;
  }

}

class Data {
  String accessToken;
  String tokenType;
  String refreshToken;
  int expiresIn;
  String scope;
  int isPerfect;
  int isPhone;
  dynamic mid;
  String uid;
  int anonymous;
  String jti;

  Data({
      this.accessToken, 
      this.tokenType, 
      this.refreshToken, 
      this.expiresIn, 
      this.scope, 
      this.isPerfect, 
      this.isPhone, 
      this.mid, 
      this.uid, 
      this.anonymous, 
      this.jti});

  Data.fromJson(dynamic json) {
    accessToken = json["access_token"];
    tokenType = json["token_type"];
    refreshToken = json["refresh_token"];
    expiresIn = json["expires_in"];
    scope = json["scope"];
    isPerfect = json["isPerfect"];
    isPhone = json["isPhone"];
    mid = json["mid"];
    uid = json["uid"];
    anonymous = json["anonymous"];
    jti = json["jti"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["access_token"] = accessToken;
    map["token_type"] = tokenType;
    map["refresh_token"] = refreshToken;
    map["expires_in"] = expiresIn;
    map["scope"] = scope;
    map["isPerfect"] = isPerfect;
    map["isPhone"] = isPhone;
    map["mid"] = mid;
    map["uid"] = uid;
    map["anonymous"] = anonymous;
    map["jti"] = jti;
    return map;
  }

}