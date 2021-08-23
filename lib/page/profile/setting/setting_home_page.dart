import 'dart:io';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/api/version_api.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


///设置主页
class SettingHomePage extends StatefulWidget {
  PanelController pcController;

  SettingHomePage({this.pcController});

  @override
  State<StatefulWidget> createState() {
    return _SettingHomePageState();
  }
}

class _SettingHomePageState extends State<SettingHomePage> {
  bool haveNewVersion = false;
  VersionModel versionModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(AppConfig.needShowTraining)_getNewVersion();
  }

  _getNewVersion() async {
    VersionModel model = await getNewVersion();
    if (model != null) {
      versionModel = model;
      if (model.version != AppConfig.version) {
        haveNewVersion = true;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        backgroundColor: AppColor.mainBlack,
        appBar: CustomAppBar(
          titleString: "设置",
        ),
        body: Container(
          height: height - ScreenUtil.instance.statusBarHeight,
          width: width,
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              InkWell(
                child: _rowItem(width, "账号与安全"),
                onTap: () {
                  AppRouter.navigateToSettingAccountSecurity(context);
                },
              ),
              InkWell(
                onTap: () {
                  AppRouter.navigateToSettingBlackList(context);
                },
                child: _rowItem(width, "黑名单"),
              ),
              Container(
                height: 12,
                color: AppColor.mainBlack,
                width: width,
              ),
              InkWell(
                onTap: () {
                  AppRouter.navigateToSettingNoticeSetting(context);
                },
                child: _rowItem(width, "通知设置"),
              ),
              InkWell(
                onTap: () {
                  showAppDialog(
                    context,
                    confirm: AppDialogButton("清除", () {
                      //清掉拍照截图、录制视频、录制语言的文件夹内容
                      try{
                        //不影响弹窗关闭
                        _clearCache(AppConfig.getAppPicDir());
                        _clearCache(AppConfig.getAppChatImageDir());
                        _clearCache(AppConfig.getAppVideoDir());
                        _clearCache(AppConfig.getAppVoiceDir());
                        _clearCache(AppConfig.getAppDownloadDir());
                        AppPrefs.clearDownLadTask();
                      }catch(e){
                        print("clearCacheError=====:$e");
                      }
                      //下载的视频课内容不在这里清，在专门管理课程的地方清
                      return true;
                    }),
                    cancel: AppDialogButton("取消", () {
                      return true;
                    }),
                    title: "清除缓存",
                    info: "你确定要清除缓存么",
                  );
                },
                child: _rowItem(width, "清除缓存"),
              ),
              if(AppConfig.needShowTraining)InkWell(
                onTap: () {
                  AppRouter.navigateToSettingFeedBack(context);
                },
                child: _rowItem(width, "意见反馈"),
              ),
              if(AppConfig.needShowTraining)InkWell(
                child: _rowItem(width, "关于"),
                onTap: () {
                  AppRouter.navigateToSettingAbout(context, versionModel,haveNewVersion);
                },
              ),
              Container(
                height: 12,
                color: AppColor.mainBlack,
                width: width,
              ),
              _signOutRow(width)
            ],
          ),
        ));
  }

  Widget _signOutRow(double width) {
    return InkWell(
      onTap: () async {
        // 清空曝光过的listKey
        ExposureDetectorController.instance.signOutClearHistory();
        //清楚通知的数量
        MessageManager.unreadMessageNumber=0;
        MessageManager.unreadNoticeNumber=0;
        await Application.appLogout(context: context);
      },
      child: Container(
        height: 48,
        width: width,
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Row(
          children: [
            Text(
              "退出登录",
              style: AppStyle.redRegular16,
            ),
            Spacer()
          ],
        ),
      ),
    );
  }

  Widget _rowItem(double width, String text) {
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: AppStyle.whiteRegular16,
          ),
          Spacer(),
          text == "关于" && haveNewVersion
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 64,
                    height: 18,
                    color: AppColor.mainRed,
                    child: Center(
                      child: Text(
                        "有新版本",
                        style: AppStyle.whiteRegular12,
                      ),
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            width: 12,
          ),
          Container(
            height: 18,
            width: 18,
            alignment: Alignment.centerRight,
            child: AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              18,
              color: AppColor.textWhite60,
            ),
          )
        ],
      ),
    );
  }

  void _clearCache(String path) async {
    try {
      //删除缓存目录
      Directory file = Directory(path);
      await delDir(file);
      Toast.show('清除缓存成功', context);
    } catch (e) {
      print(e);
      Toast.show('清除缓存失败', context);
    } finally {}
  }

  ///递归方式删除目录
  Future<Null> delDir(FileSystemEntity file) async {
    try {
      await file.stat().then((value) => print('========文件信息---------------$value'));
      print('=============path=============${file.path}');
      if (file is Directory) {
        print('=========================================if');
        final List<FileSystemEntity> children = file.listSync();
        if (children.isNotEmpty) {
          print('=====================${children.first.path}');
          for (final FileSystemEntity child in children) {
            await delDir(child);
          }
        }
      } else {
        //只清理子文件
        print('=========================================else');
        await file.delete(recursive: false);
      }
    } catch (e) {
      print(e);
    }
  }
}
