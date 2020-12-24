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
  String _province = "";
  String _city = "未设置";
  String _provinceCity = "未设置";
  String _introduction = "";
  String avataruri = "";
  //取图裁剪得到的图片数据
  Uint8List imageData;
  List<File> fileList = [];
  int textSize = 20;
  Color textColor = AppColor.black;
  int leftIndex = 0;
  int rightIndex = 0;
  FixedExtentScrollController leftfixedExtentController = FixedExtentScrollController(
    initialItem: 5);
  FixedExtentScrollController rightfixedExtentController = FixedExtentScrollController(
    initialItem: 5);
  bool isFirst = true;
  UploadResultModel uploadmodel;
  String upLoadAvatar;
  bool havaUpDataImage = false;
  List<PicUrlsModel> picUrls = [];
  List<String> textList = [
    "我",
    "带我打",
    "先吃饭",
    "相册",
    "吃饭",
    "分为非",
    "为对方答复VDE",
    "打死",
    "爱吃啥",
    "好基友",
    "有一年",
    "VBVB",
    "财富公馆",
    "从包一百一十一",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
    "包一百",
  ];
  List<int> intList = [
    1,
    2,
    3,
    4,
    5,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    11,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    11,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    12,
    3,
    11,
    1,
    1,
    1,
    1,
  ];

  @override
  void initState() {
    super.initState();
    _setUserData();
    if (isFirst = true) {
      leftIndex = leftfixedExtentController.initialItem;
      rightIndex = rightfixedExtentController.initialItem;
    }
    _ExtentControllerAddListener();
  }
  _setUserData(){
    print('========================================给用户资料赋值');
      avataruri = context.read<ProfileNotifier>().profile.avatarUri;
      userName = context.read<ProfileNotifier>().profile.nickName;
      userSex = context.read<ProfileNotifier>().profile.sex;
      userBirthday = context.read<ProfileNotifier>().profile.birthday;
      _introduction = context.read<ProfileNotifier>().profile.description;
      print('userSex==========================================$userSex');
    print('userBirthday==========================================$userBirthday');
    print('_introduction==========================================$_introduction');
    print('=====================================赋值完成');
  }
  _ExtentControllerAddListener() {
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
    if(userSex==1){
      print('=====================================男');
      userSexText = "男";
    }else if(userSex==2){
      userSexText = "女";
      print('=====================================女');
    }else{
      userSexText = " ";
    }
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      body: SlidingUpPanel(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isCity ? 0.0 : 10.0),
          topRight: Radius.circular(isCity ? 0.0 : 10.0),
        ),
        panel: isCity ? _addressPicler(height, width) : _bottomDialog(),
        onPanelClosed: () {},
        maxHeight: isCity ? height * 0.31 + 42 : height * 0.19 + 32,
        backdropEnabled: true,
        controller: pcController,
        minHeight: 0,
        body: Container(
          color: AppColor.white,
          height: height,
          width: width,
          child: Column(
            children: [
              Container(
                height: 44,
                color: AppColor.white,
              ),
              _title(width),
              Container(
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                width: 71,
                height: 71,
                child: InkWell(
                  child: _avatar(context,height),
                  onTap: () {
                    AppRouter.navigateToMediaPickerPage(
                      context,
                      1,
                      typeImage,
                      true,
                      startPageGallery,
                      true,
                      false, (result) async {

                      SelectedMediaFiles files = Application.selectedMediaFiles;
                      if (result != true || files == null) {
                        print('===============================值为空退回');
                              return;
                      }
                      if(fileList.isNotEmpty){
                        fileList.clear();
                      }
                      Application.selectedMediaFiles = null;
                      MediaFileModel model = files.list.first;
                      print('model croppedImageData 1=========================${model.croppedImageData}  ${model.croppedImage}   ${model.file}');
                      if (model != null) {
                        print("开始获取ByteData" + DateTime
                          .now()
                          .millisecondsSinceEpoch
                          .toString());
                        ByteData byteData = await model.croppedImage.toByteData(
                          format: ui.ImageByteFormat.png);
                        print("已获取到ByteData" + DateTime
                          .now()
                          .millisecondsSinceEpoch
                          .toString());
                        Uint8List picBytes = byteData.buffer.asUint8List();
                        print("已获取到Uint8List" + DateTime
                          .now()
                          .millisecondsSinceEpoch
                          .toString());
                        model.croppedImageData = picBytes;
                      }
                      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
                      if(model.croppedImageData!=null){
                        print('==================================model.croppedImageData!=null');
                        File imageFile = await FileUtil().writeImageDataToFile(model.croppedImageData,timeStr);
                        print('imageFile==============================$imageFile');
                        fileList.add(imageFile);
                        print('===============================${fileList.length}');
                      }
                      print('havaUpDataImage===================================$havaUpDataImage');
                            print(
                        'model.croppedImageData 2===========================${model.croppedImageData}');
                      // context.read<InformationImageNotifier>().setImage(model.croppedImageData);
                      setState(() {
                        imageData = model.croppedImageData;
                      });
                    }

                    );
                  }
                  ,)
                /*  context.read<InformationImageNotifier>();*/
              ),
              SizedBox(height: 16,),
              InkWell(
                onTap: () {
                  AppRouter.navigationToEditInfomationName(
                    context, userName, (result) {
                    setState(() {
                      userName = result;
                    });
                  });
                },
                child: _rowChose(width, "昵称", userName),),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isCity = false;
                  });
                  pcController.open();
                },
                child: _rowChose(width, "性别",userSexText),),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                onTap: () {
                  _showDatePicker();
                },
                child: _rowChose(width, "生日", userBirthday),)
              ,
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
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
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                child: _rowChose(width, "简介",
                  _introduction != null ? _introduction : "去编辑"),
                onTap: () {
                  AppRouter.navigationToEditInfomationIntroduction(
                    context, _introduction, (result) {
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
                color: AppColor.bgWhite_65,
              ),

            ],
          ),))
    );
  }


  Widget _rowChose(double width, String title, String TextContent) {
    print('===================================进入了$title');
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Row(
          children: [
            Text(title, style: AppStyle.textRegular16,),
            SizedBox(width: 28,),
            Container(
              height: 23,
              width: width * 0.67,
              child: Text(
                TextContent!=null?TextContent:"----",
                style: AppStyle.textRegular16,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(child: SizedBox()),
            Text(">",
              style: TextStyle(fontSize: 20, color: AppColor.textSecondary),)
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context,double height) {
    return Stack(
      children: [
        Container(
          height: height*0.09,
          width: height*0.09,
          child: ClipOval(
            child: imageData != null ? Image.memory(
              imageData, fit: BoxFit.cover,)
              : CachedNetworkImage(
              imageUrl: avataruri,
              fit: BoxFit.cover,
              placeholder: (context, url) => Image.asset(
                "images/test.png",
                fit: BoxFit.cover,
              ),
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
              borderRadius: BorderRadius.all(Radius.circular(59)),),
            child: Center(
              child: Image.asset(
                "images/test/user-filling1.png",
                fit: BoxFit.cover,
              )
            ),
          ))
      ],
    );
  }

  ///顶部title
  Widget _title(double width) {
    return Container(
      height: 44,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(this.context);
            },
            child: Image.asset("images/test/back.png"),
          ),
          Expanded(child: Center(
            child: Text("编辑资料", style: AppStyle.textMedium18,),),),
          InkWell(
            onTap: () {
              if(userName!=null&&avataruri!=null){
                _upDataUserInfo();
              }else{
                Toast.show("头像和昵称不能为空!",context);
              }
            },
            child: Container(
              height: 28,
              width: 60,
              child: Center(child: Text(
                "确定", style: TextStyle(fontSize: 14, color: AppColor.white),),),
              decoration: BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.all(Radius.circular(60)),)),)
        ],
      ),
    );
  }

  ///性别选择dialog
  Widget _bottomDialog() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 50,
            child: InkWell(
              onTap: () {
                setState(() {
                  userSex = 2;
                });
                pcController.close();
              },
              child: Center(
                child: Text("女", style: AppStyle.textRegular16),
              )),),
          InkWell(
            onTap: () {
              setState(() {
                userSex = 1;
              });
              pcController.close();
            },
            child: Container(
              height: 50,
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
              height: 50,
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
        confirm: Text('确定', style: AppStyle.textRegular16),
        cancel: Text('取消', style: AppStyle.textRegular16),
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

  ///城市选择器
  Widget _addressChose(double height) {
    return Container(
      height: height * 0.31 + 42,
      child: Column(
        children: [
          Container(
            height: 42,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                InkWell(
                  child: Text("取消", style: AppStyle.textHintRegular16,),
                  onTap: () {
                    pcController.close();
                  },
                ),
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: () {
                    setState(() {
                      _provinceCity = "$_province $_city";
                    });
                    pcController.close();
                  },
                  child: Text("完成", style: AppStyle.textRegularRed16,),
                )
              ],
            ),),
          Container(
            height: height * 0.31,
            child: AddressPicker(
              style: TextStyle(color: Colors.black, fontSize: 17),
              mode: AddressPickerMode.provinceAndCity,
              onSelectedAddressChanged: (address) {
                setState(() {
                  _province = address.currentProvince.province;
                  _city = address.currentCity.city;
                });
              },
            ),
          )
        ],
      )
    );
  }

  Widget _addressPicler(double height, double width) {
    return Container(
      height: height * 0.31,
      width: width,
      child: Column(
        children: [
          Container(
            height: 42,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                InkWell(
                  child: Text("取消", style: AppStyle.textHintRegular16,),
                  onTap: () {
                    pcController.close();
                  },
                ),
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: () {
                    int leftIndex = leftfixedExtentController.selectedItem;
                    int rightIndex = rightfixedExtentController.selectedItem;
                    Toast.show(
                      "左边选择了${textList[leftIndex]}  右边选择了${intList[rightIndex]}",
                      context);
                    /*  setState(() {

                      */ /*_provinceCity = "$_province $_city";*/ /*
                    });*/
                    pcController.close();
                  },
                  child: Text("完成", style: AppStyle.textRegularRed16,),
                )
              ],
            ),),
          Container(
            height: height * 0.31 - 42,
            width: width,
            child: Row(
              children: [
                Expanded(child: _listScrollWheel(
                  height, width, textList, leftfixedExtentController, 1),
                  flex: 1,),
                Expanded(child: _listScrollWheel(
                  height, width, intList, rightfixedExtentController, 2),
                  flex: 1,)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _listScrollWheel(double height, double width, List textContext,
    FixedExtentScrollController controller, int type) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      physics: FixedExtentScrollPhysics(),
      itemExtent: 60,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: textContext.length,
        builder: (context, index) {
          return Container(
            child: Center(
              child: _listItem(textContext, controller, index, type)
            ),
          );
        }),
    );
  }

  Widget _listItem(List textContext, FixedExtentScrollController controller,
    int index, int type) {
    return Container(
      child: Center(
        child: Text(
          "${textContext[index]}",
          style: (type == 1 && index == leftIndex) ||
            (type == 2 && index == rightIndex)
            ? AppStyle.textRegularRed16
            : AppStyle.textRegular16,
        ),
      ),
    );
  }

  _upDataUserInfo() async {
    if(fileList.isNotEmpty){
      print('avataruri   1=====================================$avataruri');
      print('=============================开始上传图片');
      var results = await FileUtil().uploadPics(fileList, (percent) {
        print('===========================正在上传');
      });
      avataruri = results.resultMap.values.first.url;
    }
    print('avataruri   2=====================================$avataruri');
    print('================================开始请求接口');
    UserModel model = await ProfileUpdataUserInfo(userName,avataruri,description:_introduction,sex: userSex,birthday:userBirthday);
    print('model==============================================${model.uid}');
    if(model!=null){
      print('=========================资料修改成功！=========================');
      var profile = ProfileDto.fromUserModel(model);
      await ProfileDBHelper().insertProfile(profile);
      context.read<ProfileNotifier>().setProfile(profile);
      Navigator.pop(context,true);
      print('更新过后的数据库用户头像${context.read<ProfileNotifier>().profile.avatarUri}');
    }else{
      print('=========================资料修改失败！=========================');
    }
  }
}