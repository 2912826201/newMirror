import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_location_muka/amap_location_muka.dart' hide LatLng;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:permission_handler/permission_handler.dart';

class createMapScreen extends StatefulWidget {
  createMapScreen({this.latitude, this.longitude, this.keyWords});

  double longitude;
  double latitude;
  String keyWords;

  @override
  _createMapScreenState createState() => _createMapScreenState();
}

class _createMapScreenState extends State<createMapScreen> {
  AMapController _controller;
  String formatted_address;
  Location currentAddressInfo; //当前位置的信息
  // List<MarkerOption> markers = [];
  Set<Marker> markerSet = Set();

  @override
  void initState() {
    aroundHttp();

    //flutter定位只能获取到经纬度信息
    super.initState();
  }

  // 查询定位信息
  aroundHttp() async {
    Marker marker = Marker(position: LatLng(widget.latitude, widget.longitude));
    markerSet.add(marker);
    // 获取权限状态
    PermissionStatus permissions = await Permission.locationWhenInUse.status;
    // 用户授予了对所请求功能的访问权限
    if (permissions == PermissionStatus.granted) {
      //flutter定位只能获取到经纬度信息
      currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
      Marker marker = Marker(
          position: LatLng(currentAddressInfo.latitude, currentAddressInfo.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));
      markerSet.add(marker);
      print("currentAddressInfo ::::${currentAddressInfo.toJson()}");
      // markers.add(MarkerOption(
      //   coordinate: LatLng(currentAddressInfo?.latLng?.latitude, currentAddressInfo?.latLng?.longitude),
      //   widget: AppIcon.getAppIcon(
      //     AppIcon.pin_map_self,
      //     36,
      //   ),
      // ));
    }
    PeripheralInformationEntity locationInformationEntity =
        await reverseGeographyHttp(widget.longitude, widget.latitude);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      formatted_address = locationInformationEntity.regeocode.formatted_address;
      // markers.add(MarkerOption(
      //   coordinate: LatLng(widget.latitude, widget.longitude),
      //   widget: AppIcon.getAppIcon(
      //     AppIcon.pin_map,
      //     36,
      //   ),
      // ));
      print(formatted_address);
    } else {
      // 请求失败
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition _kInitialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 19.0,
    );
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          titleString: "查看地图",
        ),
        body: widget.longitude == null ||
                formatted_address == null ||
                formatted_address.isEmpty ||
                widget.keyWords == null
            ? Container(
                width: ScreenUtil.instance.width,
                height: ScreenUtil.instance.height,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ))
            : ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    height: ScreenUtil.instance.height -
                        ScreenUtil.instance.height * 0.085 -
                        kToolbarHeight -
                        ScreenUtil.instance.statusBarHeight -
                        ScreenUtil.instance.bottomBarHeight,
                    child: AMapWidget(
                      initialCameraPosition: _kInitialPosition,
                      mapType: MapType.normal,
                      markers: markerSet,
                      // scaleEnabled: ,
                    ),
                    // child: AmapView(
                    //   /// 地图类型
                    //   mapType:
                    //       // 正常视图
                    //       MapType.Standard,
                    //   // 公交视图
                    //   // MapType.Bus,
                    //   // '卫星视图':
                    //   // MapType.Satellite,
                    //   // '黑夜视图':
                    //   // MapType.Night,
                    //   // '导航视图':
                    //   // MapType.Navi,
                    //
                    //   /// 是否显示缩放控件
                    //   showZoomControl: false,
                    //
                    //   /// 是否显示指南针控件
                    //   showCompass: false,
                    //
                    //   /// 倾斜度
                    //   tilt: 0,
                    //
                    //   /// 地图的缩放级别一共分为 17 级，从 3 到 19. 数字越大，展示的图面信息越精细
                    //   zoomLevel: 19,
                    //
                    //   /// 中心点坐标
                    //   centerCoordinate: LatLng(widget.latitude, widget.longitude),
                    //
                    //   /// [PlatformView]创建时, 会有一下的黑屏, 这里提供一个在[PlatformView]初始化时, 盖住其黑屏
                    //   /// 的遮罩, [maskDelay]配置延迟多少时间之后再显示地图, 默认不延迟, 即0.
                    //   maskDelay: Duration(milliseconds: 500),
                    //
                    //   /// 标记
                    //   markers: markers,
                    //   // onMapClicked: (latLng) async{
                    //   //   print("点击");
                    //   //   MarkerOption option = MarkerOption(
                    //   //     coordinate: LatLng(latLng.latitude, latLng.longitude),
                    //   //     widget: AppIcon.getAppIcon(
                    //   //       AppIcon.pin_map,
                    //   //       36,
                    //   //     ),
                    //   //   );
                    //   //   _controller.addMarker(option);
                    //   // },
                    //   /// 地图创建完成回调
                    //   onMapCreated: (controller) async {
                    //     _controller = controller;
                    //     // 标记
                    //     _controller.addMarkers(markers);
                    //   },
                    // )
                  ),
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
                                  margin: const EdgeInsets.only(left: 16, right: 16),
                                  child: Text(
                                    widget.keyWords,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.textRegular16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Container(
                                    margin: const EdgeInsets.only(left: 16, right: 16),
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
