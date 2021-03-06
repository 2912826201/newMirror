import 'dart:convert';

import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/activity/activity_change_address_page.dart';
import 'package:mirror/page/activity/activity_detail_page.dart';
import 'package:mirror/page/activity/activity_flow.dart';
import 'package:mirror/page/activity/activity_user_page.dart';
import 'package:mirror/page/activity/create_activity_page.dart';
import 'package:mirror/page/activity/participated_in_activities_page.dart';
import 'package:mirror/page/feed/feed_flow/feed_flow_page.dart';
import 'package:mirror/page/feed/create_map_screen.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/feed/search_or_location.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/login/login_page.dart';
import 'package:mirror/page/login/perfect_user_page.dart';
import 'package:mirror/page/login/phone_login_page.dart';
import 'package:mirror/page/login/sms_code_page.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/media_picker/preview_photo_page.dart';
import 'package:mirror/page/media_picker/preview_video_page.dart';
import 'package:mirror/page/message/chat_page.dart';
import 'package:mirror/page/message/link_failure/network_link_failure_page.dart';
import 'package:mirror/page/message/more_page/group_more_page.dart';
import 'package:mirror/page/message/more_page/group_qrcode_page.dart';
import 'package:mirror/page/message/more_page/private_more_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/body_type_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/fitness_level_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/fitness_part_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/fitness_target_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/height_and_weight_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/login_success_page.dart';
import 'package:mirror/page/profile/edit_information/edit_information_introduction.dart';
import 'package:mirror/page/profile/edit_information/edit_information_name.dart';
import 'package:mirror/page/profile/edit_information/edit_information_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/train_several_times.dart';
import 'package:mirror/page/profile/interactive_notification/interactive_notice_page.dart';
import 'package:mirror/page/profile/me_course/me_course_page.dart';
import 'package:mirror/page/profile/me_course/me_download_video_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/query_list/query_follow_list.dart';
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
import 'package:mirror/page/promotion/manager_qr_code_page.dart';
import 'package:mirror/page/promotion/new_user_promotion_page.dart';
import 'package:mirror/page/test/rc_test_page.dart';
import 'package:mirror/page/scan_code/my_qrcode_page.dart';
import 'package:mirror/page/scan_code/scan_code_page.dart';
import 'package:mirror/page/scan_code/scan_result_page.dart';
import 'package:mirror/page/search/search_page.dart';
import 'package:mirror/page/test/test_page.dart';
import 'package:mirror/page/topic/topic_detail.dart';
import 'package:mirror/page/training/live_broadcast/live_broadcast_page.dart';
import 'package:mirror/page/training/live_broadcast/live_detail_page.dart';
import 'package:mirror/page/training/machine/connection_info_page.dart';
import 'package:mirror/page/training/machine/machine_setting_page.dart';
import 'package:mirror/page/training/machine/remote_controller_page.dart';
import 'package:mirror/page/training/video_course/video_course_list_page.dart';
import 'package:mirror/page/training/video_course/video_course_play_page.dart';
import 'package:mirror/page/training/video_course/video_course_result_page.dart';
import 'package:mirror/page/training/video_course/video_detail_page.dart';
import 'package:mirror/page/webview/webview_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';
import 'package:mirror/widget/surrounding_information.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// route_handler
/// Created by yangjiayi on 2020/11/14.

// ???router??????????????????????????????map????????????AppRouter.paramData????????????????????????????????????????????????map
// ??????Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
var handlerIfPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  GlobalKey thekey = GlobalKey();
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

var handlerRCTest = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ProfileDto profile = ProfileDto.fromMap(data["profile"]);
  return RCTestPage();
});

var handlerMediaPicker = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ActivityModel activityModel;
  if (data["activityModel"] != null) {
    activityModel = ActivityModel.fromJson(data["activityModel"]);
  }
  return MediaPickerPage(
    data["maxImageAmount"],
    data["mediaType"],
    data["needCrop"],
    data["startPage"],
    data["cropOnlySquare"],
    publishMode: data["publishMode"],
    fixedWidth: data["fixedWidth"],
    fixedHeight: data["fixedHeight"],
    startCount: data["startCount"],
    topicId: data["topicId"],
    activityModel: activityModel,
  );
});

