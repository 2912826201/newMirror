import 'home/home_feed.dart';

/// hasNext : 1
/// lastTime : null
/// lastId : null
/// lastScore : null
/// list : [{"id":450721505458813630,"targetId":1,"type":1,"content":"我在评论课程","picUrls":null,"createTime":1606298780904,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[{"id":450763525506235100,"targetId":450721505458813630,"type":2,"content":"hello world!!!!!!","picUrls":null,"createTime":1606308799263,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[{"id":450992876965362370,"targetId":450763525506235100,"type":2,"content":"good morning","picUrls":null,"createTime":1606363480912,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":450992757125708500,"targetId":450763525506235100,"type":2,"content":"hello world!!!!!!","picUrls":null,"createTime":1606363452343,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null}],"replyCount":4,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":450764844413516500,"targetId":450721505458813630,"type":2,"content":"hello world!!!!!!","picUrls":null,"createTime":1606309113717,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null}],"replyCount":14,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451052317958045700,"targetId":1,"type":1,"content":"我又来了","picUrls":null,"createTime":1606377652751,"atUsers":null,"uid":1000111,"name":"bigfish","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":1,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451112464067690500,"targetId":1,"type":1,"content":"我又来了le 啊啊啊","picUrls":null,"createTime":1606391992702,"atUsers":null,"uid":1000111,"name":"bigfish","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451058859914657800,"targetId":1,"type":1,"content":"我又来了le 乐乐乐","picUrls":null,"createTime":1606379212473,"atUsers":[{"uid":1000000413,"index":0,"len":7,"type":null},{"uid":1000000405,"index":0,"len":8,"type":null},{"uid":1000000405,"index":0,"len":8,"type":null}],"uid":1000111,"name":"bigfish","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451040533687597760,"targetId":1,"type":1,"content":"评论一下课程","picUrls":null,"createTime":1606374843161,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null}]
/// totalPage : null
/// totalCount : 6

class CommentModel {
  int _hasNext;
  dynamic _lastTime;
  dynamic _lastId;
  dynamic _lastScore;
  List<CommentDtoModel> _list;
  dynamic _totalPage;
  int _totalCount;

  int get hasNext => _hasNext;

  dynamic get lastTime => _lastTime;

  dynamic get lastId => _lastId;

  dynamic get lastScore => _lastScore;

  List<CommentDtoModel> get list => _list;

  dynamic get totalPage => _totalPage;

  int get totalCount => _totalCount;

  CommentModel(
      {int hasNext,
      dynamic lastTime,
      dynamic lastId,
      dynamic lastScore,
      List<CommentDtoModel> list,
      dynamic totalPage,
      int totalCount}) {
    _hasNext = hasNext;
    _lastTime = lastTime;
    _lastId = lastId;
    _lastScore = lastScore;
    _list = list;
    _totalPage = totalPage;
    _totalCount = totalCount;
  }

  CommentModel.fromJson(dynamic json) {
    _hasNext = json["hasNext"];
    _lastTime = json["lastTime"];
    _lastId = json["lastId"];
    _lastScore = json["lastScore"];
    if (json["list"] != null) {
      _list = [];
      json["list"].forEach((v) {
        _list.add(CommentDtoModel.fromJson(v));
      });
    }
    _totalPage = json["totalPage"];
    _totalCount = json["totalCount"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["hasNext"] = _hasNext;
    map["lastTime"] = _lastTime;
    map["lastId"] = _lastId;
    map["lastScore"] = _lastScore;
    if (_list != null) {
      map["list"] = _list.map((v) => v.toJson()).toList();
    }
    map["totalPage"] = _totalPage;
    map["totalCount"] = _totalCount;
    return map;
  }
}
