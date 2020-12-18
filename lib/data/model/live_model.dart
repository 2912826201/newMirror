import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/util/date_util.dart';

/// data : {"id":1,"courseId":1,"name":"减脂塑形","creatorId":1008611,"coachId":1008611,"coachDto":{"uid":1008611,"phone":"13111856853","type":2,"subType":1,"nickName":"爸爸","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","description":null,"birthday":null,"sex":null,"constellation":null,"cityCode":null,"longitude":null,"latitude":null,"password":"MTMxMTE4NTY4NTM=","address":null,"source":null,"createTime":1605182811646,"updateTime":null,"deletedTime":null,"status":2,"age":null,"isPerfect":1,"isPhone":1},"coursewareId":1,"coursewareDto":{"id":1,"name":"测试一","picUrl":"www.baidu.com","seconds":300000,"calories":167,"levelId":2,"levelDto":{"id":2,"type":null,"name":"初级","updateTime":1608014618089,"ename":"L1"},"targetId":1,"targetDto":{"id":1,"type":null,"name":"减脂","updateTime":1607673809453,"ename":null},"partId":1,"partDto":{"id":1,"type":null,"name":"全身","updateTime":1607673781969,"ename":null},"description":"测试测试","dataState":2,"createTime":1605254544449,"updateTime":1605254544449},"playBackUrl":null,"videoUrl":null,"startTime":"2020-11-16 09:00","endTime":"2020-11-16 10:00","videoSeconds":null,"movementDtos":[{"id":1,"name":"动作名","point":100,"picUrl":"http://devpic.aimymusic.com/ifcms/12萌妹子.jpg","levelId":1,"levelDto":{"id":1,"type":null,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partId":1,"partDto":{"id":1,"type":null,"name":"减脂","updateTime":1607673809453,"ename":null},"calories":1000,"expectHeartRate":100,"steps":"步骤、自己猜","breathingRhythm":"呼吸节奏","movementFeeling":"动作感觉","positionId":1,"muscleId":1,"detail":null,"state":1,"creatorId":1008611,"dataState":2,"createTime":1607570185761,"updateTime":1607570185761,"positionDto":{"url":"http://devpic.aimymusic.com/ifcms/shoubi.jpg","content":"手臂"},"muscleDto":{"url":"http://devpic.aimymusic.com/ifcms/gongertouji.jpg","content":"肱二头肌"},"amount":10,"seconds":null,"unit":"次","aicheckSteps":[{"url":"www.baidu.com","content":"这是内容"}]}],"isBooked":0,"totalTrainingTime":0,"totalTrainingAmount":0,"totalCalories":0,"joinAmount":null,"commentCount":null,"laudCount":null,"finishAmount":null,"dataState":2,"createTime":1605254544449,"updateTime":1605254544449}
/// code : 200

/// id : 1
/// courseId : 1
/// name : "减脂塑形"
/// creatorId : 1008611
/// coachId : 1008611
/// coachDto : {"uid":1008611,"phone":"13111856853","type":2,"subType":1,"nickName":"爸爸","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","description":null,"birthday":null,"sex":null,"constellation":null,"cityCode":null,"longitude":null,"latitude":null,"password":"MTMxMTE4NTY4NTM=","address":null,"source":null,"createTime":1605182811646,"updateTime":null,"deletedTime":null,"status":2,"age":null,"isPerfect":1,"isPhone":1}
/// coursewareId : 1
/// coursewareDto : {"id":1,"name":"测试一","picUrl":"www.baidu.com","seconds":300000,"calories":167,"levelId":2,"levelDto":{"id":2,"type":null,"name":"初级","updateTime":1608014618089,"ename":"L1"},"targetId":1,"targetDto":{"id":1,"type":null,"name":"减脂","updateTime":1607673809453,"ename":null},"partId":1,"partDto":{"id":1,"type":null,"name":"全身","updateTime":1607673781969,"ename":null},"description":"测试测试","dataState":2,"createTime":1605254544449,"updateTime":1605254544449}
/// playBackUrl : null
/// videoUrl : null
/// startTime : "2020-11-16 09:00"
/// endTime : "2020-11-16 10:00"
/// videoSeconds : null
/// movementDtos : [{"id":1,"name":"动作名","point":100,"picUrl":"http://devpic.aimymusic.com/ifcms/12萌妹子.jpg","levelId":1,"levelDto":{"id":1,"type":null,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partId":1,"partDto":{"id":1,"type":null,"name":"减脂","updateTime":1607673809453,"ename":null},"calories":1000,"expectHeartRate":100,"steps":"步骤、自己猜","breathingRhythm":"呼吸节奏","movementFeeling":"动作感觉","positionId":1,"muscleId":1,"detail":null,"state":1,"creatorId":1008611,"dataState":2,"createTime":1607570185761,"updateTime":1607570185761,"positionDto":{"url":"http://devpic.aimymusic.com/ifcms/shoubi.jpg","content":"手臂"},"muscleDto":{"url":"http://devpic.aimymusic.com/ifcms/gongertouji.jpg","content":"肱二头肌"},"amount":10,"seconds":null,"unit":"次","aicheckSteps":[{"url":"www.baidu.com","content":"这是内容"}]}]
/// isBooked : 0
/// totalTrainingTime : 0
/// totalTrainingAmount : 0
/// totalCalories : 0
/// joinAmount : null
/// commentCount : null
/// laudCount : null
/// finishAmount : null
/// dataState : 2
/// createTime : 1605254544449
/// updateTime : 1605254544449

