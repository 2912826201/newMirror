import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';

import 'bottom_sheet.dart';
import 'icon.dart';

typedef OnChoseCallBack = void Function(int);

Future openUserNumberPickerBottomSheet(
    {@required BuildContext context, int start, int end, OnChoseCallBack onChoseCallBack}) async {
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

  ChangeInsertUserBottomSheet({this.start, this.end, this.onChoseCallBack});

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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 376 + ScreenUtil.instance.bottomBarHeight,
      width: double.infinity,
      padding: EdgeInsets.only(top: 16, bottom: ScreenUtil.instance.bottomBarHeight, left: 16, right: 16),
      decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        children: [
          _text(AppStyle.whiteRegular16, "修改参加人数"),
          SizedBox(
            height: 8,
          ),
          _hintText(),
          SizedBox(
            height: 8,
          ),
          _pickerUserNumber(),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            child: _bottomButton("确定"),
            onTap: () {
              widget.onChoseCallBack(userNumberList[selectIndex]);
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child: _bottomButton("取消"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _hintText() {
    String title = "活动开始三小时内不能修改参加人数，且只能修改一次";
    String beforResult = "";
    String afterResult = "";
    title.characters.toList().forEach((element) {
      Size size = getTextSize(beforResult + element, AppStyle.text1Regular14, 1);
      if (size.width <= ScreenUtil.instance.width - 58) {
        beforResult += element;
      } else {
        afterResult += element;
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2),
              child: AppIcon.getAppIcon(
                AppIcon.error_circle,
                16,
                color: AppColor.mainRed,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(child: Text(beforResult, style: AppStyle.text1Regular14))
          ],
        ),
        afterResult.length > 0
            ? Container(
                margin: EdgeInsets.only(left: 26),
                child: Text(afterResult, style: AppStyle.text1Regular14),
              )
            : Container()
      ],
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

  Widget _bottomButton(String text) {
    return Container(
      height: 50,
      child: Center(
        child: Text(
          text,
          style: AppStyle.whiteRegular17,
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
