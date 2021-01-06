import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// 动态详情页
class FeedDetailPage extends StatefulWidget {
  FeedDetailPage({Key key, this.model, this.isComplex, this.index});

  HomeFeedModel model;
  int index;
  bool isComplex;

  @override
  FeedDetailPageState createState() => FeedDetailPageState();
}

class FeedDetailPageState extends State<FeedDetailPage> {
  @override
  void initState() {
    // getFeedDetail();
  }

  // getFeedDetail() async {
  //   feedModel = await feedDetail(id: widget.model.id);
  //   setState(() {
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(
              "动态详情页",
              style: TextStyle(color: AppColor.textPrimary1, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            backgroundColor: AppColor.white,
            leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Image.asset(
                    "images/resource/2.0x/return2x.png",
                  ),
                )),
            leadingWidth: 44.0,
            elevation: 0.5),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text('老孟'),
              )
            ];
          },
          body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // 顶部间距
            SizedBox(
              height: 14,
            ),
            // 头部布局
            HeadView(
                model: widget.model,
                deleteFeedChanged: (id) {
                  // deleteFeedChanged(id);
                },
                removeFollowChanged: (m) {
                  // removeFollowChanged(m);
                }),
            // 图片区域
            widget.model.picUrls.isNotEmpty
                ? Hero(
                    tag: widget.isComplex ? "complex${widget.model.id}" : "${widget.model.id}:${widget.index}",
                    child: SlideBanner(
                      height: widget.model.picUrls[0].height.toDouble(),
                      model: widget.model,
                    )
                    // SlideBanner(height: model.picUrls[0].height.toDouble(),model: model,),
                    )
                : Container(),
            // 视频区域
            widget.model.videos.isNotEmpty ? Container() : Container(),
            // 点赞，转发，评论三连区域 getTripleArea
            GetTripleArea(
              model: widget.model,
            ),
            // 课程信息和地址
            Offstage(
              offstage: (widget.model.address == null),
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                // color: Colors.orange,
                width: ScreenUtil.instance.width,
                child: getCourseInfo(widget.model),
              ),
            ),
            // // 文本文案
            Offstage(
              offstage: widget.model.content.length == 0,
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 12),
                width: ScreenUtil.instance.width,
                child: ExpandableText(
                  text: widget.model.content,
                  model: widget.model,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
                ),
              ),
            ),
            Expanded(
                child: CommentBottomSheet(
              feedId: widget.model.id,
            )),
          ]),
        ));
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
}
