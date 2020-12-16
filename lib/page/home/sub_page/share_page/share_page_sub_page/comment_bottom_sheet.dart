// 底部评论抽屉
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class CommentBottomSheet extends StatefulWidget {
  CommentBottomSheet({Key key, this.pc, this.feedId}) : super(key: key);
  // 动态id
  int feedId;
  // 抽屉控制器
  PanelController pc;

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
    List<CommentDtoModel> modelList = await queryListByHot1(
        targetId: widget.feedId, targetType: 0, page: this.dataPage, size: 20);

    print("打印返回值￥%${modelList.isNotEmpty}");
    setState(() {
      totalCount = modelList[0].totalCount;
      modelList.removeAt(0);
      if (this.dataPage == 1) {
        if (modelList.isNotEmpty) {
          for (CommentDtoModel model in modelList) {
             if(model.replyCount > 0) {
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
          if(model.replyCount > 0) {
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
      context.read<FeedMapNotifier>().commensAssignment(widget.feedId, commentModel,totalCount);
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
    } else if ( context.select((FeedMapNotifier value) => value.feedMap[widget.feedId].totalCount) == 0) {
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
              if (index == commentModel.length
              ) {
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
                            "共$totalCount条评论",
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
                        widget.pc.close();
                      },
                    ))
              ],
            ),
          ),
          createMiddleView(),
          CommentInputBox(
            isUnderline: true,
            feedModel: context.watch<FeedMapNotifier>().feedMap[widget.feedId],
          )
        ],
      ),
    );
  }
}





//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 中间的评论视图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥




class CommentBottomListView extends StatelessWidget {
  CommentDtoModel model;
  int index;
  int feedId;
  CommentBottomListView({this.model, this.index,this.feedId});

  @override
  Widget build(BuildContext context) {
    print(model.targetId);
    // 头像
    var avatar = Container(
      child: Container(
        height: 42,
        width: 42,
        child: ClipOval(
          child:  model.avatarUrl != null ? Image.network(model.avatarUrl, fit: BoxFit.cover) : Image.asset("images/test/yxlm1.jpeg",fit: BoxFit.cover),
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
                model.name + " " + model.content,
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
              ),
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
              richTexts: [
                BaseRichText(
                  (model.name + " " + model.content).substring(0, model.name.length),
                  style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
                  onTap: () {
                    print(model.uid);
                  },
                ),
              ],
            ),
            Container(height: 6),
            Container(
              child: Text(
                "${model.createTime}  回复",
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
        Icon(
          Icons.favorite,
          color: Colors.grey,
        ),
        Container(
          height: 4,
        ),
        Offstage(
          offstage: context.watch<FeedMapNotifier>().feedMap[feedId].comments[index].laudCount == 0,
          child: Text(
            "${context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].laudCount)}",
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
        )
      ],
    );

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              openInputBottomSheet(
                context: context,
                hintText: "回复 ${model.name}" ,
                voidCallback: (String text, BuildContext context)  {
                  // 评论父评论
                  postComments(targetId: model.id, targetType: 2, content: text, commentModelCallback:(CommentDtoModel commentModel) {
                    context.read<FeedMapNotifier>().commentFeedCom(feedId,index,commentModel);
                    // 关闭评论输入框
                    Navigator.of(context).pop(1);
                  });

                },
              );
            },
            child: Row(
              // 横轴距定对齐
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                avatar,
                Expanded(child: info),
                right,
              ],
            ),
          ),
          // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replyCount)  != 0
        model.replyCount != 0
              ? BottomListViewSubComment(
            replys:
            // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index].replys),
          model.replys,
          commentDtoModel:
              model,
          // context.select((FeedMapNotifier value) => value.feedMap[feedId].comments[index]),
    listIndex: index,feedId: feedId,)
              : Container(),
        ],
      ),
    );
  }
}




//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 评论抽屉内的评论列表的子评论 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
//￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥

