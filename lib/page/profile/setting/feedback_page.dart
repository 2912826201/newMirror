import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/loading.dart';
import 'package:toast/toast.dart';

///意见反馈
class FeedBackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _feedBackPage();
  }
}

class _feedBackPage extends State<FeedBackPage> {
  String editText;
  List<Uint8List> imageDataList = [];
  List<File> fileList = [];
  double upLoadProgress;

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        titleString: "意见反馈",
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding),
            child: CustomRedButton(
              "提交",
              CustomRedButton.buttonStateNormal,
              () {
                _uploadImage();
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Container(
              height: 48,
              width: width,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "你的意见和建议,是对我们最大的支持",
                  style: AppStyle.textRegular16,
                ),
              ),
            ),
            _inputBox(width),
            _imageList(width),
          ],
        ),
      ),
    );
  }

  ///输入框
  Widget _inputBox(double width) {
    return Container(
      height: 148,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)), border: Border.all(width: 0.5, color: AppColor.bgWhite)),
      child: TextField(
        cursorColor: AppColor.black,
        style: AppStyle.textRegular16,
        maxLines: 10,
        decoration: InputDecoration(
          counterText: '',
          hintText: "请告诉我们您的宝贵意见,我们会认真对待~",
          hintStyle: TextStyle(fontSize: 16, color: AppColor.textHint),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            editText = value;
          });
        },
      ),
    );
  }

Widget _imageList(double width){
    if(imageDataList.length>8){
      imageDataList.removeRange(8,imageDataList.length);
    }
    return Container(
      height: 95,
      width: width,
      child: ListView.separated(
          itemCount: imageDataList != null ? imageDataList.length + 1 : 1,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                width: 10.0,
                color: Color(0xFFFFFFFF),
              ),
          itemBuilder: (context, index) {
            if (imageDataList != null) {
              if (index == imageDataList.length) {
                return _addImageItem();
              } else {
                return _item(index);
              }
            } else {
              return _addImageItem();
            }
          }),
    );
  }

  Widget _item(int index) {
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
              top: 2,
              right: 0,
              child: InkWell(
                onTap: () {
                  imageDataList.removeAt(index);
                  setState(() {});
                },
                child: Container(
                  width: 16,
                  height: 16,
                  decoration:
                      BoxDecoration(color: AppColor.bgBlack, borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Center(
                      child: Icon(
                    Icons.close,
                    color: AppColor.white,
                    size: 12,
                  )),
                ),
              )),
        ],
      ),
    );
  }

Widget _addImageItem(){
    return imageDataList.length<8?InkWell(
      onTap: (){
        _getImage();
      },
      child: Container(
      margin: EdgeInsets.only( top: 9, right: 16),
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: AppColor.bgWhite,
        borderRadius: BorderRadius.all(Radius.circular(3.0)),
      ),
      child: Center(
        child: Icon(Icons.add, color: AppColor.textHint),
      ),
    ),):Container();
}

    //从相册获取照片
  _getImage(){
    AppRouter.navigateToMediaPickerPage(
      context, 8, typeImage, true, startPageGallery, false, (result) {
      SelectedMediaFiles files = Application.selectedMediaFiles;
      if (!result|| files == null) {
        print('===============================值为空退回');
        return;
      }
      Application.selectedMediaFiles = null;
      List<MediaFileModel> model = files.list;
      model.forEach((element) async {
        if (element.croppedImage != null) {
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
          File imageFile = await FileUtil().writeImageDataToFile(element.croppedImageData, timeStr + i.toString());
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

  _uploadImage() async {
    Loading.showLoading(context);
    List<String> list = [];
    if (fileList != null) {
      var result = await FileUtil().uploadPics(fileList, (percent) {
        print('===========================正在上传%%$percent');
      });
      if (result.resultMap.values != null) {
        result.resultMap.values.forEach((element) {
          print('上传成功的图片===========================${element.url}');
          list.add(element.url);
        });
      }
      bool model = await putFeedBack(editText, jsonEncode(list));
      if (model) {
        Toast.show("反馈成功", context);
        Navigator.pop(context);
      }
    } else {
      Toast.show("请添加图片", context);
    }
    Loading.hideLoading(context);
  }
}
