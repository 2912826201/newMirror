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
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyQrCodePageState();
  }
}

class _MyQrCodePageState extends State<MyQrCodePage> {
  GlobalKey rootWidgetKey = GlobalKey();
  Uint8List pngBytes;
  File imageFile;
  SharedImageModel model = SharedImageModel();
  double width;
  double height;
  String codeData;

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
    _getShortUrl();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          _capturePngToByteData();
        } catch (e) {}
      });
    });
  }

  _getShortUrl() async {
    Map<String, dynamic> map = await getShortUrl(type: 3, targetId: context.read<ProfileNotifier>().profile.uid);
    if (map != null) {
      codeData = map["url"];
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "我的二维码",
        actions: [
          CustomAppBarIconButton(
              svgName: AppIcon.nav_share,
              iconColor: AppColor.black,
              onTap: () {
                model.width = int.parse("$width".substring(0, "$width".indexOf(".")));
                model.height = int.parse("$height".substring(0, "$height".indexOf(".")));
                model.file = imageFile;
                openShareBottomSheet(
                    context: context,
                    chatTypeModel: ChatTypeModel.MESSAGE_TYPE_IMAGE,
                    map: model.toJson(),
                    sharedType: 2);
              }),
        ],
      ),
      body: Selector<ProfileNotifier, ProfileDto>(builder: (context, profileDto, child) {
        return RepaintBoundary(
          key: rootWidgetKey,
          child: Container(
              height: ScreenUtil.instance.height,
              width: ScreenUtil.instance.screenWidthDp,
              child: Stack(
                children: [
                  //背景图
                  Container(
                      height: ScreenUtil.instance.height,
                      width: ScreenUtil.instance.screenWidthDp,
                      child: Image.network(
                        "http://devpic.aimymusic.com/ifapp/1008977/1615279317627.jpg",
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                      left: (ScreenUtil.instance.screenWidthDp - ScreenUtil.instance.screenWidthDp * 0.8) / 2,
                      top: ScreenUtil.instance.height * 0.17,
                      child: _centerQr(profileDto)),
                  Positioned(
                      left: (ScreenUtil.instance.screenWidthDp - 64) / 2,
                      top: ScreenUtil.instance.height * 0.17 - 32,
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            border: Border.all(width: 3, color: AppColor.white)),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            height: 64,
                            width: 64,
                            imageUrl: profileDto.avatarUri,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                  Positioned(
                      top: ScreenUtil.instance.height * 0.73,
                      left: (ScreenUtil.instance.screenWidthDp - 120) / 2,
                      child: Container(
                        width: 120,
                        height: 30,
                        color: AppColor.black,
                      ))
                ],
              )),
        );
      }, selector: (context, notifier) {
        return notifier.profile;
      }),
    );
  }

  Widget _centerQr(ProfileDto data) {
    return Container(
        width: ScreenUtil.instance.screenWidthDp * 0.8,
        height: ScreenUtil.instance.height * 0.49,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 64 / 2,
            ),
            Text(
              data.nickName,
              style: AppStyle.textMedium18,
            ),
            Spacer(),
            Text(
              "已加入iF APP${_getUserCreateTime(data)}",
              style: AppStyle.textPrimary3Regular14,
            ),
            Spacer(),
            QrImage(
              data: codeData != null ? codeData : "没有数据",
              size: ScreenUtil.instance.height * 0.49 * 0.57,
              padding: EdgeInsets.zero,
              backgroundColor: AppColor.white,
              version: QrVersions.auto,
            ),
            Spacer(),
            Text("扫一扫二维码,加我好友吧。"),
            Spacer(),
          ],
        ));
  }

  String _getUserCreateTime(ProfileDto dto) {
    int createTime = dto.createTime;
    int nowTime = DateUtil.getNowDateMs();

    String day = "${((nowTime - createTime) / 86400000)}";
    return day.substring(0, day.indexOf(".")) + "天";
  }
}
