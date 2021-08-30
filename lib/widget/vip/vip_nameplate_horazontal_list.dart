

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/vip/vip_nameplate_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/Clip_util.dart';
import 'package:provider/provider.dart';

import '../overscroll_behavior.dart';

double namePlateWidth = 93.5;
class VipNamePlateHorazontalList extends StatefulWidget{
  int index;
  ScrollController scrollController;
  PageController pageController;
  VipNamePlateHorazontalList({this.index,this.scrollController,this.pageController});
  @override
  State<StatefulWidget> createState() {
    return _VipNamePlateState();
  }

}

class _VipNamePlateState extends State<VipNamePlateHorazontalList>{
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
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print('========================build');
    return Container(
     height: 88,
     width: ScreenUtil.instance.screenWidthDp,
     child: ScrollConfiguration(
     behavior: OverScrollBehavior(),
    child: ListView.builder(
       controller: widget.scrollController,
       itemCount: itemName.length,
       scrollDirection: Axis.horizontal,
       itemBuilder:(context,index){
           return InkWell(
             onTap: (){
               if(index!=context.read<VipMoveNotifier>().choseIndex){
                 context.read<VipMoveNotifier>().changeListOldIndex(index);
                 widget.pageController.jumpToPage(index);
               }
             },
             child:Container(
               width: namePlateWidth,
               height: 88,

               child: Center(
                 child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                  Spacer(),
                   ClipOval(
                     child: Container(
                       height:context.watch<VipMoveNotifier>().choseIndex==index?49:38,
                       width: context.watch<VipMoveNotifier>().choseIndex==index?49:38,
                       color: AppColor.bgVip1,
                     )
                   ),
                   Spacer(),
                   Text(itemName[index],style:context.watch<VipMoveNotifier>().choseIndex==index?AppStyle.redMedium13:AppStyle.redRegular13,),
                   SizedBox(height: 2,),
                   Opacity(
                     opacity:context.watch<VipMoveNotifier>().choseIndex==index?1:0,
                     child: CustomPaint(
                         size: Size(13,7),
                         painter: TrianglePath(false,AppColor.white),
                       ),),

                 ],
               ),),
             ),);
       }
       )),
   );
  }
}