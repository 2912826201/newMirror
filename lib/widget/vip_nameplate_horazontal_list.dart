

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/triangle_path.dart';

class VipNamePlateHorazontalList extends StatefulWidget{
  int index;
  VipNamePlateHorazontalList({this.index});
  @override
  State<StatefulWidget> createState() {
    return _vipNamePlateState();
  }

}
class _vipNamePlateState extends State<VipNamePlateHorazontalList>{
  double itemWidth = 38;
  int oldIndex;
  ScrollController controller;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.index<4){
        controller  = ScrollController();
    }else{
      double offset = 93.5*widget.index;
      controller  = ScrollController(initialScrollOffset: offset);
    }
    oldIndex = widget.index;
  }
  @override
  Widget build(BuildContext context) {
   return Container(
     height: 88,
     width: ScreenUtil.instance.screenWidthDp,
     child: ListView.builder(
       controller: controller,
       itemCount: itemName.length,
       scrollDirection: Axis.horizontal,
       itemBuilder:(context,index){
           return _item(index);
       }
       ),
   );
  }
  Widget _item(int index){
    return InkWell(
      onTap: (){
        if(oldIndex!=index){
          setState(() {
            oldIndex = index;
          });
        }else{
          setState(() {
            oldIndex = 100;
          });
        }
      },
      child:Container(
      width: 93,
      height: 88,

      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            oldIndex==index?Container(height: 0,):Spacer(),
            ClipOval(
              child: Container(
                height:oldIndex==index?49:38,
                width: oldIndex==index?49:38,
                color: AppColor.bgVip1,
              )
            ),
            SizedBox(height: 10,),
            Text(itemName[index],style:oldIndex==index?AppStyle.textMediumRed13:AppStyle.textRegularRed13,),
           Opacity(
             opacity:oldIndex==index?1:0,
             child: ClipPath(
                clipper: TrianglePath(),
                child: Container(
                  height: 6,
                  width: 13,
                  color: AppColor.white,
                ),
              ),),
            Spacer(),
          ],
        ),
    ),);

  }
}