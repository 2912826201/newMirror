import 'package:amap_map_fluttify/amap_map_fluttify.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/location/location.api.dart';

import 'dart:io';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/page/feed/search_location.dart';
import 'package:mirror/util/screen_util.dart';

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  Location currentAddressInfo; //当前位置的信息

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  init() async {
    //flutter定位
    print("艹");
    currentAddressInfo = await AmapLocation.instance.fetchLocation();
    print("艹)))))))))))))))))))))))))");
    getLocation();
  }

  TextEditingController searchController = TextEditingController(); //搜索关键字控制器
  int pageSize = 20; //一页大小
  int pageIndex = 1; //当前页
  int pages = 1; //总页数
  List<PeripheralInformationPoi> pois = []; //返回页面显示的数据集合
  String androidAMapKey = "fef4e35be05e2337119aeb3b4e57388d"; //安卓高德key 搜索POI需要
  String iosKey = "836c55dba7d3a44793ec9ae1e1dc2e82";
  bool cityLimit = true; //仅返回指定城市数据
  getLocation() async {
    print('获取定位成功');
    aroundHttp();
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
        child: Column(
          children: <Widget>[
            //搜索框
            //输入框
            Container(
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
                              controller: searchController,
                              onSubmitted: (val) {
                                //调用搜索接口
                                if (val == null || val == "" || val.length == 0) {
                                  return;
                                } else {
                                  print('调用搜索接口');
                                  searchHttp();
                                }
                              },
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
            ),
            //数据列表
            Expanded(
                child:pois.isNotEmpty ? Container(
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView.builder(
                        itemCount: 15,
                        // shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return LocationItem(poi:pois[index]);
                        }),
                  ),
                ) : Container()
            )
          ],
        ),
        color: Colors.white,
      ),
    );
  }

  //调用接口
  Future<Null> searchHttp() async {
    pois = [];
    PeripheralInformationEntity locationInformationEntity = await searchForHttp(1);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      pageIndex = 1;
      pois = locationInformationEntity.pois;
      int total = int.parse(locationInformationEntity.count);
      //整页
      if (total % pageSize == 0) {
        pages = (total / pageSize).floor();
      } else {
        pages = (total / pageSize).floor() + 1;
      }
      setState(() {});
    } else {
      // Fluttertoast.showToast(msg: "请求失败");
    }
  }

  //加载更多
  Future<Null> onLoadMore() async {
    if (pageIndex < pages) {
      PeripheralInformationEntity locationInformationEntity = await searchForHttp(pageIndex + 1);
      if (locationInformationEntity.status == "1") {
        print('请求成功');
        pageIndex++;
        pois.addAll(locationInformationEntity.pois);
      } else {
        // Fluttertoast.showToast(msg: "请求失败");
      }
    } else {
      // Fluttertoast.showToast(msg: "没有更多数据了");
    }
  }

  //高德接口获取周边数据---不使用插件
  aroundHttp() async {
    PeripheralInformationEntity locationInformationEntity = await aroundForHttp();
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      setState(() {
        pois = locationInformationEntity.pois;
      });
      int total = int.parse(locationInformationEntity.count); //总数量
      //算页数
      if (total % pageSize == 0) {
        pages = (total / pageSize).floor();
      } else {
        pages = (total / pageSize).floor() + 1;
      }
    } else {
      // Fluttertoast.showToast(msg: "没有更多数据了");
    }
  }

  //高德接口搜索---不使用插件
  Future<PeripheralInformationEntity> searchForHttp(pageIndex) async {
    String BaseUrl = "https://restapi.amap.com/v3/place/text";
    Map<String, dynamic> map = Map();
    if (Platform.isIOS) {
      map["key"] = iosKey;
    } else {
      map["key"] = androidAMapKey;
    }
    map["keywords"] = searchController.text;
    map["city"] = currentAddressInfo.city; //搜索的城市
    map["offset"] = pageSize; //每页记录数据
    map["page"] = pageIndex; //每页记录数据
    map["citylimit"] = cityLimit; //仅返回指定城市数据
    Response resp = await Http.getInstance()
        .dio
        .get(
          BaseUrl,
          queryParameters: map,
        )
        .catchError((e) {
      print(e);
    });
    PeripheralInformationEntity baseBean = PeripheralInformationEntity.fromJson(resp.data);
    return baseBean;
  }

  //高德接口获取当前位置周边信息---不使用插件
  Future<PeripheralInformationEntity> aroundForHttp() async {
    AMapSearchAPI search = AMapSearchAPI();
    // https://restapi.amap.com/v3/place/around?key=<用户的key>&location=116.473168,39.993015&radius=10000&types=011100
    String BaseUrl = "https://restapi.amap.com/v3/place/around";
    Map<String, dynamic> map = Map();
    if (Platform.isIOS) {
      print("ios");
      map["key"] = iosKey;
    } else {
      map["key"] = androidAMapKey;
      print("androidAMapKey");
    }
    print("高德接口获取当前位置周边信息");
    print(currentAddressInfo.city);
    map["location"] =
        "${currentAddressInfo.latLng.longitude},${currentAddressInfo.latLng.latitude}"; //中心点坐标 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
    map["offset"] = pageSize; //每页记录数据
    map["page"] = pageIndex; //每页记录数据
    Response resp = await Http.getInstance()
        .dio
        .get(
          BaseUrl,
          queryParameters: map,
        )
        .catchError((e) {
      print(e);
    });
    PeripheralInformationEntity baseBean = PeripheralInformationEntity.fromJson(resp.data);
    return baseBean;
  }
}








