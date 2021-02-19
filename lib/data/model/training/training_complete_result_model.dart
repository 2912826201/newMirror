class TrainingCompleteResultModel {
  int uid; //用户id
  int hasResult; //是否有结果 0-无 1-有
  int mseconds; //本次训练时长
  int msecondsCount; //总训练时长
  int calorie; //本次消耗卡路里
  int calorieCount; //总卡路里
  int synthesisScore; //动作总得分
  double synthesisRank; //综合排名
  double coreRank; //核心排名
  double upperRank; //上肢排名
  double lowerRank; //下肢排名
  double completionDegree; //完成度
  int courseId; //课程id
  int type; //课程类型 0-直播 1-视频
  int no; //第几次完成该训练
  String startTime; //直播课的话有开始时间

  TrainingCompleteResultModel(
      {this.uid,
      this.hasResult,
      this.mseconds,
      this.msecondsCount,
      this.calorie,
      this.calorieCount,
      this.synthesisScore,
      this.synthesisRank,
      this.coreRank,
      this.upperRank,
      this.lowerRank,
      this.completionDegree,
      this.courseId,
      this.type,
      this.no,
      this.startTime});

  TrainingCompleteResultModel.fromJson(dynamic json) {
    uid = json["uid"];
    hasResult = json["hasResult"];
    mseconds = json["mseconds"];
    msecondsCount = json["msecondsCount"];
    calorie = json["calorie"];
    calorieCount = json["calorieCount"];
    synthesisScore = json["synthesisScore"];
    synthesisRank = json["synthesisRank"];
    coreRank = json["coreRank"];
    upperRank = json["upperRank"];
    lowerRank = json["lowerRank"];
    completionDegree = json["completionDegree"];
    courseId = json["courseId"];
    type = json["type"];
    no = json["no"];
    startTime = json["startTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["hasResult"] = hasResult;
    map["mseconds"] = mseconds;
    map["msecondsCount"] = msecondsCount;
    map["calorie"] = calorie;
    map["calorieCount"] = calorieCount;
    map["synthesisScore"] = synthesisScore;
    map["synthesisRank"] = synthesisRank;
    map["coreRank"] = coreRank;
    map["upperRank"] = upperRank;
    map["lowerRank"] = lowerRank;
    map["completionDegree"] = completionDegree;
    map["courseId"] = courseId;
    map["type"] = type;
    map["no"] = no;
    map["startTime"] = startTime;
    return map;
  }
}
