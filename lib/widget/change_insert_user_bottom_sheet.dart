import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

import 'bottom_sheet.dart';
typedef OnChoseCallBack = void Function(int);
Future openUserNumberPickerBottomSheet(
    {@required BuildContext context,
      int start,
      int end,
      OnChoseCallBack onChoseCallBack}) async {
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
        return SingleChildScrollView(
          child: ChangeInsertUserBottomSheet(
            start: start,
            end: end,
            onChoseCallBack: onChoseCallBack,
          ),
        );
      });
}
class ChangeInsertUserBottomSheet extends StatefulWidget {
  int start;
  int end;
  OnChoseCallBack onChoseCallBack;
  ChangeInsertUserBottomSheet({this.start, this.end,this.onChoseCallBack});

  @override
  _ChangeInsertUserBottomSheetState createState() => _ChangeInsertUserBottomSheetState();
}

class _ChangeInsertUserBottomSheetState extends State<ChangeInsertUserBottomSheet> {
  List<int> userNumberList = [];
  FixedExtentScrollController controller = FixedExtentScrollController();
  int selectIndex = 0;
  @override
  void initState() {
    super.initState();
    _initNumberPeople();
  }

  void _initNumberPeople() {
    int totalCount = widget.end - widget.start + 1;
    for (int i = 0; i < totalCount; i++) {
      userNumberList.add(widget.start + i);
    }
  }
    @override
  void deactivate() {
    super.deactivate();
    //弹窗关闭时回调
    widget.onChoseCallBack(userNumberList[selectIndex]);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 276 + ScreenUtil.instance.bottomBarHeight,
      width: double.infinity,
      padding: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        children: [_text(AppStyle.whiteRegular16, "修改参加人数"), _pickerUserNumber()],
      ),
    );
  }

  Widget _text(TextStyle style, String text) {
    return Container(
      height: 32,
      child: Center(
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }

  Widget _pickerUserNumber() {
    return Expanded(
        child: CupertinoPicker(
      backgroundColor: AppColor.layoutBgGrey,
      scrollController: controller,
      squeeze: 0.95,
      diameterRatio: 1.5,
      itemExtent: 42,
      //循环
      looping: true,
      selectionOverlay: null,
      children: List<Widget>.generate(
        userNumberList.length,
        (index) {
          return _text(AppStyle.whiteRegular17, userNumberList[index].toString());
        },
      ),
      onSelectedItemChanged: (index) {
        selectIndex = index;
      },
    ));
  }
}
