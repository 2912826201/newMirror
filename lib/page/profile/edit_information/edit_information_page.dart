import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:address_picker/address_picker.dart';
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
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/media_picker/gallery_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import 'loading.dart';

class EditInformation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _editInformationState();
  }
}

class _editInformationState extends State<EditInformation> {
  String userName = "这是一个十五个字的名字我我我我";
  PanelController pcController = PanelController();
  int userSex;
  String userSexText = "";
  DateTime _selectedDateTime = DateTime.now();
  String userBirthday = "2000-07-08";
  bool isCity = true;
  String _provinceText = "";
  String _cityText = "未设置";
  String cityCode = "";
  String _provinceCity = "未设置";
  double longitude;
  double latitude;
  String _introduction = "";
  String avataruri = "";

  //取图裁剪得到的图片数据
  Uint8List imageData;
  List<File> fileList = [];
  int textSize = 20;
  Color textColor = AppColor.black;
  int leftIndex = 0;
  int rightIndex = 0;
  FixedExtentScrollController leftfixedExtentController = FixedExtentScrollController(initialItem: 0);
  FixedExtentScrollController rightfixedExtentController = FixedExtentScrollController(initialItem: 0);
  bool isFirst = true;
  bool cityNotChange = false;
  List<String> provinceNameList = [];
  List<String> cityNameList = [];
  List<int> provinceIdList = [];
  List<RegionDto> cityDtoList = [];
  LinkedHashMap<int, RegionDto> provinceMap = Application.provinceMap;
  Map<int, List<RegionDto>> cityMap = Application.cityMap;

  @override
  void initState() {
    super.initState();
    _setUserData();
    _ExtentControllerAddListener();
    _getAddressData();
  }

  _setUserData() {
    print('========================================给用户资料赋值');
    avataruri = context.read<ProfileNotifier>().profile.avatarUri;
    userName = context.read<ProfileNotifier>().profile.nickName;
    userSex = context.read<ProfileNotifier>().profile.sex;
    userBirthday = context.read<ProfileNotifier>().profile.birthday;
    _introduction = context.read<ProfileNotifier>().profile.description;
    cityCode = context.read<ProfileNotifier>().profile.cityCode;
    if (context.read<ProfileNotifier>().profile.cityCode != null) {
      provinceMap.forEach((key, value) {
        if (cityCode == value.regionCode) {
          _cityText = value.regionName;
          _provinceText = value.regionName;
          _provinceCity = "$_provinceText $_cityText";
          longitude = value.longitude;
          latitude = value.latitude;
        }
      });
      cityMap.forEach((key, value) {
        value.forEach((element) {
          if (cityCode == element.regionCode) {
            _cityText = element.regionName;
            _provinceText = provinceMap[element.parentId].regionName;
            longitude = element.longitude;
            latitude = element.latitude;
            _provinceCity = "$_provinceText $_cityText";
          }
        });
      });
    }
    print('userSex==========================================$userSex');
    print('userBirthday==========================================$userBirthday');
    print('_introduction==========================================$_introduction');
    print('=====================================赋值完成');
  }

