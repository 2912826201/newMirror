import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/style.dart';

class ActivityDefaultMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 224,
            height: 224,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
            ),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          const Text(
            "这里空空如也",
            style: AppStyle.text1Regular14,
          ),
        ],
      ),
    );
  }
}
