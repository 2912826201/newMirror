

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/page/profile/fitness_information_entry/fitness_part_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/train_several_times.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
class FitnessLevelPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _fitnessLevelState();
  }

}
class _fitnessLevelState extends State<FitnessLevelPage>{
  List<SubTagModel> levelList;
  int beforIndex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    levelList = Application.videoTagModel.level;
    levelList.forEach((element) {
      print('levelListId==========================${element.id}');
    });
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
      return Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          leading: InkWell(
            child: Container(
              margin: EdgeInsets.only(left: 16),
              child: Image.asset("images/resource/2.0x/return2x.png"),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          width: width,
          height: height,
          padding: EdgeInsets.only(left:ScreenUtil.instance.screenWidthDp*0.11,right: ScreenUtil.instance.screenWidthDp*0.11),
          child: Column(
            children: [
              SizedBox(
                height: height*0.05,
              ),
              Container(
                width: width,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "选择适合你的难度",
                      style: AppStyle.textBlackMedium23,
                    ),
                  ),
              SizedBox(
                height: 12,
              ),
              Container(
                  width: width,
                  alignment: Alignment.centerLeft,
                  child:Text(
                    "我们将以此为你推荐训练计划,让你一试身手。",
                    style: AppStyle.textRegular14,
                  ) ,
                ),
              SizedBox(height: height*0.05,),
              Expanded(
                child:ListView.builder(
                itemCount: levelList.length,
                itemBuilder: (context,index){
                    return _levelItem(levelList[index].ename,levelList[index].name,"从零开始，通过适应性训练，为塑造肌肉线条打好基础",index);
                },
              ) ),
            ],
          ),
        ),
      );
  }
    Widget _levelItem(String level,String leveltext,String introduction,int index){
          return InkWell(
            onTap: (){
                setState(() {
                  beforIndex = index;
                });
              context.read<FitnessInformationNotifier>().setHard(index);
              print('index===============================$index');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FitnesspartPage();
              }));
            },
            child: Container(
            height: 95,
            color: beforIndex==index?AppColor.bgWhite:AppColor.white,
            padding: EdgeInsets.only(left: 7,right: 7),
            child: Row(
              children: [
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Text(level,style:beforIndex!=index?AppStyle.textPrimary3Medium23:AppStyle.textBlackMedium23,),
                            SizedBox(width: 7.5,),
                            Text(leveltext,style:beforIndex!=index?AppStyle.textPrimary3Medium16:AppStyle.textMedium16,)
                        ],
                        ),
                        SizedBox(height: 11,),
                        Container(
                          width:ScreenUtil.instance.screenWidthDp*0.78*0.73,
                          child: Text(introduction,style: AppStyle.textHintRegular12,maxLines: 2,overflow: TextOverflow.clip,),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                Expanded(child: Container()),
                Center(
                  child: Icon(Icons.arrow_forward_ios),
                )
              ],
            ),
          ),);
    }
}