import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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

  _VersionDialogState({this.url, this.content, this.strong});

  @override
  void initState() {
    super.initState();
  }

  void _updateProgress() {
    FileUtil().download(url, (taskId, received, total) async {
      if (received != total) {
        progressWidth = received / total;
        progressText = "${100 * (received / total)}".substring(0, "${100 * (received / total)}".indexOf(".")) + "%";
        setState(() {});
      }
      print('==taskId$taskId====================progress${received / total}');
    }).then((value){
      if(value.filePath!=null){
        Future.delayed(Duration(milliseconds: 100), () async {
          _installApk();
        });
      }
    });
  }

  _installApk() async {
    String path = await FileUtil().getDownloadedPath(url);
    print('===========================path$path');
    if (path != null) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses.isNotEmpty) {
        await File(path).stat().then((value) => print('========文件信息---------------$value'));
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
        child: Column(
          children: [
            Container(
              height: ScreenUtil.instance.height * 0.15,
              color: AppColor.bgVip1,
            ),
            Spacer(),
            Text(
              "发现新版本",
              style: AppStyle.textMedium16,
            ),
            Spacer(),
            Container(
              height: 75,
              width: ScreenUtil.instance.screenWidthDp,
              padding: EdgeInsets.only(left: 23, right: 23),
              child: SingleChildScrollView(
                  child: Text(
                content,
                style: AppStyle.textMedium15,
              )),
            ),
            Spacer(),
            InkWell(
              onTap: () async {
                if (progressText == "立即更新") {
                    if(Platform.isIOS){
                      LaunchReview.launch(writeReview: false, iOSAppId: "585027354");
                    }else{
                      _updateProgress();
                    }
                } else if (progressText == "去安装") {
                  _installApk();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      width: 180,
                      height: 32,
                      color: AppColor.bgWhite,
                    ),
                    Container(
                      width: progressWidth * 180,
                      height: 32,
                      decoration:
                          BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    Container(
                      width: 180,
                      height: 32,
                      child: Center(
                        child: Text(
                          progressText,
                          style: AppStyle.whiteMedium15,
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      "下次再说",
                      style: AppStyle.textHintRegular14,
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
