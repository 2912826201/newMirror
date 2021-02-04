import 'package:amap_map_fluttify/amap_map_fluttify.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/location/location.api.dart';
import 'package:mirror/config/application.dart';

import 'dart:io';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TestWidget extends StatefulWidget {
  TestWidget({this.checkIndex, this.selectAddress, this.childrenACallBack});

  @override
  _TestWidgetState createState() => _TestWidgetState();

  // 展示勾选的索引
  int checkIndex;

  // 传入之前选择地址
  PeripheralInformationPoi selectAddress;

  // 定义接收父类回调函数
  ValueChanged<PeripheralInformationPoi> childrenACallBack;
}

class _TestWidgetState extends State<TestWidget> {
  Location currentAddressInfo; //当前位置的信息

  TextEditingController searchController = TextEditingController(); //搜索关键字控制器
  int pageSize = 20; //一页大小
  int pageIndex = 1; //当前页
  int pages = 1; //总页数
  ScrollController scrollController = ScrollController(); //列表控制器
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  List<PeripheralInformationPoi> pois = []; //返回周边信息页面显示的数据集合
  List<PeripheralInformationPoi> searchPois = []; //返回搜索页面的数据集合
  String androidAMapKey = "fef4e35be05e2337119aeb3b4e57388d"; //安卓高德key 搜索POI需要
  String iosKey = "836c55dba7d3a44793ec9ae1e1dc2e82";
  bool cityLimit = true; //仅返回指定城市数据

  @override
  void initState() {
    // TODO: implement initState
    if (mounted) {
      init();
    }
    searchController.addListener(() {
      String val = searchController.text;
      //调用搜索接口
      if (val == null || val == "" || val.length == 0) {
        setState(() {
          scrollController.jumpTo(0);
        });
      } else {
        print('调用搜索接口');
        scrollController.jumpTo(0);
        searchHttp();
      }
    });
    super.initState();
  }

  init() async {
    //flutter定位只能获取到经纬度信息
    currentAddressInfo = await AmapLocation.instance.fetchLocation();
    // 调用周边
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
                child: pois.isNotEmpty
                    ? SmartRefresher(
                        enablePullUp: true,
                        enablePullDown: false,
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus mode) {
                            Widget body;
                            if (mode == LoadStatus.loading) {
                              body = Text("正在加载");
                            } else if (mode == LoadStatus.idle) {
                              body = Text("上拉加载更多");
                            } else if (mode == LoadStatus.failed) {
                              body = Text("加载失败,请重试");
                            } else {
                              body = Text("没有更多了");
                            }
                            return Container(
                              child: Center(
                                child: body,
                              ),
                            );
                          },
                        ),

