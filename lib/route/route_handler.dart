import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/model/profile/fitness_entry_model.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/page/feed/feed_flow/feed_flow_page.dart';
import 'package:mirror/page/feed/feed_flow/two_column_feed_page.dart';
import 'package:mirror/page/feed/create_map_screen.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/feed/search_or_location.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/login/login_page.dart';
import 'package:mirror/page/login/perfect_user_page.dart';
import 'package:mirror/page/login/phone_login_page.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/media_picker/preview_photo_page.dart';
import 'package:mirror/page/media_picker/preview_video_page.dart';
import 'package:mirror/page/message/chat_page.dart';
import 'package:mirror/page/message/link_failure/network_link_failure_page.dart';
import 'package:mirror/page/message/more_page/group_qrcode_page.dart';
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
import 'package:mirror/page/profile/login_test_page.dart';
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
import 'package:mirror/page/rc_test_page.dart';
import 'package:mirror/page/scan_code/my_qrcode_page.dart';
import 'package:mirror/page/scan_code/scan_code_page.dart';
import 'package:mirror/page/scan_code/scan_result_page.dart';
import 'package:mirror/page/search/search_page.dart';
import 'package:mirror/page/test_page.dart';
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
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/address_Picker.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// route_handler
/// Created by yangjiayi on 2020/11/14.

// 在router中已将所有参数装进了map中，并以AppRouter.paramData字段入参，所以处理入参时先解析该map
// 例：Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
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
    publishMode: data["publishMode"],
    fixedWidth: data["fixedWidth"],
    fixedHeight: data["fixedHeight"],
    startCount: data["startCount"],
  );
});

var handlerLogin = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

var handlerLoginPhone = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PhoneLoginPage();
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
  return ProfileDetailPage(
    userId: data["userId"],
  );
});

var handlerProfileDetailMore = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ProfileDetailsMore();
});

var handlerEditInformation = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return  EditInformation();
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
  return ChangeNotifierProvider(
    create: (_) => SettingNotifile(),
    child: NoticeSettingPage(),
  );
});

var handlerSettingFeedBack = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return FeedBackPage();
});

var handlerSettingAbout = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return AboutPage(
    url: data["url"],
    haveNewVersion: data["haveNewVersion"],
    content: data["content"],
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
  return VipOpenPage();
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
  return FitnessLevelPage(
  );
});
var handlerFitnessTargetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return FitnessTargetPage(
  );
});
var handlerFitnesspartPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return FitnessPartPage(
  );
});
var handlerBodyTypePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return BodyTypePage(
  );
});
var handlerTrainSeveralTimes = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return TrainSeveralTimes(
  );
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

//课程结果页
var handlerVideoCourseResult = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return VideoCourseResultPage(TrainingCompleteResultModel.fromJson(data["result"]));
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
    commentDtoModel: data["commentDtoModel"] == null ? null : CommentDtoModel.fromJson(data["commentDtoModel"]),
    fatherComment: data["fatherComment"] == null ? null : CommentDtoModel.fromJson(data["fatherComment"],),
    isInteractive: data["isInteractive"],
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
    videoCourseId: data["videoCourseId"],
    videoModel: videoModel,
    commentDtoModel: data["commentDtoModel"] == null ? null : CommentDtoModel.fromJson(data["commentDtoModel"]),
    fatherComment: data["fatherComment"] == null ? null : CommentDtoModel.fromJson(data["fatherComment"],
    ),
    isInteractive: data["isInteractive"],
  );
});

//其他人也完成了这个视频课程训练页
var handlerOtherCompleteCourse = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  // return TwoColumnFeedPage(
  //   targetId:  data["liveCourseId"],
  // );
  return FeedFlowPage(
    pageName:data["pageName"],
    pullFeedType:data["pullFeedType"],
    pullFeedTargetId:data["pullFeedTargetId"],
    initScrollHeight:data["initScrollHeight"]??0.0,
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

var handlerNetworkLinkFailure = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return NetworkLinkFailure();
});

//消息界面
var handlerChatPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  ConversationDto conversation = ConversationDto.fromMap(data["conversation"]);
  Message shareMessage = Application.shareMessage;
  Application.shareMessage = null;
  return ChatPage(conversation: conversation, shareMessage: shareMessage);
});

//群聊二维码界面
var handlerGroupQrCodePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return GroupQrCodePage(imageUrl: data["imageUrl"], name: data["name"], groupId: data["groupId"]);
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

//扫描二维码结果页
var handlerScanCodeResult = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return ScanCodeResultPage(ScanCodeResultModel.fromJson(data["resultModel"]));
});
var handlerMyQrcodePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  /*Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);*/
  return MyQrCodePage();
});
//健身相册页
var handlerTrainingGallery = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TrainingGalleryPage();
});

//健身相册详情页
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
var handlerQueryFollowList = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return QueryFollowList(
    type: data["type"],
    userId: data["userId"],
  );
});

//我的课程界面--下载课程界面
var handlerMeDownloadVideoCoursePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MeDownloadVideoCoursePage();
});
// 话题详情页
var handlerTopicDetailPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  TopicDtoModel topicModel;
  if(data["topicModel"] != null ) {
    topicModel = TopicDtoModel.fromJson(data["topicModel"]);
  }
  return ChangeNotifierProvider(create: (_) => TopicDetailNotifier(),child: TopicDetail(model:topicModel ,
  isTopicList: data["isTopicList"],),);
});
// 搜索页面
var handlerSearchPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SearchPage();
});
// 好友页面
var handlerFriendsPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return FriendsPage(
    type: data["type"]??0,
    groupChatId: data["groupChatId"],
    shareMap: data["shareMap"],
    chatTypeModel: data["chatTypeModel"],
  );
});
// 创建地图页
var handlerCreateMapScreenPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return createMapScreen(
    longitude: data['longitude'],
    latitude: data['latitude'],
    keyWords: data['keyWords'],
  );
});
// 跳转动态详情页
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
// 所在位置页面
var handlerSearchOrLocationPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  PeripheralInformationPoi selectAddress;
  if(data['selectAddress'] != null) {
    selectAddress = PeripheralInformationPoi.fromJson(data['selectAddress']);
  }
  return SearchOrLocationWidget(
    checkIndex: data['checkIndex'],
    // 传入之前选择地址
    selectAddress: selectAddress,
  );
});
