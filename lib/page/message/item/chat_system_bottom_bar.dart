import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';

import 'currency_msg.dart';

///管家界面-底部可操作列表
class ChatSystemBottomBar extends StatelessWidget {
  // final List<String> alertList = ["获取个人数据", "获取食谱", "获取今日课件", "其他操作", "其他操作", "其他操作", "其他操作"];
  final List<String> alertList = ["拉入群聊"];

  final VoidMessageClickCallBack voidMessageClickCallBack;

  ChatSystemBottomBar(this.voidMessageClickCallBack);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      // color: Colors.lightGreen,
      child: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      width: double.infinity,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alertList.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return getItem(alertList[index], index, alertList.length - 1);
        },
      ),
    );
  }

  //每一个item
  Widget getItem(String text, int index, int len) {
    var firstMargin = const EdgeInsets.only(left: 15.5, top: 8, bottom: 8, right: 4);
    var commandMargin = const EdgeInsets.only(left: 4, top: 8, bottom: 8, right: 4);
    var endMargin = const EdgeInsets.only(left: 4, top: 8, bottom: 8, right: 15.5);
    return Container(
      margin: index == 0 ? firstMargin : (index == len ? endMargin : commandMargin),
      height: 32,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Material(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: AppColor.white,
              child: new InkWell(
                child: Container(
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 14, color: AppColor.black),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                splashColor: AppColor.textHint,
                onTap: () {
                  voidMessageClickCallBack(content: text, contentType: ChatTypeModel.CHAT_SYSTEM_BOTTOM_BAR);
                },
              ))),
    );
  }
}
