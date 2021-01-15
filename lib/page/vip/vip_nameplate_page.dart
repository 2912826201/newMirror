
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/triangle_path.dart';
import 'package:mirror/widget/vip_nameplate_horazontal_list.dart';
import 'package:provider/provider.dart';
class VipNamePlatePage extends StatefulWidget{
  int index;
  VipNamePlatePage({this.index});
  @override
  State<StatefulWidget> createState() {
   return _vipNamePlateState();
  }

}
class _vipNamePlateState extends State<VipNamePlatePage>{
  ScrollController controller = ScrollController();
  double itemWidth = 38;
  int oldIndex;
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
        return Scaffold(
          body: Container(
          height: ScreenUtil.instance.height,
          width: ScreenUtil.instance.height,
          child: Stack(
            children: [
                  Positioned(
                    child:Container(
                      height:132+ScreenUtil.instance.statusBarHeight,
                      width: ScreenUtil.instance.screenWidthDp,
                      color: AppColor.mainBlue,
                    ) ),
              Positioned(
                top: ScreenUtil.instance.statusBarHeight,
                child: _title()),
              Positioned(
                top: 44+ScreenUtil.instance.statusBarHeight,
                child:VipNamePlateHorazontalList(index: widget.index,)),
                  Positioned(
                    bottom: 0,
                    child: _bottomButton())
            ],
          )
        ),);
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
  Widget _title(){
      return Container(
        height: 44,
        width: ScreenUtil.instance.screenWidthDp,
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  height: 20,
                  width: 20,
                  alignment: Alignment.centerLeft,
                  child: Image.asset("images/resource/2.0x/return2x.png"),
                ),
              ),),
              Expanded(
                flex: 1,
                child: Center(
                    child: Text("会员特权",style: AppStyle.textMedium18,),
                  ),
                ),
              Spacer()
            ],
          )),
      );

  }
  Widget _bottomButton() {
    return Container(
      height: ScreenUtil.instance.bottomBarHeight + 49,
      width: ScreenUtil.instance.screenWidthDp,
      decoration: BoxDecoration(
        boxShadow: [
          //阴影效果
          BoxShadow(
            offset: Offset(0, 0.5),
            color: AppColor.textSecondary,
            blurRadius: 3.0, //阴影程度
            spreadRadius: 0, //阴影扩散的程度 取值可以正数,也可以是负数
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            height: 49,
            child: Center(
              child: Container(
                height: 40,
                width: ScreenUtil.instance.screenWidthDp * 0.91,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.lightGreen, AppColor.textVipPrimary1],
                    begin: FractionalOffset(0.6, 0),
                    end: FractionalOffset(1, 0.6)),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    "立即开通",
                    style: AppStyle.textMediumRed16,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: ScreenUtil.instance.bottomBarHeight,
          )
        ],
      ),
    );
  }

}