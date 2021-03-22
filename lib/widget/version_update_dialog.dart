import 'dart:io';

import 'package:connectivity/connectivity.dart';
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
import 'package:r_upgrade/r_upgrade.dart';

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
  bool isAutoRequestInstall = true;
  UpgradeMethod upgradeMethod;
  DownloadStatus lastStatus;
  int lastId;
  String apkName = 'mirror.apk';
  _VersionDialogState({this.url, this.content, this.strong});

  @override
  void initState() {
    super.initState();
   /* checkDownLoadStatus();
    RUpgrade.stream.listen((DownloadInfo info){
     if(info.status == DownloadStatus.STATUS_FAILED){
       ToastShow.show(msg:"下载异常,请检查网络后重试", context: context);
       progressText = "继续更新";
       setState(() {
       });
       _puaseDownLoad();
       return;
     }else if(info.status==DownloadStatus.STATUS_SUCCESSFUL){
       progressText = "去安装";
       setState(() {
       });
     }
      if(info.currentLength!=info.maxLength){
        progressText = "${(info.currentLength/info.maxLength*100).toString().substring(0,(info.currentLength/info
            .maxLength*100).toString().indexOf("."))}%";
        if(mounted){
          setState(() {
          });
        }
      }
    });*/
  }

  /*checkDownLoadStatus() async {
    lastId = await RUpgrade.getLastUpgradedId();
      if (lastId != null) {
        lastStatus = await RUpgrade.getDownloadStatus(lastId);
        if (lastStatus != null) {
          print('=======================lastStatus${lastStatus.toString()}');
        if (lastStatus == DownloadStatus.STATUS_PAUSED) {
            progressText = "继续更新";
          }else if(lastStatus == DownloadStatus.STATUS_SUCCESSFUL){
          Directory file = Directory(AppConfig.getAppApkDir());
          file.stat().then((value) => print('========apk文件信息---------------$value'));
          List<FileSystemEntity> children = file.listSync();
          if(children.isNotEmpty){
            for (final FileSystemEntity child in children) {
              if(child.path.contains("apk")){
                progressText = "去安装";
              }else{
                progressText = "立即更新";
              }
            }
          }
          }else if(lastStatus == DownloadStatus.STATUS_FAILED){
          Directory file = Directory(AppConfig.getAppApkDir());
          file.stat().then((value) => print('========apk文件信息---------------$value'));
          List<FileSystemEntity> children = file.listSync();
          if(children.isNotEmpty){
            for (final FileSystemEntity child in children) {
              if(child.path.contains("apk")){
                progressText = "继续更新";
              }else{
                progressText = "立即更新";
              }
            }
          }
          }else if(lastStatus == DownloadStatus.STATUS_PENDING){
            progressText = "立即更新";
          }
          setState(() {
          });
        }
      }
  }*/

  void _updateProgress() {
    FileUtil().download(url, (taskId, received, total) async {
      if (received != total) {
        progressWidth = received / total;
        progressText = "${100 * (received / total)}".substring(0, "${100 * (received / total)}".indexOf(".")) + "%";
        setState(() {});
      }
      print('==taskId$taskId====================progress${received / total}');
    }).then((value) {
      if (value.filePath != null) {
        Future.delayed(Duration.zero, () async {
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

  _testUpDataVersionApk() async {
    lastId = await RUpgrade.upgrade(url,
        fileName: apkName,
        isAutoRequestInstall: isAutoRequestInstall,
        notificationStyle: NotificationStyle.speech,
        useDownloadManager: false);
    upgradeMethod = UpgradeMethod.all;
  }

  _puaseDownLoad(){
    RUpgrade.pause(lastId).then((value){

    });

  }

  _cancelDownLoad()async{
    bool isSuccess = await RUpgrade.cancel(lastId);
    if(isSuccess){
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
   /* return StreamBuilder(
        stream: RUpgrade.stream,
        builder: (BuildContext context, AsyncSnapshot<DownloadInfo> snapshot) {
          if(snapshot.data!=null){
            print('==========================snapshot.data.path${snapshot.data.path.substring(0,snapshot.data.path
                .indexOf(apkName))
            }');
          }
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
                        switch(progressText){
                          case "去安装":
                           *//* _testUpDataVersionApk();*//*
                            await RUpgrade.install(lastId).then((value){
                              if(value){
                                Navigator.pop(context);
                              }
                            });
                            break;
                          case "继续更新":
                            await RUpgrade.upgradeWithId(lastId,
                                notificationVisibility: NotificationVisibility.VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION);
                            break;
                          case "立即更新":
                              _testUpDataVersionApk();
                              break;
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
                              width:progressText!="立即更新"&&progressText!="去安装"&&progressText!="继续更新"
                                  ?(snapshot.data
                                  .percent / 100) * 180
                                  : 180,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: AppColor.black, borderRadius: BorderRadius.all(Radius.circular(16))),
                            ),
                            Container(
                              width: 180,
                              height: 32,
                              child: Center(
                                child: Text(
                                   progressText,
                                    style: AppStyle.whiteMedium15),
                              ),
                            ),
                          ],
                        ),
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  !strong
                      ? InkWell(
                          onTap: () {
                            if (snapshot.data!=null&&snapshot.data.status ==DownloadStatus.STATUS_RUNNING) {
                              _cancelDownLoad();
                            }
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
        });*/

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
