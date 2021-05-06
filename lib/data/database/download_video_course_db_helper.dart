import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/download_video_dto.dart';
import 'package:mirror/data/model/training/course_model.dart';

/// download_video_course_db_helper
/// Created by shipk on 2021/1/21.

class DownloadVideoCourseDBHelper {
  Future<bool> update(CourseModel videoCourseModel, List<String> courseUrls, List<String> courseFilePaths) async {
    if (videoCourseModel == null) {
      return false;
    }
    if (await isHave(videoCourseModel.id)) {
      return await _update(videoCourseModel, courseUrls, courseFilePaths);
    } else {
      return await _insert(videoCourseModel, courseUrls, courseFilePaths);
    }
  }

  Future<bool> _insert(CourseModel videoCourseModel, List<String> courseUrls, List<String> courseFilePaths) async {
    if (videoCourseModel == null) {
      return false;
    }
    DownloadCourseVideoDto dto = DownloadCourseVideoDto();
    dto.courseId = videoCourseModel.id;
    dto.courseName = videoCourseModel.title;
    dto.courseFilePaths = courseFilePaths;
    dto.courseUrls = courseUrls;
    dto.downloadTime = new DateTime.now().millisecondsSinceEpoch;
    // dto.videoCourseModel=videoCourseModel;
    var result = await DBHelper.instance.db.insert(TABLE_NAME_DOWNLOAD_COURSE_VIDEO, dto.toMap());
    return result > 0;
  }

  Future<bool> _update(CourseModel videoCourseModel, List<String> courseUrls, List<String> courseFilePaths) async {
    if (videoCourseModel == null) {
      return false;
    }
    DownloadCourseVideoDto dto = DownloadCourseVideoDto();
    dto.courseId = videoCourseModel.id;
    dto.courseName = videoCourseModel.title;
    dto.courseFilePaths = courseFilePaths;
    dto.courseUrls = courseUrls;
    dto.downloadTime = new DateTime.now().millisecondsSinceEpoch;
    // dto.videoCourseModel=videoCourseModel;
    var result = await DBHelper.instance.db.update(TABLE_NAME_DOWNLOAD_COURSE_VIDEO, dto.toMap(),
        where: "$COLUMN_NAME_DOWNLOAD_COURSE_ID = '${dto.courseId}'");
    return result > 0;
  }

  Future<List<DownloadCourseVideoDto>> queryAll({int limit = -1, int downloadTime = 0}) async {
    List<DownloadCourseVideoDto> list = [];
    List<Map<String, dynamic>> result = [];

    if (limit > 0) {
      if (downloadTime != 0) {
        result = await DBHelper.instance.db.query(TABLE_NAME_DOWNLOAD_COURSE_VIDEO,
            where: "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME < '$downloadTime'",
            limit: limit,
            orderBy: "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME desc");
      } else {
        result = await DBHelper.instance.db.query(TABLE_NAME_DOWNLOAD_COURSE_VIDEO,
            limit: limit, orderBy: "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME desc");
      }
    } else {
      if (downloadTime != 0) {
        result = await DBHelper.instance.db.query(TABLE_NAME_DOWNLOAD_COURSE_VIDEO,
            where: "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME < '$downloadTime'",
            orderBy: "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME desc");
      } else {
        result = await DBHelper.instance.db
            .query(TABLE_NAME_DOWNLOAD_COURSE_VIDEO, orderBy: "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME desc");
      }
    }

    print("result:${result.length}， result1:${result.toString()}");

    for (Map<String, dynamic> map in result) {
      list.add(DownloadCourseVideoDto.fromMap(map));
    }
    return list;
  }

  Future<bool> isHave(int courseId) async {
    List<Map<String, dynamic>> result = [];
    result = await DBHelper.instance.db
        .query(TABLE_NAME_DOWNLOAD_COURSE_VIDEO, where: "$COLUMN_NAME_DOWNLOAD_COURSE_ID = '$courseId'");
    return result != null && result.length > 0;
  }

  Future<void> clearAll() async {
    await DBHelper.instance.db.delete(TABLE_NAME_DOWNLOAD_COURSE_VIDEO);
  }

  Future<void> remove(DownloadCourseVideoDto dto) async {
    await DBHelper.instance.db
        .delete(TABLE_NAME_DOWNLOAD_COURSE_VIDEO, where: "$COLUMN_NAME_DOWNLOAD_COURSE_ID = '${dto.courseId}'");
  }
}
