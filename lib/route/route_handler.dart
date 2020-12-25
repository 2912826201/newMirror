import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/login/login_page.dart';
import 'package:mirror/page/login/perfect_user_page.dart';
import 'package:mirror/page/login/phone_login_page.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/media_picker/preview_photo_page.dart';
import 'package:mirror/page/message/chat_page.dart';
import 'package:mirror/page/profile/Profile_add_remarks.dart';
import 'package:mirror/page/profile/edit_information/edit_information_introduction.dart';
import 'package:mirror/page/profile/edit_information/edit_information_name.dart';
import 'package:mirror/page/profile/edit_information/edit_information_page.dart';
import 'package:mirror/page/profile/login_test_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/scan_code_page.dart';
import 'package:mirror/page/profile/setting_page/setting_home_page.dart';
import 'package:mirror/page/rc_test_page.dart';
import 'package:mirror/page/test_page.dart';
import 'package:mirror/page/training/live_broadcast/live_broadcast_page.dart';
import 'package:mirror/page/training/live_broadcast/live_detail_page.dart';
import 'package:mirror/page/training/video_course/video_course_list_page.dart';
import 'package:mirror/page/training/video_course/video_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// route_handler
/// Created by yangjiayi on 2020/11/14.

// 在router中已将所有参数装进了map中，并以AppRouter.paramData字段入参，所以处理入参时先解析该map
// 例：Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
var handlerIfPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  GlobalKey thekey = GlobalKey();
  SingletonForWholePages.singleton().IfPagekey = thekey;
  return IfPage(
    key: thekey,
  );
});
// var handlerIfPage = Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   return IfPage();
// });
var handlerMain = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MainPage();
});

var handlerTest = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TestPage();
});

var handlerLoginTest = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginTestPage();
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

var handlerLoginPhone = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PhoneLoginPage();
});

var handlerLike = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return Like();
});
var handlerScan = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ScanCodePage();
});
var handlermineDetails = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ProfileDetailPage(
    userId: data["userId"],
    pcController: data["pcController"],
  );
});
var handlerProfileDetailMore = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ProfileDetailsMore();
});
var handlerProfileAddRemarks = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ProfileAddRemarks(
    userName: data["username"],
    userId: data["userId"],
  );
});

var handlerEditInformation = Handler(handlerFunc: (BuildContext context,Map<String,List<String>> params){
  return EditInformation();
});

var handlerEditInformationName = Handler(handlerFunc: (BuildContext context,Map<String,List<String>> params){
  Map<String, dynamic> data = json.decode(
    params[AppRouter.paramData].first);
  return EditInformationName(
    userName: data["username"],
  );
});

var handlerEditInformationIntroduction = Handler(handlerFunc: (BuildContext context,Map<String,List<String>> params){
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return EditInformationIntroduction(introduction: data["introduction"],);
});
var handlerSettingHomePage = Handler(handlerFunc: (BuildContext context,Map<String,List<String>> params){
  return SettingHomePage();
});
var handlerReleaseFeed = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ReleasePage();
});

var handlerLiveBroadcast = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LiveBroadcastPage();
});

var handlerVideoCourseList = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return VideoCourseListPage();
});

var handlerLiveDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  LiveModel liveModel = LiveModel.fromJson(data["liveModel"]);
  return LiveDetailPage(
    heroTag: data["heroTag"],
    liveCourseId: data["liveCourseId"],
    courseId: data["courseId"],
    liveModel: liveModel,
  );
});

var handlerVideoDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  LiveModel videoModel = LiveModel.fromJson(data["videoModel"]);
  return VideoDetailPage(
    heroTag: data["heroTag"],
    liveCourseId: data["liveCourseId"],
    courseId: data["courseId"],
    videoModel: videoModel,
  );
});

var handlerPreviewPhoto = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return PreviewPhotoPage(
    filePath: data["filePath"],
  );
});

//完善信息界面
var handlerPerfectUserPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PerfectUserPage();
});

var handlerChatPage = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
      ConversationDto conversation = ConversationDto.fromMap(data["conversation"]);
      Message shareMessage = Application.shareMessage;
      Application.shareMessage = null;
      return ChatPage(conversation: conversation, shareMessage: shareMessage);
    });
