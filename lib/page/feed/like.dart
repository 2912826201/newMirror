import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';

class Like extends StatefulWidget {
  Like({Key key}) : super(key: key);

  LikeState createState() => LikeState();
}

class LikeState extends State<Like> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Container(
            height: 44.0,
            color: Colors.red,
            width: ScreenUtil.instance.screenWidthDp,
            margin: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
            padding: EdgeInsets.only(left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyIconBtn(
                  width: 28,
                  height: 28,
                  iconSting: "images/resource/2.0x/return2x.png",
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                Center(
                  child: Text(
                    "赞",
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColor.textPrimary1,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );

  }
}
