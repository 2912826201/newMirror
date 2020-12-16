import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/login/guid_complete_infor_page.dart';
import 'package:mirror/page/login/login_page.dart';
import 'package:mirror/page/login/perfect_user_page.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/Chat/chat_page.dart';
import 'package:mirror/page/rc_test_page.dart';
import 'package:mirror/route/router.dart';

/// route_handler
/// Created by yangjiayi on 2020/11/14.

// 在router中已将所有参数装进了map中，并以AppRouter.paramData字段入参，所以处理入参时先解析该map
// 例：Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
var handlerIfPage = Handler(handlerFunc: (BuildContext context, Map<String,List<String>> params) {
  GlobalKey  thekey = GlobalKey();
  SingletonForWholePages.singleton().IfPagekey = thekey;
  return IfPage(key: thekey,);
});
var handlerMain = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MainPage();
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
    cropOnlySquare: data["cropOnlySquare"],
  );
});

var handlerLogin = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params){
  return LoginPage();
});

var handlerLike = Handler(handlerFunc: (BuildContext context, Map<String,List<String>> params) {
  return Like();
});
var handlerReleaseFeed = Handler(handlerFunc: (BuildContext context , Map<String,List<String>> params){
  return ReleasePage();
});
//聊天页面
var handlerChatPage = Handler(handlerFunc: (BuildContext context , Map<String,List<String>> params){
   List<dynamic> list = params["data"];
   ConversationDto dto = ConversationDto.fromMap(json.decode(list.first));
   return ChatPage(conversation: dto,);
});
//完善信息界面
var handlerPerfectUserPage = Handler(handlerFunc: (BuildContext context , Map<String,List<String>> params){
return PerfectUserPage();
});
var handlerGuildCompleteInfor =  Handler(handlerFunc: (BuildContext context , Map<String,List<String>> params){
  Map<String, dynamic> data = json.decode(params[AppRouter.paramData].first);
  return GuidCompleteInforPage(avatarUrl: data["avatarUrl"], nickName: data["nickName"]);
});