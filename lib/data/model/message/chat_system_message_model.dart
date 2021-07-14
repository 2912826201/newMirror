/// msgUID : "ec78460e-ef0c-4461-b964-a5c603b6f4f1"
/// fromUserId : null
/// toUserId : null
/// objectName : "IF:SystemMessage"
/// content : "{\"subObjectName\":\"MSG_TYPE_IF_SYSTEM\",\"name\":\"General\",\"data\":\"{\\\"text\\\":\\\"尊敬的用户您好，您于2021-06-02 17:52:28举报的用户222222经查证无明显证据判定其违反规定，未能通过审核，给予驳回。感谢您对我们工作的支持！ \\\"}\"}"
/// channelType : null
/// msgTimestamp : 1622627632280
/// sensitiveType : 0
/// source : null
/// groupUserIds : null

class ChatSystemMessageModel {
  String _msgUID;
  String _fromUserId;
  String _toUserId;
  String _objectName;
  String _content;
  String _channelType;
  int _msgTimestamp;
  int _sensitiveType;
  String _source;
  String _groupUserIds;

  String get msgUID => _msgUID;
  String get fromUserId => _fromUserId;
  String get toUserId => _toUserId;
  String get objectName => _objectName;
  String get content => _content;
  String get channelType => _channelType;
  int get msgTimestamp => _msgTimestamp;
  int get sensitiveType => _sensitiveType;
  String get source => _source;
  String get groupUserIds => _groupUserIds;

  ChatSystemMessageModel({
      String msgUID,
      String fromUserId,
      String toUserId,
      String objectName, 
      String content,
      String channelType,
      int msgTimestamp, 
      int sensitiveType,
      String source,
      String groupUserIds}){
    _msgUID = msgUID;
    _fromUserId = fromUserId;
    _toUserId = toUserId;
    _objectName = objectName;
    _content = content;
    _channelType = channelType;
    _msgTimestamp = msgTimestamp;
    _sensitiveType = sensitiveType;
    _source = source;
    _groupUserIds = groupUserIds;
}

  ChatSystemMessageModel.fromJson(dynamic json) {
    _msgUID = json["msgUID"];
    _fromUserId = json["fromUserId"];
    _toUserId = json["toUserId"];
    _objectName = json["objectName"];
    _content = json["content"];
    _channelType = json["channelType"];
    _msgTimestamp = json["msgTimestamp"];
    _sensitiveType = json["sensitiveType"];
    _source = json["source"];
    _groupUserIds = json["groupUserIds"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["msgUID"] = _msgUID;
    map["fromUserId"] = _fromUserId;
    map["toUserId"] = _toUserId;
    map["objectName"] = _objectName;
    map["content"] = _content;
    map["channelType"] = _channelType;
    map["msgTimestamp"] = _msgTimestamp;
    map["sensitiveType"] = _sensitiveType;
    map["source"] = _source;
    map["groupUserIds"] = _groupUserIds;
    return map;
  }

}


class ChatSystemMessageSubModel{
  String title; // 标题
  String text; // 文字
  String picUrl; // 图片url
  String prePicUrl; // 预览图片url
  String linkUrl; // 跳转链接 可为外部链接也可为内部页面链接
  String linkText; // 提示点击跳转链接的文字

  ChatSystemMessageSubModel({this.title, this.text, this.picUrl, this.prePicUrl, this.linkUrl, this.linkText});

  ChatSystemMessageSubModel.fromJson(dynamic json) {
    title = json["title"];
    text = json["text"];
    picUrl = json["picUrl"];
    if (json["prePicUrl"] == null || json["prePicUrl"].toString().length < 1) {
      prePicUrl = json["picUrl"];
    } else {
      prePicUrl = json["prePicUrl"];
    }
    linkUrl = json["linkUrl"];
    linkText = json["linkText"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["title"] = title;
    map["text"] = text;
    map["picUrl"] = picUrl;
    map["linkUrl"] = linkUrl;
    map["linkText"] = linkText;
    return map;
  }
}