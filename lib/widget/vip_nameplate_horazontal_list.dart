

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/vip/vip_nameplate_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/triangle_path.dart';
import 'package:provider/provider.dart';

class VipNamePlateHorazontalList extends StatefulWidget{
  int index;
  ScrollController scrollController;
  PageController pageController;
  VipNamePlateHorazontalList({this.index,this.scrollController,this.pageController});
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
  }
  @override
  Widget build(BuildContext context) {
    print('========================build');
    return Container(
     height: 88,
     width: ScreenUtil.instance.screenWidthDp,
     child: ListView.builder(
       controller: widget.scrollController,
       itemCount: itemName.length,
       scrollDirection: Axis.horizontal,
       itemBuilder:(context,index){
           return InkWell(
             onTap: (){
               if(index!=context.read<VipMoveNotifier>().choseIndex){
                 context.read<VipMoveNotifier>().changeListOldIndex(index);
                 widget.pageController.jumpToPage(context.read<VipMoveNotifier>().choseIndex);
               }
             },
             child:Container(
               width: 93,
               height: 88,

               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                  context.watch<VipMoveNotifier>().choseIndex==index?Container(height: 0,):Spacer(),
                   ClipOval(
                     child: Container(
                       height:context.watch<VipMoveNotifier>().choseIndex==index?49:38,
                       width: context.watch<VipMoveNotifier>().choseIndex==index?49:38,
                       color: AppColor.bgVip1,
                     )
                   ),
                   SizedBox(height: 10,),
                   Text(itemName[index],style:context.watch<VipMoveNotifier>().choseIndex==index?AppStyle.textMediumRed13:AppStyle.textRegularRed13,),
                   Spacer(),
                   Opacity(
                     opacity:context.watch<VipMoveNotifier>().choseIndex==index?1:0,
                     child: ClipPath(
                       clipper: TrianglePath(),
                       child: Container(
                         height: 6,
                         width: 13,
                         color: AppColor.white,
                       ),
                     ),),

                 ],
               ),
             ),);
       }
       ),
   );
  }
}