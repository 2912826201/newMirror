import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/shared_image_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GroupQrCodePage extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String groupId;

  GroupQrCodePage({@required this.imageUrl, @required this.name, @required this.groupId});

  @override
  State<StatefulWidget> createState() {
    return _GroupQrCodePageState();
  }
}

class _GroupQrCodePageState extends State<GroupQrCodePage> {
  GlobalKey rootWidgetKey = GlobalKey();
  Uint8List pngBytes;
  File imageFile;
  SharedImageModel model = SharedImageModel();
  double width;
  double height;
  String qrImageString;

  //过期时间
  int expirationTime;

  _capturePngToByteData() async {
    RenderRepaintBoundary boundary = rootWidgetKey.currentContext.findRenderObject();
    double dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
    ui.Image image = await boundary.toImage(pixelRatio: dpr);
    ByteData _byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
    Uint8List pngByte = _byteData.buffer.asUint8List();
    imageFile = await FileUtil().writeImageDataToFile(pngByte, timeStr);
    print('rootWidgetKey width===============${rootWidgetKey.currentContext.size.width}');
    print('rootWidgetKey height===============${rootWidgetKey.currentContext.size.height}');
    width = rootWidgetKey.currentContext.size.width * dpr;
    height = rootWidgetKey.currentContext.size.height * dpr;
    print('model height===========================$width');
    print('nodel weith=========================$height');
  }

  @override
  void initState() {
    super.initState();

    loadData();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          _capturePngToByteData();
        } catch (e) {}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleString: "群聊二维码", actions: [
        CustomAppBarButton(Icons.ios_share, AppColor.black, false, () {
          model.width = int.parse("$width".substring(0, "$width".indexOf(".")));
          model.height = int.parse("$height".substring(0, "$height".indexOf(".")));
          model.file = imageFile;
          openShareBottomSheet(
              context: context, chatTypeModel: ChatTypeModel.MESSAGE_TYPE_IMAGE, map: model.toJson(), sharedType: 2);
        }),
      ]),
      body: RepaintBoundary(
        key: rootWidgetKey,
        child: Container(
            height: ScreenUtil.instance.height,
            width: ScreenUtil.instance.screenWidthDp,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                //背景图
                Container(
                  height: ScreenUtil.instance.height,
                  width: ScreenUtil.instance.screenWidthDp,
                  color: AppColor.bgWhite,
                ),
                Positioned(
                  child: UnconstrainedBox(
                    child: _centerQr(),
                  ),
                ),
                // Positioned(
                //     top: ScreenUtil.instance.height * 0.73,
                //     child: Container(
                //       width: 120,
                //       height: 30,
                //       color: AppColor.black,
                //     ))
              ],
            )),
      ),
    );
  }

  //用户头像
  Widget getUserImagePr() {
    String image = widget.imageUrl;
    if (image == null) {
      image = "";
    }
    List<String> avatarList = image.split(",");
    return Container(
      height: 50,
      width: 50,
      child: Stack(
        children: [
          avatarList.length == 1
              ? ClipOval(
                  child: CachedNetworkImage(
                    height: 50,
                    width: 50,
                    imageUrl: avatarList.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      "images/test.png",
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "images/test.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : avatarList.length > 1
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            //这里的边框颜色需要随背景变化
                            border: Border.all(width: 0, color: AppColor.white)),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            height: 32,
                            width: 32,
                            imageUrl: avatarList.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                              "images/test.png",
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "images/test.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ))
                  : Container(),
          avatarList.length > 1
              ? Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        //这里的边框颜色需要随背景变化
                        border: Border.all(width: 3, color: AppColor.white)),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        height: 32,
                        width: 32,
                        imageUrl: avatarList[1],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Container()
        ],
      ),
    );
  }

  Widget _centerQr() {
    return Container(
        width: MediaQuery.of(context).size.width - (37.5 * 2),
        margin: const EdgeInsets.only(left: 37.5, right: 37.5, bottom: 50),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              getUserImagePr(),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Text(
                  widget.name,
                  style: TextStyle(fontSize: 18, color: AppColor.textPrimary1, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 16),
              QrImage(
                data: qrImageString == null ? "用户${widget.groupId}" : qrImageString,
                size: ScreenUtil.instance.height * 0.49 * 0.57,
                padding: EdgeInsets.zero,
                backgroundColor: AppColor.white,
                version: QrVersions.auto,
              ),
              SizedBox(height: 16),
              Text("此二维码${DateUtil.formatSecondToDay(expirationTime)}内有效"),
              SizedBox(height: 24),
            ],
          ),
        ));
  }

  void loadData() async {
    Map<String, dynamic> map = await getShortUrl(type: 2, targetId: int.parse(widget.groupId));
    if (map != null && map["url"] != null) {
      qrImageString = map["url"];
      expirationTime = map["expireTime"];
      if (mounted) {
        setState(() {});
      }
    }
  }
}
