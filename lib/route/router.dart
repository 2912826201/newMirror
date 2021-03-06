import 'dart:convert';

import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/scan_code/scan_result_page.dart';
import 'package:mirror/page/training/live_broadcast/live_room_page_common.dart';
import 'package:mirror/page/training/live_broadcast/live_room_video_operation_page.dart';
import 'package:mirror/page/training/live_broadcast/live_room_video_page.dart';
import 'package:mirror/data/model/training/course_mode.dart';
import 'package:mirror/route/route_handler.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/widget/surrounding_information.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// router
/// Created by yangjiayi on 2020/11/14.

class AppRouter {
  static String paramData = "data";

  static String pathIfPage = "/";
  static String pathMain = "/main";
  static String pathLogin = "/login";
  static String pathLoginPhone = "/login/phone";
  static String pathLoginSmsCode = "/login/smscode";
  static String pathTest = "/test";
  static String pathLoginTest = "/logintest";
  static String pathRCTest = "/rctest";
  static String pathMediaPicker = "/mediapicker";
  static String pathLike = "/like";
  static String pathRelease = "/release";
  static String pathPerfectUserPage = "/perfectuser";
  static String pathPreviewPhoto = "/previewphoto";
  static String pathPreviewVideo = "/previewvideo";
  static String pathLiveBroadcast = "/training/livebroadcast";
  static String pathLiveDetail = "/training/livebroadcast/livedetail";
  static String pathVideoCourseList = "/training/videocourselist";
  static String pathVideoDetail = "/training/videocourselist/videodetail";
  static String pathOtherCompleteCourse = "/training/videocourselist/videodetail/pathOtherCompleteCoursePage";
  static String pathVideoCoursePlay = "/training/videocourseplay";
  static String pathVideoCourseResult = "/training/videocourseresult";
  static String pathScanCode = "/scancode";
  static String pathScanCodeResult = "/scancode/result";
  static String pathMyQrCodePage = "/scancode/myqrcodepage";
  static String pathMineDetails = "/minedetails";
  static String pathProfileDetails = "/profile/details";
  static String pathProfileDetailsMore = "/profile/details/more";
  static String pathProfileFollowListPage = "/profile/followlistpage";
  static String pathProfileInteractiveNoticePage = "/message/interactivenoticepage";
  static String pathEditInformation = "/profile/editinformation";
  static String pathEditInformationName = "/profile/editinformation/name";
  static String pathEditInformationIntroduction = "/profile/editinformation/introduction";
  static String pathChatPage = "/profile/chatPage";
  static String pathGroupMorePage = "/profile/chatPage/groupMorePage";
  static String pathPrivateMorePage = "/profile/chatPage/privateMorePage";
  static String pathNetworkLinkFailure = "/profile/networkLinkFailure";
  static String pathGroupQrCodePage = "/profile/chatPage/groupMorePage/groupQrCodePage";
  static String pathSettingHomePage = "/profile/settinghomepage";
  static String pathSettingFeedBack = "/profile/settingfeedback";
  static String pathSettingBlackList = "/profile/settingblacklist";
  static String pathSettingNoticeSetting = "/profile/settingnoticeSetting";
  static String pathMachineRemoteController = "/machine/remotecontroller";
  static String pathMachineConnectionInfo = "/machine/connectioninfo";
  static String pathMachineSetting = "/machine/setting";
  static String pathSettingAbout = "/profile/settingabout";
  static String pathSettingAccountSecurity = "/profile/settingaccountsecurity";
  static String pathLoginSucess = "/profile/loginsucess";
  static String pathTrainingRecord = "/profile/trainingrecord";
  static String pathWeightRecordPage = "/profile/weightrecordpage";
  static String pathTrainingRecordAllPage = "/profile/trainingrecord/trainingrecordallpage";
  static String pathTrainingGallery = "/profile/traininggallery";
  static String pathTrainingGalleryDetail = "/profile/traininggallery/detail";
  static String pathTrainingGalleryComparison = "/profile/traininggallery/comparison";
  static String pathMeCoursePage = "/profile/mecoursepage";
  static String pathQueryFollowList = "/profile/queryfollowlist";
  static String pathMeDownloadVideoCoursePage = "/profile/mecoursepage/medownloadvideocoursepage";
  static String pathVipNotOpenPage = "/profile/vip/notopenpage";
  static String pathVipOpenPage = "/profile/vip/openpage";
  static String pathVipNamePlatePage = "/profile/vip/nameplatepage";
  static String pathHeightAndWeigetPage = "/login/heightandweightpage";
  static String pathFitnessPartPage = "/login/fitnesspartpage";
  static String pathFitnessLevelPage = "/login/fitnesslevelpage";
  static String pathFitnessTargetPage = "/login/fitnesstargetpage";
  static String pathBodyTypePage = "/login/bodytypepage";
  static String pathTrainSeveralPage = "/login/trainseveralpage";

  // ???????????????Pl
  static String pathTopicDetailPage = "topic/topicdetail";

  // ????????????
  static String pathSearchPage = "search/searchpage";

  // ????????????
  static String pathFriendsPage = "widget/feed/feedsharepopups";

  // ???????????????
  static String pahtCreateMapScreenPage = "feed/createmapscreen";

