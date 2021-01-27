import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
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
import 'package:mirror/page/profile/me_course/me_course_page.dart';
import 'package:mirror/page/profile/me_course/me_download_video_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/setting/about_page.dart';
import 'package:mirror/page/profile/setting/account_security_page.dart';
import 'package:mirror/page/profile/setting/blacklist_page.dart';
import 'package:mirror/page/profile/setting/feedback_page.dart';
import 'package:mirror/page/profile/setting/notice_setting_page.dart';
import 'package:mirror/page/profile/setting/setting_home_page.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_comparison_page.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_detail_page.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_page.dart';
import 'package:mirror/page/profile/training_record/training_record_all_page.dart';
import 'package:mirror/page/profile/training_record/training_record_page.dart';
import 'package:mirror/page/profile/training_record/weight_record_page.dart';
import 'package:mirror/page/profile/vip/vip_nameplate_page.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/profile/vip/vip_open_page.dart';
import 'package:mirror/page/rc_test_page.dart';
import 'package:mirror/page/scan_code/scan_code_page.dart';
import 'package:mirror/page/test_page.dart';
import 'package:mirror/page/training/live_broadcast/live_broadcast_page.dart';
import 'package:mirror/page/training/live_broadcast/live_detail_page.dart';
import 'package:mirror/page/training/machine/connection_info_page.dart';
import 'package:mirror/page/training/machine/machine_setting_page.dart';
import 'package:mirror/page/training/machine/remote_controller_page.dart';
import 'package:mirror/page/training/video_course/video_course_list_page.dart';
import 'package:mirror/page/training/video_course/video_course_play_page.dart';
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
var handlerVipNotOpen = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VipNotOpenPage(type:data["vipState"]);
});
var handlerVipOpen = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return VipOpenPage();
});
var handlerVipNamePlatePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VipNamePlatePage(index: data["index"],);
});

var handlerTrainingRecord = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TrainingRecordPage();
});

var handlerWeightRecordPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return WeightRecordPage();
});

var handlerTrainingRecordAllPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TrainingRecordAllPage();
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

var handlerVideoCoursePlay = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VideoCoursePlayPage(
      Map<String, String>.from(data["videoPathMap"]), LiveVideoModel.fromJson(data["videoCourseModel"]));
});

//直播课程详情界面
var handlerLiveDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  LiveVideoModel liveModel;
  if (data["liveModel"] != null) {
    liveModel = LiveVideoModel.fromJson(data["liveModel"]);
  }
  return LiveDetailPage(
    heroTag: data["heroTag"] == null ? "" : data["heroTag"],
    liveCourseId: data["liveCourseId"],
    isHaveStartTime: data["isHaveStartTime"],
    liveModel: liveModel,
  );
});

//视频课程详情界面
var handlerVideoDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  LiveVideoModel videoModel;
  if (data["videoModel"] != null) {
    videoModel = LiveVideoModel.fromJson(data["videoModel"]);
  }
  return VideoDetailPage(
    heroTag: data["heroTag"] == null ? "" : data["heroTag"],
    liveCourseId: data["videoCourseId"],
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

//消息界面
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

//健身相册页
var handlerTrainingGallery = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TrainingGalleryPage();
});

//健身相册详情页
var handlerTrainingGalleryDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  List<TrainingGalleryDayModel> dataList = [];
  data["dataList"].forEach((e){
    dataList.add(TrainingGalleryDayModel.fromJson(e));
  });
  int dayIndex = data["dayIndex"];
  int imageIndex = data["imageIndex"];
  return TrainingGalleryDetailPage(dataList, dayIndex: dayIndex, imageIndex: imageIndex);
});

//健身相册对比图页
var handlerTrainingGalleryComparison = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  TrainingGalleryImageModel image1 = TrainingGalleryImageModel.fromJson(data["image1"]);
  TrainingGalleryImageModel image2 = TrainingGalleryImageModel.fromJson(data["image2"]);
  return TrainingGalleryComparisonPage(image1, image2);
});

//我的课程界面
var handlerMeCoursePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MeCoursePage();
});

//我的课程界面--下载课程界面
var handlerMeDownloadVideoCoursePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MeDownloadVideoCoursePage();
});
