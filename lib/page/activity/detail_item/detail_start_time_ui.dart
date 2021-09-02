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
        Container(
          decoration: BoxDecoration(
            color: AppColor.textWhite40,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text("1", style: AppStyle.yellowRegular12),
        ),
        SizedBox(width: 1),
        Container(
          decoration: BoxDecoration(
            color: AppColor.textWhite40,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text("天", style: AppStyle.whiteRegular11),
        ),
        SizedBox(width: 1),
        Container(
          decoration: BoxDecoration(
            color: AppColor.textWhite40,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text("22", style: AppStyle.yellowRegular12),
        ),
        SizedBox(width: 1),
        Container(
          decoration: BoxDecoration(
            color: AppColor.textWhite40,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text("时", style: AppStyle.whiteRegular11),
        ),
        SizedBox(width: 1),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text("开始", style: AppStyle.whiteRegular11),
        ),
      ],
    );
  }
}
