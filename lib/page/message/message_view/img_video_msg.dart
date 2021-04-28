import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/image_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'currency_msg.dart';

///图片视频消息
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
  final int sendTime;
  final int position;
  final ImageMessage imageMessage;
  final bool isCanLongClick;
  final Map<String, dynamic> sizeInfoMap;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  ImgVideoMsg(
      {this.isMyself,
      this.sendTime,
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

    return
        // sizeInfoMap == null
        //   ?
        getContentBoxItem(context);
    // : Hero(
    //     tag: sizeInfoMap["messageId"],
    //     child: getContentBoxItem(context),
    //   );
  }

  Widget getContentBoxItem(BuildContext context) {
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
        child: getUserImage(userUrl, 38, 38),
        onTap: () {
          if (isCanLongClick) {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_USER,
                map: new UserModel(uid: int.parse(sendChatUserId)).toJson());
          }
        },
      ),
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
        sendTime: sendTime,
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
      contentHeight: MessageItemHeightUtil.init().getImgVideoMsgHeight(
          isTemporary: isTemporary,
          mediaFileModel: mediaFileModel,
          imageMessage: imageMessage,
          isShowName: isShowChatUserName,
          sizeInfoMap: sizeInfoMap,
          isOnlyContentHeight: true),
      child: GestureDetector(
        child: sizeInfoMap == null
            ? imgVideoContentBox(context)
            : Hero(
                tag: sizeInfoMap["messageId"],
                child: imgVideoContentBox(context),
              ),
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
            getVideoMask(),
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
    if (sizeInfoMap["isTemporary"] != null && sizeInfoMap["isTemporary"]) {
      File videoImageFile = File(sizeInfoMap["videoFilePath"]);
      File videoFile = File(sizeInfoMap["showImageUrl"]);
      if (videoFile.existsSync()) {
        if (videoImageFile.existsSync()) {
          //print("11111-videoImageFile");
          return getImageFile(videoImageFile);
        } else {
          //print("文件缩略图失效");
          return getImagePlaceHolder();
        }
      } else {
        //print("文件失效");
        return getImagePlaceHolder();
      }
    } else {
      return getCachedNetworkImage(FileUtil.getLargeVideoFirstImage(sizeInfoMap["showImageUrl"]));
    }
  }

  //获取视频的缺省图
  Widget getVideoShowImage() {
    if (mediaFileModel != null && mediaFileModel.thumb != null) {
      return getImageMemory(mediaFileModel.thumb);
    } else {
      return getImagePlaceHolder();
    }
  }

  //获取图片的展示
  Widget getImageUi() {
    if (imageMessage != null) {
      Uint8List bytes = Base64Decoder().convert(imageMessage.content);
      return bytes != null ? getImageMemory(bytes) : Container(child: Text("离线-图片资源有问题"));
    } else {
      if (sizeInfoMap["isTemporary"] != null && sizeInfoMap["isTemporary"]) {
        File imageFile = File(sizeInfoMap["showImageUrl"]);
        if (imageFile.existsSync()) {
          return getImageFile(imageFile);
        } else {
          //print("文件失效");
          return getImagePlaceHolder();
        }
      } else {
        return getCachedNetworkImage(FileUtil.getLargeImage(sizeInfoMap["showImageUrl"]));
      }
    }
  }

  Widget getImageMemory(Uint8List thumb) {
    //print("thumb:${thumb.length}");
    return Image.memory(
      thumb ?? "",
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget getImageAsset(String assetPath) {
    //print("assetPath:${assetPath}");
    return Image.asset(
      assetPath ?? "",
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget getImageFile(File file) {
    //print("file:${file.path}");
    return Image.file(
      file,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget getImagePlaceHolder() {
    return Container(
      width: width,
      height: height,
      color: AppColor.bgWhite,
    );
  }

  Widget getCachedNetworkImage(String imageUrl) {
    //print("imageUrl:${imageUrl}");
    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl ?? "",
      fit: BoxFit.cover,
      placeholder: (context, url) => getImageShowImage(),
      errorWidget: (context, url, error) => getImageShowImage(),
    );
  }

  //获取过渡与错误图
  Widget getImageShowImage() {
    if (isImgOrVideo) {
      if (mediaFileModel != null && (mediaFileModel.file != null || mediaFileModel.croppedImageData != null)) {
        return mediaFileModel.croppedImageData == null
            ? getImageFile(mediaFileModel.file)
            : getImageMemory(mediaFileModel.croppedImageData);
      } else {
        return getImagePlaceHolder();
      }
    } else if (sizeInfoMap["videoFilePath"] != null) {
      File videoImageFile = File(sizeInfoMap["videoFilePath"]);
      return getImageFile(videoImageFile);
    } else {
      return getImagePlaceHolder();
    }
  }

  //获取视频的标识
  Widget getVideoState() {
    return Offstage(
      offstage: isImgOrVideo,
      child: Container(
        child: Center(
          child: AppIcon.getAppIcon(AppIcon.play_28, 28),
        ),
      ),
    );
  }

  //获取视频的标识遮罩
  Widget getVideoMask() {
    return Offstage(
      offstage: isImgOrVideo,
      child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.textPrimary1.withOpacity(0),
                AppColor.textPrimary1.withOpacity(0.35),
              ],
            ),
          )),
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
    List<double> widthOrHeight = ImageUtil.getImageWidthAndHeight(width, height);
    width = widthOrHeight[0];
    height = widthOrHeight[1];
  }

  void onImgVideoContentBoxClick(BuildContext context) {
    String imageUrl = sizeInfoMap["showImageUrl"];
    if (isImgOrVideo) {
      print("___________________________${sizeInfoMap["messageId"]}");
      voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_IMAGE, content: imageUrl, position: position);
      // ToastShow.show(msg: "点击了图片", context: context);
    } else {
      print("___________________________${sizeInfoMap["messageId"]}");
      voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_VIDEO, content: imageUrl, position: position);
      // ToastShow.show(msg: "点击了视频", context: context);

    }
  }
}
