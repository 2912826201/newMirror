import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/address_picker.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/time_picker_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class EditInformation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditInformationState();
  }
}

class _EditInformationState extends State<EditInformation> {
  String userName;
  int userSex;
  String userSexText;
  String userBirthday;
  String _introduction;
  String avataruri;

  //取图裁剪得到的图片数据
  Uint8List imageData;
  List<File> fileList = [];
  int textSize = 20;
  Color textColor = AppColor.mainBlack;
  LinkedHashMap<int, RegionDto> provinceMap = Application.provinceMap;
  Map<int, List<RegionDto>> cityMap = Application.cityMap;
  OnItemClickListener onItemClickListener;
  double textHeight = 0;
  int buttonState = CustomYellowButton.buttonStateNormal;
  double width = ScreenUtil.instance.screenWidthDp;
  double height = ScreenUtil.instance.height;
  String cityCode;
  String provinceCity;
  @override
  void initState() {
    super.initState();
    _setUserData();
  }

  _setUserData() {
    print('========================================给用户资料赋值');
    avataruri = context.read<ProfileNotifier>().profile.avatarUri;
    userName = context.read<ProfileNotifier>().profile.nickName;
    userSex = context.read<ProfileNotifier>().profile.sex;
    userBirthday = context.read<ProfileNotifier>().profile.birthday;
    if (context.read<ProfileNotifier>().profile.description != null &&
        context.read<ProfileNotifier>().profile.description != "") {
      _introduction = context.read<ProfileNotifier>().profile.description;
    }
    if (context.read<ProfileNotifier>().profile.cityCode != null) {
      provinceMap.forEach((key, value) {
        if (context.read<ProfileNotifier>().profile.cityCode == value.regionCode) {
          print('初始化城市=======================================cityCode=====${value.regionCode}');
          print('初始化城市=======================================cityName=====${value.regionName}');
          provinceCity = value.regionName;
          cityCode = value.regionCode;
        }
      });
      cityMap.forEach((key, value) {
        value.forEach((element) {
          if (context.read<ProfileNotifier>().profile.cityCode == element.regionCode) {
            print('初始化城市=======================================cityCode=====${element.regionCode}');
            print('初始化城市=======================================cityName=====${element.regionName}');
            provinceCity = element.regionName+" "+provinceMap[element.parentId].regionName;
            cityCode = element.regionCode;
          }
        });
      });
      if (mounted) {
        setState(() {});
      }
    }
    print('userSex==========================================$userSex');
    print('userBirthday==========================================$userBirthday');
    print('_introduction==========================================$_introduction');
    print('=====================================赋值完成');
  }

