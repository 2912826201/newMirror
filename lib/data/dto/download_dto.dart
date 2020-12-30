/// download_dto
/// Created by yangjiayi on 2020/12/29.

const String TABLE_NAME_DOWNLOAD = "download";
const String COLUMN_NAME_DOWNLOAD_ID = 'id';
const String COLUMN_NAME_DOWNLOAD_TASKID = 'taskId';
const String COLUMN_NAME_DOWNLOAD_URL = 'url';
const String COLUMN_NAME_DOWNLOAD_FILEPATH = 'filePath';
const String COLUMN_NAME_DOWNLOAD_CREATETIME = 'createTime';

class DownloadDto {
  int id;
  String taskId;
  String url;
  String filePath;
  int createTime;

  DownloadDto();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_DOWNLOAD_ID : id,
      COLUMN_NAME_DOWNLOAD_TASKID : taskId,
      COLUMN_NAME_DOWNLOAD_URL : url,
      COLUMN_NAME_DOWNLOAD_FILEPATH : filePath,
      COLUMN_NAME_DOWNLOAD_CREATETIME : createTime,
    };
    return map;
  }

  DownloadDto.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_NAME_DOWNLOAD_ID];
    taskId = map[COLUMN_NAME_DOWNLOAD_TASKID];
    url = map[COLUMN_NAME_DOWNLOAD_URL];
    filePath = map[COLUMN_NAME_DOWNLOAD_FILEPATH];
    createTime = map[COLUMN_NAME_DOWNLOAD_CREATETIME];
  }
}