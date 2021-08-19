import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

import 'overscroll_behavior.dart';

//城市选择底部弹窗
Future openaddressPickerBottomSheet(
    {@required BuildContext context,
    @required LinkedHashMap<int, RegionDto> provinceMap,
    @required Map<int, List<RegionDto>> cityMap,
    @required Function(String provinceCity, String cityCode, double longitude, double latitude) onConfirm}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AddressPicker(
            provinceMap: provinceMap,
            cityMap: cityMap,
            onConfirm: onConfirm,
          ),
        );
      });
}

class AddressPicker extends StatefulWidget {
  LinkedHashMap<int, RegionDto> provinceMap;
  Map<int, List<RegionDto>> cityMap;
  Function(String provinceCity, String cityCode, double longitude, double latitude) onConfirm;

  AddressPicker({this.provinceMap, this.cityMap, this.onConfirm});

  @override
  State<StatefulWidget> createState() {
    return _AddressPickerState();
  }
}

class _AddressPickerState extends State<AddressPicker> {
  FixedExtentScrollController leftfixedExtentController = FixedExtentScrollController(initialItem: 0);
  FixedExtentScrollController rightfixedExtentController = FixedExtentScrollController(initialItem: 0);
  bool isFirst = true;
  bool cityChange = false;
  List<String> provinceNameList = [];
  List<String> cityNameList = [];
  List<RegionDto> provinceDtoList = [];
  List<int> provinceIdList = [];
  List<RegionDto> cityDtoList = [];



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
      height: 259.5 + ScreenUtil.instance.bottomBarHeight,
      width: width,
      color: AppColor.layoutBgGrey,
      child: Column(
        children: [
          Container(
            height: 42,
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Row(
              children: [
                InkWell(
                  child: Text(
                    "取消",
                    style: AppStyle.whiteRegular17,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: () {
                    String provinceCity;
                    String cityCode;
                    double longitude;
                    double latitude;
                    if (cityNameList[rightfixedExtentController.selectedItem] ==
                        provinceNameList[leftfixedExtentController.selectedItem]) {
                      provinceCity = cityNameList[rightfixedExtentController.selectedItem];
                    } else {
                      provinceCity =provinceNameList[leftfixedExtentController.selectedItem]
                          +" "+cityNameList[rightfixedExtentController.selectedItem];
                    }
                    if (widget.cityMap[provinceIdList[leftfixedExtentController.selectedItem]] == null) {
                      cityCode = provinceDtoList[leftfixedExtentController.selectedItem].regionCode;
                      longitude = provinceDtoList[leftfixedExtentController.selectedItem].longitude;
                      latitude = provinceDtoList[leftfixedExtentController.selectedItem].latitude;
                    } else {
                      cityCode =  cityDtoList[rightfixedExtentController.selectedItem].regionCode;
                      longitude = cityDtoList[rightfixedExtentController.selectedItem].longitude;
                      latitude =cityDtoList[rightfixedExtentController.selectedItem].latitude;
                    }
                    widget.onConfirm(
                      provinceCity,
                      cityCode,
                      longitude,
                      latitude
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    "确定",
                    style: AppStyle.redRegular17,
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: _addressList(leftfixedExtentController, provinceNameList, 1),
                  flex: 1,
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: _addressList(rightfixedExtentController, cityNameList, 2),
                  flex: 1,
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _addressList(FixedExtentScrollController controller, List textContext, int type) {
    return CupertinoPicker(
      backgroundColor: AppColor.layoutBgGrey,
      scrollController: controller,
      squeeze: 0.95,
      diameterRatio: 1.5,
      itemExtent: 42,
      //循环
      looping: false,
      selectionOverlay: null,
      children: List<Widget>.generate(
        textContext.length,
        (index) {
          return Container(
            child: Center(
              child: Text("${textContext[index]}", style: AppStyle.whiteRegular17),
            ),
          );
        },
      ),
      onSelectedItemChanged: (index) {
        if (type == 1) {
          cityNameList.clear();
          cityDtoList.clear();
          if (widget.cityMap[provinceIdList[index]] == null) {
            cityDtoList.add(widget.provinceMap[provinceIdList[index]]);
            cityNameList.add(widget.provinceMap[provinceIdList[index]].regionName);
            print(
                'cityName======================================${widget.provinceMap[provinceIdList[index]].regionName}');
          } else {
            widget.cityMap[provinceIdList[index]].forEach((element) {
              cityDtoList.add(element);
              cityNameList.add(element.regionName);
            });
          }
          rightfixedExtentController.jumpToItem(0);
          setState(() {});
        }
      },
    );
  }
}

