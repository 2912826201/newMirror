import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
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
            child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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

            ]))));
  }
}
