
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/vip/vip_nameplate_page.dart';
import 'package:mirror/util/screen_util.dart';

class VipGridList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _vipGridState();
  }

}

class _vipGridState extends State<VipGridList>{

  final List<String> itemName = [
    "身份铭牌",
    "定制计划",
    "饮食指导",
    "专属指导",
    "AI智能纠正",
    "无限次训练",
    "在线互动",
    "视频通话",
    "训练统计",
    "群内答疑",
  ];
  @override
  Widget build(BuildContext context) {
      return Wrap(
        runAlignment: WrapAlignment.spaceAround,
        direction: Axis.horizontal,
        children: _boxitem(),
      );
  }
  List<Widget> _boxitem()=> List.generate(itemName.length, (index){
    return InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return VipNamePlatePage(index: index,);
          }));
        },
      child: Container(
      width: ScreenUtil.instance.screenWidthDp/4,
      height: ScreenUtil.instance.screenWidthDp/4,
      child: Center(
        child: Column(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color:AppColor.bgVip1,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            SizedBox(height: 10,),
            Text(itemName[index],style: AppStyle.textRegular13,),
          ],
        ),
      ),
    ),);
  });
}