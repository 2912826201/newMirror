import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

typedef VoidCallback = void Function(String name, int userId, BuildContext context);

// ignore: must_be_immutable
class FriendsCell extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String groupTitle;
  final String imageAssets;
  final int userId;
  final VoidCallback voidCallback;
  final bool isShowTitle;
  final bool isShowSingleChoice;
  final bool isSelectSingleChoice;
  int noBottomIndex = 0;

  FriendsCell(
      {this.imageUrl,
      this.name,
      this.imageAssets,
      this.groupTitle,
      this.noBottomIndex = 0,
      this.voidCallback,
      this.isShowTitle = true,
      this.isShowSingleChoice = true,
      this.isSelectSingleChoice = false,
      this.userId}); //首字母大写

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: _buildUi(),
      ),
      onTap: () {
        if (voidCallback != null) {
          voidCallback(name, userId, context);
        }
      },
    );
  }

  Widget _buildUi() {
    return Column(
      children: <Widget>[
        getTitleUi(), //title
        itemUi(), //item
      ],
    );
  }

  //头部的title
  Widget getTitleUi() {
    return Visibility(
      visible: isShowTitle,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        height: groupTitle != null ? 28.5 : 0,
        color: AppColor.bgWhite,
        child: groupTitle != null
            ? Text(
                groupTitle,
                style: TextStyle(fontSize: 14, color: AppColor.textPrimary3),
              )
            : null,
      ),
    );
  }

  //item-ui
  Widget itemUi() {
    return Container(
      color: Colors.white,
      height: 48,
      margin: EdgeInsets.only(bottom: noBottomIndex == 0 ? 10 : 0, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          getSingleChoiceUi(), //单选

          getUserImage(), //用户头像

          getUserName(), //昵称
        ],
      ),
    );
  }

  //单选按钮
  Widget getSingleChoiceUi() {
    return Visibility(
      visible: isShowSingleChoice,
      child: Container(
        margin: const EdgeInsets.only(right: 14.5),
        // color: Colors.lightGreen,
        width: 24,
        height: 24,
        decoration: !isSelectSingleChoice
            ? BoxDecoration(
                color: isShowSingleChoice && groupTitle != "群成员"
                    ? AppColor.white
                    : AppColor.textSecondary.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 0.5, color: AppColor.textHint),
              )
            : BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.circular(12),
              ),
      ),
    );
  }

  //用户头像
  Widget getUserImage() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19.0),
          image: DecorationImage(
              image: imageUrl != null ? NetworkImage(imageUrl) : AssetImage(imageAssets), fit: BoxFit.cover)),
    );
  }

  //用户的名字
  Widget getUserName() {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Text(
        name,
        style: TextStyle(fontSize: 15, color: AppColor.textPrimary3),
      ),
    );
  }
}
