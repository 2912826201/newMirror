import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/share_page/share_popup.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';
import 'package:provider/provider.dart';

import 'feed_friends_cell.dart';

// import '../bottom_sheet.dart';

Future openShareBottomSheet({
  @required BuildContext context,
  @required Map<String, dynamic> map,
  @required String chatTypeModel,
  @required int sharedType,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: FeedSharePopups(
            map: map,
            chatTypeModel: chatTypeModel,
            sharedType: sharedType,
          ),
        );
      });
}

class FeedSharePopups extends StatelessWidget {
  String chatTypeModel;
  Map<String, dynamic> map;
  int sharedType;

  FeedSharePopups({this.map, this.chatTypeModel, this.sharedType});

  List<FeedViewModel> feedViewModel = [];
  List<String> name = ["站内好友", "微信好友", "朋友圈", "微博", "QQ好友", "QQ空间"];
  List<String> image = [
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2623955494.webp",
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2615992304.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2615642201.webp",
    "https://img2.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2599858573.webp",
    "https://img1.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620104689.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620161520.webp",
  ];

  Widget build(BuildContext context) {
    for (var i = 0; i < name.length; i++) {
      FeedViewModel a = new FeedViewModel(name: name[i], image: image[i]);
      feedViewModel.add(a);
    }
    if (sharedType != 1) {
      FeedViewModel a = new FeedViewModel(
          name: "保存本地", image: "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620161520.webp");
      feedViewModel.insert(0, a);
    }
    if(sharedType==3){
      feedViewModel.removeWhere((element){
        return element.name=="站内好友";
      });
    }
    print('map===================${map.toString()}');
    return Container(
      color: AppColor.white,
      width: ScreenUtil.instance.screenWidthDp,
      height: 48 + 89 + ScreenUtil.instance.bottomHeight+49,
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
            height: 89,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: feedViewModel.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      print("点击了￥${feedViewModel[index].name}");
                      switch (feedViewModel[index].name) {
                        case "站内好友":
                          if (!(context != null && context.read<TokenNotifier>().isLoggedIn)) {
                            ToastShow.show(msg: "请先登陆app!", context: context);
                            AppRouter.navigateToLoginPage(context);
                            return;
                          }
                          Navigator.of(context).pop(1);
                          showSharePopup(context,map,chatTypeModel);
                          // AppRouter.navigateFriendsPage(context: context,shareMap: map,chatTypeModel: chatTypeModel);
                          break;
                        case "保存本地":
                          var result = await ImageGallerySaver.saveFile(map["file"]);
                          if (result["isSuccess"] == true) {
                            ToastShow.show(msg: "保存成功", context: context);
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
                                right: index == feedViewModel.length - 1 ? 16 : 0,
                                top: 8,
                                bottom: 8),
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              // color: Colors.redAccent,
                              image:
                                  DecorationImage(image: NetworkImage(feedViewModel[index].image), fit: BoxFit.cover),
                              // image
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                          Container(
                            width: 48,
                            margin: EdgeInsets.only(
                              left: index > 0 ? 32 : 16,
                              right: index == feedViewModel.length - 1 ? 16 : 0,
                            ),
                            child: Center(
                              child: Text(
                                feedViewModel[index].name,
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
            height: 1,
            color: AppColor.bgWhite,
          ),
          InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
            height: 48,
            width: ScreenUtil.instance.screenWidthDp,
            child: Center(
              child: Text("取消",style: AppStyle.textMedium18,),
            ),
          ),)
        ],
      ),
    );
  }
}

class FeedViewModel {
  String name;
  String image;

  FeedViewModel({this.name, this.image});
}
