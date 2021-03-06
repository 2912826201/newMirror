import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import '../bottom_sheet.dart';

typedef OnItemClickListener = void Function(int index);

Future openMoreBottomSheet({
  @required BuildContext context,
  @required OnItemClickListener onItemClickListener,
  @required List<String> lists,
  bool isFillet = true,
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
        return SingleChildScrollView(
            child: BottomPopup(
          list: lists,
          isFillet: isFillet,
          onItemClickListener: onItemClickListener,
        ));
      });
}

// 底部弹窗
class BottomPopup extends StatefulWidget {
  BottomPopup({Key key, this.list, this.isFillet, this.onItemClickListener})
      : assert(list != null),
        super(key: key);
  List<String> list;
  bool isFillet;
  OnItemClickListener onItemClickListener;

  @override
  BottomopupState createState() => BottomopupState();
}

class BottomopupState extends State<BottomPopup> {
  // 回调点击的哪个Item
  OnItemClickListener onItemClickListener;

  // 几个Item
  var itemCount;

  // 每个底部item的高度
  double itemHeight = 50;

  @override
  void initState() {
    super.initState();
    print(widget.isFillet);
    onItemClickListener = widget.onItemClickListener;
  }

  @override
  Widget build(BuildContext context) {
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
    int listLength = widget.list.length;

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
                    style: AppStyle.whiteRegular17,
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
    if (widget.list == null) {
      return Container();
    }
    var text = widget.list[index];
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
      if (onItemClickListener != null) {
        Navigator.pop(context);
        onItemClickListener(index);
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
          border: Border(top: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
          color: AppColor.layoutBgGrey, // 底色
        );
      } else if (index >= 1) {
        decoration = const BoxDecoration(
          color: AppColor.layoutBgGrey, // 底色
          border: Border(top: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
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
}
