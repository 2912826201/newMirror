
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

class EditInformationIntroduction extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _troductionState();
  }

}
class _troductionState extends State<EditInformationIntroduction>{
  String editText = "";
  int textLength = 0;
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
          return Scaffold(
              body: Container(
                color: AppColor.white,
                height: height,
                width: width,
                child: Column(
                  children: [
                    Container(
                      height: 44,
                    ),
                    _title(width),
                    Container(
                      width: width,
                      height: 0.5,
                      color: AppColor.bgWhite_65,
                    ),
                    SizedBox(height: 21,),
                    _inputBox(width),
                  ],
                ),
              ),
            );
  }


  Widget _inputBox(double width){
    return Container(
      height: 148,
      width: width,
      margin: EdgeInsets.only(left: 16,right: 16),
      padding: EdgeInsets.only(left: 16,right: 16,top: 8,bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(width: 0.5, color: AppColor.frame)),
        child: Column(
          children: [
          TextField(
          maxLength: 90,
          maxLines: 5,
          cursorColor:AppColor.black,
          style: AppStyle.textRegular16,
          decoration: InputDecoration(
            counterText: '',
            hintText: "有意思的简介会吸引更多关注~",
            hintStyle:TextStyle(fontSize: 16,color: AppColor.textHint),
            border: InputBorder.none,),
          onChanged: (value){
            setState(() {
              textLength = value.length;
              editText = value;
            });
          },
        ),
            Container(
              alignment: Alignment.bottomRight,
              child: Text("$textLength/90",style: AppStyle.textHintRegular12,),
            )
          ],
        ),
    );
  }
  Widget _title(double width){
    return Container(
      height: 44,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(this.context);
            },
            child: Image.asset("images/test/back.png"),
          ),
          Expanded(child: Center(child: Text("编辑简介",style: AppStyle.textMedium18,),),),
          InkWell(
            onTap: (){

            },
            child: Container(
              height: 28,
              width: 60,
              child: Center(child: Text("确定",style: TextStyle(fontSize: 14,color:AppColor.white),),),
              decoration: BoxDecoration(
                color: editText.isEmpty?AppColor.textHint:AppColor.mainRed,
                borderRadius: BorderRadius.all(Radius.circular(60)),
                border: Border.all(width: 1, color: AppColor.black))),)
        ],
      ),
    );
  }
}