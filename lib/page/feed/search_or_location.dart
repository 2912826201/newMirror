import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchOrLocationWidget extends StatefulWidget {
  SearchOrLocationWidget({this.checkIndex, this.selectAddress});

  @override
  _SearchOrLocationWidgetState createState() => _SearchOrLocationWidgetState();

  // 展示勾选的索引
  int checkIndex;

  // 传入之前选择地址
  PeripheralInformationPoi selectAddress;
}

class _SearchOrLocationWidgetState extends State<SearchOrLocationWidget> {
  Location currentAddressInfo; //当前位置的信息

  TextEditingController searchController = TextEditingController(); //搜索关键字控制器
  int pageSize = 20; //一页大小
  int pageIndex = 1; //当前页
  int pages = 1; //总页数
  ScrollController scrollController = ScrollController(); //列表控制器
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  List<PeripheralInformationPoi> pois = []; //返回周边信息页面显示的数据集合
  List<PeripheralInformationPoi> searchPois = []; //返回搜索页面的数据集合
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
      appBar: CustomAppBar(
        titleString: "所在位置",
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            //搜索框
            Container(
              margin: const EdgeInsets.only(top: 6),
              color: AppColor.white,
              height: 44.0,
              width: ScreenUtil.instance.screenWidthDp,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    height: 32,
                    width: ScreenUtil.instance.screenWidthDp - 32,
                    decoration: BoxDecoration(
                      color: AppColor.bgWhite.withOpacity(0.65),
                      borderRadius: new BorderRadius.all(new Radius.circular(3.0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 9,
                        ),
                        AppIcon.getAppIcon(AppIcon.input_search, 24),
                        Expanded(
                          child: Container(
                            height: 32,
                            alignment: Alignment.center,
                            child: TextField(
                              controller: searchController,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                                  hintText: '搜索附近的位置',
                                  hintStyle: TextStyle(color: AppColor.textHint, fontSize: 16),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                        footer: SmartRefresherHeadFooter.init().getHeader(),
                        controller: _refreshController,
                        onLoading: onLoadMore,
                        // child: MediaQuery.removePadding(
                        //   removeTop: true,
                        //   context: context,
                        child: ListView.builder(
                            controller: scrollController,
                            itemExtent:69,
                            itemCount: searchController.text != null && searchController.text.isNotEmpty
                                ? searchPois.length
                                : pois.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      searchController.text != null && searchController.text.isNotEmpty
                                          ? searchPois[index]
                                          : pois[index],
                                    );
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
      PeripheralInformationEntity locationInformationEntity =
          await searchForHttp(searchController.text, currentAddressInfo.city, page: 1);
      if (locationInformationEntity.status == "1") {
        _refreshController.refreshCompleted();
        print('请求成功');
        pageIndex = 1;
        print(locationInformationEntity.pois);
        if (locationInformationEntity.pois.isNotEmpty) {
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
        PeripheralInformationEntity locationInformationEntity =
            await searchForHttp(searchController.text, currentAddressInfo.city, page: pageIndex + 1);
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
        PeripheralInformationEntity locationInformationEntity = await aroundForHttp(
            currentAddressInfo.latLng.longitude, currentAddressInfo.latLng.latitude,
            page: pageIndex + 1);
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
    PeripheralInformationEntity locationInformationEntity =
        await aroundForHttp(currentAddressInfo.latLng.longitude, currentAddressInfo.latLng.latitude, page: 1);
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
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColor.bgWhite, width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil.instance.width - 32 - 27 - 12,
            height: 45,
            child: locationLayout(),
          ),
          const Spacer(),
          Offstage(
            offstage: index != checkIndex,
            child: AppIcon.getAppIcon(AppIcon.check, 18, color: AppColor.mainRed),
          ),
          const SizedBox(
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
        alignment: const Alignment(-1, 0),
        child: Text(poi.name, style: AppStyle.textRegular16, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(poi.name, style: AppStyle.textRegular16, maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
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
