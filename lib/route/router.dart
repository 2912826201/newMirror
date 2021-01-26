import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/route/route_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// router
/// Created by yangjiayi on 2020/11/14.

class AppRouter {
  static String paramData = "data";

  static String pathIfPage = "/";
  static String pathMain = "/main";
  static String pathLogin = "/login";
  static String pathLoginPhone = "/login/phone";
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
  static String pathLiveDetail = "/training/livedetail";
  static String pathVideoDetail = "/training/videodetail";
  static String pathVideoCourseList = "/training/videocourselist";
  static String pathVideoCoursePlay = "/training/videocourseplay";
  static String pathScanCode = "/scancode";
  static String pathMineDetails = "/minedetails";
  static String pathProfileDetails = "/profile/details";
  static String pathProfileDetailsMore = "/profile/details/more";
  static String pathEditInformation = "/profile/editinformation";
  static String pathEditInformationName = "/profile/editinformation/name";
  static String pathEditInformationIntroduction = "/profile/editinformation/introduction";
  static String pathChatPage = "/chatPage";
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
  static String pathMeDownloadVideoCoursePage = "/profile/mecoursepage/medownloadvideocoursepage";
  static String pathVipNotOpenPage = "/profile/vip/notopenpage";
  static String pathVipOpenPage = "/profile/vip/openpage";
  static String pathVipNamePlatePage = "/profile/vip/nameplatepage";

