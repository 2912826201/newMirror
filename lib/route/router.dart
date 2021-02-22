import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/page/scan_code/scan_result_page.dart';
import 'package:mirror/route/route_handler.dart';
import 'package:mirror/widget/feed/feed_friends_cell.dart';
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
  static String pathEditInformation = "/profile/editinformation";
  static String pathEditInformationName = "/profile/editinformation/name";
  static String pathEditInformationIntroduction = "/profile/editinformation/introduction";
  static String pathChatPage = "/profile/chatPage";
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
    // 点赞页面
    router.define(pathLike, handler: handlerLike);
    router.define(pathRelease, handler: handlerReleaseFeed);
    router.define(pathPerfectUserPage, handler: handlerPerfectUserPage);
    router.define(pathLoginSucess, handler: handlerLoginSucessPagePage);
    router.define(pathChatPage, handler: handlerChatPage);
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
    // router.define(login, handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(test, handler: demoFunctionHandler);
  }

  // 封装了入参，无论入参是什么格式都转成map
  static void _navigateToPage(BuildContext context, String path, Map<String, dynamic> params,
      {Function(dynamic result) callback, bool replace = false,int transitionDuration=250,bool isBuilder=false}) {
    String data = Uri.encodeComponent(json.encode(params));
    String uri = path + "?$paramData=" + data;
    if (callback == null) {
      if(isBuilder){
        Application.router.navigateTo(context, uri, replace: replace,
          transitionDuration: Duration(milliseconds: transitionDuration),
          transition:TransitionType.custom,
          transitionBuilder:getCurvedAnimationPageRouteBuilder(),
        );
      }else {
        Application.router.navigateTo(context, uri, replace: replace,
          transitionDuration: Duration(milliseconds: transitionDuration),);
      }
    } else {
      if(isBuilder){
        Application.router.navigateTo(context, uri, replace: replace,
          transitionDuration: Duration(milliseconds: transitionDuration),
          transition:TransitionType.custom,
          transitionBuilder: getCurvedAnimationPageRouteBuilder(),
        ).then(callback);
      }else {
        Application.router.navigateTo(context, uri, replace: replace,
          transitionDuration: Duration(milliseconds: transitionDuration),)
            .then(callback);
      }
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

  // maxImageAmount 最大图片数量
  // mediaType 媒体文件类型 目前的类型有typeImage和typeImageAndVideo
  // needCrop 是否需要裁剪 false的情况没有裁剪预览框
  // startPage 起始页 startPageGallery或startPagePhoto
  // cropOnlySquare 是否只切正方形 只有needCrop为true时这个值才生效
  // publishMode 是否在操作完成后跳转到发布页 0关闭页面不跳转到发布页 1关闭页面跳转到发布页 2不关闭页面跳转到发布页
  static void navigateToMediaPickerPage(BuildContext context, int maxImageAmount, int mediaType, bool needCrop,
      int startPage, bool cropOnlySquare, Function(dynamic result) callback,
      {int publishMode = 0, int fixedWidth, int fixedHeight}) {
    Map<String, dynamic> map = Map();
    map["maxImageAmount"] = maxImageAmount;
    map["mediaType"] = mediaType;
    map["needCrop"] = needCrop;
    map["startPage"] = startPage;
    map["cropOnlySquare"] = cropOnlySquare;
    map["publishMode"] = publishMode;
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

  // static void navigateToLiveDetail(BuildContext context, int liveCourseId,
  //     ){String heroTag,
  //     bool isHaveStartTime = true,
  //     LiveVideoModel liveModel,
  //     CommentDtoModel commentDtoModel,
  //     CommentDtoModel fatherComment}

  static void navigateToVideoCourseResult(BuildContext context, TrainingCompleteResultModel trainingResult) {
    Map<String, dynamic> map = Map();
    map["result"] = trainingResult.toJson();
    _navigateToPage(context, pathVideoCourseResult, map);
  }

  static void navigateToLiveDetail(BuildContext context, int liveCourseId,
      {String heroTag,
      bool isHaveStartTime = true,
      LiveVideoModel liveModel,
      CommentDtoModel commentDtoModel,
      CommentDtoModel fatherComment}) {
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
    _navigateToPage(context, pathLiveDetail, map);
  }

  static void navigateToVideoDetail(BuildContext context, int liveCourseId,
      {String heroTag, LiveVideoModel videoModel, CommentDtoModel commentDtoModel, CommentDtoModel fatherComment}) {
    Map<String, dynamic> map = Map();
    map["videoCourseId"] = liveCourseId;
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
    _navigateToPage(context, pathVideoDetail, map);
  }

  static void navigateToScanCodePage(BuildContext context) {
    _navigateToPage(context, pathScanCode, {});
  }

  static void navigateToScanCodeResultPage(BuildContext context, ScanCodeResultModel resultModel) {
    Map<String, dynamic> map = Map();
    map["resultModel"] = resultModel.toJson();
    _navigateToPage(context, pathScanCodeResult, map);
  }

  static void navigateToMyQrCodePage(BuildContext context) {
    _navigateToPage(context, pathMyQrCodePage, {});
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

  static void navigateToSettingAbout(BuildContext context, String url, bool haveNewVersion, String content) {
    Map<String, dynamic> map = Map();
    map["url"] = url;
    map["haveNewVersion"] = haveNewVersion;
    map["content"] = content;
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
  static void navigateToOtherCompleteCoursePage(BuildContext context,
      int pullFeedTargetId,int pullFeedType,double initScrollHeight,
      String pageName,
      {int duration=0}) {
    Map<String, dynamic> map = Map();
    map["pageName"] = pageName;
    map["pullFeedTargetId"] = pullFeedTargetId;
    map["pullFeedType"] = pullFeedType;
    map["initScrollHeight"] = initScrollHeight;
    _navigateToPage(context, pathOtherCompleteCourse, map,transitionDuration: duration,isBuilder: duration>0);
  }

  /// 自定义页面切换动画 - 渐变切换
  static RouteTransitionsBuilder getCurvedAnimationPageRouteBuilder(){
    return (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child
      );
    };
  }

  // 话题详情页
  static void navigateToTopicDetailPage(BuildContext context, int topicId) {
    Map<String, dynamic> map = Map();
    map["topicId"] = topicId;
    _navigateToPage(context, pathTopicDetailPage, map);
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
  static void navigateFeedDetailPage({
    BuildContext context,
    CommentDtoModel fatherModel,
    CommentDtoModel comment,
    HomeFeedModel model,
    int index,
    int type,
    Function(dynamic result) callBack
  }) {
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
    _navigateToPage(context, pathFeedDetailPage, map,callback: callBack);
  }

  // 所在位置页面
  static void navigateSearchOrLocationPage(
      BuildContext context, int checkIndex, PeripheralInformationPoi selectAddress, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map['checkIndex'] = checkIndex;
    map['selectAddress'] = selectAddress.toJson();
    _navigateToPage(context, pathSearchOrLocationPage, map, callback: callback);
  }
}
