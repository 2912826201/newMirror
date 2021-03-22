
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/date_util.dart';

class LiveRoomPageCommon{
  static LiveRoomPageCommon _common;

  List<String> textArray = [];
  List<Color> colorArray = [];

  static LiveRoomPageCommon init(){
    if(_common==null){
      _common=LiveRoomPageCommon();
    }
    return _common;
  }


  //获取直播间评论样式
  Widget getLiveRoomMessageText(UserMessageModel userMessageModel){
    textArray.clear();
    colorArray.clear();
    _initLiveRoomMessageText(userMessageModel);
    if(textArray.length<1){
      return Container();
    }
    return _liveRoomMessageText();
  }


  //获取用户的头像
  Widget getUserImage(String imageUrl, double height, double width) {
    if (imageUrl == null || imageUrl == ""||imageUrl.length<1) {
      imageUrl =
      "http://pic.netbian.com/uploads/allimg/201220/220540-16084731404798.jpg";
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: CachedNetworkImage(
        height: height,
        width: width,
        imageUrl: imageUrl == null ? "" : imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          "images/test/bg.png",
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "images/test/bg.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  //获取直播间展示的时间
  Widget getLiveRoomShowTimeUi(String startTime){
    return Text(DateUtil.getSpecifyDateTimeDifferenceMinutesAndSeconds(startTime)
        ,style: TextStyle(fontSize: 18,color: AppColor.white.withOpacity(0.85)));
  }

  //获取直播间在线人数ui
  Widget getLiveOnlineMenNumberUi(int number){
    return Text("在线人数$number",style: TextStyle(fontSize: 9,color: AppColor.white.withOpacity(0.65)));
  }

  //获取直播间在线人数ui
  Widget getOtherOnlineUserImageUi(List<String> urlImageList){
    print(urlImageList[0]);
    print(urlImageList[1]);
    print(urlImageList[2]);
    return Container(
      width: 21.0*3-12.0,
      height: 21.0,
      child: Stack(
        children: [
          Positioned(
            child: getUserImage(urlImageList[0],21,21),
            right: 0,
          ),
          Positioned(
            child: getUserImage(urlImageList[1],21,21),
            right: 12,
          ),
          Positioned(
            child: getUserImage(urlImageList[2],21,21),
            right: 24,
          ),
        ],
      ),
    );
  }


  //获取消息
  Widget _liveRoomMessageText() {
    return Container(
      child: RichText(
        textAlign: TextAlign.left,
        maxLines: 100,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(fontSize: 13, color: AppColor.white.withOpacity(0.85)),
          children: _getMessageTextSpan(),
        ),
      ),
    );
  }
  //获取所有的textspan
  List<TextSpan> _getMessageTextSpan() {
    List<TextSpan> listTextSpan = <TextSpan>[];
    for (int i = 0; i < textArray.length; i++) {
      listTextSpan.add(_getTextSpan(textArray[i], colorArray[i]));
    }
    return listTextSpan;
  }

  //获取重新编辑的text
  TextSpan _getTextSpan(String text, Color color) {
    return TextSpan(
      text: text,
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          print("点击了弹幕...");
        },
      style: TextStyle(
          color: color,
          fontSize: 13
      ),
    );
  }

  //初始化直播间的评论的列表文字
  _initLiveRoomMessageText(UserMessageModel userMessageModel){
    if(null==userMessageModel.messageContent||userMessageModel.messageContent.length<1){
      return;
    }
    // print("userMessageModel.isJoinLiveRoomMessage:${userMessageModel.isJoinLiveRoomMessage}");
    if(null!=userMessageModel.name&&userMessageModel.name.length>0){
      textArray.add("${userMessageModel.name} : ");
      if(userMessageModel.uId.toString()==Application.profile.uid.toString()){
        colorArray.add(AppColor.colorfcb6bf);
      }else{
        colorArray.add(AppColor.white.withOpacity(0.85));
      }
    }
    if(userMessageModel.isJoinLiveRoomMessage!=null&&userMessageModel.isJoinLiveRoomMessage){
      textArray.add(userMessageModel.messageContent);
    }else{
      textArray.add(userMessageModel.messageContent);
    }
    colorArray.add(AppColor.white.withOpacity(0.85));
  }



}

class UserMessageModel{
  String name;
  String uId;
  String messageContent;
  bool isJoinLiveRoomMessage;
  UserMessageModel({this.name, this.uId, this.messageContent,this.isJoinLiveRoomMessage=false});
}




class SimpleRoute extends PageRoute {
  SimpleRoute({
    @required this.name,
    @required this.title,
    @required this.builder,
  }) : super(
    settings: RouteSettings(name: name),
  );

  final String title;
  final String name;
  final WidgetBuilder builder;

  @override
  String get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Title(
      title: title,
      color: Theme.of(context).primaryColor,
      child: builder(context),
    );
  }

  /// 页面切换动画
  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Color get barrierColor => null;
}
