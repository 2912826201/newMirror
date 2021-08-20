import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

class FitnessTargetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FitnessTargetState();
  }
}

class _FitnessTargetState extends State<FitnessTargetPage> {
  List<SubTagModel> targetList = [];
  int beforIndex;
  double width = ScreenUtil.instance.screenWidthDp;
  double height = ScreenUtil.instance.height;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    targetList = Application.videoTagModel.target;
    targetList.sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      appBar: CustomAppBar(
        hasDivider: false,
      ),
      body: Container(
        width: width,
        height: height,
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
                    "你的目标是？",
                    style: AppStyle.whiteMedium23,
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
                  style: AppStyle.text1Regular14,
                ),
              ),
            SizedBox(
              height: 42,
            ),
            Column(
              children: List.generate(targetList.length, (index){
                  return _choseItem(targetList[index].id, targetList[index].name, "体脂偏高，像快速减掉赘肉，击退小肚腩", index);
              }),)
          ],
        ),
      ),
    );
  }

  Widget _choseItem(int order, String title, String introduction, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          beforIndex = index;
          Application.fitnessEntryModel.target = targetList[index].id - 1;
          if (Application.videoTagModel != null) {
            if (Application.videoTagModel.level != null) {
              AppRouter.navigateToFitnessLevelPage(context);
            } else if (Application.videoTagModel.part != null) {
              AppRouter.navigateToFitnessPartPage(context);
            } else {
              AppRouter.navigateToTrainSeveralPage(context);
            }
          } else {
            AppRouter.navigateToTrainSeveralPage(context);
          }
        });
      },
      child:Container(
        height: 78,
      color: beforIndex == index ? AppColor.white.withOpacity(0.1) : AppColor.transparent,
        width: width,
        padding: EdgeInsets.only(left: 7, right: 7,top: 12,bottom: 12),
        child:Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                "${index + 1}",
                style: beforIndex == index ? AppStyle.whiteMedium29 : AppStyle.text1Medium29,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Text(
                  title,
                  style: beforIndex == index ? AppStyle.whiteMedium21 : AppStyle.text1Medium21,
                ),
                Spacer(),
                Text(
                  introduction,
                  style: AppStyle.text2Regular12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
              ],
            ),
            Spacer(),
            Center(
              child: AppIcon.getAppIcon(
                AppIcon.arrow_right_12,
                12,
                color: AppColor.textWhite40,
                containerWidth: 22,
                containerHeight: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