var handlerLogin = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

var handlerLoginPhone = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PhoneLoginPage();
});

var handlerLoginSmsCode = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return SmsCodePage(
    phoneNumber: data["phoneNumber"],
    isSent: data["isSent"],
  );
});

var handlerLike = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  HomeFeedModel model;
  if (data["model"] != null) {
    model = HomeFeedModel.fromJson(data["model"]);
  }
  return Like(model: model);
});

var handlerMineDetails = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  UserModel userModel;
  if (data["userModel"] != null) {
    userModel = UserModel.fromJson(data["userModel"]);
  }
  return ProfileDetailPage(
      userId: data["userId"],
      userName: data["userName"] != null ? data["userName"] : null,
      imageUrl: data["imageUrl"] != null ? data["imageUrl"] : null,
      userModel: userModel);
});
var handlerProfileFollowList = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return QueryFollowList(
    userId: data["userId"],
    type: data["type"],
  );
});
var handlerProfileDetailMore = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ProfileDetailsMore(
    userId: data["userId"],
  );
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
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  VersionModel versionModel;
  if (data["versionModel"] != null) {
    versionModel = VersionModel.fromJson(data["versionModel"]);
  }
  return AboutPage(
    haveNewVersion: data["haveNewVersion"],
    versionModel: versionModel,
  );
});

var handlerSettingAccountSecurity = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return AccountSecurityPage();
});
var handlerVipNotOpen = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VipNotOpenPage(type: data["vipState"]);
});
var handlerVipOpen = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VipOpenPage(
    vipState: data["vipState"],
  );
});
var handlerVipNamePlatePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VipNamePlatePage(
    index: data["index"],
  );
});
var handlerHeightAndWeigetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HeightAndWeightPage();
});
var handlerFitnessLevelPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return FitnessLevelPage();
});
var handlerFitnessTargetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return FitnessTargetPage();
});
var handlerFitnesspartPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return FitnessPartPage();
});
var handlerBodyTypePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return BodyTypePage();
});
var handlerInteractiveNoticePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return InteractiveNoticePage(
    type: data["type"],
  );
});
var handlerTrainSeveralTimes = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return TrainSeveralTimes();
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
  ActivityModel activityModel;
  if (data["activityModel"] != null) {
    activityModel = ActivityModel.fromJson(data["activityModel"]);
  }
  return ReleasePage(
    topicId: data["topicId"],
    activityModel: activityModel,
    videoCourseId: data["videoCourseId"],
  );
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
      Map<String, String>.from(data["videoPathMap"]), CourseModel.fromJson(data["videoCourseModel"]));
});

//???????????????
var handlerVideoCourseResult = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VideoCourseResultPage(
      TrainingCompleteResultModel.fromJson(data["result"]), CourseModel.fromJson(data["course"]));
});

//????????????????????????
var handlerLiveDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  CourseModel liveModel;
  if (data["liveModel"] != null) {
    liveModel = CourseModel.fromJson(data["liveModel"]);
  }
  return LiveDetailPage(
    heroTag: data["heroTag"] == null ? "" : data["heroTag"],
    liveCourseId: data["liveCourseId"],
    isHaveStartTime: data["isHaveStartTime"],
    liveModel: liveModel,
    commentDtoModel: data["commentDtoModel"] == null ? null : CommentDtoModel.fromJson(data["commentDtoModel"]),
    fatherComment: data["fatherComment"] == null
        ? null
        : CommentDtoModel.fromJson(
            data["fatherComment"],
          ),
    isInteractive: data["isInteractive"],
  );
});

//????????????????????????
var handlerVideoDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  CourseModel videoModel;
  if (data["videoModel"] != null) {
    videoModel = CourseModel.fromJson(data["videoModel"]);
  }
  return VideoDetailPage(
    heroTag: data["heroTag"] == null ? "" : data["heroTag"],
    videoCourseId: data["videoCourseId"],
    videoModel: videoModel,
    commentDtoModel: data["commentDtoModel"] == null ? null : CommentDtoModel.fromJson(data["commentDtoModel"]),
    fatherComment: data["fatherComment"] == null
        ? null
        : CommentDtoModel.fromJson(
            data["fatherComment"],
          ),
    isInteractive: data["isInteractive"],
  );
});

