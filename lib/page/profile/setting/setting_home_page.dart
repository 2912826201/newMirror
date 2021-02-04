import 'dart:io';

import 'package:mirror/config/config.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/page/profile/setting/blacklist_page.dart';
import 'package:mirror/page/profile/setting/feedback_page.dart';
import 'package:mirror/page/profile/setting/notice_setting_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toast/toast.dart';

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
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
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
              child: _rowItem(width, "账户与安全"),
              onTap: () {
                AppRouter.navigateToSettingAccountSecurity(context);
              },
            ),
            InkWell(
              onTap: () {
                /* AppRouter.navigateToSettingBlackList(context);*/
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return BlackListPage(
                    pc: widget.pcController,
                  );
                }));
              },
              child: _rowItem(width, "黑名单"),
            ),
            Container(
              height: 12,
              color: AppColor.bgWhite,
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
                    _clearCache(AppConfig.getAppPicDir());
                    _clearCache(AppConfig.getAppVideoDir());
                    _clearCache(AppConfig.getAppVoiceDir());
                    //TODO Android还需要清更新用的apk包
                    if(Platform.isAndroid){
                      ///遍历下载的文件，删掉带有apk后缀的文件
                      Directory file = Directory(AppConfig.getAppDownloadDir());
                      List<FileSystemEntity> children = file.listSync();
                      for (final FileSystemEntity child in children) {
                        if(child.path.contains("apk")){
                          print('===================存在安装包${child.path}');
                          child.delete(recursive: false);
                        }
                      }
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
            InkWell(
              onTap: () {
                AppRouter.navigateToSettingFeedBack(context);
              },
              child: _rowItem(width, "意见反馈"),
            ),
            InkWell(
              child: _rowItem(width, "关于"),
              onTap: () {
                AppRouter.navigateToSettingAbout(context);
              },
            ),
            Container(
              height: 12,
              color: AppColor.bgWhite,
              width: width,
            ),
            _signOutRow(width)
          ],
        ),
      ),
    );
  }

  Widget _signOutRow(double width) {
    return InkWell(
      onTap: () async {
        await Application.appLogout();
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
            Expanded(child: SizedBox())
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
        children: [
          Text(
            text,
            style: AppStyle.textRegular16,
          ),
          Expanded(
            child: SizedBox(),
          ),
          Container(
            height: 18,
            width: 18,
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColor.textSecondary,
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
        final List<FileSystemEntity> children = file.listSync();
        print('=====================${children.first.path}');
        for (final FileSystemEntity child in children) {
          await delDir(child);
        }
      }
      await file.delete(recursive: false);
    } catch (e) {
      print(e);
    }
  }
}
