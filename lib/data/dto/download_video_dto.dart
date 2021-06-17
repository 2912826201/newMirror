import 'dart:convert';

import 'package:mirror/data/model/training/course_model.dart';

/// download_course_video_dto
/// Created by shipk on 2021/1/21

const String TABLE_NAME_DOWNLOAD_COURSE_VIDEO = "download_course_video";
const String COLUMN_NAME_DOWNLOAD_COURSE_ID = 'course_id';
const String COLUMN_NAME_DOWNLOAD_COURSE_NAME = 'course_name';
const String COLUMN_NAME_DOWNLOAD_COURSE_URLS = 'course_urls';
const String COLUMN_NAME_DOWNLOAD_COURSE_FILEPATHS = 'course_filePaths';
const String COLUMN_NAME_DOWNLOAD_COURSE_MODEL = 'course_model';
const String COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME = 'course_download_time';

class DownloadCourseVideoDto {
  int courseId;
  String courseName;
  List<String> courseUrls;
  List<String> courseFilePaths;
  CourseModel videoCourseModel;
  int downloadTime;

  DownloadCourseVideoDto();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_DOWNLOAD_COURSE_ID: courseId,
      COLUMN_NAME_DOWNLOAD_COURSE_NAME: courseName,
      COLUMN_NAME_DOWNLOAD_COURSE_URLS: getString(courseUrls),
      COLUMN_NAME_DOWNLOAD_COURSE_FILEPATHS: getString(courseFilePaths),
      COLUMN_NAME_DOWNLOAD_COURSE_MODEL: jsonEncode(videoCourseModel),
      COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME: downloadTime,
    };
    return map;
  }

  DownloadCourseVideoDto.fromMap(Map<String, dynamic> map) {
    courseId = map[COLUMN_NAME_DOWNLOAD_COURSE_ID];
    courseName = map[COLUMN_NAME_DOWNLOAD_COURSE_NAME];
    downloadTime = map[COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME];
    if (map[COLUMN_NAME_DOWNLOAD_COURSE_URLS] != null) {
      courseUrls = map[COLUMN_NAME_DOWNLOAD_COURSE_URLS].toString().split(",");
    }
    if (map[COLUMN_NAME_DOWNLOAD_COURSE_FILEPATHS] != null) {
      courseFilePaths = map[COLUMN_NAME_DOWNLOAD_COURSE_FILEPATHS].toString().split(",");
    }
    if (map[COLUMN_NAME_DOWNLOAD_COURSE_MODEL] != null) {
      dynamic mapDynamic=json.decode(map[COLUMN_NAME_DOWNLOAD_COURSE_MODEL]);
      if(mapDynamic!=null) {
        if(mapDynamic is CourseModel) {
          videoCourseModel = mapDynamic;
        }else{
          videoCourseModel = CourseModel.fromJson(mapDynamic);
        }
      }
    }
  }

  String getString(List<String> values) {
    if (values == null || values.length < 1) {
      return "";
    }
    String string = "";
    for (int i = 0; i < values.length; i++) {
      if (i == 0) {
        string += values[i];
      } else {
        string = string + "," + values[i];
      }
    }
    return string;
  }
}