class LiveModel {
  int playType; //播放类型-0没有设置 1去上课  2预约  3回放 4已预约

  String getGetPlayType() {
    if (this.isBooked == 1) {
      this.playType = 4;
    }
    if (this.playType == 2) {
      return "预约";
    } else if (this.playType == 3) {
      return "回放";
    } else if (this.playType == 4) {
      return "已预约";
    } else if (this.playType == 1) {
      return "去上课";
    } else {
      if (startTime != null && startTime.isNotEmpty) {
        DateTime dateTime = DateUtil.stringToDateTime(this.startTime);
        DateTime endTime = DateUtil.stringToDateTime(this.endTime);
        var startTime = dateTime.add(new Duration(minutes: -15));
        if (DateUtil.compareNowDate(startTime)) {
          this.playType = 2;
          return "预约";
        } else if (DateUtil.compareNowDate(endTime)) {
          this.playType = 1;
          return "去上课";
        } else {
          this.playType = 3;
          return "回放";
        }
      } else {
        this.playType = 2;
        return "预约";
      }
    }
  }

  int _id;
  int _courseId;
  String _name;
  int _creatorId;
  int _coachId;
  UserModel _coachDto;
  int _coursewareId;
  CoursewareDto _coursewareDto;
  String _playBackUrl;
  String _videoUrl;
  String _startTime;
  String _endTime;
  int _videoSeconds;
  List<MovementDtos> _movementDtos;
  int _isBooked;
  int _totalTrainingTime;
  int _totalTrainingAmount;
  int _totalCalories;
  int _joinAmount;
  int _commentCount;
  int _laudCount;
  int _finishAmount;
  int _dataState;
  int _createTime;
  int _updateTime;

  int get id => _id;

  int get courseId => _courseId;

  String get name => _name;

  int get creatorId => _creatorId;

  int get coachId => _coachId;

  UserModel get coachDto => _coachDto;

  int get coursewareId => _coursewareId;

  CoursewareDto get coursewareDto => _coursewareDto;

  String get playBackUrl => _playBackUrl;

  String get videoUrl => _videoUrl;

  String get startTime => _startTime;

  String get endTime => _endTime;

  int get videoSeconds => _videoSeconds;

  List<MovementDtos> get movementDtos => _movementDtos;

  int get isBooked => _isBooked;

  int get totalTrainingTime => _totalTrainingTime;

  int get totalTrainingAmount => _totalTrainingAmount;

  int get totalCalories => _totalCalories;

  int get joinAmount => _joinAmount;

  int get commentCount => _commentCount;

  int get laudCount => _laudCount;

  int get finishAmount => _finishAmount;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  LiveModel(
      {int id,
      int courseId,
      String name,
      int creatorId,
      int coachId,
      UserModel coachDto,
      int coursewareId,
      CoursewareDto coursewareDto,
      String playBackUrl,
      String videoUrl,
      String startTime,
      String endTime,
      int videoSeconds,
      List<MovementDtos> movementDtos,
      int isBooked,
      int totalTrainingTime,
      int totalTrainingAmount,
      int totalCalories,
      int joinAmount,
      int commentCount,
      int laudCount,
      int finishAmount,
      int dataState,
      int createTime,
      int updateTime}) {
    _id = id;
    _courseId = courseId;
    _name = name;
    _creatorId = creatorId;
    _coachId = coachId;
    _coachDto = coachDto;
    _coursewareId = coursewareId;
    _coursewareDto = coursewareDto;
    _playBackUrl = playBackUrl;
    _videoUrl = videoUrl;
    _startTime = startTime;
    _endTime = endTime;
    _videoSeconds = videoSeconds;
    _movementDtos = movementDtos;
    _isBooked = isBooked;
    _totalTrainingTime = totalTrainingTime;
    _totalTrainingAmount = totalTrainingAmount;
    _totalCalories = totalCalories;
    _joinAmount = joinAmount;
    _commentCount = commentCount;
    _laudCount = laudCount;
    _finishAmount = finishAmount;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
    playType = 0;
  }

