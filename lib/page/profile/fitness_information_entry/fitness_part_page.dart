import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:toast/toast.dart';

class FitnessPartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FitnessPartState();
  }
}

class _FitnessPartState extends State<FitnessPartPage> {
  List<int> choselist = [];
  List<SubTagModel> partList = [];

  @override
  void initState() {
    super.initState();
    List<SubTagModel> list = Application.videoTagModel.part;
    partList = list;
    //根据id排序
    partList.sort((a, b) => a.id.compareTo(b.id));
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
        padding: EdgeInsets.only(left: 31,right: 31),
        width: width,
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "有重要想要训练的部位吗？",
                    style: AppStyle.textMedium23,
                  ),
                ),
            SizedBox(
              height: 12,
            ),
             Container(
               width: width,
                alignment: Alignment.bottomLeft,
                child: Text(
                  "可选全身或1-2个重点部位",
                  style: AppStyle.textRegular14,
                ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Container(
              height: 260,
              width: width,
              alignment: Alignment.topCenter,
              child: Wrap(
                runSpacing: 28,
                runAlignment: WrapAlignment.spaceAround,
                direction: Axis.horizontal,
                children: _boxitem(),
              ),
            ),
            Container(
              width: width,
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
                  if (choselist.isEmpty) {
                    Toast.show("请选择想要训练的部位", context);
                  } else {
                    List<int> choseIdList = [];
                    choselist.forEach((element) {
                      choseIdList.add(partList[element].id);
                    });
                    print('----------------choseIdList------------${choseIdList}');
                    Application.fitnessEntryModel.keyParts = choseIdList;
                    /*  context.read<FitnessInformationNotifier>().setKeyPartList(choselist);*/
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

  List<Widget> _boxitem() => List.generate(partList.length, (index) {
        return Container(
          width: (ScreenUtil.instance.screenWidthDp - 62) / 3,
          alignment: Alignment.centerLeft,
          child:  ClickLineBtn(
                title: partList[index].name,
                height: 44.0,
                width: 88,
                circular: 3.0,
                textColor: choselist.indexOf(index) != -1 ? AppColor.white : AppColor.textHint,
                fontSize: 16,
                backColor: choselist.indexOf(index) != -1 ? AppColor.bgBlack : AppColor.transparent,
                color: choselist.indexOf(index) != -1 ? AppColor.transparent : AppColor.textHint,
                onTap: () {
                  if (partList[index].name=="全身") {
                    setState(() {
                      if (choselist.indexOf(0) != -1) {
                        choselist.remove(choselist.indexOf(0));
                      } else {
                        if (choselist.isNotEmpty) {
                          choselist.clear();
                        }
                        choselist.add(0);
                      }
                      print('${choselist.length}');
                    });
                  } else {
                    _changeListData(index);
                  }
                }),
        );
      });

  _changeListData(int type) {
    setState(() {
      if (choselist.indexOf(type) != -1) {
        choselist.remove(type);
      } else {
        if (choselist.length < 2) {
          if (choselist.indexOf(0) != -1) {
            choselist.clear();
          }
          choselist.add(type);
        } else {
          choselist.remove(choselist.first);
          choselist.add(type);
          Toast.show("只能选择两个重点部位", context);
        }
      }
      print('${choselist.length}');
    });
  }
}
