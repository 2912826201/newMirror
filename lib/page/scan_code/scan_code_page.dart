import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/scan_code/scan_result_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:qrcode/qrcode.dart';
import 'package:scan/scan.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/constant/color.dart';
import 'package:provider/provider.dart';

class ScanCodePage extends StatefulWidget {
  bool showMyCode;

  ScanCodePage({this.showMyCode});

  @override
  scanCodePageState createState() => scanCodePageState();
}

class scanCodePageState extends State<ScanCodePage> {
  String codeData;
  StreamController<double> streamController = StreamController<double>();
  QRCaptureController _captureController = QRCaptureController();
  bool upOrDown = false;

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('----------------------扫码界面deactivate');
    _captureController.pause();
  }

  @override
  void initState() {
    super.initState();
    streamController.sink.add(250);
    _captureController.onCapture((data) {
      print('onCapture----$data');
      resolveScanResult(data);
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
          CustomAppBarTextButton("相册", AppColor.textPrimary2, () {
            _getImagePicker();
          }),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: ScreenUtil.instance.screenWidthDp,
            height: ScreenUtil.instance.height,
            child: QRCaptureView(
              controller: _captureController,
            ),
          ),
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
                    AppRouter.navigateToMyQrCodePage(context, (result) {});
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
      width: 26,
      height: 4,
      color: AppColor.white,
    );
  }

  Widget _whiteSmallCloumn() {
    return Container(
      width: 4,
      height: 26,
      color: AppColor.white,
    );
  }

  Widget _animationContainer() {
    return Container(
        width: 250,
        height: 250,
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, child: _whiteSmallRow()),
            Positioned(top: 0, left: 0, child: _whiteSmallCloumn()),
            Positioned(top: 0, right: 0, child: _whiteSmallRow()),
            Positioned(top: 0, right: 0, child: _whiteSmallCloumn()),
            Positioned(bottom: 0, left: 0, child: _whiteSmallRow()),
            Positioned(bottom: 0, left: 0, child: _whiteSmallCloumn()),
            Positioned(bottom: 0, right: 0, child: _whiteSmallRow()),
            Positioned(bottom: 0, right: 0, child: _whiteSmallCloumn()),
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
                      color: AppColor.white,
                    ),
                  );
                })
          ],
        ));
  }

  _getImagePicker() {
    AppRouter.navigateToMediaPickerPage(context, 1, typeImage, true, startPageGallery, true, (result) async {
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
        if (result != null) {
          resolveScanResult(result);
        }
      }
    });
  }

  //解析这个短链接
  void resolveScanResult(String result) async {
    //TODO 判断二维码短链接的语句之后要换
    if (result.startsWith("http://ifdev.aimymusic.com/third/web/url/fitness")) {
      //是我们自己的短链接 要用get请求获取其中的uri
      String uri = await resolveShortUrl(result);
      _resolveUri(uri);
    } else {
      _resolveUri(result);
    }
  }

  _resolveUri(String uri) async {
    if (uri == null) {
      ToastShow.show(msg: "不支持的二维码", context: context);
      return;
    } else if (uri.startsWith("if://")) {
      _captureController.pause();
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
          Navigator.pop(context);
          print('--------------------------uid----$uid-');
          getUserInfo(uid: uid).then((value){
            AppRouter.navigateToMineDetail(context, value.uid,avatarUrl: value.avatarUri,userName: value.nickName);
          });
          break;
        default:
          ScanCodeResultModel model = ScanCodeResultModel();
          model.type = ScanCodeResultType.CODE_INVALID;
          Navigator.pop(context);
          AppRouter.navigateToScanCodeResultPage(context, model);
          break;
      }
    } else if (uri.startsWith("http://") || uri.startsWith("https://")) {
      _captureController.pause();
      //网页 需要再细致区分处理 暂时先不处理
      ScanCodeResultModel model = ScanCodeResultModel();
      model.type = ScanCodeResultType.CODE_INVALID;
      Navigator.pop(context);
      AppRouter.navigateToScanCodeResultPage(context, model);
    } else {
      _captureController.pause();
      ScanCodeResultModel model = ScanCodeResultModel();
      model.type = ScanCodeResultType.CODE_INVALID;
      Navigator.pop(context);
      AppRouter.navigateToScanCodeResultPage(context, model);
    }
  }
}
