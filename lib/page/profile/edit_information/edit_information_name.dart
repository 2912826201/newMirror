

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

///编辑昵称
class EditInformationName extends StatefulWidget{
  String userName;
  EditInformationName({this.userName});
  @override
  State<StatefulWidget> createState() {
   return _editInformationNameState();
  }

}
class _editInformationNameState extends State<EditInformationName>{
  int textLength = 0;
  String _EditText = "";
  int _reciprocal = 15;
  int nowLength = 0;

  @override
  void initState() {
    super.initState();
    if(widget.userName!=null){
      _EditText = widget.userName;
      textLength = widget.userName.length;
      _reciprocal+= nowLength - textLength;
      nowLength = textLength;
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
          backgroundColor: AppColor.white,
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
            title: Text("编辑昵称",style: AppStyle.textMedium18,),
            centerTitle: true,
            actions: [
              InkWell(
                onTap: (){
                  Navigator.pop(this.context,_EditText);
                },
                child:Container(
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
              ),
              )
            ],
          ),
          body: Container(
            height: height - ScreenUtil.instance.statusBarHeight,
            width: width,
            child: Column(
              children: [
                Container(
                  width: width,
                  height: 0.5,
                  color: AppColor.bgWhite.withOpacity(0.65),
                ),
                  SizedBox(height: 17,),
                  Container(
                    width: width,
                    margin: EdgeInsets.only(top: 29),
                    child: _inputWidget(width)
                  ),
                Container(
                  margin: EdgeInsets.only(left: 16,right: 16),
                  width: width,
                  height: 0.5,
                  color: AppColor.bgWhite.withOpacity(0.65),
                ),
                  SizedBox(height: 12,),
                  _bottomText(width)
              ],
            ),
          ),
        );
  }

  Widget _bottomText(double width){
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          Text("0-15个字符，起个好听的名字吧~",style: AppStyle.textPrimary3Regular14,),
          Expanded(child: Container()),
          Text("$_reciprocal",style: AppStyle.textPrimary3Regular14,)
        ],
      ),
    );
  }
  Widget _inputWidget(double width){
    var putFiled = TextField(
      maxLength: 15,
      controller: TextEditingController.fromValue(TextEditingValue(
        text: _EditText,
        selection: TextSelection.fromPosition(TextPosition(
        affinity: TextAffinity.downstream,
        offset: _EditText.length))
      )),
      cursorColor:AppColor.black,
      style: AppStyle.textRegular16,
      decoration: InputDecoration(
        counterText: '',
        hintText: "戳这里输入昵称",
        hintStyle:TextStyle(fontSize: 16,color: AppColor.textHint),
        border: InputBorder.none,),
        onChanged: (value){

        setState(() {
          _EditText = value;
          textLength = value.length;
          _reciprocal+= nowLength - textLength;
          nowLength = textLength;
        });

      },
    );
    return Container(
     padding: EdgeInsets.only(left: 16,right: 16),
      child: putFiled
    );
  }

}