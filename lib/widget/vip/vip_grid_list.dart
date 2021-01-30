
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/vip/vip_nameplate_page.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
enum VipType { NOTOPEN, OPEN }

class VipGridList extends StatefulWidget{
  VipType vipType;
  VipState vipState;
  VipGridList({this.vipType,this.vipState});
  @override
  State<StatefulWidget> createState() {
   return _VipGridState();
  }

}

class _VipGridState extends State<VipGridList>{

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
  List<String> contentList = [
    "彰显尊贵身份",
    "量身定制个人专属计划",
    "专属饮食和营养指导",
    "提供练前练后专属建议",
    "科学指导智能纠错",
    "免费训练所有直播，视频课程",
    "专业教练实时针对性指导",
    "和好友一起视频一起练",
    "便捷查看训练结果",
    "群组内在线答疑，让训练更高效",
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
          AppRouter.navigateToVipNamePlatePage(context, index);
        },
      child:widget.vipType==VipType.NOTOPEN?_notOpenItem(index):_openItem(index));
  });

  Widget _notOpenItem(int index){
    return Container(
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
    );
  }
  Widget _openItem(int index){
    return Container(
      width: (ScreenUtil.instance.screenWidthDp-32)/2,
      height:93,
      padding: EdgeInsets.only(left: 12,right: 12,top: 12),
      child: Row(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color:widget.vipState==VipState.EXPIRED?AppColor.textSecondaryRound:AppColor.bgVip1,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          ),),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${itemName[index]}",style:widget.vipState==VipState.EXPIRED
                  ?AppStyle.textSecondaryRegular16
                  :AppStyle.textMedium16,),
              SizedBox(height: 5,),
              Container(
                width: ScreenUtil.instance.screenWidthDp*0.26,
                child: Text("${contentList[index]}",style:widget.vipState==VipState.EXPIRED
               ?AppStyle.textHintRegular14
                :AppStyle.textPrimary3Regular14,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,),
              )
            ],
          )
        ],
      ),
    );
  }
}