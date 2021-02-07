import 'dart:io';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/location/location.api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';

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
  String formatted_address;

  @override
  void initState() {
    aroundHttp();
    super.initState();
  }

  // 查询定位信息
  aroundHttp() async {
    PeripheralInformationEntity locationInformationEntity = await reverseGeographyHttp();
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      formatted_address = locationInformationEntity.regeocode.formatted_address;
      print(formatted_address);
      if (mounted) {
        setState(() {});
      }
    } else {
      // 请求失败
    }
  }

  // 逆地理编码
  Future<PeripheralInformationEntity> reverseGeographyHttp() async {
    String BaseUrl = "https://restapi.amap.com/v3/geocode/regeo";
    Map<String, dynamic> map = Map();
    map["key"] = AppConfig.getAmapKey();
    map["location"] = "${widget.longitude},${widget.latitude}"; //中心点坐标 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
    map["batch"] = false;
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
        appBar: CustomAppBar(
          titleString: "查看地图",
        ),
        body: widget.longitude == null ||
                formatted_address == null ||
                formatted_address.isEmpty ||
                widget.keyWords == null
            ? Container()
            : ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                      height: ScreenUtil.instance.height -
                          ScreenUtil.instance.height * 0.085 -
                          kToolbarHeight -
                          ScreenUtil.instance.statusBarHeight -
                          ScreenUtil.instance.bottomBarHeight,
                      child: AmapView(
                        /// 地图类型
                        mapType:
                            // 正常视图
                            MapType.Standard,
                        // 公交视图
                        // MapType.Bus,
                        // '卫星视图':
                        // MapType.Satellite,
                        // '黑夜视图':
                        // MapType.Night,
                        // '导航视图':
                        // MapType.Navi,

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

                        /// 标记
                        markers: [
                          MarkerOption(
                            coordinate: LatLng(widget.latitude, widget.longitude),
                            widget: Image.asset(
                              'images/test/map.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ],

                        /// 地图创建完成回调
                        onMapCreated: (controller) async {
                          _controller = controller;
                          // 标记
                          _controller.addMarker(
                            MarkerOption(
                              coordinate: LatLng(widget.latitude, widget.longitude),
                              widget: Image.asset(
                                'images/test/map.png',
                                width: 36,
                                height: 36,
                              ),
                            ),
                          );
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
                                    widget.keyWords,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.textRegular16,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 16, right: 16),
                                    child: Text(formatted_address,
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
