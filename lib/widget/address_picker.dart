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
    @required Function(String provinceCity, String cityCode, double longitude, double latitude) onConfirm,
    double bottomSheetHeight,
    String initCityCode}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.layoutBgGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AddressPicker(
            provinceMap: provinceMap,
            cityMap: cityMap,
            onConfirm: onConfirm,
            bottomSheetHeight: bottomSheetHeight,
            initCityCode: initCityCode,
          ),
        );
      });
}

class AddressPicker extends StatefulWidget {
  LinkedHashMap<int, RegionDto> provinceMap;
  Map<int, List<RegionDto>> cityMap;
  Function(String provinceCity, String cityCode, double longitude, double latitude) onConfirm;
  double bottomSheetHeight;
  String initCityCode;

  AddressPicker({this.provinceMap, this.cityMap, this.onConfirm, this.bottomSheetHeight, this.initCityCode});

  @override
  State<StatefulWidget> createState() {
    return _AddressPickerState();
  }
}

class _AddressPickerState extends State<AddressPicker> {
  FixedExtentScrollController leftfixedExtentController;
  FixedExtentScrollController rightfixedExtentController;

  bool isFirst = true;
  bool cityChange = false;
  List<String> provinceNameList = [];
  List<String> cityNameList = [];
  List<RegionDto> provinceDtoList = [];
  List<int> provinceIdList = [];
  List<RegionDto> cityDtoList = [];
  int provinceInitIndex = 0;
  int cityInitIndex = 0;

  ///从map取值
  _getAddressData() {
    widget.provinceMap.forEach((provincekey, provinceDto) {
      print('--provincekey$provincekey------provinceDto------------provinceDto-${provinceDto.toMap()}');
      provinceNameList.add(provinceDto.regionName);
      provinceIdList.add(provinceDto.id);
      provinceDtoList.add(provinceDto);
      if (widget.cityMap[provinceDto.id] != null) {
        for (int i = 0; i < widget.cityMap[provinceDto.id].length; i++) {
          if (widget.cityMap[provinceDto.id][i].regionCode == widget.initCityCode) {
            provinceInitIndex = provinceIdList.indexOf(provinceDto.id);
            continue;
          }
        }
      }else if(provinceDto.regionCode==widget.initCityCode){
        provinceInitIndex = provinceIdList.indexOf(provinceDto.id);
      }
    });
    leftfixedExtentController = FixedExtentScrollController(initialItem: provinceInitIndex);
    cityNameList.clear();
    cityDtoList.clear();
    if (widget.cityMap[provinceIdList[leftfixedExtentController.initialItem]] == null) {
      cityDtoList.add(widget.provinceMap[provinceIdList[leftfixedExtentController.initialItem]]);
      cityNameList.add(widget.provinceMap[provinceIdList[leftfixedExtentController.initialItem]].regionName);
    } else {
      for (int i = 0; i < widget.cityMap[provinceIdList[leftfixedExtentController.initialItem]].length; i++) {
        var element = widget.cityMap[provinceIdList[leftfixedExtentController.initialItem]][i];
        print('-----cityDtoList------------cityDtoList-${element.toMap()}');
        cityDtoList.add(element);
        cityNameList.add(element.regionName);
        if (element.regionCode == widget.initCityCode) {
          cityInitIndex = i;
        }
      }
    }
    rightfixedExtentController = FixedExtentScrollController(initialItem: cityInitIndex);
  }

  @override
  void initState() {
    _getAddressData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Container(
      decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      height: widget.bottomSheetHeight != null ? widget.bottomSheetHeight : 259.5 + ScreenUtil.instance.bottomBarHeight,
      width: width,
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
                      provinceCity = provinceNameList[leftfixedExtentController.selectedItem] +
                          " " +
                          cityNameList[rightfixedExtentController.selectedItem];
                    }
                    if (widget.cityMap[provinceIdList[leftfixedExtentController.selectedItem]] == null) {
                      cityCode = provinceDtoList[leftfixedExtentController.selectedItem].regionCode;
                      longitude = provinceDtoList[leftfixedExtentController.selectedItem].longitude;
                      latitude = provinceDtoList[leftfixedExtentController.selectedItem].latitude;
                    } else {
                      cityCode = cityDtoList[rightfixedExtentController.selectedItem].regionCode;
                      longitude = cityDtoList[rightfixedExtentController.selectedItem].longitude;
                      latitude = cityDtoList[rightfixedExtentController.selectedItem].latitude;
                    }
                    widget.onConfirm(provinceCity, cityCode, longitude, latitude);
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