  _ExtentControllerAddListener() {
    if (isFirst = true) {
      leftIndex = leftfixedExtentController.initialItem;
      rightIndex = rightfixedExtentController.initialItem;
    }
    leftfixedExtentController.addListener(() {
      setState(() {
        isFirst = false;
        leftIndex = leftfixedExtentController.selectedItem;
      });
    });
    rightfixedExtentController.addListener(() {
      setState(() {
        isFirst = false;
        rightIndex = rightfixedExtentController.selectedItem;
      });
    });
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
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(this.context);
            },
            child: Image.asset("images/test/back.png"),
          ),
          title: Text(
            "编辑资料",
            style: AppStyle.textMedium18,
          ),
          actions: [
            InkWell(
              onTap: () {
                if (userName != null && avataruri != null) {
                  Loading.showLoading(context);
                  _upDataUserInfo();
                } else {
                  Toast.show("头像和昵称不能为空!", context);
                }
              },
              child: Container(
              width: 60,
              margin: EdgeInsets.only(right: 16),
              child: Center(
                  child: Container(
                decoration: BoxDecoration(
                  color: AppColor.mainRed,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                child: Text(
                  "确定",
                  style: TextStyle(fontSize: 14, color: AppColor.white),
                ),
              )),
            ),
            )
          ],
        ),
        body: SlidingUpPanel(
            /*borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCity ? 0.0 : 10.0),
              topRight: Radius.circular(isCity ? 0.0 : 10.0),
            ),*/
            panel: isCity ? _addressPicler(height, width) : _bottomDialog(width),
            onPanelClosed: () {},
            maxHeight: isCity ? height * 0.35 : width * 0.5,
            backdropEnabled: true,
            controller: pcController,
            minHeight: 0,
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
                        child: _avatar(context, height,width),
                        onTap: () {
                          AppRouter.navigateToMediaPickerPage(
                              context, 1, typeImage, true, startPageGallery, true, false, (result) async {
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
                      )
                      /*  context.read<InformationImageNotifier>();*/
                      ),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () {
                      AppRouter.navigationToEditInfomationName(context, userName, (result) {
                        setState(() {
                          userName = result;
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
                      setState(() {
                        isCity = false;
                      });
                      pcController.open();
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
                    child: _rowChose(width, "地区", _provinceCity),
                    onTap: () {
                      setState(() {
                        isCity = true;
                      });
                      pcController.open();
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    width: width,
                    height: 0.5,
                    color: AppColor.bgWhite,
                  ),
                  InkWell(
                    child: _rowChose(width, "简介", _introduction != null ? _introduction : "去编辑"),
                    onTap: () {
                      AppRouter.navigationToEditInfomationIntroduction(context, _introduction, (result) {
                        setState(() {
                          _introduction = result;
                        });
                      });
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
            )));
  }

  Widget _rowChose(double width, String title, String TextContent) {
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: AppStyle.textRegular16,
            ),
            SizedBox(
              width: 28,
            ),
            Container(
              height: 23,
              width: width * 0.67,
              child: Text(
                TextContent != null ? TextContent : "----",
                style: AppStyle.textRegular16,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(child: SizedBox()),
            Text(
              ">",
              style: TextStyle(fontSize: 20, color: AppColor.textSecondary),
            )
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context, double height,double width) {
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

  ///性别选择dialog
  Widget _bottomDialog(double width) {
    return Container(
      child: Column(
        children: [
          Container(
            height: width * 0.13,
            child: InkWell(
                onTap: () {
                  setState(() {
                    userSex = 2;
                  });
                  pcController.close();
                },
                child: Center(
                  child: Text("女", style: AppStyle.textRegular16),
                )),
          ),
          InkWell(
              onTap: () {
                setState(() {
                  userSex = 1;
                });
                pcController.close();
              },
              child: Container(
                  height: width * 0.13,
                  child: Center(
                    child: Text("男", style: AppStyle.textRegular16),
                  ))),
          Container(
            color: AppColor.bgWhite,
            height: 12,
          ),
          InkWell(
              onTap: () {
                pcController.close();
              },
              child: Container(
                  height: width * 0.13,
                  child: Center(
                      child: Text(
                    "取消",
                    style: AppStyle.textRegular16,
                  ))))
        ],
      ),
    );
  }

  ///时间选择器
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('确定', style: AppStyle.textRegularRed16),
        cancel: Text('取消', style: AppStyle.textHintRegular16),
      ),
      minDateTime: DateTime.parse("1900-01-01"),
      //选择器上可选择的最早时间
      maxDateTime: DateTime.parse(DateUtil.formatToDayDateString()),
      //选择器上可选择的最晚时间
      initialDateTime: _selectedDateTime,
      //选择器的当前选中时间
      dateFormat: "yyyy年,MM月,dd日",
      //时间格式
      locale: DateTimePickerLocale.zh_cn,
      //国际化配置
      onClose: () {
        setState(() {
          userBirthday = DateFormat("yyyy-MM-dd").format(_selectedDateTime);
        });
      },
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _selectedDateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _selectedDateTime = dateTime;
        });
      },
    );
  }

  ///这里是给城市List赋值
  _getAddressData() {
    provinceMap.forEach((provincekey, provinceDto) {
      provinceNameList.add(provinceDto.regionName);
      provinceIdList.add(provinceDto.id);
    });
    if (isFirst) {
      cityNameList.clear();
      cityDtoList.clear();
      if (cityMap[provinceIdList[leftfixedExtentController.initialItem]] == null) {
        cityDtoList.add(provinceMap[provinceIdList[leftfixedExtentController.initialItem]]);
        cityNameList.add(provinceMap[provinceIdList[leftfixedExtentController.initialItem]].regionName);
      } else {
        cityMap[provinceIdList[leftfixedExtentController.initialItem]].forEach((element) {
          cityDtoList.add(element);
          cityNameList.add(element.regionName);
        });
      }
    }
  }

  Widget _addressPicler(double height, double width) {
    print('=====================================builder');
    return Container(
      height: height * 0.33,
      width: width,
      child: Column(
        children: [
          Container(
            height: height*0.05,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                InkWell(
                  child: Text(
                    "取消",
                    style: AppStyle.textHintRegular16,
                  ),
                  onTap: () {
                    pcController.close();
                  },
                ),
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: () {
                    setState(() {
                      ///点击确定才更改城市码，否则就是初始
                      cityNotChange = true;
                      _cityText = cityNameList[rightfixedExtentController.selectedItem];
                      _provinceText = provinceNameList[leftfixedExtentController.selectedItem];
                      _provinceCity = "$_provinceText $_cityText";
                    });
                    pcController.close();
                  },
                  child: Text(
                    "完成",
                    style: AppStyle.textRegularRed16,
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AppColor.frame,
            width: width,
          ),
          Stack(
            children: [
              Container(
                height: height * 0.32 - height*0.05,
                width: width,
                child: Row(
                  children: [
                    Expanded(
                      child: _listScrollWheel(height, width, provinceNameList, leftfixedExtentController, 1),
                      flex: 1,
                    ),
                    Expanded(
                      child: _listScrollWheel(height, width, cityNameList, rightfixedExtentController, 2),
                      flex: 1,
                    )
                  ],
                ),
              ),
              Positioned(
                  top: 0,
                  child: Container(
                    width: width,
                    height: (height * 0.32 - height*0.05) / 2 - 15,
                    color: AppColor.white.withOpacity(0.5),
                  )),
              Positioned(
                  bottom: 0,
                  child: Container(
                    width: width,
                    height: (height * 0.32 - height*0.05) / 2 - 15,
                    color: AppColor.white.withOpacity(0.6),
                  )),
              Positioned(
                  left: width / 2 * 0.15,
                  top: (height * 0.32 - height*0.05) / 2 - 15,
                  child: Container(
                    height: 0.5,
                    width: width / 2 * 0.7,
                    color: AppColor.frame,
                  )),
              Positioned(
                  left: width / 2 * 0.15,
                  bottom:(height * 0.32 - height*0.05) / 2 - 15,
                  child: Container(
                    height: 0.5,
                    width: width / 2 * 0.7,
                    color: AppColor.frame,
                  )),
              Positioned(
                  right: width / 2 * 0.15,
                  top: (height * 0.32 - height*0.05) / 2 - 15,
                  child: Container(
                    height: 0.5,
                    width: width / 2 * 0.7,
                    color: AppColor.frame,
                  )),
              Positioned(
                  right: width / 2 * 0.15,
                  bottom: (height * 0.32 - height*0.05) / 2 - 15,
                  child: Container(
                    height: 0.5,
                    width: width / 2 * 0.7,
                    color: AppColor.frame,
                  )),
            ],
          )
        ],
      ),
    );
  }

  ///自定义底部滚轮组件
  Widget _listScrollWheel(
      double height, double width, List textContext, FixedExtentScrollController controller, int type) {
    print('=====================================右边视图');
    /*print('===================================${textContext.first}');*/
    return ListWheelScrollView.useDelegate(
      controller: controller,
      diameterRatio: 1,
      useMagnifier: true,
      magnification: 1.1,
      physics: FixedExtentScrollPhysics(),
      itemExtent: 25,
      childDelegate: ListWheelChildBuilderDelegate(
          childCount: textContext.length,
          builder: (context, index) {
            return Container(
              child: Center(child: _listItem(textContext, index, type)),
            );
          }),

      ///这里是滚动滑动后的判断
      onSelectedItemChanged: (index) {
        if (type == 1) {
          cityNameList.clear();
          cityDtoList.clear();
          if (cityMap[provinceIdList[index]] == null) {
            cityDtoList.add(provinceMap[provinceIdList[index]]);
            cityNameList.add(provinceMap[provinceIdList[index]].regionName);
            print('cityName======================================${provinceMap[provinceIdList[index]].regionName}');
          } else {
            cityMap[provinceIdList[index]].forEach((element) {
              cityDtoList.add(element);
              cityNameList.add(element.regionName);
            });
          }
          setState(() {});
        }
      },
    );
  }

  ///这里是滚轮的item，通过type来改变选中颜色和大小
  Widget _listItem(List textContext, int index, int type) {
    print('adress========%%%%%%%%%%%%%%%%%=================${provinceIdList[index]}');
    return Column(
      children: [
        Container(
          child: Center(
            child: Text("${textContext[index]}",
                style: AppStyle.textRegular15

                ),
          ),
        ),
      ],
    );
  }

  ///这里将选择的城市转成cityCode
  _getCityCode() {
    print('===================================================转成cityCode');
    if (cityNotChange) {
      ///这个判断是为了防止原来的CityCode被清零，只有在按下doalog的确定按钮才会被设置成true，默认是false
      if (cityMap[provinceIdList[leftfixedExtentController.selectedItem]] == null) {
        print('============================================这里是直辖市,拿的是省级code');
        cityCode = provinceMap[leftfixedExtentController.selectedItem].regionCode;
        longitude = provinceMap[leftfixedExtentController.selectedItem].longitude;
        latitude = provinceMap[leftfixedExtentController.selectedItem].latitude;
      } else {
        print('============================================这里是省市，拿的是市级code');
        cityCode = cityDtoList[rightfixedExtentController.selectedItem].regionCode;
        longitude = cityDtoList[rightfixedExtentController.selectedItem].longitude;
        latitude = cityDtoList[rightfixedExtentController.selectedItem].latitude;
      }
      setState(() {});
    } else {}
  }

  _upDataUserInfo() async {
    _getCityCode();
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
    print('城市码：==================================$cityCode');
    UserModel model = await ProfileUpdataUserInfo(userName, avataruri,
        description: _introduction, sex: userSex, birthday: userBirthday, cityCode: cityCode);
    print('model==============================================${model.uid}');
    if (model != null) {
      print('=========================资料修改成功！=========================');
      var profile = ProfileDto.fromUserModel(model);
      await ProfileDBHelper().insertProfile(profile);
      context.read<ProfileNotifier>().setProfile(profile);
      Toast.show("资料修改成功",context,);
      Loading.hideLoading(context);
      Navigator.pop(context, true);
      print('更新过后的数据库用户头像${context.read<ProfileNotifier>().profile.avatarUri}');
    } else {
      print('=========================资料修改失败！=========================');
    }
  }
}
