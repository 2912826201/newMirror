

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:toast/toast.dart';

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
  String _EditText;
  int _reciprocal = 15;
  int beforeLength = 0;
  FocusNode blankNode = FocusNode();
  @override
  void initState() {
    super.initState();
    if(widget.userName!=null){
      _EditText = widget.userName;
      textLength = widget.userName.length;
      _reciprocal += beforeLength - textLength;
      beforeLength = textLength;
      widget.userName = null;
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
                FocusScope.of(context).requestFocus(blankNode);
                Navigator.pop(context);
              },
            ),
            leadingWidth: 44,
            title: Text("编辑昵称",style: AppStyle.textMedium18,),
            centerTitle: true,
            actions: [
              InkWell(
                onTap: (){
                  if(_EditText.isEmpty){
                    Toast.show("昵称不能为空", context);
                    return;
                  }
                  FocusScope.of(context).requestFocus(blankNode);
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
  //底部提示字数文字
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
          _reciprocal += beforeLength - textLength;
          beforeLength = textLength;
        });

      },
    );
    return Container(
     padding: EdgeInsets.only(left: 16,right: 16),
      child: putFiled
    );
  }

}