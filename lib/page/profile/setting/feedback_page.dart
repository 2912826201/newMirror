import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/loading.dart';
import 'package:mirror/widget/Clip_util.dart';

///意见反馈
class FeedBackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _feedBackPage();
  }
}

class _feedBackPage extends State<FeedBackPage> {
  String editText = "";
  List<File> fileList = [];
  double width = ScreenUtil.instance.screenWidthDp;
  double height = ScreenUtil.instance.height;
  bool longClick = false;
  Size numTextSize = getTextSize("322292818", AppStyle.text1Regular14, 1);
  Size textSize = getTextSize("意见反馈QQ群: ", AppStyle.text1Regular14, 1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        titleString: "意见反馈",
        actions: [
          Container(
            padding:
                const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
            child: CustomYellowButton(
              "提交",
              CustomYellowButton.buttonStateNormal,
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
        child:InkWell(
          highlightColor: AppColor.transparent,
          splashColor: AppColor.transparent,
          onTap: (){
            longClick = false;
            setState(() {
            });
            // FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 13.5,
                      ),
                      Text(
                        "你的意见和建议,是对我们最大的支持",
                        style: AppStyle.whiteRegular16,
                      ),
                      SizedBox(
                        height: 13.5,
                      ),
                      Row(
                        children: [
                          Text("意见反馈QQ群: ",style: AppStyle.text1Regular14,),
                          InkWell(
                            onLongPress: (){
                              longClick = true;
                              setState(() {
                              });
                            },
                            child: Container(
                              height: numTextSize.height,
                              width: numTextSize.width+10,
                              child: Text("322292818",style:longClick?AppStyle.whiteRegular14: AppStyle
                                  .text1Regular14,) ,
                              color: longClick ? AppColor.white.withOpacity(0.1) : AppColor.mainBlack,
                            ),)
                        ],
                      ),
                    ],
                  ),
                   Positioned(
                      top: 10,
                      left: textSize.width+16+(numTextSize.width/2-textSize.width/2),
                      child:_bubble(),)
                ],
              ),
            ),

            SizedBox(
              height: 25.5,
            ),
            _inputBox(width),
            _imageList(width),
          ],
        ),
      ) ,),
    );
  }

  Widget _bubble(){
    return InkWell(
      highlightColor: AppColor.transparent,
      splashColor: AppColor.transparent,
      onTap: (){
        setState(() {
          longClick = false;
        });
        Clipboard.setData(ClipboardData(text: '322292818'));
        ToastShow.show(msg: "群号已复制到剪切板", context: context);
      },
      child: Opacity(
        opacity: longClick?1:0,
        child:Container(
          height: 40,
          child:Stack(
            children: [
              Container(
                height: 30,
                width: 60,
                child: Center(child: Text("复制",style: AppStyle.textRegular14,),),
                decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius:BorderRadius.all(Radius.circular(8))
                ),
              ),
              Positioned(
                  top: 29,
                  left: 25,
                  child:CustomPaint(
                    size: Size(5,8),
                    painter: TrianglePath(true,AppColor.white),
                  ) )
            ],) ,),),
    );
  }
  ///输入框
  Widget _inputBox(double width) {
    return Container(
      height: 148,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),color: AppColor.layoutBgGrey),
      child: TextField(
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular16,
        maxLines: null,
        maxLength: 500,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "请告诉我们您的宝贵意见,我们会认真对待~",
          hintStyle: AppStyle.text2Regular12,
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
          itemCount: fileList.length < 8 ? fileList.length + 1 : fileList.length,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                width: 10.0,
                color: AppColor.mainBlack,
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
                fit: BoxFit.cover,
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
      highlightColor: AppColor.transparent,
      splashColor: AppColor.transparent,
      onTap: () {
        _getImage();
      },
      child: Container(
        margin: EdgeInsets.only(top: 9, right: 16),
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
        ),
        child: Center(
          child: AppIcon.getAppIcon(AppIcon.add_gallery, 13,color: AppColor.white),
        ),
      ),
    );
  }

  //从相册获取照片
  _getImage() {
    if (fileList.length == 8) {
      ToastShow.show(msg: "最多只能选择8张图片哦~", context: context);
    }
    AppRouter.navigateToMediaPickerPage(context, 8 - fileList.length, typeImage, false, startPageGallery, false,
        (result) {
      SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
      if (!result || files == null) {
        print('===============================值为空退回');
        return;
      }
      RuntimeProperties.selectedMediaFiles = null;
      List<MediaFileModel> model = files.list;
      model.forEach((element) async {
        if (element.file != null) {
          fileList.add(element.file);
          setState(() {});
        }
      });
    });
  }

  _uploadImage() async {
    if (fileList.length == 0 || editText.length == 0) {
      ToastShow.show(msg: "图片和文字不可为空", context: context);
      return;
    }
    Loading.showLoading(context, infoText: "正在反馈");
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
