import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';

class SearchLocation extends StatefulWidget {
  @override
  SearchLocationState createState() => SearchLocationState();
}

class SearchLocationState extends State<SearchLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
            titleString: "所在位置",
        ),
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
                Text("牛水煮·麻辣水煮牛肉(天府三街旗舰店）",style: AppStyle.textRegular16,),
                Spacer(),
                Text("四川省成都市武侯区天府三街69号新希望国际b座...",style: AppStyle.textSecondaryRegular13,),
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
