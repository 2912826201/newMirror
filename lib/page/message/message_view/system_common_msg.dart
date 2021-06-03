
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/chat_page_ui.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'file:///E:/git/mirror/lib/page/message/item/currency_msg.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/icon.dart';

import '../item/message_item_height_util.dart';

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
              margin:const EdgeInsets.only( bottom: 4),
              child: Text(
                name,
                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
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
          color: AppColor.white,
          child: Column(
            children: _getSystemCommonList(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _getSystemCommonList(BuildContext context){
    List<Widget> arrayWidget=[];
    if(StringUtil.isURL(subModel.picUrl)){
      arrayWidget.add(_getImageWidget());
    }

    if(subModel.text!=null&&subModel.text.length>0){
      arrayWidget.add(_getTextWidget());
    }

    if(subModel.linkUrl!=null&&subModel.linkUrl.length>0){
      arrayWidget.add(_getUrlJumpWidget());
    }
    return arrayWidget;
  }

  Widget _getImageWidget(){
    return Hero(
      tag: heroId,
      child: GestureDetector(
        onTap: (){
          if(!StringUtil.isURL(subModel.linkUrl)){
            // voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_IMAGE, content: imageUrl, position: position);
          }
        },
        child: Container(
          color: AppColor.transparent,
          child: CachedNetworkImage(
            width: 200.0,
            height: 100.0,
            imageUrl: subModel.picUrl == null ? "" : FileUtil.getLargeImage(subModel.picUrl),
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 0),
            placeholder: (context, url) => Container(
              color: AppColor.bgWhite,
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColor.bgWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTextWidget(){
    return Container(
      color: AppColor.transparent,
      constraints: StringUtil.isURL(subModel.picUrl)?
        BoxConstraints(maxWidth: textMaxWidth+24.0,minWidth: textMaxWidth+24.0):
        BoxConstraints(maxWidth: textMaxWidth+24.0),
      padding: const EdgeInsets.all(12.0),
      child: Text(
        subModel.text,
        style: AppStyle.textPrimary2Medium12,
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
            border: Border(top: BorderSide(width: 0.5, color: AppColor.textHint.withOpacity(0.25)))
        ),
        padding: const EdgeInsets.only(top: 6,bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subModel.linkText??"查看更多",style: AppStyle.textSecondaryRegular10),
            AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              12,
              color: AppColor.textHint,
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


  _openUrl(){
    print("点击了$position:url:${subModel.linkUrl}");
    if(StringUtil.isURL(subModel.linkUrl)) {
      voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_TEXT, content: subModel.linkUrl, isUrl: true);
    }
  }
}
