import 'dart:convert';

import 'package:mirror/config/application.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// count : 0
/// AtMes : [{"groupId":12312,"sendTime":1111111111111,"mesId":12},{"groupId":12312,"sendTime":1111111111111,"mesId":12}]

class AtMesGroupModel {
  int _count;
  List<AtMsg> _atMsg;

  int get count => _count;

  List<AtMsg> get atMes => _atMsg;

  AtMesGroupModel({int count, List<AtMsg> atMsg}) {
    _count = count;
    _atMsg = atMsg;
  }

  AtMesGroupModel.fromJson(dynamic json) {
    _count = json["count"];
    if (json["AtMes"] != null) {
      _atMsg = [];
      json["AtMes"].forEach((v) {
        _atMsg.add(AtMsg.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["count"] = _count;
    if (_atMsg != null) {
      map["AtMes"] = _atMsg.map((v) => v.toJson()).toList();
    }
    return map;
  }

  void add(AtMsg atMsg) {
    if (atMsg != null) {
      if (this._atMsg != null) {
        for (int i = 0; i < _atMsg.length; i++) {
          if (_atMsg[i].groupId == atMsg.groupId) {
            _atMsg.removeAt(i);
            break;
          }
        }
        this._atMsg.add(atMsg);
      } else {
        List<AtMsg> array = <AtMsg>[];
        array.add(atMsg);
        this._atMsg = array;
      }
      this._count = this._atMsg.length;
      print(
          "this._count：${this._count}---jsonEncode(toJson()):${jsonEncode(toJson())}");
      saveAtMesGroupModel(jsonEncode(toJson()));
    }
  }

  void remove(AtMsg atMsg) {
    if (atMsg != null) {
      if (this._atMsg != null) {
        if (this._atMsg.contains(atMsg)) {
          this._atMsg.remove(atMsg);
          this._count = this._atMsg.length;
          saveAtMesGroupModel(jsonEncode(toJson()));
        }
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
    AtMesGroupModel atMesGroupModel =
        AtMesGroupModel.fromJson(json.decode(content));
    Application.atMesGroupModel = atMesGroupModel;
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
