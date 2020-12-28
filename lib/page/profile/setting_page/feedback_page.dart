


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';

///意见反馈
class FeedBackPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _feedBackPage();
  }

}
class _feedBackPage extends State<FeedBackPage>{
  String editText;
  List<Uint8List> imageDataList = [];
  List<File> fileList = [];
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.height;
    double height = ScreenUtil.instance.screenWidthDp;
      return Scaffold(
        backgroundColor: AppColor.white,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            title: Text("意见反馈",style: AppStyle.textMedium18,),
            centerTitle: true,
            leading:InkWell(
              onTap: (){
                Navigator.pop(this.context);
              },
              child: Image.asset("images/test/back.png"),
            ),
            actions: [
              Container(
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
                      "提交",
                      style: TextStyle(fontSize: 14, color: AppColor.white),
                    ),)
                ),
              )
            ],
          ),
        body: Container(
          height:height,
          width: width,
          padding: EdgeInsets.only(left: 16,right: 16),
          child: Column(
            children: [
              Container(
                height: 48,
                width: width,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child:  Text("你的意见和建议,是对我们最大的支持",style: AppStyle.textRegular16,),
                ),
              ),
              _inputBox(width),
              _imageList(width) ,

            ],
          ),
        ),
      );
  }
  ///输入框
Widget _inputBox(double width){
    return Container(
      height: 148,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16,top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(width: 0.5, color: AppColor.frame)),
      child: Column(
        children: [
          TextField(
            cursorColor:AppColor.black,
            style: AppStyle.textRegular16,
            decoration: InputDecoration(
              counterText: '',
              hintText: "请告诉我们您的宝贵意见,我们会认真对待~",
              hintStyle:TextStyle(fontSize: 16,color: AppColor.textHint),
              border: InputBorder.none,),
            onChanged: (value){
              setState(() {
                editText = value;
              });
            },
          ),
        ],
      ),
    );
}

Widget _imageList(double width){
    return Container(
      height: 95,
      width: width,
      child: ListView.builder(
        itemCount:imageDataList!=null?imageDataList.length+1:1,
        scrollDirection:Axis.horizontal,
        itemBuilder:(context,index){
                if(imageDataList!=null){
                  if(index==imageDataList.length){
                    return _addImageItem();
                  }else{
                    return _item(index);
                  }
                }else{
                  return _addImageItem();
                }

        } ),
    );
}

Widget _item(int index){
  return Container(
    height: 90,
    width: 90,
    child: Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.memory(
             imageDataList[index],
             width: 86,
             height: 86,
           )),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: (){
              imageDataList.removeAt(index);
              setState(() {
              });
            },
            child: Container(
            height: 16,
            width: 16,
            child: Icon(Icons.cancel),),
          ))
      ],
    ),
  );
}

Widget _addImageItem(){
    return imageDataList.length<9?InkWell(
      onTap: (){
        _getImage();
      },
      child:Container(
      height: 86,
      width: 86,
      child: Image.asset(
        "images/test/爱心.png"
      ),
    ) ,):Container();
}

  _getImage(){
    AppRouter.navigateToMediaPickerPage(
      context, 9, typeImage, true, startPageGallery, true, false, (result) {
      SelectedMediaFiles files = Application.selectedMediaFiles;
      if (result != true || files == null) {
        print('===============================值为空退回');
        return;
      }
      Application.selectedMediaFiles = null;
      List<MediaFileModel> model = files.list;
          model.forEach((element) async{
      if (element != null) {
        print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        ByteData byteData = await element.croppedImage.toByteData(format: ui.ImageByteFormat.png);
        print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        Uint8List picBytes = byteData.buffer.asUint8List();
        print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
        element.croppedImageData = picBytes;
      }
      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
      int i = 0;
      i++;
      if (element.croppedImageData != null) {
        print('==================================model.croppedImageData!=null');
        File imageFile = await FileUtil().writeImageDataToFile(element.croppedImageData, timeStr+i.toString());
        print('imageFile==============================$imageFile');
        fileList.add(imageFile);
        print('===============================${fileList.length}');
      }
      print('=====================================${element.croppedImageData}');
      setState(() {
        imageDataList.add(element.croppedImageData);
        });

    });
    });
  }
}