  static void configureRouter(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<dynamic>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });

    router.define(pathIfPage, handler: handlerIfPage);
    router.define(pathMain, handler: handlerMain);
    router.define(pathTest, handler: handlerTest);
    router.define(pathLoginTest, handler: handlerLoginTest);
    router.define(pathRCTest, handler: handlerRCTest);
    router.define(pathMediaPicker, handler: handlerMediaPicker);
    router.define(pathLogin, handler: handlerLogin);
    router.define(pathLoginPhone, handler: handlerLoginPhone);
    router.define(pathLike, handler: handlerLike);
    router.define(pathRelease, handler: handlerReleaseFeed);
    router.define(pathPerfectUserPage, handler: handlerPerfectUserPage);
    router.define(pathLoginSucess, handler: handlerLoginSucessPagePage);
    router.define(pathChatPage, handler: handlerChatPage);
    router.define(pathPreviewPhoto, handler: handlerPreviewPhoto);
    router.define(pathPreviewVideo, handler: handlerPreviewVideo);
    router.define(pathLiveBroadcast, handler: handlerLiveBroadcast);
    router.define(pathLiveDetail, handler: handlerLiveDetail);
    router.define(pathVideoDetail, handler: handlerVideoDetail);
    router.define(pathScanCode, handler: handlerScanCode);
    router.define(pathProfileDetails, handler: handlermineDetails);
    router.define(pathVideoCourseList, handler: handlerVideoCourseList);
    router.define(pathVideoCoursePlay, handler: handlerVideoCoursePlay);
    router.define(pathProfileDetailsMore, handler: handlerProfileDetailMore);
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
    router.define(pathMeDownloadVideoCoursePage, handler: handlerMeDownloadVideoCoursePage);
    router.define(pathVipNotOpenPage, handler: handlerVipNotOpen);
    router.define(pathVipOpenPage, handler: handlerVipOpen);
    router.define(pathVipNamePlatePage, handler: handlerVipNamePlatePage);

    // router.define(login, handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(test, handler: demoFunctionHandler);
  }

  // 封装了入参，无论入参是什么格式都转成map
  static void _navigateToPage(BuildContext context, String path, Map<String, dynamic> params,
      {Function(dynamic result) callback}) {
    String data = Uri.encodeComponent(json.encode(params));
    String uri = path + "?$paramData=" + data;
    if (callback == null) {
      Application.router.navigateTo(context, uri);
    } else {
      Application.router.navigateTo(context, uri).then(callback);
    }
  }

  static void popToBeforeLogin(BuildContext context) {
    if (Application.loginPopRouteName != null) {
      Navigator.of(context).popUntil(ModalRoute.withName(Application.loginPopRouteName));
    } else {
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

  static void navigateToMediaPickerPage(BuildContext context, int maxImageAmount, int mediaType, bool needCrop,
      int startPage, bool cropOnlySquare, bool isGoToPublish, Function(dynamic result) callback,
      {int fixedWidth, int fixedHeight}) {
    Map<String, dynamic> map = Map();
    map["maxImageAmount"] = maxImageAmount;
    map["mediaType"] = mediaType;
    map["needCrop"] = needCrop;
    map["startPage"] = startPage;
    map["cropOnlySquare"] = cropOnlySquare;
    map["isGoToPublish"] = isGoToPublish;
    map["fixedWidth"] = fixedWidth;
    map["fixedHeight"] = fixedHeight;
    _navigateToPage(context, pathMediaPicker, map, callback: callback);
  }

  static void navigateToLoginPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    //将当前页面路由名字存起来 登录完成后直接返回到该页面
    var route = ModalRoute.of(context);
    if (route != null) {
      Application.loginPopRouteName = route.settings.name;
    }
    _navigateToPage(context, pathLogin, map);
  }

  static void navigateToPhoneLoginPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLoginPhone, map);
  }

  static void navigateToLiveBroadcast(BuildContext context) {
    _navigateToPage(context, pathLiveBroadcast, {});
  }

  static void navigateToVideoCourseList(BuildContext context) {
    _navigateToPage(context, pathVideoCourseList, {});
  }

  static void navigateToVideoCoursePlay(
      BuildContext context, Map<String, String> videoPathMap, LiveVideoModel videoCourseModel) {
    Map<String, dynamic> map = Map();
    map["videoPathMap"] = videoPathMap;
    map["videoCourseModel"] = videoCourseModel.toJson();
    _navigateToPage(context, pathVideoCoursePlay, map);
  }

  static void navigateToLiveDetail(BuildContext context, int liveCourseId, {String heroTag, LiveVideoModel liveModel}) {
    Map<String, dynamic> map = Map();
    map["liveCourseId"] = liveCourseId;
    if (liveModel != null) {
      map["liveModel"] = liveModel.toJson();
    }
    if (heroTag != null) {
      map["heroTag"] = heroTag;
    }
    _navigateToPage(context, pathLiveDetail, map);
  }

  static void navigateToVideoDetail(BuildContext context, int liveCourseId,
      {String heroTag, LiveVideoModel videoModel}) {
    Map<String, dynamic> map = Map();
    map["videoCourseId"] = liveCourseId;
    if (videoModel != null) {
      map["videoModel"] = videoModel.toJson();
    }
    if (heroTag != null) {
      map["heroTag"] = heroTag;
    }
    _navigateToPage(context, pathVideoDetail, map);
  }

  static void navigateToScanCodePage(BuildContext context) {
    _navigateToPage(context, pathScanCode, {});
  }

  static void navigateToProfileDetailMore(BuildContext context) {
    _navigateToPage(context, pathProfileDetailsMore, {});
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

  static void navigateToSettingAbout(BuildContext context) {
    Map<String, dynamic> map = Map();
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

  static void navigateToLikePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLike, map);
  }

  static void navigateToMineDetail(BuildContext context, int uId) {
    Map<String, dynamic> map = Map();
    map["userId"] = uId;
    _navigateToPage(context, pathProfileDetails, map);
  }

  static void navigateToVipOpenPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathVipOpenPage, map);
  }

  static void navigateToVipNamePlatePage(BuildContext context, int index) {
    Map<String, dynamic> map = Map();
    map["index"] = index;
    _navigateToPage(context, pathVipNamePlatePage, map);
  }

  static void navigateToReleasePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathRelease, map);
  }

  static void navigateToChatPage(
      {@required BuildContext context, @required ConversationDto conversation, Message shareMessage}) {
    Map<String, dynamic> map = Map();
    if (conversation != null) {
      map["conversation"] = conversation.toMap();
    }
    Application.shareMessage = shareMessage;
    _navigateToPage(context, pathChatPage, map);
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

  static void navigateToMachineRemoteController(BuildContext context) {
    _navigateToPage(context, pathMachineRemoteController, {});
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
      BuildContext context, TrainingGalleryImageModel image1, TrainingGalleryImageModel image2) {
    Map<String, dynamic> map = Map();
    map["image1"] = image1.toJson();
    map["image2"] = image2.toJson();
    _navigateToPage(context, pathTrainingGalleryComparison, map);
  }

  static void navigateToMeCoursePage(BuildContext context) {
    _navigateToPage(context, pathMeCoursePage, {});
  }

  static void navigateToMeDownloadVideoCoursePage(BuildContext context) {
    _navigateToPage(context, pathMeDownloadVideoCoursePage, {});
  }
}
