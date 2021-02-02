

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/fitness_information_entry/body_type_page.dart';
import 'package:mirror/page/profile/fitness_information_entry/train_several_times.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:provider/provider.dart';
class HeightAndWeightPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HeightAndWeightState();
  }

}
class _HeightAndWeightState extends State<HeightAndWeightPage>{
    int weight;
    int heights;
    FocusNode blankNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: InkWell(
          child: Container(
            margin: EdgeInsets.only(left: 16),
            child: Image.asset("images/resource/2.0x/return2x.png"),),
          onTap: (){
            FocusScope.of(context).requestFocus(blankNode);
            Navigator.pop(context);
          },
        ),
      ),
        body: Container(
          height: height,
          width: width,
          child: ListView(
            children: [
              SizedBox(height: height*0.05,),
              Center(
                child: Container(
                width: width*0.78,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                  "你的身高体重是"
                    ,style: AppStyle.textMedium23,
                ),),
              ),),
              SizedBox(height: 12,),
              Center(
                child: Container(
                  width: width*0.78,
                  alignment: Alignment.centerLeft,
                  child: Text(
                  "我们将以此为你推荐训练计划,让你一试身手。",
                  style: AppStyle.textRegular14,
                ),
                ),
              ),
              SizedBox(height: height*0.05,),
              _heightAndWeightItem("身高","CM",width),
              SizedBox(height: height*0.05,),
              _heightAndWeightItem("体重","KG",width),
              SizedBox(height: height*0.07,),
              Container(
                width: width,
                padding: EdgeInsets.only(left: 41,right: 41),
                child: ClickLineBtn(
                title: "下一步",
                height: 44.0,
                width: width,
                circular:3.0,
                textColor: AppColor.white,
                fontSize: 16,
                backColor: AppColor.bgBlack,
                color: AppColor.transparent,
                onTap: (){
                  FocusScope.of(context).requestFocus(blankNode);
                  print('=height=======$heights===weight==========$weight');
                    context.read<FitnessInformationNotifier>().setHeightAndWeight(heights,weight);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return BodyTypePage();
                    }));

                },
              ),),
            ],
          ),
        ),
    );
  }

  _heightAndWeightItem(String title,String unit,double width){
      return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: SizedBox()),
            Container(
              width: width*0.37,
              child: Column(
            children: [
              Text(
                title,
                style: AppStyle.textMedium18,
              ),
              Container(
                height: 44,
               child: TextField(
                style: AppStyle.blackBold21,
                textAlign: TextAlign.center,
                 keyboardType:TextInputType.phone,
                 cursorColor: AppColor.black,
                 decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide:BorderSide(width: 0.5,color: AppColor.bgWhite)
                  ),
                  focusedBorder:UnderlineInputBorder(
                    borderSide:BorderSide(width: 0.5,color: AppColor.bgWhite)
                  )
                 ),
                 inputFormatters: <TextInputFormatter>[
                   FilteringTextInputFormatter(RegExp("[0-9]"), allow: true),
                   LengthLimitingTextInputFormatter(3)//限制长度
                 ],
                 onChanged: (value){
                  if(title=="身高"){
                    setState(() {
                      heights = int.parse(value);
                    });
                  }else{
                    setState(() {
                      weight = int.parse(value);
                    });
                  }
                 },
               ),
              ),
            ],
          ),),
          Expanded(
            child: Container(
              alignment: Alignment.bottomLeft,
            child: Text(
              unit,
              style: AppStyle.textHintRegular16,
            ),
          )),
        ],
      ),);
  }
}