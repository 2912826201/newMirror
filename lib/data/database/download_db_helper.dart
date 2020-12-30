import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/download_dto.dart';

/// download_db_helper
/// Created by yangjiayi on 2020/12/29.

class DownloadDBHelper {
  Future<bool> insertDownload(String taskId, String url, String filePath) async {
    DownloadDto dto = DownloadDto();
    dto.taskId = taskId;
    dto.url = url;
    dto.filePath = filePath;
    dto.createTime = DateTime.now().millisecondsSinceEpoch;
    var result = await DBHelper.instance.db.insert(TABLE_NAME_DOWNLOAD, dto.toMap());
    return result > 0;
  }

  Future<List<DownloadDto>> queryDownload(String url, {int limit}) async {
    List<DownloadDto> list = [];
    List<Map<String, dynamic>> result = [];

    if (limit != null && limit > 0) {
      result = await DBHelper.instance.db.query(TABLE_NAME_DOWNLOAD,
          where: "$COLUMN_NAME_DOWNLOAD_URL = '$url'", limit: limit, orderBy: "$COLUMN_NAME_DOWNLOAD_CREATETIME desc");
    } else {
      result = await DBHelper.instance.db.query(TABLE_NAME_DOWNLOAD,
          where: "$COLUMN_NAME_DOWNLOAD_URL = '$url'", orderBy: "$COLUMN_NAME_DOWNLOAD_CREATETIME desc");
    }
    for (Map<String, dynamic> map in result) {
      list.add(DownloadDto.fromMap(map));
    }
    return list;
  }

  Future<void> clearDownloadByTaskId(String taskId) async {
    await DBHelper.instance.db.delete(TABLE_NAME_DOWNLOAD, where: "$COLUMN_NAME_DOWNLOAD_TASKID = '$taskId'");
  }

  Future<void> clearDownloadByUrl(String url) async {
    await DBHelper.instance.db.delete(TABLE_NAME_DOWNLOAD, where: "$COLUMN_NAME_DOWNLOAD_URL = '$url'");
  }
}
