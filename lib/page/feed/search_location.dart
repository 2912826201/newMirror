
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/page/feed/test_location.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchLocation extends StatefulWidget {
  @override
  SearchLocationState createState() => SearchLocationState();
}

class SearchLocationState extends State<SearchLocation> {

  AmapController _controller;
  Location location;
  Dio dio = new Dio();
  @override
  void initState() {
    locationPermission();
    super.initState();
  }
  // 定位权限
  locationPermission() async {
    print("获取定位权限");
    if(mounted) {
        location = await AmapLocation.instance.fetchLocation();
        print("🌶🌶🌶🌶🌶🌶打印地址啦🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶🌶");
        print("location.cityCode:---${location.cityCode}");
        print("location.city:---${location.city}");
        print("location.address:---${location.address}");
        print("location.accuracy:---${location.accuracy}");
        print("location.altitude:---${location.altitude}");
        print("location.adCode:---${location.adCode}");
        print("location.aoiName:---${location.aoiName}");
        print("location.bearing:---${location.bearing}");
        print("location.country:---${location.country}");
        print("location.latLng:---${location.latLng}");
        print("location.poiName:---${location.poiName}");
        print("location.province:---${location.province}");
        print("location.speed:---${location.speed}");
        print("location.street:---${location.street}");
        print("location.district:___${location.district}");
        b();
      }
    }

  b() async {
    print("调用走遍");
    print(location.latLng);
    var response = await dio.get(
        "https://restapi.amap.com/v3/place/around?key=6854068676e6ca3c177da482ef13758d&location=30.547033,104.065425&keywords=&types=&radius=200&offset=20&page=1&extensions=all");
    var result = response.data;
    print('result: ${result}');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(
              "所在位置",
              style: TextStyle(color: AppColor.textPrimary1, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            backgroundColor: AppColor.white,
            leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Image.asset(
                    "images/resource/2.0x/return2x.png",
                  ),
                )),
            leadingWidth: 44.0,
            elevation: 0.5),
        body: Container(
            color: AppColor.white,
            child: Column(
              children: [
                SearchBar(),
                Expanded(
                    child: Container(
                      child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ListView.builder(
                            itemCount: 15,
                            // shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return LocationItem();
                            }),
                      ),
                    ))
              ],
            )));
  }
}

// 搜索所在位置item
class LocationItem extends StatelessWidget {
  PeripheralInformationPoi poi;
  LocationItem({this.poi});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.width,
      height: 69,
      margin: EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColor.bgWhite, width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil.instance.width - 32 - 27 - 12,
            height: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(poi.name,style: AppStyle.textRegular16,),
                Spacer(),
                Text(poi.pname + poi.cityname + poi.adname + poi.address.toString(),style: AppStyle.textSecondaryRegular13,),
              ],
            ),
          ),
          Spacer(),
          Container(
            width: 18,
            height: 18,
            color: AppColor.mainRed,
          ),
          SizedBox(
            width: 12,
          )
        ],
      ),
    );
  }
}

// // 搜索头部布局
class SearchBar extends StatefulWidget {
  SearchBar({Key key}) : super(key: key);

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  @override
  void initState() {
    controller.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 6),
      color: AppColor.white,
      height: 44.0,
      width: ScreenUtil.instance.screenWidthDp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            height: 32,
            width: ScreenUtil.instance.screenWidthDp - 32,
            decoration: BoxDecoration(
              color: AppColor.bgWhite.withOpacity(0.65),
              borderRadius: new BorderRadius.all(new Radius.circular(3.0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                Image.asset(
                  "images/resource/2.0x/search_icon_gray@2x.png",
                  width: 21,
                  height: 21,
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      decoration: new InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                          hintText: '搜索附近的位置',
                          hintStyle: TextStyle(color: AppColor.textHint, fontSize: 16),
                          border: InputBorder.none),
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
