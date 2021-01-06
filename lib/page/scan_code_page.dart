import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan/scan.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanCodeState createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCodePage> {
  String _platformVersion = 'Unknown';
  String imagePath = "";
  ScanController controller = ScanController();
  String qrcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await Scan.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColor.white,
            brightness: Brightness.light,
            leading: InkWell(
              child: Container(
                margin: EdgeInsets.only(left: 16),
                child: Image.asset("images/resource/2.0x/return2x.png"),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            leadingWidth: 44,
            title: Text(
              "扫描二维码",
              style: AppStyle.textMedium18,
            ),
            actions: [
              InkWell(
                onTap: () {
                  _getImagePicker();
                  /*getImage();*/
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(right: 17, top: 12, bottom: 12),
                    child: Text(
                      "相册",
                      style: AppStyle.textRegular14,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              Container(
                width: width,
                height: height,
                child: ScanView(
                  controller: controller,
                  scanAreaScale: .7,
                  scanLineColor: AppColor.white,
                  onCapture: (data) {
                    setState(() {
                      if (StringUtil.isURL(data)) {
                        print('===========================这是一个网址');
                        print('$data');
                      } else {
                        print('===========================这是扫码得到的结果$data');
                      }
                      Toast.show("这是扫码得到的结果=============$data", context);
                    });
                  },
                ),
              ),
              Positioned(
                  bottom: height * 0.21,
                  child: Container(
                    width: width,
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Text(
                          "将二维码放入框中,即可自动扫描",
                          style: TextStyle(fontSize: 14, color: AppColor.white),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  )),
              Positioned(
                  bottom: height * 0.064,
                  child: Container(
                    width: width,
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Column(
                          children: [
                            Center(
                                child: QrImage(
                              data: "${context.watch<ProfileNotifier>().profile.uid}",
                              size: 40,
                              backgroundColor: AppColor.white,
                              version: QrVersions.auto,
                            )),
                            SizedBox(
                              height: 9,
                            ),
                            Text(
                              "我的二维码",
                              style: TextStyle(fontSize: 12, color: AppColor.white),
                            )
                          ],
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }

  _getImagePicker() {
    AppRouter.navigateToMediaPickerPage(context, 1, typeImage, true, startPageGallery, true, false, (result) async {
      SelectedMediaFiles files = Application.selectedMediaFiles;
      if (result != true || files == null) {
        print('===============================值为空退回');
        return;
      }
      Application.selectedMediaFiles = null;
      MediaFileModel model = files.list.first;
      if (model != null) {
        print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
        print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        Uint8List picBytes = byteData.buffer.asUint8List();
        print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
        model.croppedImageData = picBytes;
      }
      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
      if (model.croppedImageData != null) {
        print('==================================model.croppedImageData!=null');
        File imageFile = await FileUtil().writeImageDataToFile(model.croppedImageData, timeStr);
        print('imageFile==============================$imageFile');
        String result = await Scan.parse(imageFile.path);
        if (StringUtil.isURL(result)) {
          print('===========================这是一个网址');
        } else {
          print('===========================这是扫码得到的结果$result');
        }
        Toast.show("这是从相册获取到的$result", context);
        setState(() {});
        print('result=====================================$result');
      }
    });
  }
}
