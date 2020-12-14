import 'package:mirror/util/date_util.dart';

import 'user_model.dart';

/// id : 2
/// courseId : 1
/// name : "减脂塑形"
/// creatorId : 1008611
/// coachId : 1008611
/// coachDto : {"uid":1008611,"phone":"13111856853","type":2,"subType":1,"nickName":"爸爸","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","description":null,"birthday":null,"sex":null,"constellation":null,"cityCode":null,"longitude":null,"latitude":null,"password":"MTMxMTE4NTY4NTM=","address":null,"source":null,"createTime":1605182811646,"updateTime":null,"deletedTime":null,"status":2,"age":null,"isPerfect":1,"isPhone":1}
/// coursewareId : 1
/// coursewareDto : {"id":1,"name":"测试一","picUrl":"www.baidu.com","seconds":300000,"calories":167,"levelId":2,"levelDto":{"id":2,"name":"初级","updateTime":1607568828227},"targetId":1,"targetDto":{"id":1,"name":"减脂","updateTime":1607422868082},"partId":1,"partDto":{"id":1,"name":"全身","updateTime":1607422919497},"description":"测试测试","dataState":2,"createTime":1605254544449,"updateTime":1605254544449}
/// videoUrl : null
/// startTime : "2020-11-16 11:00"
/// endTime : "2020-11-16 11:10"
/// videoSeconds : null
/// movementDtos : null
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
      if (startTime.isNotEmpty) {
        DateTime dateTime = DateUtil.stringToDateTime(this.startTime);
        var startTime = dateTime.add(new Duration(minutes: -15));
        if (DateUtil.compareNowDate(startTime)) {
          this.playType = 2;
          return "预约";
        } else {
          this.playType = 1;
          return "去上课";
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
  String _videoUrl;
  String _startTime;
  String _endTime;
  int _videoSeconds;
  MovementDto _movementDtos;
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

  String get videoUrl => _videoUrl;

  String get startTime => _startTime;

  String get endTime => _endTime;

  int get videoSeconds => _videoSeconds;

  MovementDto get movementDtos => _movementDtos;

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
      String videoUrl,
      String startTime,
      String endTime,
      int videoSeconds,
      MovementDto movementDtos,
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
    _coursewareDto = json["coursewareDto"] != null
        ? CoursewareDto.fromJson(json["coursewareDto"])
        : null;
    _videoUrl = json["videoUrl"];
    _startTime = json["startTime"];
    _endTime = json["endTime"];
    _videoSeconds = json["videoSeconds"];
    _movementDtos = json["movementDtos"];
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
    map["videoUrl"] = _videoUrl;
    map["startTime"] = _startTime;
    map["endTime"] = _endTime;
    map["videoSeconds"] = _videoSeconds;
    map["movementDtos"] = _movementDtos;
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
/// name : "测试一"
/// picUrl : "www.baidu.com"
/// seconds : 300000
/// calories : 167
/// levelId : 2
/// levelDto : {"id":2,"name":"初级","updateTime":1607568828227}
/// targetId : 1
/// targetDto : {"id":1,"name":"减脂","updateTime":1607422868082}
/// partId : 1
/// partDto : {"id":1,"name":"全身","updateTime":1607422919497}
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
  LevelDto _levelDto;
  int _targetId;
  TargetDto _targetDto;
  int _partId;
  PartDto _partDto;
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

  LevelDto get levelDto => _levelDto;

  int get targetId => _targetId;

  TargetDto get targetDto => _targetDto;

  int get partId => _partId;

  PartDto get partDto => _partDto;

  String get description => _description;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  CoursewareDto(
      {int id,
      String name,
      String picUrl,
      int seconds,
      int calories,
      int levelId,
      LevelDto levelDto,
      int targetId,
      TargetDto targetDto,
      int partId,
      PartDto partDto,
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
        json["levelDto"] != null ? LevelDto.fromJson(json["levelDto"]) : null;
    _targetId = json["targetId"];
    _targetDto = json["targetDto"] != null
        ? TargetDto.fromJson(json["targetDto"])
        : null;
    _partId = json["partId"];
    _partDto =
        json["partDto"] != null ? PartDto.fromJson(json["partDto"]) : null;
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

/// id : 1
/// name : "全身"
/// updateTime : 1607422919497

class PartDto {
  int _id;
  String _name;
  int _updateTime;

  int get id => _id;

  String get name => _name;

  int get updateTime => _updateTime;

  PartDto({int id, String name, int updateTime}) {
    _id = id;
    _name = name;
    _updateTime = updateTime;
  }

  PartDto.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["updateTime"] = _updateTime;
    return map;
  }
}

/// id : 1
/// name : "减脂"
/// updateTime : 1607422868082

class TargetDto {
  int _id;
  String _name;
  int _updateTime;

  int get id => _id;

  String get name => _name;

  int get updateTime => _updateTime;

  TargetDto({int id, String name, int updateTime}) {
    _id = id;
    _name = name;
    _updateTime = updateTime;
  }

  TargetDto.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["updateTime"] = _updateTime;
    return map;
  }
}

/// id : 2
/// name : "初级"
/// updateTime : 1607568828227

class LevelDto {
  int _id;
  String _name;
  int _updateTime;

  int get id => _id;

  String get name => _name;

  int get updateTime => _updateTime;

  LevelDto({int id, String name, int updateTime}) {
    _id = id;
    _name = name;
    _updateTime = updateTime;
  }

  LevelDto.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["updateTime"] = _updateTime;
    return map;
  }
}


/// id : 2
/// name : "初级"
/// updateTime : 1607568828227

class MovementDto {
  int _id;
  String _name;
  int _point;
  String _picUrl;
  int _levelId;
  dynamic _partDto;
  int _calories;
  int _expectHeartRate;
  String _steps;
  String _breathingRhythm;
  String _movementFeeling;
  int _positionId;
  int _muscleId;
  List<GeneralUrlDto> _detail;
  List<GeneralUrlDto> _AIcheckSteps;
  int _state;
  int _creatorId;
  int _dataState;
  int _createTime;
  int _updateTime;
  GeneralUrlDto _positionDto;
  GeneralUrlDto _muscleDto;
  int _amount;
  int _seconds;
  String _unit;


  int get id => _id;

  String get name => _name;

  int get point => _point;

  String get picUrl => _picUrl;

  int get levelId => _levelId;

  dynamic get partDto => _partDto;

  int get calories => _calories;

  int get expectHeartRate => _expectHeartRate;

  String get steps => _steps;

  String get breathingRhythm => _breathingRhythm;

  String get movementFeeling => _movementFeeling;

  int get positionId => _positionId;

  int get muscleId => _muscleId;

  List<GeneralUrlDto> get detail => _detail;

  List<GeneralUrlDto> get AIcheckSteps => _AIcheckSteps;

  int get state => _state;

  int get creatorId => _creatorId;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  GeneralUrlDto get positionDto => _positionDto;

  GeneralUrlDto get muscleDto => _muscleDto;

  int get amount => _amount;

  int get seconds => _seconds;

  String get unit => _unit;

  MovementDto({
    int id,
    String name,
    int point,
    String picUrl,
    int levelId,
    dynamic partDto,
    int calories,
    int expectHeartRate,
    String steps,
    String breathingRhythm,
    String movementFeeling,
    int positionId,
    int muscleId,
    List<GeneralUrlDto> detail,
    List<GeneralUrlDto> AIcheckSteps,
    int state,
    int creatorId,
    int dataState,
    int createTime,
    int updateTime,
    GeneralUrlDto positionDto,
    GeneralUrlDto muscleDto,
    int amount,
    int seconds,
    String unit,
  }) {
    _id = id;
    _name = name;
    _point = point;
    _picUrl = picUrl;
    _levelId = levelId;
    _partDto = partDto;
    _calories = calories;
    _expectHeartRate = expectHeartRate;
    _steps = steps;
    _breathingRhythm = breathingRhythm;
    _movementFeeling = movementFeeling;
    _positionId = positionId;
    _muscleId = muscleId;
    _detail = detail;
    _AIcheckSteps = AIcheckSteps;
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
  }

  MovementDto.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _point = json["point"];
    _picUrl = json["picUrl"];
    _levelId = json["levelId"];
    _partDto = json["partDto"];
    _calories = json["calories"];
    _expectHeartRate = json["expectHeartRate"];
    _steps = json["steps"];
    _breathingRhythm = json["breathingRhythm"];
    _movementFeeling = json["movementFeeling"];
    _positionId = json["positionId"];
    _muscleId = json["muscleId"];
    _detail = json["detail"];
    _AIcheckSteps = json["AIcheckSteps"];
    _state = json["state"];
    _creatorId = json["creatorId"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
    _positionDto = json["positionDto"];
    _muscleDto = json["muscleDto"];
    _amount = json["amount"];
    _seconds = json["seconds"];
    _unit = json["unit"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["point"] = _point;
    map["picUrl"] = _picUrl;
    map["levelId"] = _levelId;
    map["partDto"] = _partDto;
    map["calories"] = _calories;
    map["expectHeartRate"] = _expectHeartRate;
    map["steps"] = _steps;
    map["breathingRhythm"] = _breathingRhythm;
    map["movementFeeling"] = _movementFeeling;
    map["positionId"] = _positionId;
    map["muscleId"] = _muscleId;
    map["detail"] = _detail;
    map["AIcheckSteps"] = _AIcheckSteps;
    map["state"] = _state;
    map["creatorId"] = _creatorId;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    map["positionDto"] = _positionDto;
    map["muscleDto"] = _muscleDto;
    map["amount"] = _amount;
    map["seconds"] = _seconds;
    map["unit"] = _unit;
    return map;
  }
}


class GeneralUrlDto {
  String _url;
  String _content;

  String get url => _url;

  String get content => _content;

  GeneralUrlDto({String url, String content}) {
    _url = url;
    _content = content;
  }

  GeneralUrlDto.fromJson(dynamic json) {
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

