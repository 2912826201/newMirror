// 底部评论抽屉
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class CommentBottomSheet extends StatefulWidget {
  CommentBottomSheet({Key key, this.feedId}) : super(key: key);

  // 动态id
  int feedId;

  CommentBottomSheetState createState() => CommentBottomSheetState();
}

class CommentBottomSheetState extends State<CommentBottomSheet> {
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
    print("请求接口吗");
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
        await queryListByHot(targetId: widget.feedId, targetType: 0, page: this.dataPage, size: 20);

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
      context.read<FeedMapNotifier>().commensAssignment(widget.feedId, commentModel, totalCount);
    });
  }

  // 创建中间视图
  createMiddleView() {
    if (context.select((FeedMapNotifier value) => value.feedMap[widget.feedId].totalCount) == -1) {
      return Expanded(
          child: Container(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
            // loading 大小
            strokeWidth: 2,
          ),
        ),
      ));
    } else if (context.select((FeedMapNotifier value) => value.feedMap[widget.feedId].totalCount) == 0) {
      return Expanded(
          child: Container(
        color: Colors.redAccent,
        child: Center(
          child: Text("缺省图"),
        ),
      ));
    } else {
      return Expanded(
          // ListView头部有一段空白区域，是因为当ListView没有和AppBar一起使用时，头部会有一个padding，为了去掉padding，可以使用MediaQuery.removePadding
          child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
            itemCount: commentModel.length,
            controller: _controller,
            itemBuilder: (context, index) {
              print(index);
              print(commentModel.length);
              if (index == commentModel.length) {
                return LoadingView(
                  loadText: loadText,
                  loadStatus: loadStatus,
                );
              } else {
                return CommentBottomListView(
                  model: commentModel[index],
                  index: index,
                  feedId: widget.feedId,
                );
              }
            }),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
            ),
            child: Stack(
              overflow: Overflow.clip,
              children: [
                context.watch<FeedMapNotifier>().feedMap[widget.feedId].totalCount != -1
                    ? Positioned(
                        left: 16,
                        top: 17,
                        // DynamicModelNotifier
                        child: Selector<FeedMapNotifier, int>(builder: (context, totalCount, child) {
                          return Text(
                            "共${StringUtil.getNumber(totalCount)}条评论",
                            style: AppStyle.textRegular12,
                          );
                        }, selector: (context, notifier) {
                          return notifier.feedMap[widget.feedId].totalCount;
                        }),
                        // Text(
                        //    "共${commentModel != [] ?  commentModel[0].totalCount : 0}条评论",
                        //   style: TextStyle(fontSize: 14),
                        // )
                      )
                    : Container(),
                Positioned(
                    top: 15,
                    right: 16,
                    child: GestureDetector(
                      child: Image.asset("images/resource/2.0x/ic_big_nav_closepage@2x.png", width: 18, height: 18),
                      onTap: () {
                        // SingletonForWholePages.singleton().closePanelController();
                        Navigator.pop(context, true);
                      },
                    ))
              ],
            ),
          ),
          createMiddleView(),
          CommentInputBox(
            isUnderline: true,
            feedModel: context.watch<FeedMapNotifier>().feedMap[widget.feedId],
          ),
          SizedBox(height: ScreenUtil.instance.bottomHeight,)
        ],
      ),
    );
  }
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 中间的评论视图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥

