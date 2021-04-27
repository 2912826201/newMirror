import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';

class BodyTypePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyTypeState();
  }
}

class _BodyTypeState extends State<BodyTypePage> {
  List<SubTagModel> bodyTypeList;
  SubTagModel choseType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bodyTypeList = Application.videoTagModel.bodyType;
    bodyTypeList.sort((a, b) => a.id.compareTo(b.id));
    choseType = bodyTypeList.first;
  }

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
        height: height,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 42,
            ),
            Container(
                width: ScreenUtil.instance.screenWidthDp,
                padding: EdgeInsets.only(left: 41),
                child: Text(
              "你现在的体型是？",
              style: AppStyle.textMedium23,
            ),),
            SizedBox(
              height: 12,
            ),
        Container(
          width: ScreenUtil.instance.screenWidthDp,
          padding: EdgeInsets.only(left: 41),
          child:Text(
              "我们将以此为你推荐训练计划,让你一试身手。",
              style: AppStyle.textRegular14,
            )),
            SizedBox(
              height: 42,
            ),
            _ImageSwiper(height, width),
            SizedBox(
              height: 12,
            ),
            Center(
              child: Text(
                "${choseType.name}",
                style: AppStyle.textRegular16,
              ),
            ),
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
                  Application.fitnessEntryModel.bodyType = choseType.id;
                  if (Application.videoTagModel != null) {
                    if (Application.videoTagModel.target != null) {
                      AppRouter.navigateToFitnessTargetPage(context);
                    } else if (Application.videoTagModel.level != null) {
                      AppRouter.navigateToFitnessLevelPage(context);
                    } else if (Application.videoTagModel.part != null) {
                      AppRouter.navigateToFitnessPartPage(context);
                    } else {
                      AppRouter.navigateToTrainSeveralPage(context);
                    }
                  } else {
                    AppRouter.navigateToTrainSeveralPage(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ImageSwiper(double height, double width) {
    return Container(
      height: 284,
      width: width,
      child: Swiper(
          viewportFraction: 0.4,
          scale: 0.7,
          itemCount: bodyTypeList.length,
          onIndexChanged: (index) {
            setState(() {
              choseType = bodyTypeList[index];
            });
          },
          itemBuilder: (context, index) {
            return Container(
              color: AppColor.black,
              height: 284,
              width: 160,
              padding: EdgeInsets.only(left: 16.5, right: 16.5, top: 35, bottom: 35),
              child: Image.asset(
                "images/test/bg.png",
                fit: BoxFit.cover,
              ),
            );
          }),
    );
  }
}