//????????????????????????????????????????????????
var handlerOtherCompleteCourse = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  // return TwoColumnFeedPage(
  //   targetId:  data["liveCourseId"],
  // );
  return FeedFlowPage(
    pageName: data["pageName"],
    pullFeedType: data["pullFeedType"],
    pullFeedTargetId: data["pullFeedTargetId"],
    initScrollHeight: data["initScrollHeight"] ?? 0.0,
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

//??????????????????
var handlerPerfectUserPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PerfectUserPage();
});

var handlerLoginSucessPagePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginSucessPage();
});

var handlerNetworkLinkFailure = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return NetworkLinkFailure();
});

//????????????
var handlerChatPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ConversationDto conversation = ConversationDto.fromMap(data["conversation"]);

  // map["systemPage"] = systemPage;
  // map["systemLastTime"] = systemLastTime;
  //map["textContent"] = textContent;
  Message shareMessage = RuntimeProperties.shareMessage;
  RuntimeProperties.shareMessage = null;
  return ChatPage(
      systemPage: data["systemPage"],
      systemLastTime: data["systemLastTime"],
      textContent: data["textContent"],
      conversation: conversation,
      shareMessage: shareMessage,
      chatDataList: MessageManager.chatDataList,
      context: context);
});

//??????????????????
var handlerGroupMorePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ConversationDto dto = ConversationDto.fromMap(data["dto"]);
  return GroupMorePage(chatGroupId: data["chatUserId"], chatType: data["chatType"], groupName: data["name"], dto: dto);
});

//??????????????????
var handlerPrivateMorePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ConversationDto dto = ConversationDto.fromMap(data["dto"]);
  return PrivateMorePage(chatUserId: data["chatUserId"], chatType: data["chatType"], name: data["name"], dto: dto);
});

//?????????????????????
var handlerGroupQrCodePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return GroupQrCodePage(imageUrl: data["imageUrl"], name: data["name"], groupId: data["groupId"]);
});

//??????????????????
var handlerMachineRemoteController = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return RemoteControllerPage(
    courseId: data["courseId"],
    modeType: data["modeType"],
    liveRoomId: data["liveRoomId"],
  );
});

//?????????????????????
var handlerMachineConnectionInfo = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ConnectionInfoPage();
});

//???????????????
var handlerMachineSetting = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MachineSettingPage();
});

//??????????????????
var handlerScanCode = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ScanCodePage(
    showMyCode: data["showMyCode"],
  );
});

//????????????????????????
var handlerScanCodeResult = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ScanCodeResultPage(ScanCodeResultModel.fromJson(data["resultModel"]));
});
var handlerMyQrcodePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  /*Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);*/
  return MyQrCodePage();
});
//???????????????
var handlerTrainingGallery = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TrainingGalleryPage();
});

//?????????????????????
var handlerTrainingGalleryDetail = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  List<TrainingGalleryDayModel> dataList = [];
  data["dataList"].forEach((e) {
    dataList.add(TrainingGalleryDayModel.fromJson(e));
  });
  int dayIndex = data["dayIndex"];
  int imageIndex = data["imageIndex"];
  return TrainingGalleryDetailPage(dataList, dayIndex: dayIndex, imageIndex: imageIndex);
});

//????????????????????????
var handlerTrainingGalleryComparison = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  TrainingGalleryImageModel image1 = TrainingGalleryImageModel.fromJson(data["image1"]);
  TrainingGalleryImageModel image2 = TrainingGalleryImageModel.fromJson(data["image2"]);
  return TrainingGalleryComparisonPage(image1, image2);
});

//??????????????????
var handlerMeCoursePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MeCoursePage();
});
var handlerQueryFollowList = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return QueryFollowList(
    type: data["type"],
    userId: data["userId"],
  );
});

