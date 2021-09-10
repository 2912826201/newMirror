// 周边地址信息
import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/api/location/location.api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef SeletedAddress = void Function(PeripheralInformationPoi poi);

Future openSurroundingInformationBottomSheet({
  @required BuildContext context,
  SeletedAddress onSeletedAddress,
  double bottomSheetHeight,
}) async {
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
        return SizedBox(
          height: bottomSheetHeight != null ? bottomSheetHeight : ScreenUtil.instance.height * 0.75,
          child: SurroundingInformationPage(
            onSeletedAddress: onSeletedAddress,
          ),
        );
      });
}

class SurroundingInformationPage extends StatefulWidget {
  SeletedAddress onSeletedAddress;
  bool isChangeAddress;
  ActivityModel activityModel;

  SurroundingInformationPage({this.onSeletedAddress, this.activityModel, this.isChangeAddress = false});

  @override
  _SurroundingInformationPageState createState() => _SurroundingInformationPageState();
}

class _SurroundingInformationPageState extends State<SurroundingInformationPage> {
  //当前位置的信息
  Location currentAddressInfo;
  TextEditingController searchController = TextEditingController(); //搜索关键字控制器
  int pageSize = 20; //一页大小
  int pageIndex = 1; //当前页
  int pages = 1; //总页数
  ScrollController scrollController = ScrollController(); //列表控制器
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  List<PeripheralInformationPoi> pois = []; //返回周边信息页面显示的数据集合
  List<PeripheralInformationPoi> searchPois = []; //返回搜索页面的数据集合
  bool cityLimit = true; //仅返回指定城市数据
  String searchText = ""; // 记录上一次的搜索文本
  String searchCity = ""; // 城市赋值搜索时要用。
  // 活动更改地点提示文本
  String activityPromptText = '活动开始三小时内不能修改活动地点，且只能修改一次！';
  String activityTitle;
  String activityTitle1;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      init();
    }
    if (widget.isChangeAddress) {
      interceptText();
    }
    searchController.addListener(() {
      String val = searchController.text;
      print("val:::::::$val");
      //调用搜索接口
      if (val == null || val == "" || val.length == 0) {
        setState(() {
          scrollController.jumpTo(0);
        });
      } else if (searchText != val) {
        print('调用搜索接口');
        scrollController.jumpTo(0);
        searchHttp();
      }
    });
  }

  init() async {
    //flutter定位只能获取到经纬度信息
    currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
    // 调用周边
    aroundHttp();
  }

  //调用接口
  Future<Null> searchHttp() async {
    if (searchController.text != null && searchController.text.isNotEmpty) {
      PeripheralInformationEntity locationInformationEntity =
          await searchForHttp(searchController.text, searchCity, page: 1);
      searchText = searchController.text;
      searchPois.clear();
      if (locationInformationEntity.status == "1") {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
        print('请求成功');
        pageIndex = 1;
        print(locationInformationEntity.pois);
        if (locationInformationEntity.pois.isNotEmpty) {
          searchPois = locationInformationEntity.pois;
          int total = int.parse(locationInformationEntity.count);
          print(total);

          //整页
          if (total % pageSize == 0) {
            pages = (total / pageSize).floor();
          } else {
            pages = (total / pageSize).floor() + 1;
          }
        }
        if (mounted) {
          setState(() {});
        }
      } else {
        _refreshController.refreshFailed();
      }
    }
  }

  //加载更多
  Future<Null> onLoadMore() async {
    print("pageIndex::::::$pageIndex");
    print("pages::::::$pages");
    if (searchController.text != null && searchController.text.isNotEmpty) {
      if (pageIndex < pages) {
        PeripheralInformationEntity locationInformationEntity =
            await searchForHttp(searchController.text, searchCity, page: pageIndex + 1);
        if (locationInformationEntity.status == "1") {
          print('请求成功');
          pageIndex++;
          searchPois.addAll(locationInformationEntity.pois);
          _refreshController.loadComplete();
        } else {
          _refreshController.loadFailed();
        }
      } else {
        _refreshController.loadNoData();
      }
    } else {
      print("搜索文案为空");
      if (pageIndex < pages) {
        PeripheralInformationEntity locationInformationEntity =
            await aroundForHttp(currentAddressInfo.longitude, currentAddressInfo.latitude, page: pageIndex + 1);
        if (locationInformationEntity.status == "1") {
          print('请求成功');
          pageIndex++;
          pois.addAll(locationInformationEntity.pois);
          _refreshController.loadComplete();
        } else {
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
        await aroundForHttp(currentAddressInfo.longitude, currentAddressInfo.latitude, page: 1);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      pois = locationInformationEntity.pois;
      // 城市赋值搜索时要用。
      searchCity = pois.first.cityname;
      int total = int.parse(locationInformationEntity.count); //总数量
      print(total);
      //算页数
      if (total % pageSize == 0) {
        pages = (total / pageSize).floor();
      } else {
        pages = (total / pageSize).floor() + 1;
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      // 请求失败
      _refreshController.loadFailed();
    }
  }

  // 输入框
  Widget searchBar() {
    return Container(
      height: 68,
      alignment: Alignment.center,
      child: //搜索框
          Container(
        height: 44.0,
        width: ScreenUtil.instance.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 12),
              height: 32,
              width: ScreenUtil.instance.width - 32,
              decoration: BoxDecoration(
                color: AppColor.white.withOpacity(0.1),
                borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 4,
                  ),
                  AppIcon.getAppIcon(AppIcon.input_search, 24, color: AppColor.textWhite60),
                  Expanded(
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        // 光标颜色
                        cursorColor: AppColor.white,
                        style: AppStyle.whiteRegular16,
                        decoration: const InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                            hintText: '输入地址',
                            hintStyle: AppStyle.text1Regular12,
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
    );
  }

  // 更改地点弹窗
  Widget changeLocationPopup(PeripheralInformationPoi peripheralInformationPoi) {
    return showAppDialog(context,
        title: "更改地点",
        info: "活动地点由${widget.activityModel.address ?? "福年广场"}变更为 ${peripheralInformationPoi.name}",
        confirmColor: AppColor.mainYellow,
        poi: peripheralInformationPoi,
        cancel: AppDialogButton("取消", () {
          return true;
        }),
        confirm: AppDialogButton("确定", () {
          Navigator.pop(context);
          return true;
        }));
  }

  Widget createMiddleView() {
    return //数据列表
        Expanded(
            child: pois.isNotEmpty
                ? SmartRefresher(
                    enablePullUp: true,
                    enablePullDown: false,
                    footer: SmartRefresherHeadFooter.init().getFooter(),
                    controller: _refreshController,
                    onLoading: onLoadMore,
                    child: ListView.builder(
                        controller: scrollController,
                        // itemExtent: widget.isChangeAddress ? 48 : 68,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: searchController.text != null && searchController.text.isNotEmpty
                            ? searchPois.length
                            : pois.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (widget.isChangeAddress) {
                                  changeLocationPopup(searchController.text != null && searchController.text.isNotEmpty
                                      ? searchPois[index]
                                      : pois[index]);
                                } else {
                                  if (searchController.text != null && searchController.text.isNotEmpty) {
                                    widget.onSeletedAddress(searchPois[index]);
                                  } else {
                                    widget.onSeletedAddress(pois[index]);
                                  }
                                  Navigator.pop(
                                    context,
                                  );
                                }
                              },
                              child: SurroundingLocationItem(
                                poi: searchController.text != null && searchController.text.isNotEmpty
                                    ? searchPois[index]
                                    : pois[index],
                                isChangeAddress: widget.isChangeAddress,
                              ));
                        }),
                  )
                : Container());
  }

  // 截取文本
  interceptText() {
    // 剩余宽度
    double remainingWidth = ScreenUtil.instance.width - 32 - 16 - 10;
    // 文本总宽度
    double totalTextWidth = 0.0;
    activityPromptText.runes.forEach((element) {
      // 文本宽度
      double textWidth;
      textWidth = getTextSize(String.fromCharCode(element), AppStyle.text1Regular14, 1).width;
      totalTextWidth += textWidth;
      if (totalTextWidth > remainingWidth) {
        if (activityTitle1 == null) {
          activityTitle1 = '';
        }
        activityTitle1 += String.fromCharCode(element);
      } else {
        if (activityTitle == null) {
          activityTitle = '';
        }
        activityTitle += String.fromCharCode(element);
      }
    });
  }

  // 标题横向布局
  titleHorizontalLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppIcon.getAppIcon(
          AppIcon.error_circle,
          16,
          color: AppColor.mainRed,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          children: [
            Container(
              width: ScreenUtil.instance.width - 32 - 16 - 10,
              child: Text(
                activityTitle,
                style: AppStyle.text1Regular14,
                maxLines: 1,
              ),
            ),
          ],
        )
      ],
    );
  }

