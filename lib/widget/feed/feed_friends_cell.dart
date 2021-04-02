import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

typedef FriendsCallback = void Function(String name, int userId, int type, BuildContext context);

// ignore: must_be_immutable
class FriendsCell extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String groupTitle;
  final String imageAssets;
  final int userId;
  final FriendsCallback friendsCallback;
  final bool isShowTitle;
  final bool isShowSingleChoice;
  final bool isSelectSingleChoice;
  int noBottomIndex = 0;

  FriendsCell({this.imageUrl,
    this.name,
    this.imageAssets,
    this.groupTitle,
    this.noBottomIndex = 0,
    this.friendsCallback,
    this.isShowTitle = true,
    this.isShowSingleChoice = true,
    this.isSelectSingleChoice = false,
    this.userId}); //首字母大写

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: _buildUi(context),
      ),
      onTap: () {
        if (friendsCallback != null) {
          friendsCallback(name, userId, RCConversationType.Private, context);
        }
      },
    );
  }

  Widget _buildUi(BuildContext context) {
    return Column(
      children: <Widget>[
        getTitleUi(), //title
        itemUi(context), //item
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
          style: const TextStyle(fontSize: 14, color: AppColor.textPrimary3),
        )
            : null,
      ),
    );
  }

  //item-ui
  Widget itemUi(BuildContext context) {
    if(isShowSingleChoice && groupTitle == "群成员"){
      return Opacity(
        opacity: 0.2,
        child: Container(
          color: Colors.white,
          height: 48,
          margin: EdgeInsets.only(bottom: noBottomIndex == 0 ? 10 : 0, left: 16, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              getSingleChoiceUi(), //单选

              getUserImagePr(), //用户头像

              getUserName(context), //昵称
            ],
          ),
        ),
      );
    }else{
      return Container(
        color: Colors.white,
        height: 48,
        margin: EdgeInsets.only(bottom: noBottomIndex == 0 ? 10 : 0, left: 16, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            getSingleChoiceUi(), //单选

            getUserImagePr(), //用户头像

            getUserName(context), //昵称
          ],
        ),
      );
    }

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
          color: AppColor.white,
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
  Widget getUserImagePr() {
    List<String> avatarList = imageUrl.split(",");
    return Container(
      height: 38,
      width: 38,
      child: Stack(
        children: [
          avatarList.length == 1
              ? ClipOval(
                  child: CachedNetworkImage(
                    height: 38,
                    width: 38,
                    imageUrl: avatarList.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      "images/test.png",
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "images/test.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : avatarList.length > 1
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          height: 28,
                          width: 28,
                          imageUrl: avatarList.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            "images/test.png",
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            "images/test.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                  : Container(),
          avatarList.length > 1
              ? Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        //这里的边框颜色需要随背景变化
                        border: Border.all(width: 3, color: AppColor.white)),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        height: 28,
                        width: 28,
                        imageUrl: avatarList[1],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Container()
        ],
      ),
    );
  }

  //用户的名字
  Widget getUserName(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      width: MediaQuery.of(context).size.width - 16 - 16 - 24 - 14.5 - 38 - 12 - 10,
      child: Text(
        name,
        style: const TextStyle(fontSize: 15, color: AppColor.textPrimary3),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
