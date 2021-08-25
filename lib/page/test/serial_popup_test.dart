import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';

Future openSerialPopupBottom({
  @required BuildContext context,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: AppColor.layoutBgGrey,
    // 圆角
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (BuildContext context) {
      // return SingleChildScrollView(
      return SerialPopupPage();
    },
  );
}

class SerialPopupPage extends StatefulWidget {
  @override
  _SerialPopupPageState createState() => _SerialPopupPageState();
}

class _SerialPopupPageState extends State<SerialPopupPage> {
  List<String> oneName = ["站内好友", "微信好友", "朋友圈", "微博", "QQ好友", "QQ空间"];
  List<String> oneIcon = [
    AppIcon.share_friend_circle,
    AppIcon.share_wechat_circle,
    AppIcon.share_moment_circle,
    AppIcon.share_weibo_circle,
    AppIcon.share_qq_circle,
    AppIcon.share_qzone_circle,
  ];
  List<ShareViewModel> shareViewModel = [];
  double PopupHeight = 48 + 88 + 8 + 48 + ScreenUtil.instance.bottomHeight;

  // 几个Item
  var itemCount;
  bool qqqq = false;
  // 每个底部item的高度
  double itemHeight = 50;
 List<String> twoList = ["item0","item1","item2","item3","item4","item5"];
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < oneName.length; i++) {
      ShareViewModel a = ShareViewModel(name: oneName[i], icon: oneIcon[i]);
      shareViewModel.add(a);
    }
  }

  onePopup() {
    return Column(
      children: [
        Container(
          height: 48,
          child: Center(
            child: const Text(
              "分享到",
              style: AppStyle.whiteRegular16,
            ),
          ),
        ),
        Container(
          height: 88,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: shareViewModel.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    switch (shareViewModel[index].name) {
                      case "站内好友":
                        // Navigator.of(context).pop(1);
                        // showSharePopup(context, map, chatTypeModel);
                        // AppRouter.navigateFriendsPage(context: context,shareMap: map,chatTypeModel: chatTypeModel);
                      setState(() {
                        itemCount = twoList.length;
                        PopupHeight =  ((itemCount + 1) * 50 + 12 + ScreenUtil.instance.bottomBarHeight).toDouble();
                         qqqq= true;
                      });
                        break;
                      case "保存本地":
                        Navigator.of(context).pop(1);
                        break;
                      case "动态":
                        break;
                      case "微信好友":
                        Navigator.of(context).pop(1);
                        break;
                      case "朋友圈":
                        Navigator.of(context).pop(1);
                        break;
                      case "微博":
                        Navigator.of(context).pop(1);
                        break;
                      case "QQ好友":
                        Navigator.of(context).pop(1);
                        break;
                      case "QQ空间":
                        Navigator.of(context).pop(1);
                        break;
                      default:
                        Navigator.of(context).pop(1);
                        break;
                    }
                  },
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: index > 0 ? 32 : 16,
                              right: index == shareViewModel.length - 1 ? 16 : 0,
                              top: 8,
                              bottom: 8),
                          height: 48,
                          width: 48,
                          child: AppIcon.getAppIcon(shareViewModel[index].icon, 48),
                        ),
                        Container(
                          width: 48,
                          margin: EdgeInsets.only(
                            left: index > 0 ? 32 : 16,
                            right: index == shareViewModel.length - 1 ? 16 : 0,
                          ),
                          child: Center(
                            child: Text(
                              shareViewModel[index].name,
                              style: AppStyle.whiteRegular12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
        Container(
          width: ScreenUtil.instance.screenWidthDp,
          height: 8,
          color: AppColor.mainBlack,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 48,
            width: ScreenUtil.instance.screenWidthDp,
            child: Center(
              child: Text(
                "取消",
                style: TextStyle(fontSize: 17, color: AppColor.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  twoPopup() {
    // 获取设备的宽度
    var deviceWidth = MediaQuery.of(context).size.width;
    // print("宽度$deviceWidth");
    /*
    区分刘海屏
     */
    // 获取底部间距
    final double bottomPadding = ScreenUtil.instance.bottomBarHeight;
    // 获取顶部间距
    final double topPanding = ScreenUtil.instance.statusBarHeight;
    int listLength = twoList.length;

    /// 最后还有一个cancel，所以加1
    itemCount = listLength + 1;
    // 算出弹窗总高度
    var height;
    height = ((listLength + 1) * 50 + 12 + bottomPadding).toDouble();

    // 取消Item
    var cancelContainer = Container(
        height: itemHeight + 12 + bottomPadding,
        decoration: const BoxDecoration(
          color: AppColor.layoutBgGrey, // 底色
        ),
        child: Column(
          children: [
            // 取消上面的分割块
            Container(
              height: 8,
              color: AppColor.mainBlack,
            ),
            Container(
              height: 50,
              child: GestureDetector(
                // 点击空白区域点击无效，事件不响应。此属性可以扩大点击范围,让自身整个区域都响应点击事件。
                // HitTestBehavior.opaque 和HitTestBehavior.translucent不同点在于opaque会阻挡下一层元素获得事件，而translucent不会
                // 因为opaque会修改hitTestSelf的返回值，让自己通过测试进而让父类结束对其它子类的碰撞测试
                // HitTestBehavior.translucent的穿透是有条件的，只能在"空白区域"穿透。这里的空白区域是指点击的区域没有child可以通过碰撞测试
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                  print("点击了吗");
                },
                child: Center(
                  child: const Text(
                    "取消",
                    style: TextStyle(color: AppColor.white, fontSize: 17),
                  ),
                ),
              ),
            ),
            Container(
              height: bottomPadding,
            )
          ],
        ));
    // itemlist创建视图
    var listview = ListView.builder(
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if (index == itemCount - 1) {
            return new Container(
              child: cancelContainer,
            );
          }
          return getItemContainer(context, index, listLength);
        });
    // 组合
    var totalContainer = Container(
      child: listview,
      height: height,
      width: deviceWidth,
    );
    return totalContainer;
  }

  // 创建其他传入的Item
  Widget getItemContainer(BuildContext context, int index, int listLength) {
    if (twoList == null) {
      return Container();
    }
    var text = twoList[index];
    var contentText = Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.normal, decoration: TextDecoration.none, color: AppColor.white, fontSize: 17),
    );

    var decoration;

    var center;
    var itemContainer;
    center = Center(
      child: contentText,
    );
    var onTap2 = () {
      // if (onItemClickListener != null) {
      //   Navigator.pop(context);
      //   onItemClickListener(index);
      // }
      if(index == 0) {
        twoList.removeWhere((element) => twoList.indexOf(element) > 3);
        setState(() {
          itemCount = twoList.length;
          PopupHeight =  ((itemCount + 1) * 50 + 12 + ScreenUtil.instance.bottomBarHeight).toDouble();
        });
      }
    };
    // 除开取只有一个时
    if (listLength == 1) {
      decoration = const BoxDecoration(
        color: AppColor.layoutBgGrey, // 底色
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      );
    } else if (listLength > 1) {
      // 除开取消的最后一个
      if (index == listLength - 1) {
        decoration = const BoxDecoration(
          border: Border(top: BorderSide(width: 0.5, color: AppColor.mainBlack)),
          color: AppColor.layoutBgGrey, // 底色
        );
      } else if (index >= 1) {
        decoration = const BoxDecoration(
          color: AppColor.layoutBgGrey, // 底色
          border: Border(top: BorderSide(width: 0.5, color: AppColor.mainBlack)),
        );
      }
    }
    itemContainer = Container(height: itemHeight, decoration: decoration, child: center);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap2,
      child: itemContainer,
    );
  }

  threePopup() {}

  FourPopup() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      height: PopupHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: qqqq ? twoPopup() : onePopup(),
    );
  }
}
