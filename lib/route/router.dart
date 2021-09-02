import 'dart:convert';

import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

import 'package:mirror/data/dto/profile_dto.dart';
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

  // 话题详情页Pl
  static String pathTopicDetailPage = "topic/topicdetail";

  // 搜索页面
  static String pathSearchPage = "search/searchpage";

  // 好友页面
  static String pathFriendsPage = "widget/feed/feedsharepopups";

  // 创建地图页
  static String pahtCreateMapScreenPage = "feed/createmapscreen";

  // 动态详情页
  static String pathFeedDetailPage = "feed/feeddetailpage";

  // 所在位置页面
  static String pathSearchOrLocationPage = "feed/searchOrlocationwidget";

  // 活动界面
  static String pathNewUserPromotionPage = "/newUserPromotionPage";

  // 活动界面-添加老师和群聊界面
  static String pathLordQRCodePage = "/newUserPromotionPage/pathLordQRCodePage";

  // 内部webview
  static String pathWebViewPage = "/webViewPage";

  // 创建活动界面
  static String pathCreateActivityPage = "/activity_page/createActivityPage";

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
    // 点赞页面
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
    // 话题详情页
    router.define(pathTopicDetailPage, handler: handlerTopicDetailPage);
    // 搜索页面
    router.define(pathSearchPage, handler: handlerSearchPage);
    // 好友页面
    router.define(pathFriendsPage, handler: handlerFriendsPage);
    // 创建地图页
    router.define(pahtCreateMapScreenPage, handler: handlerCreateMapScreenPage);
    // 跳转动态详情页
    router.define(pathFeedDetailPage, handler: handlerFeedDetailPage);
    // 所在位置页面
    router.define(pathSearchOrLocationPage, handler: handlerSearchOrLocationPage);
    // 新用户活动界面
    router.define(pathNewUserPromotionPage, handler: handlerNewUserPromotionPage);
    // 新用户活动界面-添加老师和进入群聊界面
    router.define(pathLordQRCodePage, handler: handlerLordQRCodePage);
    router.define(pathWebViewPage, handler: handlerWebViewPage);
    // router.define(login, handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(test, handler: demoFunctionHandler);
    router.define(pathCreateActivityPage, handler: handlerCreateActivityPage);
  }

  // 封装了入参，无论入参是什么格式都转成map
  //TODO 需要统一页面切换的过场效果
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
      for (int i = 0; i < Application.pagePopRouterName.length; i++) {
        if (i > Application.pagePopRouterName.indexOf(uri)) {
          Application.pagePopRouterName.remove(Application.pagePopRouterName[i]);
        }
      }
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

  // maxImageAmount 最大图片数量
  // mediaType 媒体文件类型 目前的类型有typeImage和typeImageAndVideo
  // needCrop 是否需要裁剪 false的情况没有裁剪预览框
  // startPage 起始页 startPageGallery或startPagePhoto
  // cropOnlySquare 是否只切正方形 只有needCrop为true时这个值才生效
  // publishMode 是否在操作完成后跳转到发布页 0关闭页面不跳转到发布页 1关闭页面跳转到发布页 2不关闭页面跳转到发布页
  // fixedWidth fixedHeight固定约束的图片视频尺寸
  // startCount 之前已经选择了多少文件，显示计数要加上这个数
  static void navigateToMediaPickerPage(BuildContext context, int maxImageAmount, int mediaType, bool needCrop,
      int startPage, bool cropOnlySquare, Function(dynamic result) callback,
      {int publishMode = 0, int fixedWidth, int fixedHeight, int startCount = 0, int topicId}) async {
    //TODO 先做权限校验 这里先写起始页为相册页的
    if (startPage == startPageGallery) {
      PermissionStatus status;
      //安卓和iOS的权限不一样
      if (CheckPhoneSystemUtil.init().isAndroid()) {
        status = await Permission.storage.status;
      } else {
        status = await Permission.photos.status;
      }

      if (status.isDenied) {
        //undetermined在新版中被移除了 合并进了denied 这种情况下可以通过请求弹窗获取权限
        if (CheckPhoneSystemUtil.init().isAndroid()) {
          await Permission.storage.request();
        } else {
          await Permission.photos.request();
        }
      } else if (status.isGranted || status.isLimited) {
        //已授权直接进(iOS有给部分照片权限的选项，视为已授权)
      } else if (status.isPermanentlyDenied) {
        //安卓的拒绝不再提示 iOS的拒绝授权 直接进 在里面点去授权
      } else {
        //其他情况 尝试请求 无需处理结果 都在里面做后续处理
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
    _navigateToPage(context, pathMediaPicker, map, callback: callback, isFromBottom: true);
  }

  static void navigateToLoginPage(BuildContext context, {Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    //将当前页面路由名字存起来 登录完成后直接返回到该页面
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
        EventBus.getDefault().post(msg: list, registerName: VIDEO_COURSE_RESULT);
      });
    }
  }

  //判断用户是不是在活动界面
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

  static void navigateToProfileDetailMore(BuildContext context,int userId,Function(dynamic result) callBack) {
    Map<String, dynamic> map = Map();
    map["userId"] = userId;
    _navigateToPage(context, pathProfileDetailsMore, map,callback: callBack);
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

  static void navigateToSettingAbout(BuildContext context,VersionModel versionModel, bool haveNewVersion) {
    Map<String, dynamic> map = Map();
    map["haveNewVersion"] = haveNewVersion;
    if(versionModel!=null){
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

  ///跳转个人主页使用处理过未登录情况的方法，
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

  static void navigateToReleasePage(BuildContext context, {int topicId, int videoCourseId}) {
    Map<String, dynamic> map = Map();
    if (topicId != null) {
      map["topicId"] = topicId;
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
  ///courseId：课程id,直播课程id或者视频课程的id
  ///modeTye:类型,[CourseMode]
  static void navigateToMachineRemoteController(BuildContext context,
      {int courseId, int liveRoomId, String modeType = mode_null}) {
    Map<String, dynamic> map = Map();
    map["courseId"] = courseId;
    map["modeType"] = modeType;
    map["liveRoomId"] = liveRoomId;
    _navigateToPage(context, pathMachineRemoteController, map, isFromBottom: true);
  }

  //判断打开遥控器界面没有
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

  //判断有没有登陆成功界面
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

  //时间 毫秒级
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

  /// 自定义页面切换动画 - 渐变切换
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

  // 话题详情页
  static void navigateToTopicDetailPage(BuildContext context, int topicId,
      {bool isTopicList = false, Function(dynamic result) callback}) {
    Map<String, dynamic> map = Map();
    map["topicId"] = topicId;
    map["isTopicList"] = isTopicList;
    _navigateToPage(context, pathTopicDetailPage, map, callback: callback);
  }

  // 搜索页面
  static void navigateSearchPage(BuildContext context) {
    _navigateToPage(context, pathSearchPage, {});
  }

  // 好友页面
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

// 创建地图页
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

  // 动态详情页
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

  // 所在位置页面
  static void navigateSearchOrLocationPage(
      BuildContext context, int checkIndex, PeripheralInformationPoi selectAddress, Location currentAddressInfo, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map['checkIndex'] = checkIndex;
    map['selectAddress'] = selectAddress.toJson();
    if(currentAddressInfo != null) {
      map['currentAddressInfo'] = currentAddressInfo.toJson();
    }
    _navigateToPage(context, pathSearchOrLocationPage, map, callback: callback);
  }

  //去直播间
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

  // 活动界面
  static void navigateNewUserPromotionPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathNewUserPromotionPage, map);
  }

  // 活动界面-添加老师和群聊界面
  static void navigateLordQRCodePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLordQRCodePage, map);
  }

  //内部webview
  static void navigateWebViewPage(BuildContext context, String url) {
    Map<String, dynamic> map = Map();
    map["url"] = url;
    _navigateToPage(context, pathWebViewPage, map);
  }

  //判断用户是不是在活动界面
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

  //判断打开聊天界面没有
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


  //去创建活动界面
  static void navigateCreateActivityPage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathCreateActivityPage, map);
  }
}
