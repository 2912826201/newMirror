import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/attention_user.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_layout.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DynamicListLayout extends StatelessWidget {
  DynamicListLayout(
      {Key key,
      this.index,
      this.isShowRecommendUser,
      this.model,
      this.isComplex = false,
      this.deleteFeedChanged,
      this.removeFollowChanged})
      : super(key: key);
  final index;
  bool isShowRecommendUser;
  HomeFeedModel model;
  bool isComplex;

  // 删除动态
  ValueChanged<int> deleteFeedChanged;

  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;

  @override
  Widget build(BuildContext context) {
    print('==============================动态itembuild');
    double screen_width = ScreenUtil.instance.screenWidthDp;
    // print("推荐页数据￥${ model.picUrls.isEmpty}");
    // return ChangeNotifierProvider(
    //     create: (_) => DynamicModelNotifier(model),
    //     builder: (context, _) {
    // print("我要看model的值");
    //  print(model.toString());
    if(index >= 35) {
      print("用户￥￥${model.name}");
      print(model.picUrls.toString());
    }
    return Column(
      children: [
        // 头部头像时间
        HeadView(
            model: model,
            isDetail: false,
            deleteFeedChanged: (id) {
              deleteFeedChanged(id);
            },
            removeFollowChanged: (m) {
              removeFollowChanged(m);
            }),
        // 图片区域
        model.picUrls.isNotEmpty
            ?
        SlideBanner(
                height: model.picUrls[0].height.toDouble(),
                model: model,
                isComplex: isComplex,
              )
            : Container(),
        // 视频区域
        model.videos.isNotEmpty ? getVideo() : Container(),
        // 点赞，转发，评论三连区域 getTripleArea
        GetTripleArea( model: model, index: index),
        // 课程信息和地址
        Offstage(
          offstage: (model.address == null && model.courseDto == null),
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            // color: Colors.orange,
            width: ScreenUtil.instance.width,
            child: getCourseInfo(model),
          ),
        ),

        // 文本文案
        Offstage(
          offstage: model.content.length == 0,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 12),
            width: ScreenUtil.instance.screenWidthDp,
            child: ExpandableText(
              text: model.content,
              model: model,
              maxLines: 2,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
            ),
          ),
        ),

        // 评论文本
        context.watch<FeedMapNotifier>().feedMap[model.id].comments.length != 0
            ? CommentLayout(model: model)
            : Container(),
        // 输入框
        CommentInputBox(feedModel: model),
        // 推荐用户
        getAttention(this.index, this.isShowRecommendUser),
        // 分割块
        Container(
          height: 18,
          color: AppColor.white,
        )
      ],
    );
    //     }
    // );
  }

  // // 删除动态
  // deleteFeed() async {
  //   Map<String, dynamic> map = await deletefeed(id: model.id);
  //   if (map["state"]) {
  //     deleteFeedChanged(model.id);
  //   } else {
  //     print("删除失败");
  //   }
  // }
  //
  // // 关注or取消关注
  // removeFollow(int isFollow, int id, BuildContext context) async {
  //   print("isFollow:::::::::$isFollow");
  //   // 取消关注
  //   if (isFollow == 1) {
  //     int relation = await ProfileCancelFollow(id);
  //     if (relation == 0 || relation == 2) {
  //       // context.read<FeedMapNotifier>().setIsFollow(id, isFollow);
  //       removeFollowChanged(model);
  //       ToastShow.show(msg: "已取消关注", context: context);
  //     } else {
  //       ToastShow.show(msg: "取消关注失败", context: context);
  //     }
  //   }
  // }

  // // 头部
  // Widget getHead( BuildContext context, HomeFeedModel model) {
  //   return Container(
  //       height: 62,
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           GestureDetector(
  //             onTap: () {
  //               Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //                 return ProfileDetailPage(
  //                   userId: model.pushId,
  //                   pcController: pc,
  //                 );
  //               }));
  //             },
  //             child: Container(
  //               margin: EdgeInsets.only(left: 16, right: 11),
  //               child: CircleAvatar(
  //                 // backgroundImage: AssetImage("images/test/yxlm1.jpeg"),
  //                 backgroundImage:
  //                     model.avatarUrl != null ? NetworkImage(model.avatarUrl) : NetworkImage("images/test.png"),
  //                 maxRadius: 19,
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //               child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               GestureDetector(
  //                 child: Text(
  //                   model.name ?? "空名字",
  //                   style: TextStyle(fontSize: 15),
  //                 ),
  //                 onTap: () {},
  //               ),
  //               Container(
  //                 padding: EdgeInsets.only(top: 2),
  //                 child: Text("${DateUtil.generateFormatDate(model.createTime)}",
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: AppColor.textSecondary,
  //                     )),
  //               )
  //             ],
  //           )),
  //           Container(
  //             margin: EdgeInsets.only(right: 16),
  //             child: GestureDetector(
  //               child: Image.asset("images/test/ic_big_dynamic_more.png", fit: BoxFit.cover, width: 24, height: 24),
  //               onTap: () {
  //                List<String> list = [];
  //                 if (model.pushId == context.read<ProfileNotifier>().profile.uid) {
  //                   list.add("删除");
  //                 } else {
  //                   if (model.isFollow == 1) {
  //                     list.add("取消关注");
  //                   }
  //                   list.add("举报");
  //                 }
  //                 openMoreBottomSheet(
  //                     context: context,
  //                     lists: list,
  //                     onItemClickListener: (index) {
  //                       if (list[index] == "删除") {
  //                         deleteFeed();
  //                       }
  //                       if (list[index] == "取消关注") {
  //                         removeFollow(model.isFollow, model.pushId, context);
  //                       }
  //                     });
  //               },
  //             ),
  //           )
  //         ],
  //       ));
  // }

// 视频
  Widget getVideo() {
    return Container(
      width: ScreenUtil.instance.width,
      height: 200,
      child: Center(
        child: Text("视频"),
      ),
    );
  }

  // 课程信息和地址
  Widget getCourseInfo(HomeFeedModel model) {
    List<String> tags = [];
    if (model.courseDto != null) {
      tags.add(model.courseDto.name);
    } else {
      tags.add("瑜伽课");
    }
    if (model.address != null) {
      tags.add(model.address);
    }
    return Row(
      children: [for (String item in tags) CourseAddressLabel(item, tags)],
    );
  }

  // 列表3的推荐书籍
  Widget getAttention(var index, bool isShowRecommendUser) {
    if (index == 2 && isShowRecommendUser) {
      return AttentionUser();
    }
    return Container(
      width: 0,
      height: 0,
    );
  }
}
