import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/popup/share_popup.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';
import 'package:provider/provider.dart';

import '../icon.dart';
import 'feed_friends_cell.dart';

// import '../bottom_sheet.dart';

Future openShareBottomSheet({
  @required BuildContext context,
  @required Map<String, dynamic> map,
  @required String chatTypeModel,
  @required int sharedType,
  bool fromTraingGallery = false,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: AppColor.white,
    // 圆角
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (BuildContext context) {

      return SingleChildScrollView(
        child: FeedSharePopups(
          map: map,
          chatTypeModel: chatTypeModel,
          sharedType: sharedType,
          fromTraingGallery: fromTraingGallery,
        ),
      );
    },
  );
}

class FeedSharePopups extends StatelessWidget {
  String chatTypeModel;
  Map<String, dynamic> map;
  int sharedType;
  bool fromTraingGallery;
  FeedSharePopups({this.map, this.chatTypeModel, this.sharedType,this.fromTraingGallery});

  List<ShareViewModel> shareViewModel = [];
  List<String> name = ["站内好友", "微信好友", "朋友圈", "微博", "QQ好友", "QQ空间"];
  List<String> icon = [
    AppIcon.share_friend_circle,
    AppIcon.share_wechat_circle,
    AppIcon.share_moment_circle,
    AppIcon.share_weibo_circle,
    AppIcon.share_qq_circle,
    AppIcon.share_qzone_circle,
  ];

  Widget build(BuildContext context) {
    for (var i = 0; i < name.length; i++) {
      ShareViewModel a = ShareViewModel(name: name[i], icon: icon[i]);
      shareViewModel.add(a);
    }
    if (sharedType == 2) {
      ShareViewModel a = ShareViewModel(
        name: "保存本地",
        icon: AppIcon.share_download_circle,
      );
      shareViewModel.insert(0, a);
    }
    if (sharedType == 3) {
      shareViewModel.removeWhere((element) {
        return element.name == "站内好友";
      });
    }
    print('map===================${map.toString()}');
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      height: 48 + 88 + 8 + 48 + ScreenUtil.instance.bottomHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            child: Center(
              child: const Text(
                "分享到",
                style: AppStyle.textRegular16,
              ),
            ),
          ),
          Container(
            height: 88,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: shareViewModel.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      if(fromTraingGallery){
                        context.read<UserInteractiveNotifier>().changeShowImageFrame(false);
                      }
                      print("点击了￥${shareViewModel[index].name}");
                      switch (shareViewModel[index].name) {
                        case "站内好友":
                          if (!(context != null && context.read<TokenNotifier>().isLoggedIn)) {
                            ToastShow.show(msg: "请先登录app!", context: context);
                            AppRouter.navigateToLoginPage(context);
                            return;
                          }
                          Navigator.of(context).pop(1);
                          showSharePopup(context, map, chatTypeModel);
                          // AppRouter.navigateFriendsPage(context: context,shareMap: map,chatTypeModel: chatTypeModel);
                          break;
                        case "保存本地":
                          var result = await ImageGallerySaver.saveFile(map["file"]);
                          if (result["isSuccess"] == true) {
                            ToastShow.show(msg: "保存成功", context: context);
                          }else{
                            ToastShow.show(msg: "保存失败", context: context);
                          }
                          Navigator.of(context).pop(1);
                          break;
                        case "微信好友":
                          Navigator.of(context).pop(1);
                          break;
                        case "朋友圈":
                          Navigator.of(context).pop(1);
                          break;
                        case "微博":
                          Navigator.of(context).pop(1);
                          break;
                        case "QQ好友":
                          Navigator.of(context).pop(1);
                          break;
                        case "QQ空间":
                          Navigator.of(context).pop(1);
                          break;
                        default:
                          Navigator.of(context).pop(1);
                          break;
                      }
                    },
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: index > 0 ? 32 : 16,
                                right: index == shareViewModel.length - 1 ? 16 : 0,
                                top: 8,
                                bottom: 8),
                            height: 48,
                            width: 48,
                            child: AppIcon.getAppIcon(shareViewModel[index].icon, 48),
                          ),
                          Container(
                            width: 48,
                            margin: EdgeInsets.only(
                              left: index > 0 ? 32 : 16,
                              right: index == shareViewModel.length - 1 ? 16 : 0,
                            ),
                            child: Center(
                              child: Text(
                                shareViewModel[index].name,
                                style: AppStyle.textRegular12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Container(
            width: ScreenUtil.instance.screenWidthDp,
            height: 8,
            color: AppColor.bgWhite,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 48,
              width: ScreenUtil.instance.screenWidthDp,
              child: Center(
                child: Text(
                  "取消",
                  style: TextStyle(fontSize: 17, color: AppColor.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ShareViewModel {
  String name;
  String icon;

  ShareViewModel({this.name, this.icon});
}