  @override
  Widget build(BuildContext context) {
    if (userSex == 1) {
      userSexText = "男";
    } else if (userSex == 2) {
      userSexText = "女";
    } else {
      userSexText = " ";
    }

    ///判断文字的高度，动态改变
    TextPainter testSize = calculateTextWidth(_introduction, AppStyle.textRegular16, width * 0.66, 5);
    textHeight = testSize.height;
    print('textHeight==============================$textHeight');
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AppColor.mainBlack,
          leadingOnTap: () {
            Navigator.pop(context);
          },
          titleString: "编辑资料",
          actions: [
            Container(
              padding:
                  const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
              child: CustomYellowButton(
                "保存",
                buttonState,
                () {
                  setState(() {
                    buttonState = CustomYellowButton.buttonStateLoading;
                  });
                  if (userName != null && avataruri != null) {
                    /* Loading.showLoading(context);*/
                    _upDataUserInfo();
                  } else {
                    setState(() {
                      buttonState = CustomYellowButton.buttonStateNormal;
                    });
                    Toast.show("头像和昵称不能为空!", context);
                  }
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              color: AppColor.mainBlack,
              height: height - ScreenUtil.instance.statusBarHeight,
              width: width,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 16),
                      width: 71,
                      height: 71,
                      child: InkWell(
                        child: _avatar(context),
                        onTap: () {
                          AppRouter.navigateToMediaPickerPage(context, 1, typeImage, true, startPageGallery, true,
                              (result) async {
                            SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
                            if (result != true || files == null) {
                              print('===============================值为空退回');
                              return;
                            }
                            if (fileList.isNotEmpty) {
                              fileList.clear();
                            }
                            RuntimeProperties.selectedMediaFiles = null;
                            MediaFileModel model = files.list.first;
                            print(
                                'model croppedImageData 1=========================${model.croppedImageData}  ${model.croppedImage}   ${model.file}');
                            if (model != null) {
                              print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                              ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                              print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                              Uint8List picBytes = byteData.buffer.asUint8List();
                              print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                              model.croppedImageData = picBytes;
                            }
                            String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
                            if (model.croppedImageData != null) {
                              File imageFile = await FileUtil().writeImageDataToFile(model.croppedImageData, timeStr);
                              fileList.add(imageFile);
                            }
                            setState(() {
                              imageData = model.croppedImageData;
                            });
                          });
                        },
                      )),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () {
                      AppRouter.navigateToEditInfomationName(context, userName, (result) {
                        setState(() {
                          if (result != null) {
                            userName = result;
                          }
                        });
                      });
                    },
                    child: _rowChose("昵称", userName),
                  ),
                  InkWell(
                    onTap: () {
                      List<String> list = ["男", "女"];
                      openMoreBottomSheet(
                          context: context,
                          onItemClickListener: (index) {
                            if (list[index] == "男") {
                              setState(() {
                                userSex = 1;
                              });
                            } else if (list[index] == "女") {
                              setState(() {
                                userSex = 2;
                              });
                            }
                          },
                          lists: list);
                    },
                    child: _rowChose("性别", userSexText),
                  ),

                  InkWell(
                    onTap: () {
                      openTimePickerBottomSheet(
                          context: context,
                          firstTime: DateTime(1960),
                          lastTime: DateTime.now(),
                          initTime: userBirthday!=null?DateTime.parse(userBirthday):null,
                          timeFormat: "yyyy年,MM月,dd日",
                          onConfirm: (date) {
                            userBirthday = DateFormat("yyyy-MM-dd").format(date);
                            setState(() {});
                          });
                    },
                    child: _rowChose("生日", userBirthday),
                  ),

                  InkWell(
                    child: _rowChose("地区", provinceCity),
                    onTap: () {
                      openaddressPickerBottomSheet(
                          context: context,
                          provinceMap: provinceMap,
                          cityMap: cityMap,
                          onConfirm: (provinceCity, cityCode, longitude, latitude) {
                            this.provinceCity = provinceCity;
                            this.cityCode = cityCode;
                            setState(() {
                            });
                          });
                    },
                  ),
                  InkWell(
                    child: _rowChose("简介", _introduction),
                    onTap: () {
                      AppRouter.navigateToEditInfomationIntroduction(context, _introduction, (result) {
                        if (result != null) {
                          if (result.length != 0) {
                            _introduction = result;
                          } else {
                            _introduction = null;
                          }
                        }
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
            buttonState == CustomYellowButton.buttonStateLoading
                ? Container(
                    height: ScreenUtil.instance.height,
                    child: InkWell(
                      onTap: () {
                        return null;
                      },
                      child: Container(),
                    ))
                : Container()
          ],
        ));
  }

  //这是每项资料的item
  Widget _rowChose(String title, String textContent) {
    return Container(
      height: title == "简介" ? textHeight + 25 : 48,
      width: width,
      padding: title == "简介"
          ? EdgeInsets.only(top: 13, left: 16, right: 16)
          : EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Container(
            alignment: title == "简介" ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              title,
              style: AppStyle.whiteRegular16,
            ),
          ),
          SizedBox(
            width: 28,
          ),
          Container(
            alignment: title != "简介" ? Alignment.centerLeft : Alignment.topLeft,
            // height: title == "简介" ? textHeight : 23,
            width: width * 0.67,
            child: Text(
              textContent != null ? textContent : "去编辑",
              style: title == "昵称"?AppStyle.whiteRegular16:AppStyle.text1Regular16,
            ),
          ),
          Spacer(),
          Container(
            alignment: title == "简介" ? Alignment.topRight : Alignment.centerRight,
            child: AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              18,
              color: AppColor.textWhite60,
            ),
          )
        ],
      ),
    );
  }

  //选择头像
  Widget _avatar(BuildContext context) {
    return Container(
        height: 71,
        width: 71,
        child: Stack(
          children: [
            ClipOval(
              child: imageData != null
                  ? Image.memory(
                      imageData,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      height: 72,
                      width: 72,
                      imageUrl: FileUtil.getMediumImage(avataruri),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColor.imageBgGrey,
                      ),
                    ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(59)),
                  ),
                  child: Center(
                    child: AppIcon.getAppIcon(AppIcon.edit_pen, 23, color: AppColor.white),
                  ),
                ))
          ],
        ));
  }

  _upDataUserInfo() async {
    if (fileList.isNotEmpty) {
      var results = await FileUtil().uploadPics(fileList, (percent) {});
      avataruri = results.resultMap.values.first.url;
    }
    UserModel model = await ProfileUpdataUserInfo(userName, avataruri,
        description: _introduction,
        sex: userSex,
        birthday: userBirthday,
        cityCode: cityCode);
    if (model != null) {
      var profile = ProfileDto.fromUserModel(model);
      await ProfileDBHelper().insertProfile(profile);
      context.read<ProfileNotifier>().setProfile(profile);
      Toast.show(
        "资料修改成功",
        context,
      );
      Navigator.pop(context);
      print('更新过后的数据库用户头像${context.read<ProfileNotifier>().profile.avatarUri}');
    } else {
      setState(() {
        buttonState = CustomYellowButton.buttonStateNormal;
      });
      Toast.show(
        "资料修改失败",
        context,
      );
      Navigator.pop(context);
      print('=========================资料修改失败！=========================');
    }
  }
}
