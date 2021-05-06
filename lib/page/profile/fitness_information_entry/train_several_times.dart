import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/fitness_entry_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/loading.dart';

class TrainSeveralTimes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TrainSeveralTimesState();
  }
}

class _TrainSeveralTimesState extends State<TrainSeveralTimes> {
  bool three = false;
  bool four = false;
  bool fives = false;

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        hasDivider: false,
      ),
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: 42,
            ),
            Center(
              child: Container(
                width: width,
                padding: EdgeInsets.only(left: 41),
                child:  Text(
                    "你每周训练几次",
                    style: AppStyle.textMedium23,
                  ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Center(
              child: Container(
                width: width,
                padding: EdgeInsets.only(left: 41),
                child: Text(
                  "我们将以此为你推荐训练计划，让你一试身手。",
                  style: AppStyle.textRegular14,
                ),
              ),
            ),
            SizedBox(
              height: 42,
            ),
           _button("训练3次", three, 3),
            SizedBox(
              height: 18,
            ),
             _button("训练4次", four, 4),
            SizedBox(
              height: 18,
            ),
             _button("训练5次", fives, 5),
          ],
        ),
      ),
    );
  }

  Widget _button(String text, bool selected, int type) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      padding: EdgeInsets.only(left: 41, right: 41),
      child: ClickLineBtn(
        title: text,
        height: 44.0,
        width: ScreenUtil.instance.screenWidthDp,
        circular: 3.0,
        textColor: selected ? AppColor.white : AppColor.textPrimary1,
        fontSize: 18,
        backColor: selected ? AppColor.bgBlack : AppColor.transparent,
        color: selected ? AppColor.transparent : AppColor.textHint,
        onTap: () {
          Loading.showLoading(context,infoText: "正在录入健身信息");
          setState(() {
            switch (type) {
              case 3:
                three = true;
                Application.fitnessEntryModel.timesOfWeek = 3;
                break;
              case 4:
                four = true;
                Application.fitnessEntryModel.timesOfWeek = 4;
                break;
              case 5:
                fives = true;
                Application.fitnessEntryModel.timesOfWeek = 5;
                break;
            }
          });
          _fitnessEntry();
        },
      ),
    );
  }

  _fitnessEntry() async {
    FitnessEntryModel getModel = await userFitnessEntry(
        height: Application.fitnessEntryModel.height,
        weight: Application.fitnessEntryModel.weight,
        bodyType: Application.fitnessEntryModel.bodyType,
        target: Application.fitnessEntryModel.target,
        level: Application.fitnessEntryModel.hard,
        keyParts: Application.fitnessEntryModel.keyParts.toString(),
        timesOfWeek: Application.fitnessEntryModel.timesOfWeek);
    if (getModel != null) {
      Loading.hideLoading(context);
      ToastShow.show(msg: "健身信息录入成功", context: context);
      AppRouter.popToBeforeLogin(context);
    } else {
      ToastShow.show(msg: "数据上传失败了，尝试联系客服修改吧~", context: context);
      Loading.hideLoading(context);
      AppRouter.popToBeforeLogin(context);
      print('================================健身信息录入失败');
    }
    Future.delayed(Duration(milliseconds: 100),(){
      EventBus.getDefault().post(registerName: SHOW_IMAGE_DIALOG);
    });
  }
}
