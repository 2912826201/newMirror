import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';

class DetailActivityFeedUi extends StatefulWidget {
  @override
  _DetailActivityFeedUiState createState() => _DetailActivityFeedUiState();
}

class _DetailActivityFeedUiState extends State<DetailActivityFeedUi> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text("动态", style: AppStyle.text1Regular16),
          Expanded(
            child: Text(
              "该活动还没有发布过动态哦",
              style: AppStyle.text1Regular14,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
