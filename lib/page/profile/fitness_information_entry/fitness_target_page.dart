import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/page/profile/fitness_information_entry/fitness_level_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/train_several_times.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
class FitnessTargetPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _FitnessTargetState();
  }

}
class _FitnessTargetState extends State<FitnessTargetPage>{
  List<SubTagModel> targetList = [];
  int beforIndex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    targetList = Application.videoTagModel.target;
    targetList.sort((a, b) => a.id.compareTo(b.id));
    targetList.forEach((element) {
      print('target Id============================${element.id}');
      print('target name============================${element.name}');
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
        child:Column(
          children: [
            SizedBox(
              height: height*0.05,
            ),
            Center(
              child: Container(
                width: width * 0.78,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "你的目标是？",
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
                width: width * 0.78,
                alignment: Alignment.centerLeft,
                child:Text(
                "我们将以此为你推荐训练计划,让你一试身手。",
                style: AppStyle.textRegular14,
              ) ,
              ),
            ),
            SizedBox(height: height*0.05,),
            Expanded(
              child:ListView.builder(
                itemCount: targetList.length,
                itemBuilder:(context,index){
                  return _choseItem(targetList[index].id,targetList[index].name,"体脂偏高，像快熟减掉赘肉，击退小肚腩",index );
                } )

            ),
          ],
        ),
      ),
    );
  }

  Widget _choseItem(int order,String title,String introduction,int index){
    return InkWell(
        onTap: (){
         setState(() {
           beforIndex=index;
           context.read<FitnessInformationNotifier>().setTarget(targetList[index].id-1);
           Navigator.of(context).push(MaterialPageRoute(builder: (context) {
             return FitnessLevelPage();
           }));
         });
        },
      child: Container(
      height: 78,
      color: beforIndex==index?AppColor.bgWhite:AppColor.white,
      margin: EdgeInsets.only(left:ScreenUtil.instance.screenWidthDp*0.10,right: ScreenUtil.instance.screenWidthDp*0.10),
      padding: EdgeInsets.only(left: 7,right: 7),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Container(
         margin: EdgeInsets.only(top: 12),
         child: Text("$order",style:beforIndex==index?AppStyle.textMedium29:AppStyle.textPrimary3Medium29,),) ,
          SizedBox(width: ScreenUtil.instance.screenWidthDp*0.78*0.04,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Expanded(child: SizedBox()),
                Text(title,style:beforIndex==index?AppStyle.textMedium21:AppStyle.textPrimary3Medium21,),
                SizedBox(height: 8,),
                Text(introduction,style:AppStyle.textSecondaryRegular12,maxLines: 1,overflow: TextOverflow.ellipsis,),
                Expanded(child: SizedBox()),
            ],
          ),
          Expanded(child: Container()),
          Center(
              child: Icon(Icons.arrow_forward_ios),
            ),
      ],
    ),),);

  }
}