class BottomListViewSubComment extends StatefulWidget {
  int listIndex;
  int feedId;
  List<CommentDtoModel> replys;
  CommentDtoModel commentDtoModel;
  BottomListViewSubComment({Key key, this.replys,this.commentDtoModel,this.listIndex,this.feedId}) : super(key: key);

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
    print("初始化数据了+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    if(widget.commentDtoModel.initCount == null) {
      widget.commentDtoModel.initCount = widget.commentDtoModel.replyCount;
      print("数据源总长度${ widget.commentDtoModel.initCount}::::::initCount");
      widget.commentDtoModel.isShowHiddenButtons = false;
      // widget.commentDtoModel.isShowAllComment = true;
      widget.commentDtoModel.isClickHideButton = false;
    }
  }

  // 隐藏数据
  hideData() {
    // 点击了隐藏按钮，
    // widget.commentDtoModel.isClickHideButton = true;
    widget.commentDtoModel.replys.clear();
    // 隐藏所有评论
    // widget.commentDtoModel.isShowAllComment = false;
    // 切换按钮
    widget.commentDtoModel.isShowHiddenButtons = false;
    // 恢复总条数
    widget.commentDtoModel.initCount =  widget.commentDtoModel.replyCount;
    // 请求页数还原
    pageCount = 0;
    setState(() {});
  }

  // 加载数据
  loadData() async{
    // widget.commentDtoModel.isShowAllComment = true;

    // // 是否点击过隐藏按钮，点击过表示数据已经取完
    // if ( widget.commentDtoModel.isClickHideButton) {
    //   widget.commentDtoModel.isShowHiddenButtons = true;
    //   setState(() {});
    //   return;
    // }
    pageCount += 1;
    // 总条数大于三每次点击取三条
    if (widget.commentDtoModel.initCount  > 3)  {
      Map<String, dynamic> model =
      await queryListByHot(targetId:widget.commentDtoModel.id, targetType: 2, page: this.pageCount, size: 3);
      if(model["list"] != null) {
        model["list"].forEach((v) {
          widget.replys.add(CommentDtoModel.fromJson(v));
        });
      }
      widget.commentDtoModel.initCount -= 3;
    } else {
      // 总条数不足三条把剩下条数取完，切换按钮
      if (widget.commentDtoModel.initCount > 0) {
        Map<String, dynamic> model =
        await queryListByHot(targetId:widget.commentDtoModel.id, targetType: 2, page: this.pageCount, size: widget.commentDtoModel.initCount);
        if(model["list"] != null) {
          model["list"].forEach((v) {
            widget.replys.add(CommentDtoModel.fromJson(v));
          });
        }
        widget.commentDtoModel.isShowHiddenButtons = true;
      }
    }
    setState(() {});
  }

  // 子评论
  subComments(CommentDtoModel model) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        
        // Application.isArouse = true;
        // Application.replysModel = model;
        // Application.commentDtoModel = context.read<FeedIdcommentlNotifier>().commentDtoModel[widget.listIndex];
        // // commentDtoModel[widget.listIndex];
        // // context.select((FeedIdcommentlNotifier value) => value.commentDtoModel[index]);
        // print("评论model赋值${ Application.replysModel.id}");
        // // 唤醒键盘获取焦点 commentFocus
        // FocusScope.of(context).requestFocus(commentFocus);
        // Application.hintText = "回复${model.name}";
        // Application.commentTypes = CommentTypes.commentSubCom;
      },
      child:
    Row(
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
                      model.name + " " + model.content,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
                    ),
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                    richTexts: [
                      BaseRichText(
                        model.name ,
                        style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
                        onTap: () {
                          print("点击用户LIUWEN");
                        },
                      ),
                      // BaseRichText(
                      //   "@AaryCheueng",
                      //   style: TextStyle(color: AppColor.mainBlue, fontSize: 15, fontWeight: FontWeight.w500),
                      //   onTap: () {
                      //     print("点击AaryCheueng");
                      //   },
                      // ),
                    ],
                  ),
                  Container(height: 6),
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "${model.createTime}   回复",
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.favorite,
              color: Colors.grey,
            ),
            Container(
              height: 4,
            ),
            Text(
              "${model.laudCount}",
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
            ),
          ],
        )
      ],
      ),
      // ),
    );
  }

  // 切换按钮
  toggleButton() {
    // 是否显示隐藏按钮
    if ( widget.commentDtoModel.isShowHiddenButtons) {
      return GestureDetector(
        child: Text("─── 隐藏回复", style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          hideData();
        },
      );
    } else {
      print("按钮initCount    ------${widget.commentDtoModel.initCount}");
        return GestureDetector(
          child: Text("─── 查看${widget.commentDtoModel.initCount }条回复",
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
          onTap: () {
            loadData();
          },
        );
    }
  }

  // 子评论列表
  subCommentsList(List<CommentDtoModel> model) {
    // 没有子评论就没必要显示
    return
      // Offstage(
      // offstage: widget.commentDtoModel.initCount == null,
      // child:
      Container(
          margin: EdgeInsets.only(top: 12, left: 57),
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
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: model.length,
                          itemBuilder: (context, index) {
                            return  subComments(model[index]);
                          })),
                // ),
              // ),
              // 间距
              // Container(
              //   height: 12,
              // ),
              // 查看按钮和隐藏按钮的切换
              Offstage(
                offstage: widget.commentDtoModel.isShowInteractiveButton == false,
                child:
                toggleButton(),
              ),
              SizedBox(height: 12,)
            ],
          )


    );
  }

  @override
  Widget build(BuildContext context) {

    return subCommentsList(widget.replys);
  }
}
