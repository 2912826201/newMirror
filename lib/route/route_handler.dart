import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/data/model/live_video_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/login/login_page.dart';
import 'package:mirror/page/login/perfect_user_page.dart';
import 'package:mirror/page/login/phone_login_page.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/media_picker/preview_photo_page.dart';
import 'package:mirror/page/media_picker/preview_video_page.dart';
import 'package:mirror/page/message/chat_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/login_success_page.dart';
import 'package:mirror/page/profile/edit_information/edit_information_introduction.dart';
import 'package:mirror/page/profile/edit_information/edit_information_name.dart';
import 'package:mirror/page/profile/edit_information/edit_information_page.dart';
import 'package:mirror/page/profile/login_test_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/setting/about_page.dart';
import 'package:mirror/page/profile/setting/account_security_page.dart';
import 'package:mirror/page/profile/setting/blacklist_page.dart';
import 'package:mirror/page/profile/setting/feedback_page.dart';
import 'package:mirror/page/profile/setting/notice_setting_page.dart';
import 'package:mirror/page/profile/setting/setting_home_page.dart';
import 'package:mirror/page/scan_code_page.dart';
import 'package:mirror/page/profile/setting/blacklist_page.dart';
import 'package:mirror/page/profile/setting/feedback_page.dart';
import 'package:mirror/page/profile/setting/notice_setting_page.dart';
import 'package:mirror/page/profile/setting/setting_home_page.dart';
import 'package:mirror/page/rc_test_page.dart';
import 'package:mirror/page/test_page.dart';
import 'package:mirror/page/training/live_broadcast/live_broadcast_page.dart';
import 'package:mirror/page/training/live_broadcast/live_detail_page.dart';
import 'package:mirror/page/training/machine/connection_info_page.dart';
import 'package:mirror/page/training/machine/machine_setting_page.dart';
import 'package:mirror/page/training/machine/remote_controller_page.dart';
import 'package:mirror/page/training/video_course/video_course_list_page.dart';
import 'package:mirror/page/training/video_course/video_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:photo_manager/photo_manager.dart';
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
    fixedWidth: data["fixedWidth"],
    fixedHeight: data["fixedHeight"],
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
var handlermineDetails = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ProfileDetailPage(
    userId: data["userId"],
  );
});
var handlerProfileDetailMore = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ProfileDetailsMore();
});


var handlerEditInformation = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return EditInformation();
});

var handlerEditInformationName = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  if (data["title"] != null) {
    return EditInformationName(userName: data["username"], title: data["title"]);
  } else {
    return EditInformationName(
      userName: data["username"],
    );
  }
});

var handlerEditInformationIntroduction = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return EditInformationIntroduction(
    introduction: data["introduction"],
  );
});
var handlerSettingHomePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SettingHomePage();
});
var handlerSettingBlackList = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return BlackListPage();
});
var handlerSettingNoticeSetting = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return NoticeSettingPage();
});
var handlerSettingFeedBack = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return FeedBackPage();
});
var handlerSettingAbout = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return AboutPage();
});
var handlerSettingAccountSecurity = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return AccountSecurityPage();
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
  LiveVideoModel liveModel = LiveVideoModel.fromJson(data["liveModel"]);
  return LiveDetailPage(
    heroTag: data["heroTag"],
    liveCourseId: data["liveCourseId"],
    courseId: data["courseId"],
    liveModel: liveModel,
  );
});

var handlerVideoDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  LiveVideoModel videoModel = LiveVideoModel.fromJson(data["videoModel"]);
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
    fixedWidth: data["fixedWidth"],
    fixedHeight: data["fixedHeight"],
  );
});

var handlerPreviewVideo = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  SizeInfo sizeInfo = SizeInfo.fromJson(data["sizeInfo"]);
  return PreviewVideoPage(filePath: data["filePath"], sizeInfo: sizeInfo);
});

//完善信息界面
var handlerPerfectUserPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PerfectUserPage();
});
var handlerLoginSucessPagePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginSucessPage();
});
var handlerChatPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ConversationDto conversation = ConversationDto.fromMap(data["conversation"]);
  Message shareMessage = Application.shareMessage;
  Application.shareMessage = null;
  return ChatPage(conversation: conversation, shareMessage: shareMessage);
});

//机器遥控界面
var handlerMachineRemoteController = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RemoteControllerPage();
});

//机器连接信息页
var handlerMachineConnectionInfo = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ConnectionInfoPage();
});

//终端设置页
var handlerMachineSetting = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MachineSettingPage();
});

//扫描二维码页
var handlerScanCode = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ScanCodePage();
});
