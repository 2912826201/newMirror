import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/text_util.dart';

import 'cupertino_left_scroll.dart';
import 'global/actionListener.dart';
import 'package:provider/provider.dart';

import 'left_scroll_item.dart';

//侧滑删除
class LeftScrollListView extends StatefulWidget {
  //每一个item key不一样
  final String itemKey;

  //相同的tag 可以保证只打开一个
  final String itemTag;

  //每一个item的index
  final int itemIndex;

  //child
  final Widget itemChild;

  //点击item
  final VoidCallback onTap;

  //点击删除按钮
  final ValueChanged<int> onClickRightBtn;

  //是否需要两次点击删除进行提示
  final bool isDoubleDelete;

  LeftScrollListView({
    @required this.itemKey,
    @required this.itemTag,
    @required this.itemIndex,
    @required this.itemChild,
    this.onTap,
    this.onClickRightBtn,
    this.isDoubleDelete = false,
  });

  @override
  _LeftScrollListViewState createState() => _LeftScrollListViewState();
}

class _LeftScrollListViewState extends State<LeftScrollListView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SelectPositionNotifier(),
        builder: (context, _) {
          return getItem(context);
        });
  }

  Widget getItem(BuildContext context) {
    TextStyle textStyle = AppStyle.whiteRegular16;
    return CupertinoLeftScroll(
      key: Key(widget.itemKey),
      closeTag: LeftScrollCloseTag(widget.itemTag),
      itemIndex: widget.itemIndex,
      buttonWidth: 20.0 +
          getTextSize(context.watch<SelectPositionNotifier>().singleDeletePosition == widget.itemIndex ? '确认删除' : "删除",
                  textStyle, 1)
              .width +
          20.0,
      child: widget.itemChild,
      buttons: <Widget>[
        LeftScrollItem(
          text: context.watch<SelectPositionNotifier>().singleDeletePosition == widget.itemIndex ? '确认删除' : "删除",
          color: Colors.red,
          textStyle: textStyle,
          onTap: (String title) {
            if (widget.isDoubleDelete && title == "删除") {
              setState(() {});
              Future.delayed(Duration(milliseconds: 100), () {
                context.read<SelectPositionNotifier>().set(widget.itemIndex);
              });
            } else {
              if (widget.onClickRightBtn != null) {
                widget.onClickRightBtn(widget.itemIndex);
              }
            }
          },
        ),
      ],
      onOpen: () {
        try {
          context.read<SelectPositionNotifier>().set(-1);
          setState(() {});
        } catch (e) {}
      },
      onClose: () {
        try {
          context.read<SelectPositionNotifier>().set(-1);
          setState(() {});
        } catch (e) {}
      },
      onTap: widget.onTap,
    );
  }
}

class SelectPositionNotifier extends ChangeNotifier {
  int singleDeletePosition = -1;

  SelectPositionNotifier({this.singleDeletePosition = -1});

  void set(int singleDeletePosition) {
    this.singleDeletePosition = singleDeletePosition;
    notifyListeners();
  }
}
