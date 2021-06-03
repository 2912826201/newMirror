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
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
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
  String editText = "";
  List<Uint8List> imageDataList = [];
  List<File> fileList = [];

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
            padding:
                const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
            child: CustomRedButton(
              "提交",
              CustomRedButton.buttonStateNormal,
              () {
                FocusScope.of(context).requestFocus(FocusNode());
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
        maxLines: null,
        maxLength: 500,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "请告诉我们您的宝贵意见,我们会认真对待~",
          hintStyle: TextStyle(fontSize: 16, color: AppColor.textHint),
          border: InputBorder.none,
        ),
        inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 500)],
        onChanged: (value) {
          print('----------------${utf8.encode(value).length}');
          setState(() {
            editText = value;
          });
        },
      ),
    );
  }

  Widget _imageList(double width) {
    return Container(
      height: 95,
      width: width,
      child: ListView.separated(
          itemCount: fileList.length<8 ? fileList.length + 1 : fileList.length,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                width: 10.0,
                color: Color(0xFFFFFFFF),
              ),
          itemBuilder: (context, index) {
            if (index != fileList.length) {
              return _item(index);
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
              child: Image.file(
                fileList[index],
                width: 86,
                height: 86,
              )),
          Positioned(
            right: 0,
            child: AppIconButton(
              svgName: AppIcon.delete,
              iconSize: 18,
              onTap: () {
                fileList.removeAt(index);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _addImageItem() {
    return InkWell(
            onTap: () {
              _getImage();
            },
            child: Container(
              margin: EdgeInsets.only(top: 9, right: 16),
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColor.bgWhite,
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
              child: Center(
                child: AppIcon.getAppIcon(AppIcon.add_gallery, 13),
              ),
            ),
          );
  }

  //从相册获取照片
  _getImage() {
    if(fileList.length==8){
      ToastShow.show(msg: "最多只能选择8张图片哦~", context: context);
    }
    AppRouter.navigateToMediaPickerPage(context, 8-fileList.length, typeImage, false, startPageGallery, false, (result) {
      SelectedMediaFiles files = Application.selectedMediaFiles;
      if (!result || files == null) {
        print('===============================值为空退回');
        return;
      }
      Application.selectedMediaFiles = null;
      List<MediaFileModel> model = files.list;
      model.forEach((element) async {
        if(element.file!=null){
          fileList.add(element.file);
          setState(() {
          });
        }
      });
    });
  }

  _uploadImage() async {
    if (fileList.length == 0 || editText.length == 0) {
      ToastShow.show(msg: "图片和文字不可为空", context: context);
      return;
    }
    Loading.showLoading(context,infoText: "正在反馈");
    List<String> list = [];
    var result = await FileUtil().uploadPics(fileList, (percent) {
      print('===========================正在上传%%$percent');
    });
    if (result.resultMap.values == null) {
      Toast.show("图片上传失败!", context);
      Loading.hideLoading(context);
      return;
    }
    result.resultMap.values.forEach((element) {
      print('上传成功的图片===========================${element.url}');
      list.add(element.url);
    });
    bool model = await putFeedBack(StringUtil.textWrapMatch(editText), jsonEncode(list));
    if (model != null && model) {
      Toast.show("反馈成功!", context);
      Loading.hideLoading(context);
      Navigator.pop(context);
    } else {
      Toast.show("反馈失败!", context);
      Loading.hideLoading(context);
    }
  }
}