  // ???????????????
  static String pathFeedDetailPage = "feed/feeddetailpage";

  // ??????????????????
  static String pathSearchOrLocationPage = "feed/searchOrlocationwidget";

  // ????????????
  static String pathNewUserPromotionPage = "/newUserPromotionPage";

  // ????????????-???????????????????????????
  static String pathLordQRCodePage = "/newUserPromotionPage/pathLordQRCodePage";

  // ??????webview
  static String pathWebViewPage = "/webViewPage";

  // ??????????????????
  static String pathCreateActivityPage = "/activity_page/createActivityPage";

  //???????????????
  static String pathActivityDetailPage = "/activity_page/createActivityPage/activityDetailPage";

  // ???????????????
  static String pathActivityFeedPage = "/activity_page/activityFeedPage";

  // ????????????
  static String pathActivityUserPage = "/activity_page/createActivityPage/activityDetailPage/activityUserPage";

  // ??????????????????
  static String pathMyJoinActivityPage = "/activity_page/participatedInActivitiesPage";

  // ??????????????????
  static String pathActivityChangeAddressPage = "/activity_page/activityChangeAddressPage";

  static void configureRouter(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<dynamic>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });

    router.define(pathIfPage, handler: handlerIfPage);
    router.define(pathMain, handler: handlerMain);
    router.define(pathTest, handler: handlerTest);
    router.define(pathRCTest, handler: handlerRCTest);
    router.define(pathMediaPicker, handler: handlerMediaPicker);
    router.define(pathLogin, handler: handlerLogin);
    router.define(pathLoginPhone, handler: handlerLoginPhone);
    router.define(pathLoginSmsCode, handler: handlerLoginSmsCode);
    // ????????????
    router.define(pathLike, handler: handlerLike);
    router.define(pathRelease, handler: handlerReleaseFeed);
    router.define(pathPerfectUserPage, handler: handlerPerfectUserPage);
    router.define(pathLoginSucess, handler: handlerLoginSucessPagePage);
    router.define(pathChatPage, handler: handlerChatPage);
    router.define(pathGroupMorePage, handler: handlerGroupMorePage);
    router.define(pathPrivateMorePage, handler: handlerPrivateMorePage);
    router.define(pathNetworkLinkFailure, handler: handlerNetworkLinkFailure);
    router.define(pathGroupQrCodePage, handler: handlerGroupQrCodePage);
    router.define(pathPreviewPhoto, handler: handlerPreviewPhoto);
    router.define(pathPreviewVideo, handler: handlerPreviewVideo);
    router.define(pathLiveBroadcast, handler: handlerLiveBroadcast);
    router.define(pathLiveDetail, handler: handlerLiveDetail);
    router.define(pathVideoDetail, handler: handlerVideoDetail);
    router.define(pathScanCode, handler: handlerScanCode);
    router.define(pathScanCodeResult, handler: handlerScanCodeResult);
    router.define(pathMyQrCodePage, handler: handlerMyQrcodePage);
    router.define(pathProfileDetails, handler: handlerMineDetails);
    router.define(pathVideoCourseList, handler: handlerVideoCourseList);
    router.define(pathVideoCoursePlay, handler: handlerVideoCoursePlay);
    router.define(pathVideoCourseResult, handler: handlerVideoCourseResult);
    router.define(pathProfileDetailsMore, handler: handlerProfileDetailMore);
    router.define(pathProfileFollowListPage, handler: handlerProfileFollowList);
    router.define(pathEditInformation, handler: handlerEditInformation);
    router.define(pathEditInformationName, handler: handlerEditInformationName);
    router.define(pathEditInformationIntroduction, handler: handlerEditInformationIntroduction);
    router.define(pathSettingHomePage, handler: handlerSettingHomePage);
    router.define(pathSettingFeedBack, handler: handlerSettingFeedBack);
    router.define(pathSettingNoticeSetting, handler: handlerSettingNoticeSetting);
    router.define(pathSettingBlackList, handler: handlerSettingBlackList);
    router.define(pathMachineRemoteController, handler: handlerMachineRemoteController);
    router.define(pathMachineConnectionInfo, handler: handlerMachineConnectionInfo);
    router.define(pathMachineSetting, handler: handlerMachineSetting);
    router.define(pathSettingFeedBack, handler: handlerSettingFeedBack);
    router.define(pathSettingNoticeSetting, handler: handlerSettingNoticeSetting);
    router.define(pathSettingBlackList, handler: handlerSettingBlackList);
    router.define(pathSettingAbout, handler: handlerSettingAbout);
    router.define(pathSettingAccountSecurity, handler: handlerSettingAccountSecurity);
    router.define(pathTrainingRecord, handler: handlerTrainingRecord);
    router.define(pathWeightRecordPage, handler: handlerWeightRecordPage);
    router.define(pathTrainingRecordAllPage, handler: handlerTrainingRecordAllPage);
    router.define(pathTrainingGallery, handler: handlerTrainingGallery);
    router.define(pathTrainingGalleryDetail, handler: handlerTrainingGalleryDetail);
    router.define(pathTrainingGalleryComparison, handler: handlerTrainingGalleryComparison);
    router.define(pathMeCoursePage, handler: handlerMeCoursePage);
    router.define(pathQueryFollowList, handler: handlerQueryFollowList);
    router.define(pathMeDownloadVideoCoursePage, handler: handlerMeDownloadVideoCoursePage);
    router.define(pathOtherCompleteCourse, handler: handlerOtherCompleteCourse);
    router.define(pathVipNotOpenPage, handler: handlerVipNotOpen);
    router.define(pathVipOpenPage, handler: handlerVipOpen);
    router.define(pathVipNamePlatePage, handler: handlerVipNamePlatePage);
    router.define(pathFitnessLevelPage, handler: handlerFitnessLevelPage);
    router.define(pathFitnessPartPage, handler: handlerFitnesspartPage);
    router.define(pathFitnessTargetPage, handler: handlerFitnessTargetPage);
    router.define(pathTrainSeveralPage, handler: handlerTrainSeveralTimes);
    router.define(pathBodyTypePage, handler: handlerBodyTypePage);
    router.define(pathProfileInteractiveNoticePage, handler: handlerInteractiveNoticePage);
    router.define(pathHeightAndWeigetPage, handler: handlerHeightAndWeigetPage);
    // ???????????????
    router.define(pathTopicDetailPage, handler: handlerTopicDetailPage);
    // ????????????
    router.define(pathSearchPage, handler: handlerSearchPage);
    // ????????????
    router.define(pathFriendsPage, handler: handlerFriendsPage);
    // ???????????????
    router.define(pahtCreateMapScreenPage, handler: handlerCreateMapScreenPage);
    // ?????????????????????
    router.define(pathFeedDetailPage, handler: handlerFeedDetailPage);
    // ??????????????????
    router.define(pathSearchOrLocationPage, handler: handlerSearchOrLocationPage);
    // ?????????????????????
    router.define(pathNewUserPromotionPage, handler: handlerNewUserPromotionPage);
    // ?????????????????????-?????????????????????????????????
    router.define(pathLordQRCodePage, handler: handlerLordQRCodePage);
    router.define(pathWebViewPage, handler: handlerWebViewPage);
    // router.define(login, handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(test, handler: demoFunctionHandler);
    router.define(pathCreateActivityPage, handler: handlerCreateActivityPage);
    router.define(pathActivityDetailPage, handler: handlerActivityDetailPage);
    router.define(pathActivityFeedPage, handler: handlerActivityFeedPage);
    router.define(pathActivityUserPage, handler: handlerActivityUserPage);
    router.define(pathMyJoinActivityPage, handler: handlerMyJoinActivityPage);
    router.define(pathActivityChangeAddressPage, handler: handlerActivityChangeAddressPage);
  }

  // ??????????????????????????????????????????????????????map
  //TODO ???????????????????????????????????????
  static void _navigateToPage(BuildContext context, String path, Map<String, dynamic> params,
      {Function(dynamic result) callback,
      bool replace = false,
      int duration = 250,
      bool isFromBottom = false,
      RouteTransitionsBuilder transitions}) {
    String data = Uri.encodeComponent(json.encode(params));
    String uri = path + "?$paramData=" + data;
    if (Application.pagePopRouterName == null) {
      Application.pagePopRouterName = [];
    }
    if (Application.pagePopRouterName.length != 0) {
      if (Application.pagePopRouterName.last == uri) {
        return;
      }
    }
    if (Application.pagePopRouterName.contains(uri)) {
      Navigator.of(context).popUntil(ModalRoute.withName(uri));
      return;
    }
    Application.pagePopRouterName.add(uri);

    Application.router
        .navigateTo(context, uri,
            replace: replace,
            transitionDuration: Duration(milliseconds: duration),
            transition: transitions == null
                ? isFromBottom
                    ? TransitionType.inFromBottom
                    : TransitionType.cupertino
                : TransitionType.custom,
            transitionBuilder: transitions)
        .then((value) {
      if (Application.pagePopRouterName.isNotEmpty && Application.pagePopRouterName.contains(uri)) {
        Application.pagePopRouterName.remove(uri);
      }
      if (callback != null) {
        callback(value);
      }
    });
  }

  static void popToBeforeLogin(BuildContext context) {
    if (Application.loginPopRouteName != null) {
      print('========================loginPopRouteName${Application.loginPopRouteName}');
      Navigator.of(context).popUntil(ModalRoute.withName(Application.loginPopRouteName));
    } else {
      print('=========================pathIfPage');
      Navigator.of(context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
    }
  }

  static void navigateToPerfectUserPage(BuildContext context) {
    _navigateToPage(context, pathPerfectUserPage, {});
  }

  static void navigateToRCTestPage(BuildContext context, ProfileDto profile) {
    Map<String, dynamic> map = Map();
    map["profile"] = profile.toMap();
    _navigateToPage(context, pathRCTest, map);
  }

  static void navigateToTestPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathTest, map);
  }

  static void navigateToLoginTestPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLoginTest, map);
  }

  // maxImageAmount ??????????????????
  // mediaType ?????????????????? ??????????????????typeImage???typeImageAndVideo
  // needCrop ?????????????????? false??????????????????????????????
  // startPage ????????? startPageGallery???startPagePhoto
  // cropOnlySquare ????????????????????? ??????needCrop???true?????????????????????
  // publishMode ?????????????????????????????????????????? 0????????????????????????????????? 1?????????????????????????????? 2?????????????????????????????????
  // fixedWidth fixedHeight?????????????????????????????????
  // startCount ??????????????????????????????????????????????????????????????????
  static void navigateToMediaPickerPage(BuildContext context, int maxImageAmount, int mediaType, bool needCrop,
      int startPage, bool cropOnlySquare, Function(dynamic result) callback,
      {int publishMode = 0,
      int fixedWidth,
      int fixedHeight,
      int startCount = 0,
      int topicId,
      ActivityModel activityModel}) async {
    //TODO ?????????????????? ????????????????????????????????????
    if (startPage == startPageGallery) {
      PermissionStatus status;
      //?????????iOS??????????????????
      if (CheckPhoneSystemUtil.init().isAndroid()) {
        status = await Permission.storage.status;
      } else {
        status = await Permission.photos.status;
      }

      if (status.isDenied) {
        //undetermined???????????????????????? ????????????denied ???????????????????????????????????????????????????
        if (CheckPhoneSystemUtil.init().isAndroid()) {
          await Permission.storage.request();
        } else {
          await Permission.photos.request();
        }
      } else if (status.isGranted || status.isLimited) {
        //??????????????????(iOS???????????????????????????????????????????????????)
      } else if (status.isPermanentlyDenied) {
        //??????????????????????????? iOS??????????????? ????????? ?????????????????????
      } else {
        //???????????? ???????????? ?????????????????? ???????????????????????????
        if (CheckPhoneSystemUtil.init().isAndroid()) {
          await Permission.storage.request();
        } else {
          await Permission.photos.request();
        }
      }
    }
    Map<String, dynamic> map = Map();
    map["maxImageAmount"] = maxImageAmount;
    map["mediaType"] = mediaType;
    map["needCrop"] = needCrop;
    map["startPage"] = startPage;
    map["cropOnlySquare"] = cropOnlySquare;
    map["publishMode"] = publishMode;
    map["fixedWidth"] = fixedWidth;
    map["fixedHeight"] = fixedHeight;
    map["startCount"] = startCount;
    map["topicId"] = topicId;
    if (activityModel != null) {
      map["activityModel"] = activityModel.toJson();
    }
    _navigateToPage(context, pathMediaPicker, map, callback: callback, isFromBottom: true);
  }

  static void navigateToLoginPage(BuildContext context, {Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    //???????????????????????????????????? ???????????????????????????????????????
    var route = ModalRoute.of(context);
    if (route != null) {
      Application.loginPopRouteName = route.settings.name;
    }
    _navigateToPage(context, pathLogin, map, callback: callback, isFromBottom: true);
  }

  static void navigateToPhoneLoginPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLoginPhone, map);
  }

  static void navigateToSmsCodePage(BuildContext context, String phoneNumber, bool isSent) {
    Map<String, dynamic> map = Map();
    map["phoneNumber"] = phoneNumber;
    map["isSent"] = isSent;
    _navigateToPage(context, pathLoginSmsCode, map, isFromBottom: true);
  }

  static void navigateToLiveBroadcast(BuildContext context) {
    _navigateToPage(context, pathLiveBroadcast, {});
  }

  static void navigateToVideoCourseList(BuildContext context) {
    _navigateToPage(context, pathVideoCourseList, {});
  }

  static void navigateToVideoCoursePlay(
      BuildContext context, Map<String, String> videoPathMap, CourseModel videoCourseModel) {
    Map<String, dynamic> map = Map();
    map["videoPathMap"] = videoPathMap;
    map["videoCourseModel"] = videoCourseModel.toJson();
    _navigateToPage(context, pathVideoCoursePlay, map);
  }

  // static void navigateToLiveDetail(BuildContext context, int liveCourseId,
  //     ){String heroTag,
  //     bool isHaveStartTime = true,
  //     LiveVideoModel liveModel,
  //     CommentDtoModel commentDtoModel,
  //     CommentDtoModel fatherComment}

  static void navigateToVideoCourseResult(
      BuildContext context, TrainingCompleteResultModel trainingResult, CourseModel course) {
    if (!isHaveVideoCourseResult()) {
      Map<String, dynamic> map = Map();
      map["result"] = trainingResult.toJson();
      map["course"] = course.toJson();
      _navigateToPage(context, pathVideoCourseResult, map, isFromBottom: true);
    } else {
      Future.delayed(Duration(milliseconds: 100), () {
        List list = [];
        list.add(trainingResult);
        list.add(course);
        EventBus.init().post(msg: list, registerName: VIDEO_COURSE_RESULT);
      });
    }
  }

  //????????????????????????????????????
  static bool isHaveVideoCourseResult() {
    try {
      for (String element in Application.pagePopRouterName) {
        if (element.contains(pathNewUserPromotionPage)) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  static void navigateToLiveDetail(BuildContext context, int liveCourseId,
      {String heroTag,
      bool isHaveStartTime = true,
      CourseModel liveModel,
      CommentDtoModel commentDtoModel,
      CommentDtoModel fatherComment,
      bool isInteractiveIn = false}) {
    Map<String, dynamic> map = Map();
    map["liveCourseId"] = liveCourseId;
    map["isHaveStartTime"] = isHaveStartTime;
    if (liveModel != null) {
      map["liveModel"] = liveModel.toJson();
    }
    if (heroTag != null) {
      map["heroTag"] = heroTag;
    }
    if (commentDtoModel != null) {
      map["commentDtoModel"] = commentDtoModel.toJson();
    }
    if (fatherComment != null) {
      map["fatherComment"] = fatherComment.toJson();
    }
    if (isInteractiveIn == null) {
      map["isInteractiveIn"] = false;
    } else {
      map["isInteractiveIn"] = isInteractiveIn;
    }
    _navigateToPage(context, pathLiveDetail, map);
  }

  static void navigateToVideoDetail(BuildContext context, int videoCourseId,
      {String heroTag,
      CourseModel videoModel,
      CommentDtoModel commentDtoModel,
      CommentDtoModel fatherComment,
      bool isInteractive = false,
      Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    map["videoCourseId"] = videoCourseId;
    if (videoModel != null) {
      map["videoModel"] = videoModel.toJson();
    }
    if (heroTag != null) {
      map["heroTag"] = heroTag;
    }
    if (commentDtoModel != null) {
      map["commentDtoModel"] = commentDtoModel.toJson();
    }
    if (fatherComment != null) {
      map["fatherComment"] = fatherComment.toJson();
    }
    map["isInteractive"] = isInteractive;
    _navigateToPage(context, pathVideoDetail, map, callback: callback);
  }

  static void navigateToScanCodePage(BuildContext context, {bool showMyCode = false}) {
    Map<String, dynamic> map = Map();
    map["showMyCode"] = showMyCode;
    _navigateToPage(context, pathScanCode, map);
  }

  static void navigateToScanCodeResultPage(BuildContext context, ScanCodeResultModel resultModel) {
    Map<String, dynamic> map = Map();
    map["resultModel"] = resultModel.toJson();
    _navigateToPage(context, pathScanCodeResult, map);
  }

  static void navigateToMyQrCodePage(BuildContext context, Function(dynamic result) callBack) {
    _navigateToPage(context, pathMyQrCodePage, {}, callback: callBack);
  }

  static void navigateToProfileDetailMore(BuildContext context, int userId, Function(dynamic result) callBack) {
    Map<String, dynamic> map = Map();
    map["userId"] = userId;
    _navigateToPage(context, pathProfileDetailsMore, map, callback: callBack);
  }

  static void navigateToProfileFollowListPage(BuildContext context, int userId, int type) {
    Map<String, dynamic> map = Map();
    map["userId"] = userId;
    map["type"] = type;
    _navigateToPage(context, pathProfileFollowListPage, map);
  }

  static void navigateToEditInfomation(BuildContext context, Function(dynamic result) callback) {
    _navigateToPage(context, pathEditInformation, {}, callback: callback);
  }

  static void navigateToEditInfomationName(BuildContext context, String username, Function(dynamic result) callback,
      {String title}) {
    Map<String, dynamic> map = Map();
    map["username"] = username;
    if (title != null) {
      map["title"] = title;
    }
    _navigateToPage(context, pathEditInformationName, map, callback: callback);
  }

  static void navigateToEditInfomationIntroduction(
      BuildContext context, String introduction, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map["introduction"] = introduction;
    _navigateToPage(context, pathEditInformationIntroduction, map, callback: callback);
  }

  static void navigateToSettingHomePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathSettingHomePage, map);
  }

  static void navigateToSettingFeedBack(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathSettingFeedBack, map);
  }

  static void navigateToSettingNoticeSetting(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathSettingNoticeSetting, map);
  }

  static void navigateToSettingBlackList(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathSettingBlackList, map);
  }

  static void navigateToSettingAbout(BuildContext context, VersionModel versionModel, bool haveNewVersion) {
    Map<String, dynamic> map = Map();
    map["haveNewVersion"] = haveNewVersion;
    if (versionModel != null) {
      map["versionModel"] = versionModel.toJson();
    }
    _navigateToPage(context, pathSettingAbout, map);
  }

  static void navigateToSettingAccountSecurity(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathSettingAccountSecurity, map);
  }

  static void navigateToLoginSucess(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLoginSucess, map);
  }

  static void navigateToLikePage(BuildContext context, HomeFeedModel model) {
    Map<String, dynamic> map = Map();
    if (model != null) {
      map["model"] = model.toJson();
    }
    _navigateToPage(context, pathLike, map);
  }

  ///????????????????????????????????????????????????????????????
  static void navigateToMineDetail(BuildContext context, int uId,
      {String avatarUrl, String userName, UserModel userModel, Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    map["userId"] = uId;
    if (userName != null) {
      map["userName"] = userName;
    }
    if (avatarUrl != null) {
      map["imageUrl"] = avatarUrl;
    }
    if (userModel != null) {
      map["userModel"] = userModel.toJson();
    }
    _navigateToPage(context, pathProfileDetails, map, callback: callback);
  }

  static void navigateToVipPage(BuildContext context, int vipState, {bool openOrNot = true}) {
    Map<String, dynamic> map = Map();
    if (vipState != null) {
      map["vipState"] = vipState;
    }
    _navigateToPage(context, openOrNot ? pathVipOpenPage : pathVipNotOpenPage, map);
  }

  static void navigateToVipNamePlatePage(BuildContext context, int index) {
    Map<String, dynamic> map = Map();
    map["index"] = index;
    _navigateToPage(context, pathVipNamePlatePage, map);
  }

  static void navigateToHeightAndWeigetPage(BuildContext context) {
    _navigateToPage(context, pathHeightAndWeigetPage, {});
  }

  static void navigateToFitnessTargetPage(BuildContext context) {
    _navigateToPage(context, pathFitnessTargetPage, {});
  }

  static void navigateToFitnessPartPage(BuildContext context) {
    _navigateToPage(context, pathFitnessPartPage, {});
  }

  static void navigateToFitnessLevelPage(BuildContext context) {
    _navigateToPage(context, pathFitnessLevelPage, {});
  }

  static void navigateToBodyTypePage(BuildContext context) {
    _navigateToPage(context, pathBodyTypePage, {});
  }

  static void navigateToTrainSeveralPage(BuildContext context) {
    _navigateToPage(context, pathTrainSeveralPage, {});
  }

  static void navigateToInteractivePage(BuildContext context, {int type, Function(dynamic result) callBack}) {
    Map<String, dynamic> map = Map();
    if (type != null) {
      map["type"] = type;
    }
    _navigateToPage(context, pathProfileInteractiveNoticePage, map, callback: callBack);
  }

  static void navigateToReleasePage(BuildContext context,
      {int topicId, ActivityModel activityModel, int videoCourseId}) {
    Map<String, dynamic> map = Map();
    if (topicId != null) {
      map["topicId"] = topicId;
    }
    if (activityModel != null) {
      map["activityModel"] = activityModel.toJson();
    }
    if (videoCourseId != null) {
      map["videoCourseId"] = videoCourseId;
    }
    _navigateToPage(context, pathRelease, map, isFromBottom: true);
  }

  static void navigateToChatPage(
      {@required BuildContext context,
      @required ConversationDto conversation,
      @required List<ChatDataModel> chatDataModelList,
      String systemLastTime,
      int systemPage = 0,
      int unreadCount = 0,
      String textContent,
      Message shareMessage}) {
    Map<String, dynamic> map = Map();
    if (conversation != null) {
      map["conversation"] = conversation.toMap();
    }
    map["systemPage"] = systemPage;
    map["systemLastTime"] = systemLastTime;
    map["textContent"] = textContent;
    RuntimeProperties.shareMessage = shareMessage;
    MessageManager.chatDataList.clear();
    MessageManager.chatDataList.addAll(chatDataModelList);
    _navigateToPage(context, pathChatPage, map);
  }

  static void navigateToGroupMorePage(BuildContext context, String chatUserId, int chatType, String name,
      ConversationDto dto, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    if (dto != null) {
      map["dto"] = dto.toMap();
    }
    map["name"] = name;
    map["chatType"] = chatType;
    map["chatUserId"] = chatUserId;
    _navigateToPage(context, pathGroupMorePage, map, callback: callback);
  }

  static void navigateToPrivateMorePage(BuildContext context, String chatUserId, int chatType, String name,
      ConversationDto dto, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    if (dto != null) {
      map["dto"] = dto.toMap();
    }
    map["name"] = name;
    map["chatType"] = chatType;
    map["chatUserId"] = chatUserId;
    _navigateToPage(context, pathPrivateMorePage, map, callback: callback);
  }

  static void navigateToNetworkLinkFailure({
    @required BuildContext context,
  }) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathNetworkLinkFailure, map);
  }

  static void navigateToGroupQrCodePage(
      {@required BuildContext context, @required String imageUrl, @required String name, @required String groupId}) {
    Map<String, dynamic> map = Map();
    map["imageUrl"] = imageUrl;
    map["name"] = name;
    map["groupId"] = groupId;
    _navigateToPage(context, pathGroupQrCodePage, map);
  }

  static void navigateToPreviewPhotoPage(BuildContext context, String filePath, Function(dynamic result) callback,
      {int fixedWidth, int fixedHeight}) {
    Map<String, dynamic> map = Map();
    map["filePath"] = filePath;
    map["fixedWidth"] = fixedWidth;
    map["fixedHeight"] = fixedHeight;
    _navigateToPage(context, pathPreviewPhoto, map, callback: callback);
  }

  static void navigateToPreviewVideoPage(
      BuildContext context, String filePath, SizeInfo sizeInfo, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map["filePath"] = filePath;
    map["sizeInfo"] = sizeInfo.toJson();
    _navigateToPage(context, pathPreviewVideo, map, callback: callback);
  }

  //
  ///courseId?????????id,????????????id?????????????????????id
  ///modeTye:??????,[CourseMode]
  static void navigateToMachineRemoteController(BuildContext context,
      {int courseId, int liveRoomId, String modeType = mode_null}) {
    Map<String, dynamic> map = Map();
    map["courseId"] = courseId;
    map["modeType"] = modeType;
    map["liveRoomId"] = liveRoomId;
    _navigateToPage(context, pathMachineRemoteController, map, isFromBottom: true);
  }

  //?????????????????????????????????
  static bool isHaveMachineRemoteControllerPage() {
    try {
      for (String element in Application.pagePopRouterName) {
        if (element.contains(pathMachineRemoteController)) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  //?????????????????????????????????
  static bool isHaveLoginSuccess() {
    try {
      for (String element in Application.pagePopRouterName) {
        if (element.contains(pathLoginSucess)) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  static void navigateToMachineConnectionInfo(BuildContext context) {
    _navigateToPage(context, pathMachineConnectionInfo, {});
  }

  static void navigateToMachineSetting(BuildContext context) {
    _navigateToPage(context, pathMachineSetting, {});
  }

  static void navigateToTrainingRecordPage(BuildContext context) {
    _navigateToPage(context, pathTrainingRecord, {});
  }

  static void navigateToTrainingRecordAllPage(BuildContext context) {
    _navigateToPage(context, pathTrainingRecordAllPage, {});
  }

  static void navigateToWeightRecordPage(BuildContext context) {
    _navigateToPage(context, pathWeightRecordPage, {});
  }

  static void navigateToTrainingGalleryPage(BuildContext context) {
    _navigateToPage(context, pathTrainingGallery, {});
  }

  static void navigateToTrainingGalleryDetailPage(
      BuildContext context, List<TrainingGalleryDayModel> dataList, Function(dynamic result) callback,
      {int dayIndex = 0, int imageIndex = 0}) {
    Map<String, dynamic> map = Map();
    map["dataList"] = dataList.map((e) => e.toJson()).toList();
    map["dayIndex"] = dayIndex;
    map["imageIndex"] = imageIndex;
    _navigateToPage(context, pathTrainingGalleryDetail, map, callback: callback);
  }

  static void navigateToTrainingGalleryComparisonPage(
      BuildContext context, TrainingGalleryImageModel image1, TrainingGalleryImageModel image2,
      {Function(dynamic) callBack}) {
    Map<String, dynamic> map = Map();
    map["image1"] = image1.toJson();
    map["image2"] = image2.toJson();
    _navigateToPage(context, pathTrainingGalleryComparison, map, callback: callBack);
  }

  static void navigateToMeCoursePage(BuildContext context) {
    _navigateToPage(context, pathMeCoursePage, {});
  }

  static void navigateToQueryFollowList(BuildContext context, int type, int userId) {
    Map<String, dynamic> map = Map();
    map["type"] = type;
    map["userId"] = userId;
    _navigateToPage(context, pathQueryFollowList, map);
  }

  static void navigateToMeDownloadVideoCoursePage(BuildContext context) {
    _navigateToPage(context, pathMeDownloadVideoCoursePage, {});
  }

  //?????? ?????????
  static void navigateToOtherCompleteCoursePage(
      BuildContext context, int pullFeedTargetId, int pullFeedType, double initScrollHeight, String pageName,
      {int duration = 0}) {
    Map<String, dynamic> map = Map();
    map["pageName"] = pageName;
    map["pullFeedTargetId"] = pullFeedTargetId;
    map["pullFeedType"] = pullFeedType;
    map["initScrollHeight"] = initScrollHeight;
    RouteTransitionsBuilder builder;
    if (duration > 0) {
      builder = getFadeTransitionBuilder();
    }
    _navigateToPage(context, pathOtherCompleteCourse, map, duration: duration, transitions: builder);
  }

  /// ??????????????????????????? - ????????????
  static RouteTransitionsBuilder getFadeTransitionBuilder() {
    return (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child);
    };
  }

  // ???????????????
  static void navigateToTopicDetailPage(BuildContext context, int topicId,
      {bool isTopicList = false, Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    map["topicId"] = topicId;
    map["isTopicList"] = isTopicList;
    _navigateToPage(context, pathTopicDetailPage, map, callback: callback);
  }

  // ????????????
  static void navigateSearchPage(BuildContext context) {
    _navigateToPage(context, pathSearchPage, {});
  }

  // ????????????
  static void navigateFriendsPage({
    BuildContext context,
    int type,
    int groupChatId,
    Map<String, dynamic> shareMap,
    String chatTypeModel,
  }) {
    Map<String, dynamic> map = Map();
    if (type != null) {
      map['type'] = type;
    }
    if (groupChatId != null) {
      map['groupChatId'] = groupChatId;
    }
    if (shareMap != null) {
      map['shareMap'] = shareMap;
    }
    if (chatTypeModel != null) {
      map['chatTypeModel'] = chatTypeModel;
    }
    _navigateToPage(context, pathFriendsPage, map);
  }

// ???????????????
  static void navigateCreateMapScreenPage(
    BuildContext context,
    double longitude,
    double latitude,
    String keyWords,
  ) {
    Map<String, dynamic> map = Map();
    map['longitude'] = longitude;
    map['latitude'] = latitude;
    map['keyWords'] = keyWords;
    _navigateToPage(context, pahtCreateMapScreenPage, map);
  }

  // ???????????????
  static void navigateFeedDetailPage(
      {BuildContext context,
      CommentDtoModel fatherModel,
      CommentDtoModel comment,
      HomeFeedModel model,
      int index,
      int type,
      int errorCode,
      bool isInteractive = false,
      Function(dynamic result) callBack}) {
    Map<String, dynamic> map = Map();
    if (fatherModel != null) {
      map['fatherModel'] = fatherModel.toJson();
    }
    if (comment != null) {
      map['comment'] = comment.toJson();
    }
    if (model != null) {
      map['model'] = model.toJson();
    }
    if (index != null) {
      map['index'] = index;
    }
    map['type'] = type;
    map["isInteractive"] = isInteractive;
    map["errorCode"] = errorCode;
    _navigateToPage(context, pathFeedDetailPage, map, callback: callBack);
  }

  // ??????????????????
  static void navigateSearchOrLocationPage(BuildContext context, int checkIndex, PeripheralInformationPoi selectAddress,
      Location currentAddressInfo, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map['checkIndex'] = checkIndex;
    map['selectAddress'] = selectAddress.toJson();
    if (currentAddressInfo != null) {
      map['currentAddressInfo'] = currentAddressInfo.toJson();
    }
    _navigateToPage(context, pathSearchOrLocationPage, map, callback: callback);
  }

  //????????????
  static void navigateLiveRoomPage(BuildContext context, CourseModel liveModel, {Function(int relation) callback}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LiveRoomVideoPage(liveCourseId: liveModel.id, coachId: liveModel.coachId.toString());
    }));
    Navigator.of(context).push(SimpleRoute(
      name: liveModel.title ?? "",
      title: liveModel.description ?? "",
      builder: (_) {
        return LiveRoomVideoOperationPage(
            liveCourseId: liveModel.id,
            coachName: liveModel.coachDto.nickName,
            coachUrl: liveModel.coachDto.avatarUri,
            coachRelation: liveModel.coachDto.relation,
            startTime: liveModel.startTime,
            callback: callback,
            coachId: liveModel.coachDto.uid);
      },
    ));
  }

  // ????????????
  static void navigateNewUserPromotionPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathNewUserPromotionPage, map);
  }

  // ????????????-???????????????????????????
  static void navigateLordQRCodePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLordQRCodePage, map);
  }

  //??????webview
  static void navigateWebViewPage(BuildContext context, String url) {
    Map<String, dynamic> map = Map();
    map["url"] = url;
    _navigateToPage(context, pathWebViewPage, map);
  }

  //????????????????????????????????????
  static bool isHaveNewUserPromotionPage() {
    try {
      for (String element in Application.pagePopRouterName) {
        if (element.contains(pathNewUserPromotionPage)) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  //??????????????????????????????
  static bool isHaveChatPage() {
    try {
      for (String element in Application.pagePopRouterName) {
        if (element.contains(pathChatPage)) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  //?????????????????????
  static void navigateCreateActivityPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathCreateActivityPage, map);
  }

  //?????????????????????
  static void navigateActivityDetailPage(BuildContext context, int activityId,
      {ActivityModel activityModel, int inviterId}) {
    Map<String, dynamic> map = Map();
    map['activityId'] = activityId;
    map['inviterId'] = inviterId;
    if (activityModel != null) {
      map['activityModel'] = activityModel.toJson();
    }
    if(Application.activityPageIdMap.containsKey(activityId)){
      Navigator.of(context).popUntil(ModalRoute.withName(Application.activityPageIdMap[activityId]));
      return;
    }
    String data = Uri.encodeComponent(json.encode(map));
    String uri = pathActivityDetailPage + "?$paramData=" + data;
    Application.activityPageIdMap[activityId] = uri;
    _navigateToPage(context, pathActivityDetailPage, map,callback: (result){
      Application.activityPageIdMap.remove(activityId);
    });
  }

  // ??????????????????
  static void navigateActivityFeedPage(BuildContext context, ActivityModel activityModel) {
    Map<String, dynamic> map = Map();
    if (activityModel != null) {
      map['activityModel'] = activityModel.toJson();
    }
    _navigateToPage(context, pathActivityFeedPage, map);
  }

  // ????????????
  //0-?????????????????? 1 -??????????????????  2-???????????? 3-???????????????-??????????????? 4-???????????????????????? 5-???????????????-?????????????????????
  //0-??????????????????                  ??????activityId
  //1-??????????????????                  ??????activityId type
  //2-????????????                      ??????activityId type
  //3-???????????????-???????????????           ??????activityId type
  //4-????????????????????????               ??????activityId type
  //5-???????????????-?????????????????????        ??????type
  static void navigateActivityUserPage(BuildContext context,
      {int activityId, List<UserModel> modeList, int type = 0, Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    if (modeList != null) {
      map['modeList'] = modeList.map((e) => e.toJson()).toList();
    }
    if (activityId != null) {
      map['activityId'] = activityId;
    }
    map["type"] = type;
    _navigateToPage(context, pathActivityUserPage, map, callback: callback);
  }

  // ??????????????????
  static void navigateMyJoinActivityPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathMyJoinActivityPage, map);
  }

  // ????????????
  static void navigateActivityChangeAddressPage(
      BuildContext context, ActivityModel activityModel, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    if (activityModel != null) {
      map['activityModel'] = activityModel.toJson();
    }
    _navigateToPage(context, pathActivityChangeAddressPage, map, callback: callback);
  }
}
