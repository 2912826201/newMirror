import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan/scan.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';

import 'my_qrcode_page.dart';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanCodeState createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCodePage> {
  String imagePath = "";
  ScanController controller = ScanController();

  @override
  void initState() {
    super.initState();
  }
    getUserModel(int id)async{
    UserModel userModel = await getUserInfo(uid: id);
      if(userModel!=null){
        Navigator.pop(context);
        AppRouter.navigateToMineDetail(context, userModel.uid);
      }
    }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
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
                    print("+-------------------"+data.toString());

                    resolveScanResult(data);

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
                            InkWell(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                  return MyQrCodePage();
                                }));
                              },
                              child: Center(
                                child: QrImage(
                              data: "用户${context.watch<ProfileNotifier>().profile.uid}",
                              size: 40,
                              padding: EdgeInsets.zero,
                              backgroundColor: AppColor.white,
                              version: QrVersions.auto,
                            )),),
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
          ));
  }

  _getImagePicker() {
    AppRouter.navigateToMediaPickerPage(context, 1, typeImage, false, startPageGallery, true, (result) async {
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
          if(result.substring(0,2)=="用户"){
            print('===================这是用户${result.substring(2,result.length)}');
            getUserModel(int.parse(result.substring(2,result.length)));
          }
        }
        Toast.show("这是从相册获取到的$result", context);
        setState(() {});
      }
    });
  }


  _goToUserHome(String result){
    if(result.substring(0,2)=="用户"){
      print('===================这是用户${result.substring(2,result.length)}');
      getUserModel(int.parse(result.substring(2,result.length)));
    }
  }

  //解析这个短链接
  void resolveScanResult(String result) async {
    //TODO 判断二维码短链接的语句之后要换
    if(result.startsWith("http://ifdev.aimymusic.com/third/web/url/fitness")){
      //是我们自己的短链接 要用get请求获取其中的uri
      String uri = await resolveShortUrl(result);
      _resolveUri(uri);
    } else {
      _resolveUri(result);
    }
  }

  _resolveUri(String uri) async {
    if(uri == null){
      ToastShow.show(msg: "不支持的二维码", context: context);
      return;
    } else if(uri.startsWith("if://")){
      //是我们app的指令 解析并执行指令 一般为if://XXXXX?AAA=bbb&CCC=ddd的格式
      List<String> strs = uri.split("?");
      String command = strs.first;
      Map<String, dynamic> params = {};
      if(strs.length > 1){
        List<String> paramsStrs = strs.last.split("&");
        paramsStrs.forEach((str) {
          params[str.split("=").first] = str.split("=").last;
        });
      }

      switch(command){
        case "if://loginTerminal":
          print("登录终端指令");
          break;
        case "if://activeTerminal":
          print("激活终端指令");
          break;
        case "if://joinGroup":
          print("加入群聊指令");
          Map<String, dynamic> joinMap = await joinGroupChatUnrestricted(params["code"]);
          // print("joinMap:"+joinMap.toString());
          if(joinMap != null && joinMap["id"] != null) {
            String name = "";
            if (joinMap["modifiedName"] != null) {
              name = joinMap["modifiedName"];
            } else if (joinMap["name"] != null) {
              name = joinMap["name"];
            } else {
              name = joinMap["id"].toString();
            }
            Navigator.of(context).pop();
            jumpGroupPage(context, name, joinMap["id"]);
          }
          break;
        default:
          ToastShow.show(msg: "不支持的二维码", context: context);
          break;
      }
    } else if(uri.startsWith("http://") || uri.startsWith("https://")){
      //网页 需要再细致区分处理 暂时先不处理
      ToastShow.show(msg: "不支持的二维码", context: context);
      return;
    } else {
      ToastShow.show(msg: "不支持的二维码", context: context);
      return;
    }
  }

}
