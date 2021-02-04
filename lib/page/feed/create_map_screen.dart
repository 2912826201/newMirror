import 'dart:io';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/location/location.api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';

class createMapScreen extends StatefulWidget {
  createMapScreen({this.latitude, this.longitude, this.keyWords});

  double longitude;
  double latitude;
  String keyWords;

  @override
  _createMapScreenState createState() => _createMapScreenState();
}

class _createMapScreenState extends State<createMapScreen> {
  AmapController _controller;
  PeripheralInformationPoi pois = PeripheralInformationPoi();

  @override
  void initState() {
    super.initState();
    aroundHttp();
  }

  // 查询定位信息
  aroundHttp() async {
    PeripheralInformationEntity locationInformationEntity = await aroundForHttp();
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      pois = locationInformationEntity.pois.first;
      setState(() {});
    } else {
      // 请求失败
    }
  }

  //高德接口获取当前位置周边信息
  Future<PeripheralInformationEntity> aroundForHttp() async {
    String BaseUrl = "https://restapi.amap.com/v3/place/around";
    Map<String, dynamic> map = Map();
    if (Platform.isIOS) {
      print("ios");
      map["key"] = Application.iosKey;
      ;
    } else {
      map["key"] = Application.androidAMapKey;
      print("androidAMapKey");
    }
    // map["keywords"] = widget.keyWords;
    map["radius"] = 100;
    map["location"] = "${widget.longitude},${widget.latitude}"; //中心点坐标 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
    map["offset"] = 20; //每页记录数据
    map["page"] = 1; //每页记录数据
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(
              "查看地图",
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
        body: widget.longitude == null && pois.name == null || pois.cityname == null || pois.adname == null || pois.address.toString() == null || pois.pname == null
            ? Container(
        )
            : ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                      height: ScreenUtil.instance.height -
                          ScreenUtil.instance.height * 0.085 -
                          kToolbarHeight -
                          ScreenUtil.instance.statusBarHeight - ScreenUtil.instance.bottomBarHeight,
                      child: AmapView(
                        /// 地图类型
                        mapType:
                            // 正常视图
                            // MapType.Standard,
                            // 公交视图
                            // MapType.Bus,
                            // '卫星视图':
                            // MapType.Satellite,
                            // '黑夜视图':
                            // MapType.Night,
                            // '导航视图':
                            MapType.Navi,

                        /// 是否显示缩放控件
                        showZoomControl: false,

                        /// 是否显示指南针控件
                        showCompass: false,

                        /// 倾斜度
                        tilt: 0,

                        /// 地图的缩放级别一共分为 17 级，从 3 到 19. 数字越大，展示的图面信息越精细
                        zoomLevel: 19,

                        /// 中心点坐标
                        centerCoordinate: LatLng(widget.latitude, widget.longitude),

                        /// [PlatformView]创建时, 会有一下的黑屏, 这里提供一个在[PlatformView]初始化时, 盖住其黑屏
                        /// 的遮罩, [maskDelay]配置延迟多少时间之后再显示地图, 默认不延迟, 即0.
                        maskDelay: Duration(milliseconds: 500),

                        /// 地图创建完成回调
                        onMapCreated: (controller) async {
                          _controller = controller;
                          // MyLocationOption(
                          //   show: true,
                          //   strokeWidth: 16,
                          //   iconProvider: AssetImage('images/test/map.png'),
                          // );
                          // await _controller?.showMyLocation(MyLocationOption(
                          //   show: true,
                          //     strokeWidth: 16,
                          //   iconProvider: AssetImage('images/test/map.png'),
                          // ));
                        },
                      )),
                  Container(
                      height: ScreenUtil.instance.height * 0.085 + ScreenUtil.instance.bottomBarHeight,
                      child: Column(
                        children: [
                          Container(
                            height: ScreenUtil.instance.height * 0.085,
                            // margin: EdgeInsets.only(left: 16, right: 16),
                            width: ScreenUtil.instance.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: Text(
                                    pois.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.textRegular16,
                                  ),
                                ),
                                SizedBox(height: 4,),
                                Container(
                                    margin: EdgeInsets.only(left: 16, right: 16),
                                    child: Text(pois.pname + pois.cityname + pois.adname + pois.address.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyle.textSecondaryRegular13))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.bottomBarHeight,
                          )
                        ],
                      ))
                ],
              ));
  }
}
