import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/util/Image_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'currency_msg.dart';

// ignore: must_be_immutable
class ImgVideoMsg extends StatelessWidget {
  final bool isMyself;
  final bool isTemporary;
  final bool isImgOrVideo;
  final MediaFileModel mediaFileModel;
  final String userUrl;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final String name;
  final int status;
  final int position;
  final ImageMessage imageMessage;
  final bool isCanLongClick;
  final Map<String, dynamic> sizeInfoMap;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  ImgVideoMsg(
      {this.isMyself,
      this.isTemporary,
      this.isImgOrVideo,
      this.isShowChatUserName = false,
      this.isCanLongClick = true,
      this.sendChatUserId,
      this.mediaFileModel,
      this.userUrl,
      this.name,
      this.status,
      this.position,
      this.imageMessage,
      this.sizeInfoMap,
      this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack});

  double width = 200.0;
  double height = 200.0;

  @override
  Widget build(BuildContext context) {
    intData();

    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
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
        mainAxisAlignment:
        isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status),
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
      getUserImage(userUrl, 38, 38),
      SizedBox(
        width: 7,
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

  //判断有没有长按事件
  Widget getNameAndContentUi(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: isMyself ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isShowChatUserName,
            child: Container(
              margin:
                  isMyself ? const EdgeInsets.only(right: 10, bottom: 4) : const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                name,
                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              ),
            ),
          ),
          imgVideoContentBoxLongClick(context),
        ],
      ),
    );
  }

  //长按事件
  Widget imgVideoContentBoxLongClick(BuildContext context) {
    List<String> longClickStringList = getLongClickStringList(
        isMySelf: isMyself,
        contentType: isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE : ChatTypeModel.MESSAGE_TYPE_VIDEO);
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
          position: position,
          settingType: longClickStringList[value],
          contentType: isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE : ChatTypeModel.MESSAGE_TYPE_VIDEO,
        );
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text(longClickStringList[value]), duration: Duration(milliseconds: 500),));
      },
      isCanLongClick: isCanLongClick,
      contentType: isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE : ChatTypeModel.MESSAGE_TYPE_VIDEO,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: width,
      child: GestureDetector(
        child: imgVideoContentBox(context),
        onTap: () {
          onImgVideoContentBoxClick(context);
        },
      ),
    );
  }

  //图片视频的框架
  Widget imgVideoContentBox(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.transparent,
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            getImageOrVideoUi(),
            getVideoState(),
          ],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget getImageOrVideoUi() {
    //判断是不是临时
    if (isTemporary) {
      return !isImgOrVideo ? getVideoShowImage() : getImageShowImage();
    } else {
      if (isImgOrVideo) {
        return getImageUi();
      } else {
        return getVideoUi();
      }
    }
  }

  //获取视频的图片
  Widget getVideoUi() {
    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: FileUtil.getVideoFirstPhoto(sizeInfoMap["showImageUrl"]) == null
          ? ""
          : FileUtil.getVideoFirstPhoto(sizeInfoMap["showImageUrl"]),
      fit: BoxFit.cover,
      placeholder: (context, url) => getVideoShowImage(),
      errorWidget: (context, url, error) => getVideoShowImage(),
    );
  }

  //获取视频的缺省图
  Widget getVideoShowImage() {
    if (mediaFileModel != null) {
      return Image.memory(
        mediaFileModel.thumb,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "images/test/bg.png",
        fit: BoxFit.cover,
      );
    }
  }

  //获取图片的展示
  Widget getImageUi() {
    if (imageMessage != null) {
      Uint8List bytes = Base64Decoder().convert(imageMessage.content);
      return bytes != null
          ? Image.memory(bytes, fit: BoxFit.cover, width: width, height: height)
          : Container(
              child: Text("离线-图片资源有问题"),
            );
    } else {
      return CachedNetworkImage(
        height: height,
        width: width,
        imageUrl: sizeInfoMap["showImageUrl"] == null
            ? ""
            : sizeInfoMap["showImageUrl"],
        fit: BoxFit.cover,
        placeholder: (context, url) => getImageShowImage(),
        errorWidget: (context, url, error) => getImageShowImage(),
      );
    }
  }

  //获取过渡与错误图
  Widget getImageShowImage() {
    if (mediaFileModel != null) {
      return mediaFileModel.croppedImageData == null
          ? Image.file(
              mediaFileModel.file,
              width: width,
              height: height,
              fit: BoxFit.cover,
            )
          : Image.memory(
              mediaFileModel.croppedImageData,
              width: width,
              height: height,
              fit: BoxFit.cover,
            );
    } else {
      return Image.asset(
        "images/test/bg.png",
        fit: BoxFit.cover,
      );
    }
  }

  //获取视频的标识
  Widget getVideoState() {
    return Offstage(
      offstage: isImgOrVideo,
      child: Container(
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 28,
            color: AppColor.white,
          ),
        ),
      ),
    );
  }

  //初始化数据
  intData() {
    if (isTemporary) {
      width = mediaFileModel.sizeInfo.width.toDouble();
      height = mediaFileModel.sizeInfo.height.toDouble();
    } else {
      if (imageMessage != null) {
        Map<String, dynamic> mapModel = json.decode(imageMessage.extra);
        width = int.parse(mapModel["width"].toString()).toDouble();
        height = int.parse(mapModel["height"].toString()).toDouble();
      } else {
        width = int.parse(sizeInfoMap["width"].toString()).toDouble();
        height = int.parse(sizeInfoMap["height"].toString()).toDouble();
      }
    }
    if (width == 0) {
      width = 1024.0;
    }
    if (height == 0) {
      height = 1024.0;
    }
    List<double> widthOrHeight =
        ImageUtil.getImageWidthAndHeight(width, height);
    width = widthOrHeight[0];
    height = widthOrHeight[1];
  }

  void onImgVideoContentBoxClick(BuildContext context) {
    String imageUrl;
    if (isImgOrVideo) {
      imageUrl = sizeInfoMap["showImageUrl"];
      voidMessageClickCallBack(
          contentType: ChatTypeModel.MESSAGE_TYPE_IMAGE, content: imageUrl);
      // ToastShow.show(msg: "点击了图片", context: context);
    } else {
      imageUrl = FileUtil.getVideoFirstPhoto(sizeInfoMap["showImageUrl"]);
      voidMessageClickCallBack(
          contentType: ChatTypeModel.MESSAGE_TYPE_VIDEO, content: imageUrl);
      // ToastShow.show(msg: "点击了视频", context: context);
    }
  }
}
