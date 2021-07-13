import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';

class UiControllerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titleString: "UI控制页",
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          RaisedButton(
            onPressed: () {
              Application.slideBanner2Dor3D = !Application.slideBanner2Dor3D;
              ToastShow.show(msg: Application.slideBanner2Dor3D ? "轮播图切换为3D" : "轮播图切换为2D", context: context);
            },
            child: Text("轮播图3D切换"),
          ),
          RaisedButton(
            onPressed: () {
              Application.slideTopicBezierCurve = !Application.slideTopicBezierCurve;
              ToastShow.show(msg: Application.slideTopicBezierCurve ? "话题详情页贝塞尔曲线" : "话题详情页取消贝塞尔曲线", context: context);
            },
            child: Text("话题详情页别塞尔曲线切换"),
          ),
          RaisedButton(
            onPressed: () {
              Application.slideFeedLike = !Application.slideFeedLike;
              ToastShow.show(msg: Application.slideFeedLike ? "icon有动效" : "icon无动效", context: context);
            },
            child: Text("点赞动画切换"),
          ),
          RaisedButton(
            onPressed: () {
              Application.slideColorizeAnimatedText = !Application.slideColorizeAnimatedText;
              ToastShow.show(msg: Application.slideColorizeAnimatedText ? "点赞列表文字有动效" : "点赞列表文字无动效", context: context);
            },
            child: Text("点赞列表文字颜色动画切换"),
          ),
          RaisedButton(
            onPressed: () {
              Application.slideAnimatedTextTypewriter = !Application.slideAnimatedTextTypewriter;
              ToastShow.show(
                  msg: Application.slideAnimatedTextTypewriter ? "话题详情页简介文字打字机效果" : "话题详情页简介普通展示", context: context);
            },
            child: Text("话题详情页简介文字打字机效果切换"),
          ),
          RaisedButton(
            onPressed: () {
              Application.slideReleaseFeedFadeInAnimation = !Application.slideReleaseFeedFadeInAnimation;
              ToastShow.show(
                  msg: Application.slideReleaseFeedFadeInAnimation ? "发布动态周边信息滑动动画渐隐渐现动画" : "发布动态周边信息无动画",
                  context: context);
            },
            child: Text("发布动态周边信息滑动动画渐隐渐现动画"),
          ),
                  RaisedButton(
                    onPressed: () {
                      AppConfig.needShowTraining = !AppConfig.needShowTraining;
                      ToastShow.show(
                          msg: AppConfig.needShowTraining ? "打开训练页" : "关闭训练页",
                          context: context);
                    },
                    child: Text("发布动态周边信息滑动动画渐隐渐现动画"),
                  ),

        ]))));
  }
}
