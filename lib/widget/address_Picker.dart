


import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
//城市选择底部弹窗
Future openaddressPickerBottomSheet({
  @required BuildContext context,
  @required LinkedHashMap<int, RegionDto> provinceMap,
  @required Map<int, List<RegionDto>> cityMap,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: AddressPicker(provinceMap:provinceMap,cityMap: cityMap,),
      );
    });
}
class AddressPicker extends StatefulWidget{
  LinkedHashMap<int, RegionDto> provinceMap;
  Map<int, List<RegionDto>> cityMap;
  AddressPicker({this.provinceMap,this.cityMap});
  @override
  State<StatefulWidget> createState() {
    return _AddressPickerState();
  }

}
class _AddressPickerState extends State<AddressPicker>{
  FixedExtentScrollController leftfixedExtentController = FixedExtentScrollController(initialItem: 0);
  FixedExtentScrollController rightfixedExtentController = FixedExtentScrollController(initialItem: 0);
  bool isFirst = true;
  bool cityChange = false;
  List<String> provinceNameList = [];
  List<String> cityNameList = [];
  List<RegionDto> provinceDtoList = [];
  List<int> provinceIdList = [];
  List<RegionDto> cityDtoList = [];
  ///取cotyCode
  _getCityCode() {
      if (widget.cityMap[provinceIdList[leftfixedExtentController.selectedItem]] == null) {
      context.read<AddressPickerNotifier>().changeCityCode(
          provinceDtoList[leftfixedExtentController.selectedItem].regionCode,
          provinceDtoList[leftfixedExtentController.selectedItem].longitude,
          provinceDtoList[leftfixedExtentController.selectedItem].latitude);
      } else {
        context.read<AddressPickerNotifier>().changeCityCode(
          cityDtoList[rightfixedExtentController.selectedItem].regionCode,
          cityDtoList[rightfixedExtentController.selectedItem].longitude,
          cityDtoList[rightfixedExtentController.selectedItem].latitude);
      }
  }
    ///从map取值
  _getAddressData() {
    widget.provinceMap.forEach((provincekey, provinceDto) {
      provinceNameList.add(provinceDto.regionName);
      provinceIdList.add(provinceDto.id);
      provinceDtoList.add(provinceDto);
    });
    if (isFirst) {
      cityNameList.clear();
      cityDtoList.clear();
      if (widget.cityMap[provinceIdList[leftfixedExtentController.initialItem]] == null) {
        cityDtoList.add(widget.provinceMap[provinceIdList[leftfixedExtentController.initialItem]]);
        cityNameList.add(widget.provinceMap[provinceIdList[leftfixedExtentController.initialItem]].regionName);
      } else {
        widget.cityMap[provinceIdList[leftfixedExtentController.initialItem]].forEach((element) {
          cityDtoList.add(element);
          cityNameList.add(element.regionName);
        });
      }
    }
  }
  ///因为controller的index有两种，初始化和滚动后，判断是否滚动了，没有则用默认，否则用选中
  _extentControllerAddListener() {
    leftfixedExtentController.addListener(() {
      isFirst = false;
    });
    rightfixedExtentController.addListener(() {
      isFirst = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _extentControllerAddListener();
    _getAddressData();
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
          return Container(
            height: height * 0.33,
            width: width,
            color: AppColor.white,
            child: Column(
              children: [
                Container(
                  height: height*0.05,
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Row(
                    children: [
                      InkWell(
                        child: Text(
                          "取消",
                          style: AppStyle.textHintRegular16,
                        ),
                        onTap: () {
                         Navigator.pop(context);
                        },
                      ),
                      Expanded(child: SizedBox()),
                      InkWell(
                        onTap: () {
                          ///点击确定的时候去取cityCode并给provider辅助
                              _getCityCode();
                              if(cityNameList[rightfixedExtentController.selectedItem]==provinceNameList[leftfixedExtentController.selectedItem]){
                                context.read<AddressPickerNotifier>().changeCityText(
                                  cityNameList[rightfixedExtentController.selectedItem],
                                  " ");
                              }else{
                                context.read<AddressPickerNotifier>().changeCityText(
                                  cityNameList[rightfixedExtentController.selectedItem],
                                  provinceNameList[leftfixedExtentController.selectedItem]);
                              }
                                Navigator.pop(context);
                        },
                        child: Text(
                          "确定",
                          style: AppStyle.redRegular16,
                        ),
                      )
                    ],
                  ),
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
                      child: IgnorePointer(
                        child: Container(
                        width: width,
                        height: (height * 0.32 - height*0.05) / 2 - 15,
                        color: AppColor.white.withOpacity(0.5),
                      ),)),
                    Positioned(
                      bottom: 0,
                      child:  IgnorePointer(
                          child: Container(
                        width: width,
                        height: (height * 0.32 - height*0.05) / 2 - 15,
                        color: AppColor.white.withOpacity(0.5),
                      ))),
                    Positioned(
                      left: width / 2 * 0.15,
                      top: (height * 0.32 - height*0.05) / 2 - 15,
                      child: Container(
                        height: 0.5,
                        width: width / 2 * 0.7,
                        color: AppColor.textHint.withOpacity(0.5),
                      )),
                    Positioned(
                      left: width / 2 * 0.15,
                      bottom:(height * 0.32 - height*0.05) / 2 - 15,
                      child: Container(
                        height: 0.5,
                        width: width / 2 * 0.7,
                        color: AppColor.textHint.withOpacity(0.5),
                      )),
                    Positioned(
                      right: width / 2 * 0.15,
                      top: (height * 0.32 - height*0.05) / 2 - 15,
                      child: Container(
                        height: 0.5,
                        width: width / 2 * 0.7,
                        color: AppColor.textHint.withOpacity(0.5),
                      )),
                    Positioned(
                      right: width / 2 * 0.15,
                      bottom: (height * 0.32 - height*0.05) / 2 - 15,
                      child: Container(
                        height: 0.5,
                        width: width / 2 * 0.7,
                        color: AppColor.textHint.withOpacity(0.5),
                      )),
                  ],
                )
              ],
            ),
          );
  }
  ///滚轮组件
  Widget _listScrollWheel(
    double height, double width, List textContext, FixedExtentScrollController controller, int type) {
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
            child: Center(
              child: Text("${textContext[index]}",
                style: AppStyle.textAddressText
            ),),
          );
        }),

      ///这里是滚动滑动后的判断
      onSelectedItemChanged: (index) {
        if (type == 1) {
          cityNameList.clear();
          cityDtoList.clear();
          if (widget.cityMap[provinceIdList[index]] == null) {
            cityDtoList.add(widget.provinceMap[provinceIdList[index]]);
            cityNameList.add(widget.provinceMap[provinceIdList[index]].regionName);
            print('cityName======================================${widget.provinceMap[provinceIdList[index]].regionName}');
          } else {
            widget.cityMap[provinceIdList[index]].forEach((element) {
              cityDtoList.add(element);
              cityNameList.add(element.regionName);
            });
          }
          setState(() {});
        }
      },
    );
  }
}
///通过provider去改变值
class AddressPickerNotifier extends ChangeNotifier{
AddressPickerNotifier({this.provinceCity,this.latitude,this.longitude,this.cityCode});

String provinceCity;

String cityCode;

double longitude;

double latitude;
void changeCityText(String city,String province){
  provinceCity = "$province $city";
  notifyListeners();
}

void changeCityCode(String citycode,double longitudeCode,double latitudeCode){
  cityCode = citycode;
  longitude = longitudeCode;
  latitude = latitudeCode;
  notifyListeners();
}

void cleanCityData(){
  provinceCity = null;
  cityCode = null;
  longitude = null;
  latitude = null;
  notifyListeners();
}

}