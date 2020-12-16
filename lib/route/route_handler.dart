import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/login/login_page.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/media_picker/preview_photo_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/scan_code_page.dart';
import 'package:mirror/page/rc_test_page.dart';
import 'package:mirror/page/training/live_broadcast/live_broadcast_page.dart';
import 'package:mirror/page/training/live_broadcast/live_detail_page.dart';
import 'package:mirror/page/training/video_course/video_course_list_page.dart';
import 'package:mirror/page/training/video_course/video_detail_page.dart';
import 'package:mirror/route/router.dart';

/// route_handler
/// Created by yangjiayi on 2020/11/14.

// 在router中已将所有参数装进了map中，并以AppRouter.paramData字段入参，所以处理入参时先解析该map
// 例：Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
var handlerIfPage = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return IfPage();
});
var handlerMain = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MainPage();
});

var handlerRCTest = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ProfileDto profile = ProfileDto.fromMap(data["profile"]);
  return RCTestPage();
});

var handlerMediaPicker = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return MediaPickerPage(
    data["maxImageAmount"],
    data["mediaType"],
    data["needCrop"],
    data["startPage"],
    data["cropOnlySquare"],
    data["isGoToPublish"],
  );
});

var handlerLogin = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

var handlerLike = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return Like();
});
var handlerScan = Handler(handlerFunc: (BuildContext context,Map<String,List<String>> params){
  return ScanCodePage();
});
var handlermineDetails = Handler(handlerFunc: (BuildContext context,Map<String,List<String>> params){
  return ProfileDetailPage();
});
var handlerReleaseFeed = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      Map<String, dynamic> data = json.decode(
          params[AppRouter.paramData].first);
      return ReleasePage();
    });

var handlerLiveBroadcast = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return LiveBroadcastPage();
    });

var handlerVideoCourseList = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return VideoCourseListPage();
    });

var handlerLiveDetail = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      Map<String, dynamic> data = json.decode(
          params[AppRouter.paramData].first);
      return LiveDetailPage(
        heroTag: data["heroTag"],
        liveCourseId: data["liveCourseId"],
        courseId: data["courseId"],
      );
    });

var handlerVideoDetail = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      Map<String, dynamic> data = json.decode(
          params[AppRouter.paramData].first);
      return VideoDetailPage(
        heroTag: data["heroTag"],
        liveCourseId: data["liveCourseId"],
        courseId: data["courseId"],
      );
    });

var handlerPreviewPhoto = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      Map<String, dynamic> data = json.decode(
          params[AppRouter.paramData].first);
      return PreviewPhotoPage(
        filePath: data["filePath"],
      );
    });
