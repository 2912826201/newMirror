import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

class EditInformationIntroduction extends StatefulWidget{
  final String introduction;
  EditInformationIntroduction({this.introduction});
  @override
  _IntroductionState createState() {
   return _IntroductionState();
  }

}
class _IntroductionState extends State<EditInformationIntroduction>{
  //同步的输入框和上个界面带过来的简介
  String editText;
  //底部的提示int
  int textLength = 0;
  double textHeight;
  @override
  void initState() {
    super.initState();
    //先同步简介
    if(widget.introduction==null||widget.introduction=="去编辑"){
      editText = "";
    }else{
      editText = widget.introduction;
      textLength = widget.introduction.length;
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
          return Scaffold(
            appBar: AppBar(
            backgroundColor: AppColor.white,
            leading:InkWell(
              child: Container(
                margin: EdgeInsets.only(left: 16),
                child: Image.asset("images/resource/2.0x/return2x.png"),),
              onTap: (){
                Navigator.pop(context);
              },
            ),
              leadingWidth: 44,
            title: Text("编辑简介",style: AppStyle.textMedium18,),
            centerTitle: true,
            actions: [
              InkWell(
                onTap: (){
                  Navigator.pop(this.context,editText);
                },
                child: Container(
                width: 60,
                margin: EdgeInsets.only(right: 16),
                child: Center(
                  child:Container(
                    decoration: BoxDecoration(
                      color: AppColor.mainRed,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    padding: EdgeInsets.only(left:16 ,right:16 ,top: 4,bottom:4 ),
                    child: Text(
                      "确定",
                      style: TextStyle(fontSize: 14, color: AppColor.white),
                    ),)
                ),
              )),
              ]
            ),
      body: Container(
        color: AppColor.white,
        height: height - ScreenUtil.instance.statusBarHeight,
        width: width,
        child: Column(
          children: [
            Container(
              width: width,
              height: 0.5,
              color: AppColor.bgWhite.withOpacity(0.65),
            ),
            SizedBox(
              height: 21,
            ),
            _inputBox(width, height),
          ],
        ),
      ),
    );
  }

  //输入框
  Widget _inputBox(double width,double height){
    return Container(
      height: 148,
      width: width,
      margin: EdgeInsets.only(left: 16,right: 16),
      padding: EdgeInsets.only(left: 16,right: 16,top: 8),
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
            //初始化值，设置光标始终在最后
            controller: TextEditingController.fromValue(TextEditingValue(
              text: editText,
              selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream,
                offset: editText.length))
            )),
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
}