//??????????????????--??????????????????
var handlerMeDownloadVideoCoursePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MeDownloadVideoCoursePage();
});
// ???????????????
var handlerTopicDetailPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  // TopicDtoModel topicModel;
  // if (data["topicModel"] != null) {
  //   topicModel = TopicDtoModel.fromJson(data["topicModel"]);
  // }
  return TopicDetail(
    topicId: data["topicId"],
    isTopicList: data["isTopicList"],
  );
});
// ????????????
var handlerSearchPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SearchPage();
});
// ????????????
var handlerFriendsPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return FriendsPage(
    type: data["type"] ?? 0,
    groupChatId: data["groupChatId"],
    shareMap: data["shareMap"],
    chatTypeModel: data["chatTypeModel"],
  );
});
// ???????????????
var handlerCreateMapScreenPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return createMapScreen(
    longitude: data['longitude'],
    latitude: data['latitude'],
    keyWords: data['keyWords'],
  );
});
// ?????????????????????
var handlerFeedDetailPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  CommentDtoModel fatherModel;
  CommentDtoModel comment;
  HomeFeedModel model;
  if (data["fatherModel"] != null) {
    fatherModel = CommentDtoModel.fromJson(data["fatherModel"]);
  }
  if (data["comment"] != null) {
    comment = CommentDtoModel.fromJson(data["comment"]);
  }
  if (data["model"] != null) {
    model = HomeFeedModel.fromJson(data["model"]);
  }

  return FeedDetailPage(
    fatherModel: fatherModel,
    comment: comment,
    model: model,
    index: data['index'],
    type: data['type'],
    errorCode: data["errorCode"],
    isInterative: data["isInteractive"],
  );
});
// ??????????????????
var handlerSearchOrLocationPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  PeripheralInformationPoi selectAddress;
  Location currentAddressInfo;
  if (data['selectAddress'] != null) {
    selectAddress = PeripheralInformationPoi.fromJson(data['selectAddress']);
  }
  if (data['currentAddressInfo'] != null) {
    currentAddressInfo = Location.fromJson(data['currentAddressInfo']);
  }
  return SearchOrLocationWidget(
    checkIndex: data['checkIndex'],
    // ????????????????????????
    selectAddress: selectAddress,
    currentAddressInfo: currentAddressInfo,
  );
});

// ?????????????????????
var handlerNewUserPromotionPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return NewUserPromotionPage();
});
// ???????????????????????????????????????
var handlerLordQRCodePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ManagerQRCodePage();
});

// ??????webview
var handlerWebViewPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  String url = data["url"];
  if (!StringUtil.isURL(url)) {
    url = "http://www.baidu.com";
  }
  return WebViewPage(data["url"]);
});

// ??????????????????
var handlerCreateActivityPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return CreateActivityPage();
});

// ??????????????????
var handlerActivityDetailPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ActivityModel activityModel;
  if (data['activityModel'] != null) {
    activityModel = ActivityModel.fromJson(data['activityModel']);
  }
  return ActivityDetailPage(activityId: data["activityId"], inviterId: data["inviterId"], activityModel: activityModel);
});

//??????????????????
var handlerActivityFeedPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ActivityModel activityModel;
  if (data['activityModel'] != null) {
    activityModel = ActivityModel.fromJson(data['activityModel']);
  }
  return ActivityFlow(
    activityModel: activityModel,
  );
});

//??????????????????
var handlerActivityUserPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  List<UserModel> list = [];
  if (data['modeList'] != null) {
    list = (data["modeList"] as List).map((e) => UserModel.fromJson(e)).toList();
  }
  return ActivityUserPage(
    activityId: data["activityId"],
    type: data["type"],
    userList: list,
  );
});

//????????????????????????
var handlerMyJoinActivityPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ParticipatedInActivitiesPage();
});

// ????????????
var handlerActivityChangeAddressPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ActivityModel activityModel;
  if (data['activityModel'] != null) {
    activityModel = ActivityModel.fromJson(data['activityModel']);
  }
  return ActivityChangeAddressPage(activityModel: activityModel);
});
