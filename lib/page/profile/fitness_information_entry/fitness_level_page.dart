import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

class FitnessLevelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FitnessLevelState();
  }
}

class _FitnessLevelState extends State<FitnessLevelPage> {
  List<SubTagModel> levelList;
  int beforIndex;

  @override
  void initState() {
    super.initState();
    levelList = Application.videoTagModel.level;
    levelList.sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      appBar: CustomAppBar(
        hasDivider: false,
      ),
      body: Container(
        width: width,
        height: height,
        padding: EdgeInsets.only(
            left: 41, right: 41),
        child: ListView(
          children: [
            SizedBox(
              height: 42,
            ),
            Container(
              width: width,
              alignment: Alignment.bottomLeft,
              child: Text(
                "选择适合你的难度",
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
              children: List.generate( levelList.length, (index){
                return _levelItem(levelList[index].ename, levelList[index].name, "从零开始，通过适应性训练，为塑造肌肉线条打好基础", index);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelItem(String level, String leveltext, String introduction, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          beforIndex = index;
        });
        Application.fitnessEntryModel.hard = levelList[index].id;
        /*context.read<FitnessInformationNotifier>().setHard(index);*/
        print('index===============================$index');
        if (Application.videoTagModel != null) {
          if (Application.videoTagModel.part != null) {
            AppRouter.navigateToFitnessPartPage(context);
          } else {
            AppRouter.navigateToTrainSeveralPage(context);
          }
        } else {
          AppRouter.navigateToTrainSeveralPage(context);
        }
      },
      child: Container(
        height: 95,
        color: beforIndex == index ? AppColor.white.withOpacity(0.1) : AppColor.transparent,
        padding: EdgeInsets.only(left: 7, right: 7),
        child: Row(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        level,
                        style: beforIndex != index ? AppStyle.text1Medium29 : AppStyle.whiteMedium29,
                      ),
                      SizedBox(
                        width: 7.5,
                      ),
                      Text(
                        leveltext,
                        style: beforIndex != index ? AppStyle.text1Medium21 : AppStyle.whiteMedium21,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  Container(
                    width: ScreenUtil.instance.screenWidthDp-82-12-67,
                    child: Text(
                      introduction,
                      style: AppStyle.text2Regular12,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  Spacer(),
                ],
              ),
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
            )
          ],
        ),
      ),
    );
  }
}
