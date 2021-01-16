

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/vip/pay_bottom_dialog.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';

class VipHorizontalList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
      return _vipHorizontalListState();
  }

}
class _vipHorizontalListState extends State<VipHorizontalList>{
  Color itemBackGround = AppColor.white;
  String titleText = "首月优惠dwwdww";
  double titleWidth;
  int oldIndex;
  @override
  void initState() {
    super.initState();
    TextPainter testSize = calculateTextWidth(titleText, AppStyle.textRegularRed11, 96, 1);
    titleWidth = testSize.width;
  }
  @override
  Widget build(BuildContext context) {
     return Container(
       height: 125.5,
     width: ScreenUtil.instance.screenWidthDp,
     child:ListView.builder(
        scrollDirection: Axis.horizontal,
       itemCount: 6,
       itemBuilder:(context,index){
            return Row(
              children: [
                InkWell(
                  onTap: (){
                    if(oldIndex==index){
                      setState(() {
                        oldIndex=100;
                      });
                    }else{
                      setState(() {
                        oldIndex = index;
                      });
                    }
                    PayBottomSheet(
                      context: context,
                      title: "连续包月",
                      payNumber:199);

                  },
                  child: item(index),),
                SizedBox(width: 9,)
              ],
            );
       } ));
  }

  Widget item(int index){
    return Container(
      height:125.5,
      width: 103,
      child: Stack(
      children: [
        Positioned(
          bottom: 0,
          child:Container(
            height: 117,
            width: 103,
            decoration: BoxDecoration(
              color: index==oldIndex?AppColor.bgWhite:AppColor.transparent,
              border: Border.all(width: index==oldIndex?1:0.5, color: index==oldIndex?AppColor.bgVip2:AppColor.textPrimary3),
              borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(
                child: _itemText(),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child:Container(
            height: 16,
            width: titleWidth+4,
            padding: EdgeInsets.only(left: 2,right: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:[AppColor.lightGreen,AppColor.textVipPrimary1],
                begin: FractionalOffset(0.6,0), end: FractionalOffset(1, 0.6)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight:Radius.circular(0),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(6) ),),
            child: Center(
              child: Text(titleText,style: AppStyle.textRegularRed11,),
            ),
          )
        )
      ])
    );
  }
Widget _itemText(){
    return  Column(
            children: [
              Expanded(child: SizedBox()),
              Text("连续包月",style: AppStyle.textMedium14,),
              SizedBox(height: 2,),
              RichText(
                text: TextSpan(
                  text: "￥",
                  style: AppStyle.textRegularRed13,
                  children: <TextSpan>[
                      TextSpan(text: "124.44",style: AppStyle.textRedMedium21)
                  ]
                ),
              ),
              Text("￥112",style: AppStyle.textDeleteHintRegular12,),
              Expanded(child: SizedBox()),
            ],
          );

}
}