/// data : {"level":[{"id":1,"type":0,"name":"零基础","updateTime":1607673731826},{"id":2,"type":0,"name":"初级","updateTime":1607673731871},{"id":3,"type":0,"name":"中级","updateTime":1607673731888},{"id":4,"type":0,"name":"高级","updateTime":1607673731910},{"id":5,"type":0,"name":"挑战","updateTime":1607673731923}],"part":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969},{"id":2,"type":1,"name":"颈肩","updateTime":1607673781996},{"id":3,"type":1,"name":"腹部","updateTime":1607673782019},{"id":4,"type":1,"name":"腰部","updateTime":1607673782034},{"id":5,"type":1,"name":"手臂","updateTime":1607673782048},{"id":6,"type":1,"name":"腿部","updateTime":1607673782068},{"id":7,"type":1,"name":"臀部","updateTime":1607673782083}],"target":[{"id":1,"type":2,"name":"减脂","updateTime":1607673809453},{"id":2,"type":2,"name":"塑性","updateTime":1607673809476},{"id":3,"type":2,"name":"增肌","updateTime":1607673809496},{"id":4,"type":2,"name":"健康","updateTime":1607673809513}]}
/// code : 200
/// level : [{"id":1,"type":0,"name":"零基础","updateTime":1607673731826},{"id":2,"type":0,"name":"初级","updateTime":1607673731871},{"id":3,"type":0,"name":"中级","updateTime":1607673731888},{"id":4,"type":0,"name":"高级","updateTime":1607673731910},{"id":5,"type":0,"name":"挑战","updateTime":1607673731923}]
/// part : [{"id":1,"type":1,"name":"全身","updateTime":1607673781969},{"id":2,"type":1,"name":"颈肩","updateTime":1607673781996},{"id":3,"type":1,"name":"腹部","updateTime":1607673782019},{"id":4,"type":1,"name":"腰部","updateTime":1607673782034},{"id":5,"type":1,"name":"手臂","updateTime":1607673782048},{"id":6,"type":1,"name":"腿部","updateTime":1607673782068},{"id":7,"type":1,"name":"臀部","updateTime":1607673782083}]
/// target : [{"id":1,"type":2,"name":"减脂","updateTime":1607673809453},{"id":2,"type":2,"name":"塑性","updateTime":1607673809476},{"id":3,"type":2,"name":"增肌","updateTime":1607673809496},{"id":4,"type":2,"name":"健康","updateTime":1607673809513}]

class VideoTagModel {
  List<VideoSubTagModel> _level;
  List<VideoSubTagModel> _part;
  List<VideoSubTagModel> _target;

  List<VideoSubTagModel> get level => _level;

  List<VideoSubTagModel> get part => _part;

  List<VideoSubTagModel> get target => _target;

  VideoTagModel(
      {List<VideoSubTagModel> level,
      List<VideoSubTagModel> part,
      List<VideoSubTagModel> target}) {
    _level = level;
    _part = part;
    _target = target;
  }

  VideoTagModel.fromJson(dynamic json) {
    if (json["level"] != null) {
      _level = [];
      json["level"].forEach((v) {
        _level.add(VideoSubTagModel.fromJson(v));
      });
    }
    if (json["part"] != null) {
      _part = [];
      json["part"].forEach((v) {
        _part.add(VideoSubTagModel.fromJson(v));
      });
    }
    if (json["target"] != null) {
      _target = [];
      json["target"].forEach((v) {
        _target.add(VideoSubTagModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_level != null) {
      map["level"] = _level.map((v) => v.toJson()).toList();
    }
    if (_part != null) {
      map["part"] = _part.map((v) => v.toJson()).toList();
    }
    if (_target != null) {
      map["target"] = _target.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1
/// type : 2
/// name : "减脂"
/// updateTime : 1607673809453

class VideoSubTagModel {
  int _id;
  int _type;
  String _name;
  int _updateTime;

  int get id => _id;

  int get type => _type;

  String get name => _name;

  int get updateTime => _updateTime;

  VideoSubTagModel({int id, int type, String name, int updateTime}) {
    _id = id;
    _type = type;
    _name = name;
    _updateTime = updateTime;
  }

  VideoSubTagModel.fromJson(dynamic json) {
    _id = json["id"];
    _type = json["type"];
    _name = json["name"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["type"] = _type;
    map["name"] = _name;
    map["updateTime"] = _updateTime;
    return map;
  }
}
