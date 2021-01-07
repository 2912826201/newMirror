import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';

// import '../bottom_sheet.dart';

Future openShareBottomSheet({
  @required BuildContext context,
  @required Map<String, dynamic> map,
  @required String chatTypeModel,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: FeedSharePopups(map: map, chatTypeModel: chatTypeModel),
        );
      });
}

class FeedSharePopups extends StatelessWidget {
  String chatTypeModel;
  Map<String, dynamic> map;

  FeedSharePopups({this.map, this.chatTypeModel});

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
    return Container(
      color: AppColor.white,
      width: ScreenUtil.instance.screenWidthDp,
      height: 48 + 89 + ScreenUtil.instance.bottomHeight,
      child: Column(
        children: [
          Container(
            height: 48,
            child: Center(
              child: Text(
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
                    onTap: () {
                      print("点击了￥${feedViewModel[index].name}");
                      Navigator.of(context).pop(1);
                      if(feedViewModel[index].name == "站内好友") {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return FriendsPage(voidCallback: (name, userId, context) async {
                            if (await jumpShareMessage(map, chatTypeModel, name, userId, context)) {
                              ToastShow.show(msg: "分享成功", context: context);
                            } else {
                              ToastShow.show(msg: "分享失败", context: context);
                            }
                          });
                        }));
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
          )
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