class CommentBottomListView extends StatefulWidget{
  CommentDtoModel model;
  int index;
  int feedId;
  int choseItem;
  CommentBottomListView({this.model, this.index, this.feedId,this.choseItem});
  @override
  State<StatefulWidget> createState() {
  return CommentBottomListState();
  }
}
class CommentBottomListState extends State<CommentBottomListView> {
  bool isChose = false;
  // 点赞
  setUpLuad(BuildContext context) async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否点赞了￥${context.read<FeedMapNotifier>().feedMap[widget.feedId].comments[widget.feedId].isLaud}");
    if (isLoggedIn) {
      Map<String, dynamic> model = await laudComment(commentId: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<FeedMapNotifier>().mainCommentLaud(widget.model.isLaud, widget.feedId, widget.index);
      } else {
        // 失败
        print("shib ");
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.model.itemChose){
        isChose = true;
        Timer timer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
          widget.model.itemChose = false;
          timer.cancel();
          setState(() {
          });
        });
    }else{
      isChose = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    print(widget.model.targetId);
    // 头像
    var avatar = Container(
      child: Container(
        height: 42,
        width: 42,
        child: ClipOval(
          child: widget.model.avatarUrl != null
              ? Image.network(widget.model.avatarUrl, fit: BoxFit.cover)
              : Image.asset("images/test/yxlm1.jpeg", fit: BoxFit.cover),
        ),
      ),
    );

    // 评论
    Widget info = Container(
        margin: EdgeInsets.only(left: 15, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyRichTextWidget(
              Text(
                widget.model.name + " " + widget.model.content,
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
              ),
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
              richTexts: [
                BaseRichText(
                  (widget.model.name + " " + widget.model.content).substring(0, widget.model.name.length),
                  style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
                  onTap: () {
                    print(widget.model.uid);
                  },
                ),
              ],
            ),
            Container(height: 6),
            Container(
              child: Text(
                "${DateUtil.generateFormatDate(widget.model.createTime)} 回复",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          ],
        ));

    // 点赞
    Widget right = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setUpLuad(context);
          },
          child: Icon(
            Icons.favorite,
            color: context.watch<FeedMapNotifier>().feedMap[widget.feedId].comments[widget.index].isLaud == 0
                ? Colors.grey
                : context.watch<FeedMapNotifier>().feedMap[widget.feedId].comments[widget.index].isLaud == null
                    ? Colors.grey
                    : Colors.red,
          ),
        ),
        Container(
          height: 4,
        ),
        Offstage(
          offstage: context.watch<FeedMapNotifier>().feedMap[widget.feedId].comments[widget.index].laudCount == 0,
          child: Text(
            "${StringUtil.getNumber(context.select((FeedMapNotifier value) => value.feedMap[widget.feedId].comments[widget.index].laudCount))}",
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
        )
      ],
    );

    return Container(
      margin: EdgeInsets.only(top: 12),
      // color: AppColor.mainRed,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              openInputBottomSheet(
                context: context,
                hintText: "回复 ${widget.model.name}",
                voidCallback: (String text, List<Rule> rules, BuildContext context) {
                  List<AtUsersModel> atListModel = [];
                  for (Rule rule in rules) {
                    AtUsersModel atModel;
                    atModel.index = rule.startIndex;
                    atModel.len = rule.endIndex;
                    atModel.uid = rule.id;
                    atListModel.add(atModel);
                  }
                  // 评论父评论
                  postComments(
                      targetId: widget.model.id,
                      targetType: 2,
                      content: text,
                      atUsers: jsonEncode(atListModel),
                      replyId: widget.model.uid,
                      replyCommentId: widget.model.id,
                      commentModelCallback: (CommentDtoModel commentModel) {
                        context.read<FeedMapNotifier>().commentFeedCom(widget.feedId, widget.index, commentModel);
                        // 关闭评论输入框
                        // Navigator.of(context).pop(1);
                      });
                },
              );
            },
            child:  AnimatedPhysicalModel(
              shape: BoxShape.rectangle,
              color: widget.model.itemChose ? AppColor.bgWhite: AppColor.white,
              elevation:0,
              shadowColor: !widget.model.itemChose ?AppColor.bgWhite: AppColor.white,
              duration: Duration(seconds: 1),
              child: Container(
              padding: EdgeInsets.only(left: 16,right: 16,top: 9,bottom: 8),
              child: Row(
              // 横轴距定对齐
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                avatar,
                Expanded(child: info),
                right,
              ],
            ),) ,
            ),
          ),
          // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replyCount)  != 0
          widget.model.replyCount != 0
              ? BottomListViewSubComment(
                  replys:
                      // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replys),
                  widget.model.replys,
                  commentDtoModel: widget.model,
                  // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index]),
                  listIndex: widget.index, feedId: widget.feedId,
                )
              : Container(),
        ],
      ),
    );
  }
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 评论抽屉内的评论列表的子评论列表 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥

class BottomListViewSubComment extends StatefulWidget {
  int listIndex;
  int feedId;
  List<CommentDtoModel> replys;
  CommentDtoModel commentDtoModel;
  int commentId;
  BottomListViewSubComment({Key key,this.commentId, this.replys, this.commentDtoModel, this.listIndex, this.feedId}) : super(key: key);

  BottomListViewSubCommentState createState() => BottomListViewSubCommentState();
}

class BottomListViewSubCommentState extends State<BottomListViewSubComment> {
  // 请求页数
  int pageCount = 0;

  // 记录initCount的初始值；
  int initNum;

  @override
  // 初始化赋值
  void initState() {
    print(
        "初始化数据了+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    if (widget.commentDtoModel.initCount == null) {
      widget.commentDtoModel.initCount = widget.commentDtoModel.replyCount;
      widget.commentDtoModel.isShowHiddenButtons = false;
      widget.commentDtoModel.isClickHideButton = false;
    }
  }

  // 隐藏数据
  hideData() {
    widget.commentDtoModel.replys.clear();
    // 切换按钮
    widget.commentDtoModel.isShowHiddenButtons = false;
    // 恢复总条数
    widget.commentDtoModel.initCount = widget.commentDtoModel.replyCount;
    // 请求页数还原
    pageCount = 0;
    setState(() {});
  }

  // 加载数据
  loadData() async {
    pageCount += 1;
    // 总条数大于三每次点击取三条
    if (widget.commentDtoModel.initCount > 3) {
      Map<String, dynamic> model =
          await queryListByHot2(targetId: widget.commentDtoModel.id, targetType: 2, page: this.pageCount, size: 3);
      if (model["list"] != null) {
        model["list"].forEach((v) {
          widget.replys.add(CommentDtoModel.fromJson(v));
        });
      }
      widget.commentDtoModel.initCount -= 3;
    } else {
      // 总条数不足三条把剩下条数取完，切换按钮
      if (widget.commentDtoModel.initCount > 0) {
        Map<String, dynamic> model = await queryListByHot2(
            targetId: widget.commentDtoModel.id,
            targetType: 2,
            page: this.pageCount,
            size: widget.commentDtoModel.initCount);
        if (model["list"] != null) {
          model["list"].forEach((v) {
            widget.replys.add(CommentDtoModel.fromJson(v));
          });
        }
        widget.commentDtoModel.isShowHiddenButtons = true;
      }
    }
    setState(() {});
  }

  // 切换按钮
  toggleButton() {
    // 是否显示隐藏按钮
    if (widget.commentDtoModel.isShowHiddenButtons) {
      return GestureDetector(
        child: Text("─── 隐藏回复", style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          hideData();
        },
      );
    } else {
      print("按钮initCount    ------${widget.commentDtoModel.initCount}");
      return GestureDetector(
        child: Text("─── 查看${StringUtil.getNumber(widget.commentDtoModel.initCount)}条回复",
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          loadData();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 12, left: 57),
        padding: EdgeInsets.only(left: 16,right: 16),
        // color: Colors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 子评论
            // Offstage(
            //   offstage:widget.commentDtoModel.replys.isEmpty,
            // !widget.commentDtoModel.isShowAllComment,
            // child: AnimationLimiter(
            // ListView头部有一段空白区域，是因为当ListView没有和AppBar一起使用时，头部会有一个padding，为了去掉padding，可以使用MediaQuery.removePadding
            MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child:
        ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.replys.length,
                    itemBuilder: (context, index) {
                      return BottomListViewSubCommentListItem(
                        model: widget.replys[index],
                        subIndex: index,
                        mainIndex: widget.listIndex,
                        feedId: widget.feedId,
                        commentDtoModel: widget.commentDtoModel,
                      );
                    }
                    )
    ),

            // 查看按钮和隐藏按钮的切换
            Offstage(
              offstage: widget.commentDtoModel.isShowInteractiveButton == false,
              child: toggleButton(),
            ),
            // 间距
            SizedBox(
              height: 12,
            )
          ],
        ));
  }
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 评论抽屉内的评论列表的子评论列表item %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
class BottomListViewSubCommentListItem extends StatelessWidget {
  BottomListViewSubCommentListItem({this.model, this.subIndex, this.mainIndex, this.feedId, this.commentDtoModel});