// 标题纵向布局
  titleVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHorizontalLayout(),
        Container(
          width: ScreenUtil.instance.width - 32 - 16 - 10,
          margin: EdgeInsets.only(left: 26),
          child: Text(
            activityTitle1,
            style: AppStyle.text1Regular14,
            maxLines: 1,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          widget.isChangeAddress
              ? //搜索框
              Container(
                  margin: const EdgeInsets.only(top: 6),
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
                          color: AppColor.white.withOpacity(0.1),
                          borderRadius: new BorderRadius.all(new Radius.circular(3.0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 9,
                            ),
                            AppIcon.getAppIcon(AppIcon.input_search, 24, color: AppColor.textWhite60),
                            Expanded(
                              child: Container(
                                height: 32,
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: searchController,
                                  textInputAction: TextInputAction.search,
                                  // 光标颜色
                                  cursorColor: AppColor.white,
                                  style: AppStyle.whiteRegular16,
                                  decoration: const InputDecoration(
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                                      hintText: '输入新的地点',
                                      hintStyle: AppStyle.text1Regular16,
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
                )
              : searchBar(),
          widget.isChangeAddress
              ? Container(
                  width: ScreenUtil.instance.width - 32,
                  margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: activityTitle1 != null && activityTitle1.length > 0
                      ? titleVerticalLayout()
                      : titleHorizontalLayout(),
                )
              : Container(),
          createMiddleView(),
        ],
      ),
    );
  }
}

class SurroundingLocationItem extends StatelessWidget {
  PeripheralInformationPoi poi;
  bool isChangeAddress;

  SurroundingLocationItem({this.poi, this.isChangeAddress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: ScreenUtil.instance.width,
          height: 48,
          // decoration: BoxDecoration(
          //     border: Border(bottom: BorderSide(color: AppColor.dividerWhite8, width: 0.5))),
          margin: isChangeAddress ? EdgeInsets.only(left: 28, right: 28) : EdgeInsets.only(left: 12, right: 12),
          alignment: Alignment(-1, 0),
          child: Text(poi.name,
              style: isChangeAddress ? AppStyle.whiteRegular16 : AppStyle.whiteRegular14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        Container(
          height: 8,
        )
      ],
    );
  }
}
