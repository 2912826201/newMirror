class SearchHotWords {
  int rank;
  String name;
  int count;
  String creatorName;

  SearchHotWords({this.rank, this.name, this.count, this.creatorName});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["rank"] = rank;
    map["name"] = name;
    map["creatorName"] = creatorName;
    map["count"] = count;
    return map;
  }

  SearchHotWords.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    creatorName = json["creatorName"];
    count = json["count"];
    rank = json["rank"];
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
