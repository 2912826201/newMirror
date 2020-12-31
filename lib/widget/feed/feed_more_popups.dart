import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

import '../bottom_popup.dart';
import '../bottom_sheet.dart';

typedef OnItemClickListener = void Function(int index);
Future openMoreBottomSheet({
  @required BuildContext context,
  @required OnItemClickListener onItemClickListener,
  @required List<String> lists,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: BottomPopup(
            list: lists,
            onItemClickListener: onItemClickListener,
          )
        );
      });
}

// 底部弹窗
class BottomPopup extends StatefulWidget {
  BottomPopup({Key key, this.list, this.onItemClickListener})
      : assert(list != null),
        super(key: key);
  List<String> list;
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
    final double topPadding = ScreenUtil.instance.statusBarHeight;
    int listLength=widget.list.length;
    /// 最后还有一个cancel，所以加1
    itemCount = listLength + 1;
    // 算出弹窗总高度
    var height ;
    height = ((listLength + 1) * 50 + 12 + bottomPadding).toDouble();
    // 取消Item
    var cancelContainer = Container(
        height: itemHeight + 12 + bottomPadding,
        decoration: BoxDecoration(
          color: AppColor.white, // 底色
        ),
        child:Column (
          children: [
            // 取消上面的分割块
            Container(
              height: 12,
              color: Color.fromRGBO(243, 243, 243, 1),
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
                  child: Text(
                    "取消",
                    style: TextStyle(
                        fontFamily: 'Robot',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        color: Color(0xff333333),
                        fontSize: 18),
                  ),
                ),
              ) ,
            ),
            Container(
              height: bottomPadding,
            )
          ],
        )
    );
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
          return getItemContainer(context, index,listLength);
        });
    // 组合
    var totalContainer = Container(
      child: listview,
      height: height,
      width: deviceWidth ,
    );
    return totalContainer;
  }
  // 创建其他传入的Item
  Widget getItemContainer(BuildContext context, int index,int listLength) {
    if (widget.list == null) {
      return Container();
    }
    var text = widget.list[index];
    var contentText = Text(
      text,
      style: TextStyle(
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: Color(0xFF333333),
          fontSize: 18),
    );

    var decoration;

    var center;
    var itemContainer;
    center = Center(
      child: contentText,
    );
    var onTap2 = () {
      if (onItemClickListener != null) {
        onItemClickListener(index);
        Navigator.pop(context);
      }
    };

    if(listLength==1){
      decoration = BoxDecoration(
        color: AppColor.white, // 底色
      );
    }else if(listLength>1){
      if (index == listLength - 1) {
        decoration = BoxDecoration(
          color: AppColor.white, // 底色
        );
      } else {
        decoration = BoxDecoration(
          color: AppColor.white, // 底色
          border: Border(
              bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        );
      }
    }
    itemContainer = Container(
        height: itemHeight,
        decoration: decoration,
        child: center);

    return GestureDetector(
      onTap: onTap2,
      child: itemContainer,
    );
  }
}