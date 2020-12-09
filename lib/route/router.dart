import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/route/route_handler.dart';

/// router
/// Created by yangjiayi on 2020/11/14.

class AppRouter {
  static String paramData = "data";

  static String pathIfPage = "/";
  static String pathMain = "/main";
  static String pathLogin = "/login";
  static String pathTest = "/test";
  static String pathRCTest = "/rctest";
  static String pathMediaPicker = "/mediapicker";
  static String pathLike = "/like";
  static String pathRelease = "/release";
  static String pathPreviewPhoto = "/previewPhoto";
  static String pathScanCode = "/ScanCode";
  static String pathMineDetails = "mineDetails";

  static void configureRouter(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<dynamic>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });

    router.define(pathIfPage, handler: handlerIfPage);
    router.define(pathMain, handler: handlerMain);
    router.define(pathRCTest, handler: handlerRCTest);
    router.define(pathMediaPicker, handler: handlerMediaPicker);
    router.define(pathLogin, handler: handlerLogin);
    router.define(pathLike, handler: handlerLike);
    router.define(pathRelease, handler: handlerReleaseFeed);
    router.define(pathPreviewPhoto, handler: handlerPreviewPhoto);
    router.define(pathScanCode, handler:handlerScan );
    router.define(pathMineDetails, handler:handlermineDetails );
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

  static void navigateToRCTestPage(BuildContext context, ProfileDto profile) {
    Map<String, dynamic> map = Map();
    map["profile"] = profile.toMap();
    _navigateToPage(context, pathRCTest, map);
  }

  static void navigateToMediaPickerPage(
      BuildContext context, int maxImageAmount, int mediaType, bool needCrop, int startPage,
      Function(dynamic result) callback, {bool cropOnlySquare}) {
    Map<String, dynamic> map = Map();
    map["maxImageAmount"] = maxImageAmount;
    map["mediaType"] = mediaType;
    map["needCrop"] = needCrop;
    map["cropOnlySquare"] = cropOnlySquare;
    map["startPage"] = startPage;
    _navigateToPage(context, pathMediaPicker, map, callback: callback);
  }

  static void navigateToLoginPage(BuildContext context) {
    _navigateToPage(context, pathLogin, {});
  }
  static void navigationToScanCodePage(BuildContext context){
    _navigateToPage(context, pathScanCode,{});
  }
  static void navigateToLikePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLike, map);
  }
  static void navigateToMineDetail(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathMineDetails, map);
  }

  static void navigateToReleasePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathRelease, map);
  }

  static void navigateToPreviewPhotoPage(BuildContext context, String filePath, Function(dynamic result) callback) {
    Map<String, dynamic> map = Map();
    map["filePath"] = filePath;
    _navigateToPage(context, pathPreviewPhoto, map, callback: callback);
  }
}
