import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
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
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/address_Picker.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:mirror/widget/loading.dart';

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
  String _introduction = "去编辑";
  String avataruri;
  //取图裁剪得到的图片数据
  Uint8List imageData;
  List<File> fileList = [];
  int textSize = 20;
  Color textColor = AppColor.black;
  LinkedHashMap<int, RegionDto> provinceMap = Application.provinceMap;
  Map<int, List<RegionDto>> cityMap = Application.cityMap;
  OnItemClickListener onItemClickListener;
  double textHeight = 0;
  int buttonState = CustomRedButton.buttonStateNormal;
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
    if(context.read<ProfileNotifier>().profile.description!=null&&context.read<ProfileNotifier>().profile
        .description!=""){
      _introduction = context.read<ProfileNotifier>().profile.description;
    }
    if (context.read<ProfileNotifier>().profile.cityCode != null) {
      provinceMap.forEach((key, value) {
        if (context.read<ProfileNotifier>().profile.cityCode == value.regionCode) {
          print('初始化城市=======================================cityCode=====${value.regionCode}');
          print('初始化城市=======================================cityName=====${value.regionName}');
          Future.delayed(Duration.zero).then((e) {
            context.read<AddressPickerNotifier>().changeCityText(value.regionName, " ");
            context.read<AddressPickerNotifier>().changeCityCode(value.regionCode, value.longitude, value.latitude);
          });
        }
      });
      cityMap.forEach((key, value) {
        value.forEach((element) {
          if (context.read<ProfileNotifier>().profile.cityCode == element.regionCode) {
            print('初始化城市=======================================cityCode=====${element.regionCode}');
            print('初始化城市=======================================cityName=====${element.regionName}');
            Future.delayed(Duration.zero).then((e) {
              context
                  .read<AddressPickerNotifier>()
                  .changeCityText(element.regionName, provinceMap[element.parentId].regionName);
              context
                  .read<AddressPickerNotifier>()
                  .changeCityCode(element.regionCode, element.longitude, element.latitude);
            });
          }
        });
      });
    }
    print('userSex==========================================$userSex');
    print('userBirthday==========================================$userBirthday');
    print('_introduction==========================================$_introduction');
    print('=====================================赋值完成');
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
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
          backgroundColor: AppColor.white,
          leadingOnTap: () {
            context.read<AddressPickerNotifier>().cleanCityData();
            Navigator.pop(context);
          },
          titleString: "编辑资料",
          actions: [
            Container(
              padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
              child: CustomRedButton(
                "确定",
                buttonState,
                () {
                  setState(() {
                    buttonState = CustomRedButton.buttonStateLoading;
                  });
                  if (userName != null && avataruri != null) {
                    Loading.showLoading(context);
                    _upDataUserInfo();
                  } else {
                    setState(() {
                      buttonState = CustomRedButton.buttonStateNormal;
                    });
                    Toast.show("头像和昵称不能为空!", context);
                  }
                },
              ),
            ),
          ],
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
                color: AppColor.bgWhite,
              ),
              Container(
                  margin: EdgeInsets.only(top: 16),
                  width: 71,
                  height: 71,
                  child: InkWell(
                    child: _avatar(context, height, width),
                    onTap: () {
                      AppRouter.navigateToMediaPickerPage(context, 1, typeImage, true, startPageGallery, true,
                          (result) async {
                        SelectedMediaFiles files = Application.selectedMediaFiles;
                        if (result != true || files == null) {
                          print('===============================值为空退回');
                          return;
                        }
                        if (fileList.isNotEmpty) {
                          fileList.clear();
                        }
                        Application.selectedMediaFiles = null;
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
                          print('==================================model.croppedImageData!=null');
                          File imageFile = await FileUtil().writeImageDataToFile(model.croppedImageData, timeStr);
                          print('imageFile==============================$imageFile');
                          fileList.add(imageFile);
                          print('===============================${fileList.length}');
                        }
                        print('model.croppedImageData 2===========================${model.croppedImageData}');
                        // context.read<InformationImageNotifier>().setImage(model.croppedImageData);
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
                child: _rowChose(width, "昵称", userName),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite,
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
                child: _rowChose(width, "性别", userSexText),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite,
              ),
              InkWell(
                onTap: () {
                  _showDatePicker();
                },
                child: _rowChose(width, "生日", userBirthday),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite,
              ),
              InkWell(
                child: _rowChose(width, "地区", context.watch<AddressPickerNotifier>().provinceCity),
                onTap: () {
                  openaddressPickerBottomSheet(context: context, provinceMap: provinceMap, cityMap: cityMap);
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite,
              ),
              InkWell(
                child: _rowChose(width, "简介", _introduction),
                onTap: () {
                  AppRouter.popToBeforeLogin(context);/*navigateToEditInfomationIntroduction(context, _introduction,
                  (result) {
                    if (result != null) {
                      _introduction = result;
                    } else {
                      _introduction = null;
                    }
                    setState(() {});
                  });*/
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite,
              ),
            ],
          ),
        ));
  }

  //这是每项资料的item
  Widget _rowChose(double width, String title, String textContent) {
    return Container(
      height: title == "简介" ? textHeight + 25 : 48,
      width: width,
      padding: title == "简介"
          ? EdgeInsets.only(top: 13, left: 16, right: 16, bottom: 12)
          : EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Container(
            alignment: title == "简介" ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              title,
              style: AppStyle.textRegular16,
            ),
          ),
          SizedBox(
            width: 28,
          ),
          Container(
            alignment: title != "简介" ? Alignment.centerLeft : Alignment.topLeft,
            height: title == "简介" ? 148 : 23,
            width: width * 0.67,
            child: Text(
              textContent != null ? textContent : "去编辑",
              style: AppStyle.textRegular16,
              maxLines: title != "简介"?1:5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          Container(
            alignment: title == "简介" ? Alignment.topRight : Alignment.centerRight,
            child: Text(
              ">",
              style: TextStyle(fontSize: 20, color: AppColor.textSecondary),
            ),
          )
        ],
      ),
    );
  }

  //选择头像
  Widget _avatar(BuildContext context, double height, double width) {
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
                      height: 71,
                      width: 71,
                      imageUrl: avataruri,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        "images/test.png",
                        fit: BoxFit.cover,
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
                      child: Text(
                    "+",
                    style: TextStyle(fontSize: 12, color: AppColor.white),
                  )),
                ))
          ],
        ));
  }

  ///时间选择器
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('确定', style: AppStyle.redRegular16),
        cancel: Text('取消', style: AppStyle.textHintRegular16),
      ),
      minDateTime: DateTime.parse("1900-01-01"),
      //选择器上可选择的最早时间
      maxDateTime: DateTime.parse(DateUtil.formatToDayDateString()),
      //选择器上可选择的最晚时间
      initialDateTime: DateTime.parse("1900-01-01"),
      //选择器的当前选中时间
      dateFormat: "yyyy年,MM月,dd日",
      //时间格式
      locale: DateTimePickerLocale.zh_cn,
      //国际化配置
      onClose: () {},
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {},
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          userBirthday = DateFormat("yyyy-MM-dd").format(dateTime);
        });
      },
    );
  }

  _upDataUserInfo() async {
    if (fileList.isNotEmpty) {
      print('avataruri   1=====================================$avataruri');
      print('=============================开始上传图片');
      var results = await FileUtil().uploadPics(fileList, (percent) {
        print('===========================正在上传');
      });
      avataruri = results.resultMap.values.first.url;
    }
    print('avataruri   2=====================================$avataruri');
    print('================================开始请求接口');
    UserModel model = await ProfileUpdataUserInfo(userName, avataruri,
        description: _introduction,
        sex: userSex,
        birthday: userBirthday,
        cityCode: context.read<AddressPickerNotifier>().cityCode);
    print('model==============================================${model.uid}');
    if (model != null) {
      print('=========================资料修改成功！=========================');
      var profile = ProfileDto.fromUserModel(model);
      await ProfileDBHelper().insertProfile(profile);
      context.read<ProfileNotifier>().setProfile(profile);
      /*context.read<AddressPickerNotifier>().cleanCityData();*/
      Toast.show(
        "资料修改成功",
        context,
      );
      Loading.hideLoading(context);
      Navigator.pop(context);
      print('更新过后的数据库用户头像${context.read<ProfileNotifier>().profile.avatarUri}');
    } else {
      setState(() {
        buttonState = CustomRedButton.buttonStateNormal;
      });
      Loading.hideLoading(context);
      Toast.show(
        "资料修改失败",
        context,
      );
      print('=========================资料修改失败！=========================');
    }
  }
}
