

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/attention_user.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_layout.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/bottom_popup.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DynamicListLayout extends StatelessWidget {
  final index;
  PanelController pc;
  bool isShowRecommendUser;
  HomeFeedModel model;
  DynamicListLayout({Key key, this.index, this.pc, this.isShowRecommendUser,this.model}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    double screen_width = ScreenUtil.instance.screenWidthDp;
    // print("推荐页数据￥${ model.picUrls.isEmpty}");
    // return ChangeNotifierProvider(
    //     create: (_) => DynamicModelNotifier(model),
    //     builder: (context, _) {
    // print("我要看model的值");
     // print(model.toString());
          return Column(
            children: [
              // 头部头像时间
              getHead(screen_width, context,model),
              // 图片区域

              model.picUrls.isNotEmpty ? SlideBanner(height: model.picUrls[0].height.toDouble(),model: model,) : Container(),
              // 点赞，转发，评论三连区域 getTripleArea
              GetTripleArea(pc: pc,model:model ,index:index),
              // 课程信息和地址
              Offstage(
                offstage: (model.address == null && model.courseDto == null),
                child: Container(
                  margin: EdgeInsets.only(left: 16, right: 16),
                  // color: Colors.orange,
                  width: screen_width,
                  child: getCourseInfo(model),
                ),
              ),

              // 文本文案
              Offstage(
                offstage: model.content.length == 0,
                child: Container(
                  margin: EdgeInsets.only(left: 16, right: 16, top: 12),
                  width: ScreenUtil.instance.screenWidthDp,
                  child:
                  ExpandableText(
                    text: model.content,
                    model: model,
                    maxLines: 2,
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
                  ),
                ),
              ),

              // 评论文本
               context.watch<FeedMapNotifier>().feedMap[model.id].comments.length != 0 ? CommentLayout(model: model,pc: pc) : Container(),
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

  // 头部
  Widget getHead(double width, BuildContext context,HomeFeedModel model) {
    return Container(
        height: 62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return ProfileDetailPage(userId: model.pushId,);
                }));
              },
              child:    Container(
                margin: EdgeInsets.only(left: 16, right: 11),
                child: CircleAvatar(
                  // backgroundImage: AssetImage("images/test/yxlm1.jpeg"),
                  backgroundImage:
                  model.avatarUrl != null ? NetworkImage(model.avatarUrl ) :
                  NetworkImage("https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg" ),
                  maxRadius: 19,
                ),
              ),
            ),

            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: Text(
                        model.name ?? "空名字",
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () {},
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 2),
                      child: Text("${model.createTime}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          )),
                    )
                  ],
                )),
            Container(
              margin: EdgeInsets.only(right: 16),
              child: GestureDetector(
                child: Image.asset("images/test/ic_big_dynamic_more.png", fit: BoxFit.cover, width: 28, height: 28),
                onTap: () {
                  return showDialog(
                      context: context,
                      barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
                      builder: (BuildContext context) {
                        var list = List();
                        if(model.pushId == context.watch<ProfileNotifier>().profile.uid) {
                          list.add("删除");
                        } else {
                          if(model.isFollow == 0) {
                            list.add("关注");
                          } else{
                            list.add("取消关注");
                          }
                          list.add("举报");
                        }
                        return BottomPopup(
                          list: list,
                          onItemClickListener: (index) async {
                            print(list[index]);
                            Navigator.pop(context);
                          },
                        );
                      });
                },
              ),
            )
          ],
        ));
  }



// 视频
  Widget getVideo() {}

  // 课程信息和地址
  Widget getCourseInfo(HomeFeedModel model) {
    List<String> tags = [];
    if (model.courseDto != null) {
      tags.add(model.courseDto.name);
    }
    else {
      tags.add("瑜伽课");
    }
    if(model.address != null) {
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