  LiveModel.fromJson(dynamic json) {
    _id = json["id"];
    _courseId = json["courseId"];
    _name = json["name"];
    _creatorId = json["creatorId"];
    _coachId = json["coachId"];
    _coachDto =
    json["coachDto"] != null ? UserModel.fromJson(json["coachDto"]) : null;
    _coursewareId = json["coursewareId"];
    _coursewareDto = json["coursewareDto"] != null ? CoursewareDto.fromJson(
        json["coursewareDto"]) : null;
    _playBackUrl = json["playBackUrl"];
    _videoUrl = json["videoUrl"];
    _startTime = json["startTime"];
    _endTime = json["endTime"];
    _videoSeconds = json["videoSeconds"];
    if (json["movementDtos"] != null) {
      _movementDtos = [];
      json["movementDtos"].forEach((v) {
        _movementDtos.add(MovementDtos.fromJson(v));
      });
    }
    _isBooked = json["isBooked"];
    _totalTrainingTime = json["totalTrainingTime"];
    _totalTrainingAmount = json["totalTrainingAmount"];
    _totalCalories = json["totalCalories"];
    _joinAmount = json["joinAmount"];
    _commentCount = json["commentCount"];
    _laudCount = json["laudCount"];
    _finishAmount = json["finishAmount"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["courseId"] = _courseId;
    map["name"] = _name;
    map["creatorId"] = _creatorId;
    map["coachId"] = _coachId;
    if (_coachDto != null) {
      map["coachDto"] = _coachDto.toJson();
    }
    map["coursewareId"] = _coursewareId;
    if (_coursewareDto != null) {
      map["coursewareDto"] = _coursewareDto.toJson();
    }
    map["playBackUrl"] = _playBackUrl;
    map["videoUrl"] = _videoUrl;
    map["startTime"] = _startTime;
    map["endTime"] = _endTime;
    map["videoSeconds"] = _videoSeconds;
    if (_movementDtos != null) {
      map["movementDtos"] = _movementDtos.map((v) => v.toJson()).toList();
    }
    map["isBooked"] = _isBooked;
    map["totalTrainingTime"] = _totalTrainingTime;
    map["totalTrainingAmount"] = _totalTrainingAmount;
    map["totalCalories"] = _totalCalories;
    map["joinAmount"] = _joinAmount;
    map["commentCount"] = _commentCount;
    map["laudCount"] = _laudCount;
    map["finishAmount"] = _finishAmount;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    return map;
  }

}

/// id : 1
/// name : "动作名"
/// point : 100
/// picUrl : "http://devpic.aimymusic.com/ifcms/12萌妹子.jpg"
/// levelId : 1
/// levelDto : {"id":1,"type":null,"name":"零基础","updateTime":1608014617889,"ename":"L0"}
/// partId : 1
/// partDto : {"id":1,"type":null,"name":"减脂","updateTime":1607673809453,"ename":null}
/// calories : 1000
/// expectHeartRate : 100
/// steps : "步骤、自己猜"
/// breathingRhythm : "呼吸节奏"
/// movementFeeling : "动作感觉"
/// positionId : 1
/// muscleId : 1
/// detail : null
/// state : 1
/// creatorId : 1008611
/// dataState : 2
/// createTime : 1607570185761
/// updateTime : 1607570185761
/// positionDto : {"url":"http://devpic.aimymusic.com/ifcms/shoubi.jpg","content":"手臂"}
/// muscleDto : {"url":"http://devpic.aimymusic.com/ifcms/gongertouji.jpg","content":"肱二头肌"}
/// amount : 10
/// seconds : null
/// unit : "次"
/// aicheckSteps : [{"url":"www.baidu.com","content":"这是内容"}]

class MovementDtos {
  int _id;
  String _name;
  int _point;
  String _picUrl;
  int _levelId;
  SubTagModel _levelDto;
  int _partId;
  SubTagModel _partDto;
  int _calories;
  int _expectHeartRate;
  String _steps;
  String _breathingRhythm;
  String _movementFeeling;
  int _positionId;
  int _muscleId;
  dynamic _detail;
  int _state;
  int _creatorId;
  int _dataState;
  int _createTime;
  int _updateTime;
  MuscleDto _positionDto;
  MuscleDto _muscleDto;
  int _amount;
  int _seconds;
  String _unit;
  List<MuscleDto> _aicheckSteps;

