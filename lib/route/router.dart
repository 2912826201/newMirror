import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/route/route_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  static String pathLiveBroadcast = "/livebroadcast";
  static String pathLiveDetail = "/livedetail";
  static String pathVideoDetail = "/videodetail";
  static String pathVideoCourseList = "/videocourselist";
  static String pathScanCode = "/scancode";
  static String pathMineDetails = "/minedetails";
  static String pathProfileScanCode = "/profile/scancode";
  static String pathProfileDetails = "/profile/details";
  static String pathProfileDetailsMore = "/profile/details/more";
  static String pathProfileAddRemarks = "/profile/addremarks";
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


  static void configureRouter(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<dynamic>> params) {
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
    router.define(pathChatPage, handler: handlerChatPage);
    router.define(pathPreviewPhoto, handler: handlerPreviewPhoto);
    router.define(pathLiveBroadcast, handler: handlerLiveBroadcast);
    router.define(pathLiveDetail, handler: handlerLiveDetail);
    router.define(pathVideoDetail, handler: handlerVideoDetail);
/*    router.define(pathProfileScanCode, handler: handlerScan);*/
    router.define(pathProfileDetails, handler: handlermineDetails);
    router.define(pathVideoCourseList, handler: handlerVideoCourseList);
    router.define(pathProfileDetailsMore, handler: handlerProfileDetailMore);
    router.define(pathProfileAddRemarks, handler: handlerProfileAddRemarks);
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

  static void popToBeforeLogin(BuildContext context){
    if(Application.loginPopRouteName != null) {
      Navigator.of(context).popUntil(ModalRoute.withName(Application.loginPopRouteName));
    }else{
      Navigator.of(context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
    }
  }

  static void navigateToPerfectUserPage(BuildContext context){
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

  static void navigateToMediaPickerPage(
      BuildContext context, int maxImageAmount, int mediaType, bool needCrop, int startPage,
      bool cropOnlySquare, bool isGoToPublish, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map["maxImageAmount"] = maxImageAmount;
    map["mediaType"] = mediaType;
    map["needCrop"] = needCrop;
    map["startPage"] = startPage;
    map["cropOnlySquare"] = cropOnlySquare;
    map["isGoToPublish"] = isGoToPublish;
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

  static void navigateToLiveDetail(BuildContext context, String heroTag,
      int liveCourseId, int courseId, LiveModel liveModel) {
    Map<String, dynamic> map = Map();
    map["heroTag"] = heroTag;
    map["liveCourseId"] = liveCourseId;
    map["courseId"] = courseId;
    map["liveModel"] = liveModel.toJson();
    _navigateToPage(context, pathLiveDetail, map);
  }

  static void navigateToVideoDetail(BuildContext context, String heroTag,
      int liveCourseId, int courseId, LiveModel videoModel) {
    Map<String, dynamic> map = Map();
    map["heroTag"] = heroTag;
    map["liveCourseId"] = liveCourseId;
    map["courseId"] = courseId;
    map["videoModel"] = videoModel.toJson();
    _navigateToPage(context, pathVideoDetail, map);
  }

  static void navigationToScanCodePage(BuildContext context) {
    _navigateToPage(context, pathProfileScanCode, {});
  }
  static void navigationToProfiileDetailMore(BuildContext context) {
    _navigateToPage(context, pathProfileDetailsMore, {});
  }
  static void navigationToProfileAddRemarks(BuildContext context,String username,int userId){
    Map<String,dynamic> map = Map();
    map["username"] = username;
    map["userId"] = userId;
    _navigateToPage(context, pathProfileAddRemarks,map);
  }
  static void navigationToEditInfomation(BuildContext context,Function(dynamic result) callback) {
    _navigateToPage(context, pathEditInformation, {},callback: callback);
  }
  static void navigationToEditInfomationName(BuildContext context,String username,Function(dynamic result) callback) {
    Map<String,dynamic> map = Map();
    map["username"] = username;
    _navigateToPage(context, pathEditInformationName, map,callback: callback);
  }
  static void navigationToEditInfomationIntroduction(BuildContext context,String introduction,Function(dynamic result) callback) {
    Map<String,dynamic> map = Map();
    map["introduction"] = introduction;
    _navigateToPage(context, pathEditInformationIntroduction, map,callback: callback);
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
  static void navigateToLikePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLike, map);
  }

  static void navigateToMineDetail(BuildContext context,int uId,PanelController pcController) {
    Map<String, dynamic> map = Map();
    map["userId"] = uId;
    map["pcController"] = pcController;
    _navigateToPage(context, pathProfileDetails, map);
  }

  static void navigateToReleasePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathRelease, map);
  }

  static void navigateToChatPage(
      {@required BuildContext context,
      @required ConversationDto conversation,
      Message shareMessage}) {
    Map<String, dynamic> map = Map();
    if (conversation != null) {
      map["conversation"] = conversation.toMap();
    }
    Application.shareMessage = shareMessage;
    _navigateToPage(context, pathChatPage, map);
  }

  static void navigateToPreviewPhotoPage(BuildContext context, String filePath,
      Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map["filePath"] = filePath;
    _navigateToPage(context, pathPreviewPhoto, map, callback: callback);
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
}
