import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/loading.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';

import 'comment_bottom_list.dart';

// 动态详情页
class FeedDetailPage extends StatefulWidget {
  FeedDetailPage({Key key, this.model, this.type, this.index, this.comment});

  CommentDtoModel comment;
  HomeFeedModel model;
  int index;
  int type;

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
  int totalCount = 0;
  GlobalKey _key = GlobalKey();
  int choseIndex = 0;
  bool isFirstPage = false;
  double itemHeight = 0;
  bool isFrisrtScroll = true;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print("进入详情页");
    feedModel = context.read<FeedMapNotifier>().feedMap[widget.model.id];
    itemHeight = 124 +
        calculateTextWidth(feedModel.content, AppStyle.textRegular14, ScreenUtil.instance.width, 2).height +
        setAspectRatio(feedModel.picUrls[0].height.toDouble());
    getQueryListByHot();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        print('==================动态详情刷新');
        dataPage += 1;
        getQueryListByHot();
      }
    });
  }

  _getChoseComment() async {
    print('================================   筛选评论');
    CommentDtoModel childmodel = await getComment(widget.comment.id);
    if (childmodel != null) {
      if (childmodel.type == 0) {
        if (childmodel.replyCount > 0) {
          childmodel.isShowInteractiveButton = true;
        } else {
          childmodel.isShowInteractiveButton = false;
        }
        childmodel.itemChose = true;
        if (isFirstPage) {
          commentModel.insert(choseIndex, childmodel);
        } else {
          commentModel.insert(0, childmodel);
        }
      } else if (childmodel.type == 2) {
        CommentDtoModel fsModel = await getComment(childmodel.targetId);
        if (fsModel != null) {
          fsModel.isShowInteractiveButton = true;
          if (isFirstPage) {
            commentModel.insert(choseIndex, fsModel);
            childmodel.itemChose = true;
            commentModel[choseIndex].replys.insert(0, childmodel);
          } else {
            commentModel.insert(0, fsModel);
            childmodel.itemChose = true;
            commentModel[0].replys.insert(0, childmodel);
          }
        }
      }
      context.read<FeedMapNotifier>().insertChildModel(childmodel);
    }
    context.read<FeedMapNotifier>().commensAssignment(feedModel.id, commentModel, totalCount);
  }

  // 获取热门评论
  getQueryListByHot() async {
    print('============================动态详情评论接口');
    // 评论总数
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
          if (widget.comment != null) {
            for (int i = 0; i < modelList.length; i++) {
              if (modelList[i].id == widget.comment.id || modelList[i].id == widget.comment.targetId) {
                choseIndex = i;
                isFirstPage = true;
                print('==================888888888888888888==88888888888888888===========选中的屁评论在第一页');
              } else {
                commentModel.add(modelList[i]);
              }
            }
          } else {
            commentModel.addAll(modelList);
          }
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
        if (widget.comment != null) {
          modelList.forEach((element) {
            if (element.id != widget.comment.id && element.id != widget.comment.targetId) {
              commentModel.add(element);
            }
          });
        } else {
          commentModel.addAll(modelList);
        }
        print("数据长度${commentModel.length}");
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      } else {
        // 加载完毕
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
      // commentModel.insert(commentModel.length, CommentDtoModel());
    });
    if (widget.comment == null) {
      context.read<FeedMapNotifier>().commensAssignment(feedModel.id, commentModel, totalCount);
    } else {
      if (dataPage == 1) {
        _getChoseComment();
      } else {
        context.read<FeedMapNotifier>().commensAssignment(feedModel.id, commentModel, totalCount);
      }
    }
  }

  double setAspectRatio(double height) {
    if (height == 0) {
      return ScreenUtil.instance.width;
    } else {
      return (ScreenUtil.instance.width / feedModel.picUrls[0].width) * height;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("动态详情页build---------------------------------------------${feedModel}");
    if(widget.comment!=null&&isFrisrtScroll){
      for (int i = 0; i < commentModel.length; i++) {
        if (i < choseIndex) {
          itemHeight +=
              calculateTextWidth(commentModel[i].content, AppStyle.textRegular14, ScreenUtil.instance.width - 75, 2)
                  .height +
                  60;
        } else{
          isFrisrtScroll = false;
          Future.delayed(Duration(milliseconds: 500), () {
            try {
              print('===============================================滑动倒计时结束-----开始滚动');
              _controller.animateTo(itemHeight , duration: Duration(microseconds: 1000), curve: Curves.easeInOut);
            } catch (e) {}
          });
        }
      }
    }
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
            Container(
              height: ScreenUtil.instance.height,
              child: CustomScrollView(physics: ClampingScrollPhysics(), controller: _controller, slivers: <Widget>[
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
                            height: feedModel?.picUrls[0]?.height?.toDouble(),
                            model: feedModel,
                            pageName: "FeedDetailPage",
                            isDynamicDetails: true,
                          )
                        : Container(),
                    // 视频区域
                    feedModel.videos.isNotEmpty ? Container() : Container(),
                    // 点赞，转发，评论三连区域 getTripleArea
                    GetTripleArea(
                      offsetKey: _key,
                      model: feedModel,
                      comment: widget.comment,
                      commentDtoModel: commentModel,
                      back: () {
                        context.read<FeedMapNotifier>().commensAssignment(feedModel.id, commentModel, totalCount);
                      },
                    ),
                    // 课程信息和地址
                    Offstage(
                      offstage: (feedModel.address == null && feedModel.courseDto == null),
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
                context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate((content, index) {
                        // return Container(
                        print(index);
                        print(commentModel.length);
                        if (index == commentModel.length) {
                          print("进入了吗$index");
                          return SizedBox(height: 48 + ScreenUtil.instance.bottomBarHeight + 40);
                        } else {
                          print('================${commentModel.length}');
                          return CommentBottomListView(
                            model: commentModel[index],
                            index: index,
                            type: 1,
                            feedId: feedModel.id,
                            comment: widget.comment,
                          );
                        }
                      }, childCount: commentModel.length + 1))
                    : SliverToBoxAdapter()
              ]),
            ),
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
      tags.add(model.courseDto.title);
    }
    if (model.address != null) {
      tags.add(model.address);
    }
    return Row(
      children: [for (String item in tags) CourseAddressLabel(item, tags)],
    );
  }
}
// class FeedDetailCommentBottomList extends StatelessWidget {
// //   CommentDtoModel model;
// //   int index;
// //   int feedId;
// //
// //   FeedDetailCommentBottomList({this.model, this.index, this.feedId});
// //
// //   // 点赞
// //   setUpLuad(BuildContext context) async {
// //     bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
// //     print("是否点赞了￥${context.read<FeedMapNotifier>().feedMap[feedId].comments[index].isLaud}");
// //     if (isLoggedIn) {
// //       Map<String, dynamic> model = await laudComment(commentId: this.model.id, laud: this.model.isLaud == 0 ? 1 : 0);
// //       // 点赞/取消赞成功
// //       print("state:${model["state"]}");
// //       if (model["state"]) {
// //         context.read<FeedMapNotifier>().mainCommentLaud(this.model.isLaud, this.feedId, this.index);
// //       } else {
// //         // 失败
// //         print("shib ");
// //       }
// //     } else {
// //       // 去登录
// //       AppRouter.navigateToLoginPage(context);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print(model.targetId);
// //     // 头像
// //     var avatar = Container(
// //       child: Container(
// //         height: 42,
// //         width: 42,
// //         child: ClipOval(
// //           child: model.avatarUrl != null
// //               ? Image.network(model.avatarUrl, fit: BoxFit.cover)
// //               : Image.asset("images/test/yxlm1.jpeg", fit: BoxFit.cover),
// //         ),
// //       ),
// //     );
// //
// //     // 评论
// //     Widget info = Container(
// //         margin: EdgeInsets.only(left: 15, right: 12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: <Widget>[
// //             MyRichTextWidget(
// //               Text(
// //                 model.name + " " + model.content,
// //                 overflow: TextOverflow.visible,
// //                 style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
// //               ),
// //               maxLines: 2,
// //               textOverflow: TextOverflow.ellipsis,
// //               richTexts: [
// //                 BaseRichText(
// //                   (model.name + " " + model.content).substring(0, model.name.length),
// //                   style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
// //                   onTap: () {
// //                     print(model.uid);
// //                   },
// //                 ),
// //               ],
// //             ),
// //             Container(height: 6),
// //             Container(
// //               child: Text(
// //                 "${DateUtil.generateFormatDate(model.createTime)} 回复",
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   color: AppColor.textSecondary,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ));
// //
// //     // 点赞
// //     Widget right = Column(
// //       crossAxisAlignment: CrossAxisAlignment.center,
// //       children: <Widget>[
// //         GestureDetector(
// //           onTap: () {
// //             setUpLuad(context);
// //           },
// //           child: Icon(
// //             Icons.favorite,
// //             color: context.watch<FeedMapNotifier>().feedMap[feedId].comments[index].isLaud == 0
// //                 ? Colors.grey
// //                 : context.watch<FeedMapNotifier>().feedMap[feedId].comments[index].isLaud == null
// //                 ? Colors.grey
// //                 : Colors.red,
// //           ),
// //         ),
// //         Container(
// //           height: 4,
// //         ),
// //         Offstage(
// //           offstage: context.watch<FeedMapNotifier>().feedMap[feedId].comments[index].laudCount == 0,
// //           child: Text(
// //             "${StringUtil.getNumber(context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].laudCount))}",
// //             style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
// //           ),
// //         )
// //       ],
// //     );
// //
// //     return Container(
// //       margin: EdgeInsets.only(left: 16, right: 16, top: 12),
// //       // color: AppColor.mainRed,
// //       child: Column(
// //         children: [
// //           GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTap: () {
// //               openInputBottomSheet(
// //                 context: context,
// //                 hintText: "回复 ${model.name}",
// //                 voidCallback: (String text, List<Rule> rules, BuildContext context) {
// //                   List<AtUsersModel> atListModel = [];
// //                   for (Rule rule in rules) {
// //                     AtUsersModel atModel;
// //                     atModel.index = rule.startIndex;
// //                     atModel.len = rule.endIndex;
// //                     atModel.uid = 1008611;
// //                     atListModel.add(atModel);
// //                   }
// //                   // 评论父评论
// //                   postComments(
// //                       targetId: model.id,
// //                       targetType: 2,
// //                       content: text,
// //                       atUsers: jsonEncode(atListModel),
// //                       replyId: model.uid,
// //                       replyCommentId: model.id,
// //                       commentModelCallback: (CommentDtoModel commentModel) {
// //                         context.read<FeedMapNotifier>().commentFeedCom(feedId, index, commentModel);
// //                         // 关闭评论输入框
// //                         // Navigator.of(context).pop(1);
// //                       });
// //                 },
// //               );
// //             },
// //             child: Row(
// //               // 横轴距定对齐
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: <Widget>[
// //                 avatar,
// //                 Expanded(child: info),
// //                 right,
// //               ],
// //             ),
// //           ),
// //           // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replyCount)  != 0
// //           model.replyCount != 0
// //               ? BottomListViewSubComment(
// //             replys:
// //             // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replys),
// //             model.replys,
// //             commentDtoModel: model,
// //             // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index]),
// //             listIndex: index, feedId: feedId,
// //           )
// //               : Container(),
// //         ],
// //       ),
// //     );
// //   }
// // }
