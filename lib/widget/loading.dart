import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/util/screen_util.dart';

import 'custom_appbar.dart';
import 'icon.dart';

//菊花
class Loading {
  static bool isShow = false;
  static StreamController<bool> streamController;

  ///note 还没有ui图，暂时按照需求给出大致的样子
  static showLoading(BuildContext context, {String infoText,Function() backTap}) {
    streamController = StreamController<bool>();
    if (!isShow) {
      isShow = true;
      showGeneralDialog(
          context: context,
          // barrierColor: Colors.white, // 背景色
          // barrierLabel: '',
          barrierDismissible: false,
          // 是否能通过点击空白处关闭
          transitionDuration: const Duration(milliseconds: 300),
          // 动画时长
          useRootNavigator: false,
          pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
            return WillPopScope(
              onWillPop: () async => false, //用来屏蔽安卓返回键关弹窗
              child: StreamBuilder<bool>(
                  initialData: true,
                  stream: streamController.stream,
                  builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                    return Container(
                      width: ScreenUtil.instance.screenWidthDp,
                      height: ScreenUtil.instance.height,
                      color: AppColor.white.withOpacity(0.24),
                      child: Stack(
                        children: [
                          Container(
                            height: ScreenUtil.instance.height,
                            width: ScreenUtil.instance.screenWidthDp,
                            child: Center(
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColor.layoutBgGrey,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: snapshot.data
                                      ? Lottie.asset(
                                    'assets/lottie/loading_refresh_yellow.json',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.fill,
                                  )
                                      : Image.asset(DefaultImage.nodata),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                !snapshot.data
                                    ? Text(
                                        "网络不给力",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.white,
                                            decoration: TextDecoration.none),
                                      )
                                    : infoText != null
                                        ? Text(
                                            infoText,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.white,
                                                decoration: TextDecoration.none),
                                          )
                                        : Container()
                              ]),
                            ),
                          ),
                          Positioned(
                            top: ScreenUtil.instance.statusBarHeight,
                            left: 8,
                            child: Container(
                              height: CustomAppBar.appBarButtonWidth,
                              width: CustomAppBar.appBarButtonWidth,
                              child: Center(
                                child: CustomAppBarIconButton(

                                 svgName: AppIcon.nav_return,
                                  iconColor: AppColor.white,
                                  onTap: () {
                                    streamController.onCancel;
                                    streamController.close();
                                    backTap();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            );
          }).then((value) {
        isShow = false;
      });
    }
  }

  ///关闭loading
  static hideLoading(BuildContext context) {
    if (isShow) {
      streamController.onCancel;
      streamController.close();
      Navigator.of(context).pop();
    }
  }

  ///这是请求异常时需要调用的方法
  static loadingFaild() {
    streamController.sink.add(false);
  }
}
