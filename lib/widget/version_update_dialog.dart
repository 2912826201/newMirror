import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/download_db_helper.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum UpgradeMethod {
  all,
  hot,
  increment,
}

class VersionUpdateDialog extends StatefulWidget {
  String content;
  String url;
  bool strong;

  VersionUpdateDialog({this.strong, this.content, this.url});

  @override
  State<StatefulWidget> createState() {
    return _VersionDialogState(content: content, strong: strong, url: url);
  }
}

class _VersionDialogState extends State<VersionUpdateDialog> {
  String content;
  String url;
  bool strong;
  double progressWidth = 1;
  String progressText = "立即更新";
  bool canOnClick = true;
  bool lockOrUnlock = true;
  CancelToken cancelToken = CancelToken();
  Dio dio = Dio();
  Connectivity connectivity = Connectivity();

  _VersionDialogState({this.url, this.content, this.strong});

  @override
  void initState() {
    super.initState();
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.mobile:
          print('----------mobile-----------------mobile');
          break;
        case ConnectivityResult.wifi:
          print('----------wifi-----------------wifi');
          break;
        case ConnectivityResult.none:
          dio.lock();
          ToastShow.show(msg: "下载异常，请重试", context: context);
          progressWidth = 1;
          progressText = "继续下载";
          setState(() {});
          print('----------none-----------------none');
          break;
      }
    });
  }

  void _updateProgress() {
    FileUtil().chunkDownLoad(context, url, (taskId, received, total) async {
      if (received != total) {
        progressWidth = received / total;
        progressText = "${100 * (received / total)}".substring(0, "${100 * (received / total)}".indexOf(".")) + "%";
        setState(() {});
      }
      print('==taskId$taskId====================progress${received / total}');
    }, cancelToken: cancelToken, dio: dio).then((value) {
      if (value != null && value.filePath != null) {
        print('-----------------下载完成4${value.filePath}');
        canOnClick = true;
        Future.delayed(Duration.zero, () async {
          _installApk(value.filePath);
        });
      }
    }).catchError((e) {
      canOnClick = true;
      print('versionDownLoad(ERROR)================$e');
    });
  }

  _installApk(String path) async {
      print('===========================path$path');
      if (path != null) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
        if (statuses.isNotEmpty) {
          File(path).stat().then((value) => print('========文件信息---------------$value'));
          if (strong) {
            setState(() {
              progressText = "去安装";
            });
          } else {
            Navigator.pop(context);
          }
          OpenFile.open(path).then((value) {
            print('=======================${value.message}');
          });
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: ScreenUtil.instance.screenWidthDp * 0.69,
        height: 353,
        color: AppColor.layoutBgGrey,
        child: Column(
          children: [
            Container(
              height: 123,
              color: AppColor.imageBgGrey,
            ),
            Spacer(),
            Text(
              "发现新版本",
              style: AppStyle.whiteMedium16,
            ),
            Spacer(),
            Container(
              height: 75,
              width: ScreenUtil.instance.screenWidthDp,
              padding: EdgeInsets.only(left: 23, right: 23),
              child: SingleChildScrollView(
                  child: Text(
                content,
                style: AppStyle.text1Regular15,
              )),
            ),
            Spacer(),
            InkWell(
              onTap: () async {
                if(!canOnClick){
                  return;
                }
                if (progressText == "立即更新") {
                  if (Platform.isIOS) {
                    LaunchReview.launch(writeReview: false, iOSAppId: AppConfig.iosAppId);
                  } else {
                    canOnClick  = false;
                    _updateProgress();
                  }
                } else if (progressText == "去安装") {
                  FileUtil().getDownloadedPath(url).then((path){
                    if(path!=null){
                      _installApk(path);
                    }
                  });
                } else if (progressText == "继续下载") {
                  dio = Dio();
                  _updateProgress();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      width: 180,
                      height: 32,
                      color: AppColor.white.withOpacity(0.1),
                    ),
                    Container(
                      width: progressWidth * 180,
                      height: 32,
                      decoration:
                          BoxDecoration(color: AppColor.mainYellow, borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    Container(
                      width: 180,
                      height: 32,
                      child: Center(
                        child: Text(
                          progressText,
                          style: AppStyle.textRegular15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            !strong
                ? InkWell(
                    onTap: () {
                      cancelToken.cancel();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "下次再说",
                      style: AppStyle.text2Regular14,
                    ),
                  )
                : Container(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

showVersionDialog({String content, bool strong, String url, BuildContext context, bool barrierDismissible = false}) {
  showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => barrierDismissible, //用来屏蔽安卓返回键关弹窗
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              child: VersionUpdateDialog(
                content: content,
                strong: strong,
                url: url,
              ),
            ));
      });
}