  int get id => _id;

  String get name => _name;

  int get point => _point;

  String get picUrl => _picUrl;

  int get levelId => _levelId;

  SubTagModel get levelDto => _levelDto;

  int get partId => _partId;

  SubTagModel get partDto => _partDto;

  int get calories => _calories;

  int get expectHeartRate => _expectHeartRate;

  String get steps => _steps;

  String get breathingRhythm => _breathingRhythm;

  String get movementFeeling => _movementFeeling;

  int get positionId => _positionId;

  int get muscleId => _muscleId;

  dynamic get detail => _detail;

  int get state => _state;

  int get creatorId => _creatorId;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  MuscleDto get positionDto => _positionDto;

  MuscleDto get muscleDto => _muscleDto;

  int get amount => _amount;

  int get seconds => _seconds;

  String get unit => _unit;

  List<MuscleDto> get aicheckSteps => _aicheckSteps;

  MovementDtos({
    int id,
    String name,
    int point,
    String picUrl,
    int levelId,
      SubTagModel levelDto,
      int partId,
      SubTagModel partDto,
      int calories,
      int expectHeartRate,
      String steps,
      String breathingRhythm,
      String movementFeeling,
      int positionId,
      int muscleId,
      dynamic detail,
      int state,
      int creatorId,
      int dataState,
      int createTime,
      int updateTime,
      MuscleDto positionDto,
      MuscleDto muscleDto,
      int amount,
      int seconds,
      String unit,
      List<MuscleDto> aicheckSteps}) {
    _id = id;
    _name = name;
    _point = point;
    _picUrl = picUrl;
    _levelId = levelId;
    _levelDto = levelDto;
    _partId = partId;
    _partDto = partDto;
    _calories = calories;
    _expectHeartRate = expectHeartRate;
    _steps = steps;
    _breathingRhythm = breathingRhythm;
    _movementFeeling = movementFeeling;
    _positionId = positionId;
    _muscleId = muscleId;
    _detail = detail;
    _state = state;
    _creatorId = creatorId;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
    _positionDto = positionDto;
    _muscleDto = muscleDto;
    _amount = amount;
    _seconds = seconds;
    _unit = unit;
    _aicheckSteps = aicheckSteps;
  }

