import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/surrounding_information.dart';

class ActivityChangeAddressPage extends StatefulWidget {
  SeletedAddress onSeletedAddress;
  ActivityChangeAddressPage({this.onSeletedAddress});
  @override
  _ActivityChangeAddressPageState createState() => _ActivityChangeAddressPageState();
}

class _ActivityChangeAddressPageState extends State<ActivityChangeAddressPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.mainBlack,
        appBar: CustomAppBar(
          titleString: "更改地点",
          hasLeading: true,
        ),
        body: SurroundingInformationPage(
          onSeletedAddress: widget.onSeletedAddress,
          isChangeAddress: true,
        ));
  }
}
