import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';

// 动态详情页
class FeedDetailPage extends StatefulWidget {
  FeedDetailPage({Key key, this.model, this.index});

  HomeFeedModel model;
  int index;

  @override
  FeedDetailPageState createState() => FeedDetailPageState();
}

class FeedDetailPageState extends State<FeedDetailPage> {
  HomeFeedModel feedModel;

  // 数据加载页数
  int dataPage = 1;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

//  数据源
  List<CommentDtoModel> commentModel = [];

  // 请求下一页
  int hasNext = 0;

  // 列表监听
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    print("进入详情页");
    feedModel = context.read<FeedMapNotifier>().feedMap[widget.model.id];
    getQueryListByHot();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        dataPage += 1;
        getQueryListByHot();
      }
    });
  }

  // 获取热门评论
  getQueryListByHot() async {
    // 评论总数
    int totalCount = -1;
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    List<CommentDtoModel> modelList =
        await queryListByHot(targetId: feedModel.id, targetType: 0, page: this.dataPage, size: 20);

    print("打印返回值￥%${modelList.isNotEmpty}");
    setState(() {
      totalCount = modelList[0].totalCount;
      modelList.removeAt(0);
      if (this.dataPage == 1) {
        if (modelList.isNotEmpty) {
          for (CommentDtoModel model in modelList) {
            if (model.replyCount > 0) {
              model.isShowInteractiveButton = true;
            } else {
              model.isShowInteractiveButton = false;
            }
          }
          commentModel.addAll(modelList);
          print("数据长度${commentModel.length}");
        }
      } else if (this.dataPage > 1 && this.hasNext != 0) {
        print("5data");
        for (CommentDtoModel model in modelList) {
          if (model.replyCount > 0) {
            model.isShowInteractiveButton = true;
          } else {
            model.isShowInteractiveButton = false;
          }
        }
        commentModel.addAll(modelList);
        print("数据长度${commentModel.length}");
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      } else {
        // 加载完毕
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
      // commentModel.insert(commentModel.length, CommentDtoModel());
      context.read<FeedMapNotifier>().commensAssignment(feedModel.id, commentModel, totalCount);
    });
  }

  // getFeedDetail() async {
  //   feedModel = await feedDetail(id: widget.model.id);
  //   setState(() {
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    print("动态详情页");
    return Scaffold(
        backgroundColor: AppColor.white,
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
        body: Stack(
          children: [
            CustomScrollView(controller: _controller, slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // 顶部间距
                  SizedBox(
                    height: 14,
                  ),
                  // 头部布局
                  HeadView(
                      model: feedModel,
                      deleteFeedChanged: (id) {
                        // deleteFeedChanged(id);
                      },
                      removeFollowChanged: (m) {
                        // removeFollowChanged(m);
                      }),
                  // 图片区域
                  feedModel.picUrls.isNotEmpty
                      ? SlideBanner(
                          height: feedModel.picUrls[0].height.toDouble(),
                          model: feedModel,
                          isComplex: true,
                        )
                      : Container(),
                  // 视频区域
                  feedModel.videos.isNotEmpty ? Container() : Container(),
                  // 点赞，转发，评论三连区域 getTripleArea
                  GetTripleArea(
                    model: feedModel,
                  ),
                  // 课程信息和地址
                  Offstage(
                    offstage: (feedModel.address == null),
                    child: Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      // color: Colors.orange,
                      width: ScreenUtil.instance.width,
                      child: getCourseInfo(feedModel),
                    ),
                  ),
                  // // 文本文案
                  Offstage(
                    offstage: feedModel.content.length == 0,
                    child: Container(
                      margin: EdgeInsets.only(left: 16, right: 16, top: 12),
                      width: ScreenUtil.instance.width,
                      child: ExpandableText(
                        text: feedModel.content,
                        model: feedModel,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
                      ),
                    ),
                  ),
                  context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1
                      ? Container(
                          margin: EdgeInsets.only(top: 18, left: 16),
                          alignment: Alignment(-1, 0),
                          child:
                              // context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1
                              //     ?
                              // DynamicModelNotifier
                              Selector<FeedMapNotifier, int>(builder: (context, totalCount, child) {
                            return Text(
                              "共${StringUtil.getNumber(totalCount)}条评论",
                              style: AppStyle.textRegular16,
                            );
                          }, selector: (context, notifier) {
                            return notifier.feedMap[feedModel.id].totalCount;
                          }))
                      : Container(),
                ]),
              ),
              context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1 ? SliverList(delegate: SliverChildBuilderDelegate((content, index) {
              // return Container(
                print(index);
                print(commentModel.length);
                if (index == commentModel.length -1) {
                  print("进入了吗$index");
                  return SizedBox(height: 48 + ScreenUtil.instance.bottomBarHeight);
                } else {
                  return CommentBottomListView(
                    model: commentModel[index],
                    index: index,
                    feedId: feedModel.id,
                  );
                }
              },childCount:commentModel.length + 1)) :  SliverToBoxAdapter()
            ]),
            Positioned(
              bottom: 0,
              child: CommentInputBox(
                isUnderline: true,
                isFeedDetail: true,
                feedModel: context.watch<FeedMapNotifier>().feedMap[feedModel.id],
              ),
            )
          ],
        ));
  }

  // 课程信息和地址
  Widget getCourseInfo(HomeFeedModel model) {
    List<String> tags = [];
    if (model.courseDto != null) {
      tags.add(model.courseDto.name);
    }
    if (model.address != null) {
      tags.add(model.address);
    }
    return Row(
      children: [for (String item in tags) CourseAddressLabel(item, tags)],
    );
  }
}