                        controller: _refreshController,
                        onLoading: onLoadMore,
                        // child: MediaQuery.removePadding(
                        //   removeTop: true,
                        //   context: context,
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: searchController.text != null && searchController.text.isNotEmpty
                                ? searchPois.length
                                : pois.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    widget.childrenACallBack(
                                      searchController.text != null && searchController.text.isNotEmpty
                                          ? searchPois[index]
                                          : pois[index],
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: LocationItem(
                                    poi: searchController.text != null && searchController.text.isNotEmpty
                                        ? searchPois[index]
                                        : pois[index],
                                    checkIndex: widget.checkIndex,
                                    index: index,
                                  ));
                            }),
                        // ),
                      )
                    : Container())
          ],
        ),
        color: Colors.white,
      ),
    );
  }

  //调用接口
  Future<Null> searchHttp() async {
    if (searchController.text != null && searchController.text.isNotEmpty) {
      searchPois.clear();
      PeripheralInformationEntity locationInformationEntity = await searchForHttp(1);
      if (locationInformationEntity.status == "1") {
        _refreshController.refreshCompleted();
        print('请求成功');
        pageIndex = 1;
        searchPois = locationInformationEntity.pois;
        // 城市信息导入
        PeripheralInformationPoi poi1 = PeripheralInformationPoi();
        poi1.name = searchPois.first.cityname;
        poi1.id = Application.cityId;
        poi1.citycode = locationInformationEntity.pois.first.citycode;
        // 获取城市经纬度
        Application.cityMap.forEach((key, value) {
          value.forEach((v) {
            if (v.regionCode == poi1.citycode) {
              poi1.location = v.longitude.toString() + "," + v.latitude.toString();
            }
          });
        });
        searchPois.insert(0, poi1);

        // 不显示位置
        PeripheralInformationPoi poi2 = PeripheralInformationPoi();
        poi2.name = '不显示所在位置';
        searchPois.insert(0, poi2);
        if (widget.selectAddress.id != Application.cityId && widget.selectAddress.name != null) {
          searchPois.removeWhere((v) => widget.selectAddress.id == v.id);
          searchPois.insert(1, widget.selectAddress);
        }
        int total = int.parse(locationInformationEntity.count) + 2;
        print(total);

        //整页
        if (total % pageSize == 0) {
          pages = (total / pageSize).floor();
        } else {
          pages = (total / pageSize).floor() + 1;
        }
      } else {
        _refreshController.refreshFailed();
        // Fluttertoast.showToast(msg: "请求失败");
      }
      setState(() {});
    }
  }

  //加载更多
  Future<Null> onLoadMore() async {
    if (searchController.text != null && searchController.text.isNotEmpty) {
      if (pageIndex < pages) {
        PeripheralInformationEntity locationInformationEntity = await searchForHttp(pageIndex + 1);
        if (locationInformationEntity.status == "1") {
          print('请求成功');
          pageIndex++;
          searchPois.addAll(locationInformationEntity.pois);
          if (widget.selectAddress.id != Application.cityId && widget.selectAddress.name != null) {
            searchPois.removeWhere((v) => widget.selectAddress.id == v.id);
            searchPois.insert(1, widget.selectAddress);
          }
          _refreshController.loadComplete();
        } else {
          // Fluttertoast.showToast(msg: "请求失败");
          _refreshController.loadFailed();
        }
      } else {
        // Fluttertoast.showToast(msg: "没有更多数据了");
        _refreshController.loadNoData();
      }
    } else {
      if (pageIndex < pages) {
        PeripheralInformationEntity locationInformationEntity = await aroundForHttp(pageIndex + 1);
        if (locationInformationEntity.status == "1") {
          print('请求成功');
          pageIndex++;
          pois.addAll(locationInformationEntity.pois);
          if (widget.selectAddress.id != Application.cityId && widget.selectAddress.name != null) {
            pois.removeWhere((v) => widget.selectAddress.id == v.id);
            pois.insert(1, widget.selectAddress);
          }
          _refreshController.loadComplete();
        } else {
          // Fluttertoast.showToast(msg: "请求失败");
          _refreshController.loadFailed();
        }
      } else {
        _refreshController.loadNoData();
      }
    }
    setState(() {});
  }

  //高德接口获取周边数据
  aroundHttp() async {
    PeripheralInformationEntity locationInformationEntity = await aroundForHttp(1);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      pois = locationInformationEntity.pois;
      // 城市赋值搜索时要用。
      currentAddressInfo.city = pois.first.cityname;
      // 城市信息导入
      PeripheralInformationPoi poi1 = PeripheralInformationPoi();
      poi1.name = locationInformationEntity.pois.first.cityname;
      poi1.id = Application.cityId;
      poi1.citycode = locationInformationEntity.pois.first.citycode;
      // 获取城市经纬度
      Application.cityMap.forEach((key, value) {
        value.forEach((v) {
          if (v.regionCode == poi1.citycode) {
            poi1.location = v.longitude.toString() + "," + v.latitude.toString();
          }
        });
      });
      pois.insert(0, poi1);
      // 不显示位置
      PeripheralInformationPoi poi2 = PeripheralInformationPoi();
      poi2.name = '不显示所在位置';
      pois.insert(0, poi2);
      if (widget.selectAddress.id != Application.cityId && widget.selectAddress.name != null) {
        pois.removeWhere((v) => widget.selectAddress.id == v.id);
        pois.insert(1, widget.selectAddress);
      }
      // print(pois.length);
      // pois.forEach((v) {
      //   print(v.toString());
      // });
      setState(() {});
      int total = int.parse(locationInformationEntity.count) + 2; //总数量
      print(total);
      //算页数
      if (total % pageSize == 0) {
        pages = (total / pageSize).floor();
      } else {
        pages = (total / pageSize).floor() + 1;
      }
    } else {
      // 请求失败
      _refreshController.loadFailed();
    }
  }

  //高德接口搜索
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
    print(currentAddressInfo.city);
    map["offset"] = pageSize; //每页记录数据
    map["page"] = pageIndex; //每页记录数据
    map["citylimit"] = cityLimit; //仅返回指定城市数据
    map["extensions"] = "all";
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

  //高德接口获取当前位置周边信息
  Future<PeripheralInformationEntity> aroundForHttp(pageIndex) async {
    String BaseUrl = "https://restapi.amap.com/v3/place/around";
    Map<String, dynamic> map = Map();
    if (Platform.isIOS) {
      print("ios");
      map["key"] = iosKey;
    } else {
      map["key"] = androidAMapKey;
      print("androidAMapKey");
    }
    map["location"] =
        "${currentAddressInfo.latLng.longitude},${currentAddressInfo.latLng.latitude}"; //中心点坐标 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
    map["offset"] = pageSize; //每页记录数据
    map["page"] = pageIndex; //每页记录数据
    map["extensions"] = "all";
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

// 搜索所在位置item
class LocationItem extends StatelessWidget {
  PeripheralInformationPoi poi;
  int index;

  // 展示勾选的索引
  int checkIndex;

  LocationItem({this.poi, this.index, this.checkIndex});

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
            child: locationLayout(),
          ),
          Spacer(),
          Offstage(
            offstage: index != checkIndex,
            child: Icon(
              Icons.clear,
              size: 18,
              color: AppColor.mainRed,
            ),
          ),
          SizedBox(
            width: 12,
          )
        ],
      ),
    );
  }

  // 内部布局
  locationLayout() {
    print("checkIndex￥$checkIndex");
    print(poi.toString());
    if (poi.id == Application.cityId || index == 0) {
      return Container(
        alignment: Alignment(-1, 0),
        child: Text(poi.name, style: AppStyle.textRegular16, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(poi.name, style: AppStyle.textRegular16, maxLines: 1, overflow: TextOverflow.ellipsis),
          Spacer(),
          Text(
            poi.pname + poi.cityname + poi.adname + poi.address.toString(),
            style: AppStyle.textSecondaryRegular13,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
  }
}
