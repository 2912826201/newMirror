import 'dart:convert';

import 'package:mirror/im/message_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// count : 0
/// AtMes : [{"groupId":12312,"sendTime":1111111111111,"mesId":12},{"groupId":12312,"sendTime":1111111111111,"mesId":12}]

class AtMesGroupModel {
  Map<String, dynamic> atMsgMap;

  void add(AtMsg atMsg) {
    if (atMsg != null) {
      if (this.atMsgMap == null) {
        atMsgMap = Map();
      }
      if (atMsgMap[atMsg.groupId.toString()] == null) {
        atMsgMap[atMsg.groupId.toString()] = jsonEncode(atMsg.toJson());
        saveAtMesGroupModel(jsonEncode(atMsgMap));
      }
    }
  }

  void remove(AtMsg atMsg) {
    print("清除at消息");
    if (atMsg != null) {
      if (this.atMsgMap != null) {
        atMsgMap.remove(atMsg.groupId.toString());
        saveAtMesGroupModel(jsonEncode(atMsgMap));
        atMsg = null;
      }
    }
  }

  AtMsg getAtMsg(String groupId) {
    if (atMsgMap == null) {
      return null;
    }
    if (atMsgMap[groupId] == null) {
      return null;
    } else {
      try {
        if(atMsgMap[groupId] is AtMsg){
          return atMsgMap[groupId];
        }else{
          return AtMsg.fromJson(json.decode(atMsgMap[groupId]));
        }
      } catch (e) {
        return null;
      }
    }
  }
}

void saveAtMesGroupModel(String content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("at_mes_group_model", content);
}

void initAtMesGroupModel() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String content = prefs.getString("at_mes_group_model");
  if (content != null) {
    AtMesGroupModel atMesGroupModel = AtMesGroupModel();
    atMesGroupModel.atMsgMap = json.decode(content);
    MessageManager.atMesGroupModel = atMesGroupModel;
  }
}

/// groupId : 12312
/// sendTime : 1111111111111
/// mesId : 12

class AtMsg {
  int groupId;
  int sendTime;
  String messageUId;

  AtMsg({int groupId, int sendTime, String messageUId}) {
    this.groupId = groupId;
    this.sendTime = sendTime;
    this.messageUId = messageUId;
  }

  AtMsg.fromJson(dynamic json) {
    groupId = json["groupId"];
    sendTime = json["sendTime"];
    messageUId = json["messageUId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["groupId"] = groupId;
    map["sendTime"] = sendTime;
    map["messageUId"] = messageUId;
    return map;
  }
}
