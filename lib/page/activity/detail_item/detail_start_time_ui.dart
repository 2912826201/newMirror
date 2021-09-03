import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';

class DetailStartTimeUi extends StatefulWidget {
  @override
  _DetailStartTimeUiState createState() => _DetailStartTimeUiState();
}

class _DetailStartTimeUiState extends State<DetailStartTimeUi> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColor.mainRed,
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Text("招募中", style: AppStyle.whiteRegular10),
        ),
        SizedBox(width: 12),
        getBox("1", AppStyle.yellowRegular12),
        getBox("天", AppStyle.whiteRegular11),
        getBox("22", AppStyle.yellowRegular12),
        getBox("时", AppStyle.whiteRegular11),
        SizedBox(width: 1),
        getBox("开始", AppStyle.whiteRegular11, null, false),
      ],
    );
  }

  Widget getBox(String title, TextStyle textStyle, [double width = 18, bool isDecoration = true]) {
    return Container(
      margin: EdgeInsets.only(left: 1),
      height: 18,
      width: width,
      decoration: isDecoration
          ? BoxDecoration(
              color: AppColor.textWhite40,
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      alignment: Alignment.center,
      child: Text(title, style: textStyle),
    );
  }
}