  CommentDtoModel model;
  int subIndex;
  int mainIndex;
  int feedId;
  CommentDtoModel commentDtoModel;

  @override
  // 点赞
  setUpLuad(BuildContext context, int subIndex, CommentDtoModel models) async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否点赞了￥${context.read<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys[subIndex].isLaud}");
    if (isLoggedIn) {
      Map<String, dynamic> model = await laudComment(commentId: models.id, laud: models.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<FeedMapNotifier>().subCommentLaud(models.isLaud, feedId, mainIndex, subIndex);
      } else {
        // 失败
        print("shib ");
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        openInputBottomSheet(
          context: context,
          hintText: "回复 ${model.name}",
          voidCallback: (String text, List<Rule> rules, BuildContext context) {
            List<AtUsersModel> atListModel = [];
            for (Rule rule in rules) {
              AtUsersModel atModel;
              atModel.index = rule.startIndex;
              atModel.len = rule.endIndex;
              atModel.uid = rule.id;
              atListModel.add(atModel);
            }
            // 评论子评论
            postComments(
                targetId: commentDtoModel.id,
                targetType: 2,
                content: text,
                atUsers: jsonEncode(atListModel),
                replyId: model.uid,
                replyCommentId: model.id,
                commentModelCallback: (CommentDtoModel commentModel) {
                  context.read<FeedMapNotifier>().commentFeedCom(feedId, mainIndex, commentModel);
                  // 关闭评论输入框
                  // Navigator.of(context).pop(1);
                });
          },
        );
      },
      child: Row(
        //   // 横轴距定对齐
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // child: Container(
          Container(
            height: 32,
            width: 32,
            child: ClipOval(
              child: Image.network(
                model.avatarUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ),
          Expanded(
            child: Container(
                margin: EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MyRichTextWidget(
                      Text(
                        model.replyName != null
                            ? model.name + " 回复 " + model.replyName + " " + model.content
                            : model.name + " " + model.content,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
                      ),
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      richTexts: setBaseRichText(model),
                    ),
                    Container(height: 6),
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "${DateUtil.generateFormatDate(model.createTime)} 回复",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          // 点赞
          GestureDetector(
            onTap: () {
              setUpLuad(context, subIndex, model);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.favorite,
                  color:
                      context.watch<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys[subIndex].isLaud == 0
                          ? Colors.grey
                          : Colors.red,
                ),
                Container(
                  height: 4,
                ),
                Offstage(
                  offstage:
                      context.watch<FeedMapNotifier>().feedMap[feedId].comments[mainIndex].replys[subIndex].laudCount ==
                          0,
                  child: Text(
                    "${StringUtil.getNumber(context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[mainIndex].replys[subIndex].laudCount))}",
                    style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      // ),
    );
  }

  setBaseRichText(CommentDtoModel model) {
    List<BaseRichText> richTexts = [];
    String contextText;
    if (model.replyName != null) {
      contextText = model.name + " 回复 " + model.replyName + model.content;
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length),
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.uid}");
        },
      ));
      richTexts.add(BaseRichText(
        contextText.substring(model.name.length + 4, model.name.length + 4 + model.replyName.length),
        // "${model.name + model.replyName}:",
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.replyId}");
        },
      ));
    } else {
      contextText = "${model.name} ${model.content}";
      richTexts.add(BaseRichText(
        contextText.substring(0, model.name.length),
        style: AppStyle.textMedium14,
        onTap: () {
          print("点击用户${model.uid}");
        },
      ));
    }
    return richTexts;
  }
}
