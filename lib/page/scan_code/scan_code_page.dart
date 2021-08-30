import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/widget/Clip_util.dart';
import '../message/util/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/scan_code/scan_result_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scan/scan.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/constant/color.dart';


void gotoScanCodePage(BuildContext context,{bool showMyCode = false}){
  Permission.camera.status.then((value) {
    if (value.isGranted) {
      AppRouter.navigateToScanCodePage(context, showMyCode: showMyCode);
    }else if(value.isDenied){
      Permission.camera.request().then((status){
        if(status.isPermanentlyDenied){
          showAppDialog(context,
              title: "获取相机权限",
              info: "使用该功能需要打开相机权限",
              cancel: AppDialogButton("取消", () {
                return true;
              }),
              confirm: AppDialogButton(
                "去打开",
                    () {
                  AppSettings.openAppSettings(asAnotherTask: true);
                  return true;
                },
              ),
              barrierDismissible: false);
        }else if(status.isGranted){
          AppRouter.navigateToScanCodePage(context, showMyCode: showMyCode);
        }
      });
    }
  });
}
class ScanCodePage extends StatefulWidget {
  bool showMyCode;

  ScanCodePage({this.showMyCode});

  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  String codeData;
  StreamController<double> streamController = StreamController<double>();
  bool upOrDown = false;
  int timeStamp;
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool requestOver = true;

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    streamController.sink.add(250);
  }


  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      print('scanData---------------------------${scanData.code}');
      //note 接口很慢的情况，防止重复请求和响应
      if (!requestOver) {
        return;
      }
      //note 防止回调太快，每两秒响应一次结果
      if (timeStamp == null) {
        timeStamp = DateTime.now().millisecondsSinceEpoch;
        resolveScanResult(scanData.code);
      }
      if (DateTime.now().millisecondsSinceEpoch - timeStamp > 2000) {
        timeStamp = DateTime.now().millisecondsSinceEpoch;
        resolveScanResult(scanData.code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "扫描二维码",
        leadingOnTap: () {
          Navigator.pop(context);
        },
        actions: [
          CustomAppBarTextButton("相册", AppColor.white, () {
            _getImagePicker();
          }),
        ],
      ),
      body: Stack(
        children: [
          Container(
              width: ScreenUtil.instance.screenWidthDp,
              height: ScreenUtil.instance.height,
              child: QRView(
                //note 这是支持扫描的格式,项目目前只需要支持二维码
                formatsAllowed: [BarcodeFormat.qrcode],
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              )),
          _scanCoverView()
        ],
      ),
    );
  }

  Widget _scanCoverView() {
    return Stack(
      children: [
        Container(
          height: ScreenUtil.instance.height,
          width: ScreenUtil.instance.screenWidthDp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil.instance.height * 0.24,
                width: ScreenUtil.instance.screenWidthDp,
                color: AppColor.black.withOpacity(0.3),
              ),
              SizedBox(
                height: 250,
              ),
              Expanded(
                child: Container(
                  color: AppColor.black.withOpacity(0.3),
                ),
              ),
            ],

          ),
        ),
        _textContainerColumn()
      ],
    );
  }

  Widget _textContainerColumn() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: ScreenUtil.instance.height * 0.24,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 250,
                  color: AppColor.black.withOpacity(0.3),
                ),
              ),
              _animationContainer(),
              Expanded(
                child: Container(
                  height: 250,
                  color: AppColor.black.withOpacity(0.3),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            "将二维码放入框内，即可自动扫描",
            style: AppStyle.whiteMedium14,
          ),
          SizedBox(
            height: 48,
          ),
          widget.showMyCode
              ? AppIconButton(
                  iconSize: 40,
                  svgName: AppIcon.qrcode,
                  bgColor: AppColor.white,
                  onTap: () {
                    controller.pauseCamera();
                    AppRouter.navigateToMyQrCodePage(context, (result) {
                      controller.resumeCamera();
                    });
                  },
                )
              : Container(),
          SizedBox(
            height: 9,
          ),
          widget.showMyCode
              ? Text(
                  "我的二维码",
                  style: AppStyle.whiteRegular12,
                )
              : Container()
        ],
      ),
    );
  }

  Widget _whiteSmallRow() {
    return Container(
    /*  width: 26,
      height: 4,
      color: AppColor.textWhite60,*/
    );
  }

  Widget _whiteSmallCloumn(int type) {
    return Container(
      child: CustomPaint(
    size: Size(24,24),
      painter: ScanWeaponPainter(type),
    ),);
  }

  Widget _animationContainer() {
    return Container(
        width: 250,
        height: 250,
        child: Stack(
          children: [
            Positioned(top: 2, left: 2, child: _whiteSmallCloumn(1)),
            Positioned(top: 2, right: 2, child: _whiteSmallCloumn(2)),
            Positioned(bottom: 2, left: 2, child: _whiteSmallCloumn(3)),
            Positioned(bottom: 2, right: 2, child: _whiteSmallCloumn(4)),
            StreamBuilder<double>(
                initialData: 0,
                stream: streamController.stream,
                builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 3000),
                    margin: EdgeInsets.only(top: snapshot.data),
                    onEnd: () {
                      streamController.sink.add(upOrDown ? 250 : 0);
                      upOrDown = !upOrDown;
                    },
                    child: Container(
                      width: 250,
                      height: 2,
                      color: AppColor.textWhite60,
                    ),
                  );
                })
          ],
        ));
  }

  _getImagePicker() {
    AppRouter.navigateToMediaPickerPage(context, 1, typeImage, true, startPageGallery, true, (result) async {
      SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
      if (result != true || files == null) {
        print('===============================值为空退回');
        return;
      }
      RuntimeProperties.selectedMediaFiles = null;
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
        if (result != null) {
          resolveScanResult(result);
        }
      }
    });
  }

  //解析这个短链接
  void resolveScanResult(String result) async {
    //FIXME 判断二维码短链接的语句之后要换
    if (result.startsWith("${AppConfig.getApiHost()}/third/web/url/fitness")) {
      //是我们自己的短链接 要用get请求获取其中的uri
      requestOver = false;
      String uri = await resolveShortUrl(result);
      requestOver = true;
      _resolveUri(uri);
    } else {
      _resolveUri(result);
    }
  }

  _resolveUri(String uri) async {
    if (uri == null) {
      if (mounted && context != null) {
        ToastShow.show(msg: "不支持的二维码", context: context);
      }
      return;
    } else if (uri.startsWith("if://")) {
      controller.stopCamera();
      //是我们app的指令 解析并执行指令 一般为if://XXXXX?AAA=bbb&CCC=ddd的格式
      List<String> strs = uri.split("?");
      String command = strs.first;
      Map<String, String> params = {};
      if (strs.length > 1) {
        List<String> paramsStrs = strs.last.split("&");
        paramsStrs.forEach((str) {
          params[str.split("=").first] = str.split("=").last;
        });
      }

      switch (command) {
        case "if://loginTerminal":
          print("登录终端指令");
          ScanCodeResultModel model = ScanCodeResultModel();
          model.type = ScanCodeResultType.LOGIN_MACHINE;
          model.data = {};
          model.data["mid"] = params["mid"];
          Navigator.pop(context);
          AppRouter.navigateToScanCodeResultPage(context, model);
          break;
        case "if://activeTerminal":
          print("激活终端指令");
          break;
        case "if://joinGroup":
          print("加入群聊指令");
          Map<String, dynamic> joinMap = await joinGroupChatUnrestricted(params["code"]);
          // print("joinMap:"+joinMap.toString());
          if (joinMap != null && joinMap["id"] != null) {
            String name = "";
            if (joinMap["modifiedName"] != null) {
              name = joinMap["modifiedName"];
            } else if (joinMap["name"] != null) {
              name = joinMap["name"];
            } else {
              name = joinMap["id"].toString();
            }
            Navigator.pop(context);
            jumpGroupPage(context, name, joinMap["id"]);
          }
          break;
        case "if://userProfile":
          int uid = int.parse(params["uid"]);
          print('--------------------------uid----$uid-');
          requestOver = false;
          getUserInfo(uid: uid).then((value) {
            requestOver = true;
            if (value != null) {
              Navigator.pop(context);
              jumpToUserProfilePage(context, value.uid, avatarUrl: value.avatarUri, userName: value.nickName);
            }
          });
          break;
        //登录教练端指令
        case "if://loginCoach":
          String coach = params["coach"];
          loginCoach(coach);
          Navigator.pop(context);
          break;
        //登录编辑器指令
        case "if://LoginEditor":
          String editor = params["editor"];
          loginCoach(editor);
          Navigator.pop(context);
          break;
        default:
          ScanCodeResultModel model = ScanCodeResultModel();
          model.type = ScanCodeResultType.CODE_INVALID;
          Navigator.pop(context);
          AppRouter.navigateToScanCodeResultPage(context, model);
          break;
      }
    } else if (uri.startsWith("http://") || uri.startsWith("https://")) {
      controller.stopCamera();
      //网页 需要再细致区分处理 暂时先不处理
      ScanCodeResultModel model = ScanCodeResultModel();
      model.type = ScanCodeResultType.CODE_INVALID;
      Navigator.pop(context);
      AppRouter.navigateToScanCodeResultPage(context, model);
    } else {
      controller.stopCamera();
      ScanCodeResultModel model = ScanCodeResultModel();
      model.type = ScanCodeResultType.CODE_INVALID;
      Navigator.pop(context);
      AppRouter.navigateToScanCodeResultPage(context, model);
    }
  }
}