  MovementDtos.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _point = json["point"];
    _picUrl = json["picUrl"];
    _levelId = json["levelId"];
    _levelDto =
    json["levelDto"] != null ? SubTagModel.fromJson(json["levelDto"]) : null;
    _partId = json["partId"];
    _partDto =
    json["partDto"] != null ? SubTagModel.fromJson(json["partDto"]) : null;
    _calories = json["calories"];
    _expectHeartRate = json["expectHeartRate"];
    _steps = json["steps"];
    _breathingRhythm = json["breathingRhythm"];
    _movementFeeling = json["movementFeeling"];
    _positionId = json["positionId"];
    _muscleId = json["muscleId"];
    _detail = json["detail"];
    _state = json["state"];
    _creatorId = json["creatorId"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
    _positionDto = json["positionDto"] != null
        ? MuscleDto.fromJson(json["positionDto"])
        : null;
    _muscleDto =
    json["muscleDto"] != null ? MuscleDto.fromJson(json["muscleDto"]) : null;
    _amount = json["amount"];
    _seconds = json["seconds"];
    _unit = json["unit"];
    if (json["aicheckSteps"] != null) {
      _aicheckSteps = [];
      json["aicheckSteps"].forEach((v) {
        _aicheckSteps.add(MuscleDto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["point"] = _point;
    map["picUrl"] = _picUrl;
    map["levelId"] = _levelId;
    if (_levelDto != null) {
      map["levelDto"] = _levelDto.toJson();
    }
    map["partId"] = _partId;
    if (_partDto != null) {
      map["partDto"] = _partDto.toJson();
    }
    map["calories"] = _calories;
    map["expectHeartRate"] = _expectHeartRate;
    map["steps"] = _steps;
    map["breathingRhythm"] = _breathingRhythm;
    map["movementFeeling"] = _movementFeeling;
    map["positionId"] = _positionId;
    map["muscleId"] = _muscleId;
    map["detail"] = _detail;
    map["state"] = _state;
    map["creatorId"] = _creatorId;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    if (_positionDto != null) {
      map["positionDto"] = _positionDto.toJson();
    }
    if (_muscleDto != null) {
      map["muscleDto"] = _muscleDto.toJson();
    }
    map["amount"] = _amount;
    map["seconds"] = _seconds;
    map["unit"] = _unit;
    if (_aicheckSteps != null) {
      map["aicheckSteps"] = _aicheckSteps.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// url : "http://devpic.aimymusic.com/ifcms/gongertouji.jpg"
/// content : "肱二头肌"

class MuscleDto {
  String _url;
  String _content;

  String get url => _url;

  String get content => _content;

  MuscleDto({
    String url,
    String content}) {
    _url = url;
    _content = content;
  }

  MuscleDto.fromJson(dynamic json) {
    _url = json["url"];
    _content = json["content"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["url"] = _url;
    map["content"] = _content;
    return map;
  }

}


/// id : 1
/// name : "测试一"
/// picUrl : "www.baidu.com"
/// seconds : 300000
/// calories : 167
/// levelId : 2
/// levelDto : {"id":2,"type":null,"name":"初级","updateTime":1608014618089,"ename":"L1"}
/// targetId : 1
/// targetDto : {"id":1,"type":null,"name":"减脂","updateTime":1607673809453,"ename":null}
/// partId : 1
/// partDto : {"id":1,"type":null,"name":"全身","updateTime":1607673781969,"ename":null}
/// description : "测试测试"
/// dataState : 2
/// createTime : 1605254544449
/// updateTime : 1605254544449

class CoursewareDto {
  int _id;
  String _name;
  String _picUrl;
  int _seconds;
  int _calories;
  int _levelId;
  SubTagModel _levelDto;
  int _targetId;
  SubTagModel _targetDto;
  int _partId;
  SubTagModel _partDto;
  String _description;
  int _dataState;
  int _createTime;
  int _updateTime;

  int get id => _id;

  String get name => _name;

  String get picUrl => _picUrl;

  int get seconds => _seconds;

  int get calories => _calories;

  int get levelId => _levelId;

  SubTagModel get levelDto => _levelDto;

  int get targetId => _targetId;

  SubTagModel get targetDto => _targetDto;

  int get partId => _partId;

  SubTagModel get partDto => _partDto;

  String get description => _description;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  CoursewareDto({
    int id,
    String name,
    String picUrl,
    int seconds,
    int calories,
    int levelId,
    SubTagModel levelDto,
    int targetId,
    SubTagModel targetDto,
    int partId,
    SubTagModel partDto,
    String description,
    int dataState,
    int createTime,
    int updateTime}) {
    _id = id;
    _name = name;
    _picUrl = picUrl;
    _seconds = seconds;
    _calories = calories;
    _levelId = levelId;
    _levelDto = levelDto;
    _targetId = targetId;
    _targetDto = targetDto;
    _partId = partId;
    _partDto = partDto;
    _description = description;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
  }

  CoursewareDto.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _picUrl = json["picUrl"];
    _seconds = json["seconds"];
    _calories = json["calories"];
    _levelId = json["levelId"];
    _levelDto =
    json["levelDto"] != null ? SubTagModel.fromJson(json["levelDto"]) : null;
    _targetId = json["targetId"];
    _targetDto =
    json["targetDto"] != null ? SubTagModel.fromJson(json["targetDto"]) : null;
    _partId = json["partId"];
    _partDto =
    json["partDto"] != null ? SubTagModel.fromJson(json["partDto"]) : null;
    _description = json["description"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["picUrl"] = _picUrl;
    map["seconds"] = _seconds;
    map["calories"] = _calories;
    map["levelId"] = _levelId;
    if (_levelDto != null) {
      map["levelDto"] = _levelDto.toJson();
    }
    map["targetId"] = _targetId;
    if (_targetDto != null) {
      map["targetDto"] = _targetDto.toJson();
    }
    map["partId"] = _partId;
    if (_partDto != null) {
      map["partDto"] = _partDto.toJson();
    }
    map["description"] = _description;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    return map;
  }

}
