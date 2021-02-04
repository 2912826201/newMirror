import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/page/profile/fitness_information_entry/train_several_times.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';

class FitnesspartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FitnessPartState();
  }
}

class _FitnessPartState extends State<FitnesspartPage> {
  List<int> choselist = [];
  List<SubTagModel> partList = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<SubTagModel> list = Application.videoTagModel.part;
    partList = list;
    partList.sort((a, b) => a.id.compareTo(b.id));
    partList.forEach((element) {
      print('partId========================${element.id}');
      print('partName========================${element.name}');
    });
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(),
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            Center(
              child: Container(
                width: width * 0.78,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "有重要想要训练的部位吗？",
                    style: AppStyle.textMedium23,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Center(
              child: Container(
                alignment: Alignment.centerLeft,
              width: width * 0.78,
              child: Text(
                "可选全身或1-2个重点部位",
                style: AppStyle.textRegular14,
              ),),),

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
              padding: EdgeInsets.only(left: 41,right: 41),
              child: ClickLineBtn(
                title: "下一步",
                height: 44.0,
                width: width,
                circular:3.0,
                textColor: AppColor.white,
                fontSize: 16,
                backColor: AppColor.bgBlack,
                color: AppColor.transparent,
                onTap: (){
                  if(choselist.isEmpty){
                    Toast.show("请选择想要训练的部位", context);
                  }else{
                    context.read<FitnessInformationNotifier>().setKeyPartList(choselist);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return TrainSeveralTimes();
                    }));
                  }

                },
              ),),
          ],
        ),
      ),
    );
  }


  List<Widget> _boxitem()=> List.generate(partList.length, (index){
    return Container(
      width: ScreenUtil.instance.screenWidthDp/3,
      child: Center(
        child:ClickLineBtn(
      title: partList[index].name,
      height: 44.0,
      width: 88,
      circular:3.0,
      textColor: choselist.indexOf(partList[index].id-1)!=-1?AppColor.white:AppColor.textHint,
      fontSize: 16,
      backColor: choselist.indexOf(partList[index].id-1)!=-1?AppColor.bgBlack:AppColor.transparent,
      color: choselist.indexOf(partList[index].id-1)!=-1?AppColor.transparent:AppColor.textHint,
      onTap: () {
        if(partList[index].id == 1){
                setState(() {
            if (choselist.indexOf(0)!=-1) {
                    choselist.remove(choselist.indexOf(0));
            } else {
               if(choselist.isNotEmpty){
                      choselist.clear();
              }
              choselist.add(0);
                  }
            print('${choselist.length}');
          });
        }else{
          _changeListData(partList[index].id-1);
        }
      }
    ) ,),
    );
    });
  _changeListData(int type){
    setState(() {
    if (choselist.indexOf(type)!=-1) {
      choselist.remove(type);
    } else {
      if(choselist.length <2){
        if(choselist.indexOf(0)!=-1){
          choselist.clear();
        }
        choselist.add(type);
      }else{
        choselist.remove(choselist.first);
        choselist.add(type);
        Toast.show("只能选择两个重点部位", context);
      }
    }
    print('${choselist.length}');
    });
  }
}
