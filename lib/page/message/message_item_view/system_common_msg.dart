import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import '../util/chat_page_util.dart';
import 'package:mirror/page/message/widget/currency_msg.dart';
import 'package:mirror/page/message/widget/long_click_popup_menu.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/jpush_analyze_code_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/icon.dart';

import '../util/message_item_height_util.dart';

// ignore: must_be_immutable
class SystemCommonMsg extends StatelessWidget {

  final ChatSystemMessageSubModel subModel;
  final bool isMyself;
  final String userUrl;
  final String name;
  final int status;
  final int position;
  final String sendChatUserId;
  final String heroId;
  final bool isCanLongClick;
  final int sendTime;
  final bool isShowChatUserName;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Function(void Function(),String longClickString) setCallRemoveOverlay;

  SystemCommonMsg(
      {this.subModel,
      this.isMyself,
      this.userUrl,
      this.isShowChatUserName = false,
      this.isCanLongClick = true,
      this.sendChatUserId,
      this.sendTime,
      this.name,
      this.status,
      this.position,
      this.heroId,
      this.voidMessageClickCallBack,
      this.setCallRemoveOverlay,
      this.voidItemLongClickCallBack});

  TextStyle textStyle = const TextStyle(fontSize: 15);
  double textMaxWidth;
  double jumpUrlBoxMaxWidth;
  int textMaxLine;

