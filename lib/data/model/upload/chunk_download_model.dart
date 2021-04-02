class ChunkDownLaodModel {
  int downLoadChunkEnd = 0;
  int downLoadTotal = 0;
  int downLoadChunkSize = 0;
  List<int> downLoadProgress = <int>[];
  int downLoadChunk = 0;
ChunkDownLaodModel({this.downLoadChunk =0,this.downLoadTotal =0,this.downLoadChunkEnd =0,this.downLoadChunkSize =0,this
    .downLoadProgress});
  ChunkDownLaodModel.fromJson(Map<String, dynamic> json) {
    downLoadChunkEnd = json["downLoadChunkEnd"];
    downLoadTotal = json["downLoadTotal"];
    downLoadChunkSize = json["downLoadChunkSize"];
    if (json["downLoadProgress"] != null) {
      json["downLoadProgress"].forEach((e) {
        downLoadProgress.add(e);
      });
      downLoadChunk = json["downLoadChunk"];
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["downLoadChunkEnd"] = downLoadChunkEnd;
    map["downLoadTotal"] = downLoadTotal;
    map["downLoadChunkSize"] = downLoadChunkSize;
    map["downLoadProgress"] = downLoadProgress;
    map["downLoadChunk"] = downLoadChunk;
    return map;
  }
}