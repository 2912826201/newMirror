import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/route/route_handler.dart';

/// router
/// Created by yangjiayi on 2020/11/14.

class AppRouter {
  static String paramData = "data";

  static String pathMain = "/";
  static String pathLogin = "/login";
  static String pathTest = "/test";
  static String pathRCTest = "/rctest";
  static String pathMediaPicker = "/mediapicker";
  static String pathLike = "/like";

  static void configureRouter(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<dynamic>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(pathMain, handler: handlerMain);
    router.define(pathRCTest, handler: handlerRCTest);
    router.define(pathMediaPicker, handler: handlerMediaPicker);
    router.define(pathLike, handler: handlerLike);
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

  static void navigateToRCTestPage(BuildContext context, UserModel user) {
    Map<String, dynamic> map = Map();
    map["user"] = user;
    _navigateToPage(context, pathRCTest, map);
  }

  static void navigateToMediaPickerPage(
      BuildContext context, int maxImageAmount, int mediaType, bool needCrop, Function(dynamic result) callback,
      {bool cropOnlySquare}) {
    Map<String, dynamic> map = Map();
    map["maxImageAmount"] = maxImageAmount;
    map["mediaType"] = mediaType;
    map["needCrop"] = needCrop;
    map["cropOnlySquare"] = cropOnlySquare;
    _navigateToPage(context, pathMediaPicker, map, callback: callback);
  }
  static void navigateToLikePage(BuildContext context) {
    Map<String, dynamic> map = Map();
    _navigateToPage(context, pathLike,map);
  }
}
