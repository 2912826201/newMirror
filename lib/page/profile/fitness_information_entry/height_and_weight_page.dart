import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/input_formatter/precision_limit_formatter.dart';

class HeightAndWeightPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HeightAndWeightState();
  }
}

class _HeightAndWeightState extends State<HeightAndWeightPage> {
  int weight;
  int heights;
  FocusNode blankNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        hasDivider: false,
        leading: Container(),
      ),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(left: 41,right: 41),
        child: ListView(
          children: [
            SizedBox(
              height: 42,
            ),
              Container(
                width: width,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "你的身高体重是",
                    style: AppStyle.textMedium23,
                  ),
                ),
            SizedBox(
              height: 12,
            ),
             Container(
                width: width,
                alignment: Alignment.centerLeft,
                child: Text(
                  "我们将以此为你推荐训练计划,让你一试身手。",
                  style: AppStyle.textRegular14,
                ),
              ),
            SizedBox(
              height: 42,
            ),
            _heightAndWeightItem("身高", "CM", width),
            SizedBox(
              height: 42,
            ),
            _heightAndWeightItem("体重", "KG", width),
            SizedBox(
              height: 62,
            ),
            Container(
              width: width,
              padding: EdgeInsets.only(left: 41, right: 41),
              child: ClickLineBtn(
                title: "下一步",
                height: 44.0,
                width: width,
                circular: 3.0,
                textColor: AppColor.white,
                fontSize: 16,
                backColor: AppColor.bgBlack,
                color: AppColor.transparent,
                onTap: () {
                  FocusScope.of(context).requestFocus(blankNode);
                  if(heights.bitLength<2||weight.bitLength<2){
                    ToastShow.show(msg: "请输入正确的身高体重", context: context);
                  }else{
                    print('=height=======$heights===weight==========$weight');
                    Application.fitnessEntryModel.height = heights;
                    Application.fitnessEntryModel.weight = weight;
                    if(Application.videoTagModel!=null){
                      if(Application.videoTagModel.bodyType!=null){
                        AppRouter.navigateToBodyTypePage(context);
                      }else if(Application.videoTagModel.target!=null){
                        AppRouter.navigateToFitnessTargetPage(context);
                      }else if(Application.videoTagModel.level!=null){
                        AppRouter.navigateToFitnessLevelPage(context);
                      }else if(Application.videoTagModel.part!=null){
                        AppRouter.navigateToFitnessPartPage(context);
                      }else{
                        AppRouter.navigateToTrainSeveralPage(context);
                      }
                    }else{
                      AppRouter.navigateToTrainSeveralPage(context);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _heightAndWeightItem(String title, String unit, double width) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Spacer(),
          Container(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppStyle.textMedium18,
                ),
                Container(
                  height: 44,
                  child: TextField(
                    style: AppStyle.blackBold21,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    cursorColor: AppColor.black,
                    decoration: InputDecoration(
                        enabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.bgWhite)),
                        focusedBorder:
                            UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.bgWhite))),
                    inputFormatters: [PrecisionLimitFormatter(2)],
                    onChanged: (value) {
                      if (title == "身高") {
                        setState(() {
                          heights = int.parse(value);
                        });
                      } else {
                        setState(() {
                          weight = int.parse(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.bottomLeft,
            child: Text(
              unit,
              style: AppStyle.textHintRegular16,
            ),
          )),
        ],
      ),
    );
  }
}