  @override
  Widget build(BuildContext context) {
    initData(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: getBody(context),
          ),
        ],
      ),
    );
  }

  //最外层body 加载状态和消息结构
  List<Widget> getBody(BuildContext context) {
    var body = [
      Row(
        mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status, position: position, voidMessageClickCallBack: voidMessageClickCallBack),
      ),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }


  //里面的结构-头像和消息
  List<Widget> getSmallBody(BuildContext context) {
    var body = [
      GestureDetector(
        child: getUserImageWidget(userUrl,sendChatUserId, 38, 38),
        onTap: () {
          if (isCanLongClick&&!ChatPageUtil.init(context).isSystemMsg(sendChatUserId)) {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_USER,
                map: new UserModel(uid: int.parse(sendChatUserId)).toJson());
          }
        },
      ),
      getNameAndContentUi(context),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }


  //判断有没有名字
  Widget getNameAndContentUi(BuildContext context) {
    return Container(
      margin: isMyself ? const EdgeInsets.only(right: 10) : const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: isMyself ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isShowChatUserName,
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: Text(
                name,
                style: AppStyle.text1Regular12,
              ),
            ),
          ),
          textContentBoxUiLongClick(context),
        ],
      ),
    );
  }


  //获取长按事件
  Widget textContentBoxUiLongClick(BuildContext context) {
    List<String> longClickStringList =
      getLongClickStringList(
          isMySelf: isMyself,
          status: status,
          sendTime: sendTime,
          contentType: ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON,
          content: subModel.text);
    // print("longClickStringList:$longClickStringList");
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
            position: position,
            settingType: longClickStringList[value],
            contentType: ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON,
            content: subModel.text);
      },
      setCallRemoveOverlay:setCallRemoveOverlay,
      position:position,
      isCanLongClick: isCanLongClick,
      contentType: ChatTypeModel.MESSAGE_TYPE_TEXT,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: jumpUrlBoxMaxWidth,
      contentHeight: MessageItemHeightUtil.init().getSystemCommonMsgHeight(
        isShowChatUserName,
        isOnlyContentHeight: true,
        content: subModel.text,
        url: subModel.linkUrl,
        imageUrl: subModel.picUrl,
      ),
      child: _getSystemCommonBox(context),
    );
  }


  Widget _getSystemCommonBox(BuildContext context){
    return GestureDetector(
      onTap: _openUrl,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: Container(
          color: AppColor.layoutBgGrey,
          child: Column(
            children: _getSystemCommonList(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _getSystemCommonList(BuildContext context){
    List<Widget> arrayWidget = [];
    if (StringUtil.isURL(subModel.prePicUrl)) {
      arrayWidget.add(_getImageWidget(subModel.prePicUrl));
    } else if (StringUtil.isURL(subModel.picUrl)) {
      arrayWidget.add(_getImageWidget(subModel.picUrl));
    }

    if (subModel.text != null && subModel.text.length > 0) {
      arrayWidget.add(_getTextWidget());
    }

    if (subModel.picUrl == null && subModel.text == null) {
      arrayWidget.add(_getTextWidget(text: "  " * 8));
    } else {
      if (subModel.linkUrl != null && subModel.linkUrl.length > 0) {
        arrayWidget.add(_getUrlJumpWidget());
      }
    }

    return arrayWidget;
  }

  Widget _getImageWidget(String imageUrl) {
    return Hero(
      tag: heroId,
      child: GestureDetector(
        onTap: () {
          if (subModel.linkUrl == null || subModel.linkUrl.length < 1) {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_IMAGE, content: imageUrl, position: position);
          } else {
            _openUrl();
          }
        },
        child: Container(
          color: AppColor.layoutBgGrey,
          child: CachedNetworkImage(
            width: 200.0,
            height: 100.0,
            imageUrl: imageUrl == null ? "" : FileUtil.getLargeImage(imageUrl),
            // imageUrl: "",
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 0),
            placeholder: (context, url) => Container(
              color: AppColor.imageBgGrey,
              child: Image.asset("assets/png/preload_png.png", width: 78, height: 34),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColor.imageBgGrey,
              child: Image.asset(
                "assets/png/image_error.png",
                width: 80,
                height: 80,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTextWidget({String text}) {
    return Container(
      color: AppColor.transparent,
      constraints: StringUtil.isURL(subModel.picUrl)
          ? BoxConstraints(maxWidth: textMaxWidth + 24.0, minWidth: textMaxWidth + 24.0)
          : BoxConstraints(maxWidth: textMaxWidth + 24.0),
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text ?? subModel.text,
        style: AppStyle.whiteRegular15,
        maxLines: textMaxLine,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }


  Widget _getUrlJumpWidget(){
    return Container(
      color: AppColor.transparent,
      width: jumpUrlBoxMaxWidth,
      padding: const EdgeInsets.only(left: 12,right: 12),
      child: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(width: 0.5, color: AppColor.dividerWhite8))
        ),
        padding: const EdgeInsets.only(top: 6,bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subModel.linkText ?? "查看更多", style: AppStyle.text1Regular10),
            AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              12,
              color: AppColor.textWhite60,
            ),
          ],
        ),
      ),
    );
  }

  initData(BuildContext context){
    if(StringUtil.isURL(subModel.picUrl)){
      textMaxWidth=200.0-24.0;
      jumpUrlBoxMaxWidth=200.0;
      textMaxLine=2;
    }else{
      textMaxWidth=MediaQuery.of(context).size.width - (16 + 7 + 38 + 2) * 2;
      textMaxLine=100;
      jumpUrlBoxMaxWidth=getTextSize(subModel.text, AppStyle.textPrimary2Medium12, textMaxLine, textMaxWidth).width+24.0;
    }
  }


  _openUrl() {
    String url = subModel.linkUrl;
    if (url == null || url.length < 1) {
      return;
    }
    // url="http://ifdev.aimymusic.com/h5/app/#/topic/?topicId=57&sign=e8b23518a87945689f9dc10e69e19f5f89693965";
    // url="http://ifdev.aimymusic.com/h5/app/#/user/?userId=1004346&sign=a95138dea190e17997ef250c13c550ea6e0049cb";
    // url="http://ifdev.aimymusic.com/h5/app/#/video/?courseId=63&sign=98cbd9690c8f49ba11a114d65d3f3a9d4ce1e62d";
    // url="http://ifdev.aimymusic.com/h5/app/#/live/?courseId=370&sign=b3064e3a9228d089d1563f627add8dd922b6e1ec";
    // url="http://ifdev.aimymusic.com/h5/app/#/feed/?feedId=517287538461900800&sign=861a2048ab51da3fd4776094bbd15c2d69aca2a5";
    print("点击了$position:url:$url");
    if (StringUtil.isURL(url)) {
      voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_TEXT, content: url, isUrl: true);
    } else {
      JpushAnalyzeCodeUtil.init().analyzeCode(url);
    }
  }
}
