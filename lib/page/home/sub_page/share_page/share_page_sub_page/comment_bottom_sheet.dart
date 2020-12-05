// 底部评论抽屉
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/sub_comments.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CommentBottomSheet extends StatelessWidget {
  CommentBottomSheet({Key key, this.pc}) : super(key: key);
  PanelController pc;

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
                Positioned(
                    left: 16,
                    top: 17,
                    child: Text(
                      "共150条评论",
                      style: TextStyle(fontSize: 14),
                    )),
                Positioned(
                    top: 15,
                    right: 16,
                    child: GestureDetector(
                      child: Image.asset("images/resource/2.0x/ic_big_nav_closepage@2x.png", width: 18, height: 18),
                      onTap: () {
                        pc.close();
                      },
                    ))
              ],
            ),
          ),
          Expanded(
            // ListView头部有一段空白区域，是因为当ListView没有和AppBar一起使用时，头部会有一个padding，为了去掉padding，可以使用MediaQuery.removePadding
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return CommentBottomListView();
                    }),
              )),
          CommentInputBox(
            isUnderline: true,
          )
        ],
      ),
    );
  }
}

// 评论抽屉内的评论列表
// class CommentBottomListView extends StatefulWidget {
//   CommentBottomListView({Key key}) : super(key: key);
//
//   CommentBottomListViewState createState() => CommentBottomListViewState();
// }

class CommentBottomListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 头像
    var avatar = Container(
      child: Container(
        height: 42,
        width: 42,
        child: ClipOval(
          child: Image.asset("images/test/yxlm1.jpeg", fit: BoxFit.cover),
          // (
          //   "https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg",
          //   // "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif",
          //   fit: BoxFit.cover,
          // ),
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
                "LIUWEN 很喜欢这节课已经练习过55次了加油加油加油加油加油加油加油啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦了。",
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
              ),
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
              richTexts: [
                BaseRichText(
                  "LIUWEN",
                  style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
                  onTap: () {
                    print("点击用户LIUWEN");
                  },
                ),
              ],
            ),
            Container(height: 6),
            Container(
              child: Text(
                "3小时前   回复",
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
        Text(
          '54',
          style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Column(
        children: [
          Row(
            // 横轴距定对齐
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              avatar,
              Expanded(child: info),
              right,
            ],
          ),
          BottomListViewSubComment(index: 2)
        ],
      ),
    );
  }
}

// 评论抽屉内的评论列表的子评论
class BottomListViewSubComment extends StatefulWidget {
  var index;

  BottomListViewSubComment({Key key, this.index}) : super(key: key);

  BottomListViewSubCommentState createState() => BottomListViewSubCommentState();
}

class BottomListViewSubCommentState extends State<BottomListViewSubComment> {
  List<SubCommentsModel> subModel = [];

  // 子评论总条数
  int count;

  // 是否显示隐藏按钮
  bool isShowHiddenButtons;

  // 保存的总条数
  int initCount;

  // 是否显示所有子评论
  bool isShowAllComment;

  // 是否点击过隐藏按钮
  bool isClickHideButton;

  @override
  // 初始化赋值
  void initState() {
    count = 5;
    initCount = 5;
    isShowHiddenButtons = false;
    isShowAllComment = true;
    isClickHideButton = false;
  }

  // 隐藏数据
  hideData() {
    // 点击了隐藏按钮，
    isClickHideButton = true;
    // 隐藏所有评论
    isShowAllComment = false;
    // 切换按钮
    isShowHiddenButtons = false;
    // 恢复总条数
    count = initCount;
    setState(() {});
  }

  // 加载数据
  loadData() {
    isShowAllComment = true;
    // 是否点击过隐藏按钮，点击过表示数据已经取完
    if (isClickHideButton) {
      isShowHiddenButtons = true;
      setState(() {});
      return;
    }
    // 总条数大于三每次点击取三条
    if (count - 3 > 0) {
      for (var i = 0; i < 3; i++) {
        var model = new SubCommentsModel();
        model.totalCommentNum = widget.index + 3;
        model.avatar = "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2623955494.webp";
        model.commentStr = "LIUWEN 好棒强烈推 @AaryCheueng一起来学习吧~";
        model.timeub = "3小时前 回复";
        subModel.add(model);
      }
      count -= 3;
    } else {
      // 总条数不足三条把剩下条数取完，切换按钮
      if (count > 0) {
        for (var i = 0; i < count; i++) {
          var model = new SubCommentsModel();
          model.totalCommentNum = widget.index + 3;
          model.avatar = "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2623955494.webp";
          model.commentStr = "LIUWEN 好棒强烈推 @AaryCheueng一起来学习吧~";
          model.timeub = "3小时前 回复";
          subModel.add(model);
        }
        isShowHiddenButtons = true;
      }
    }
    setState(() {});
  }

  // 子评论
  subComments(SubCommentsModel model) {
    // return   Container(
    // color: Colors.red,
    // child: Expanded(
    return Row(
      //   // 横轴距定对齐
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // child: Container(
        Container(
          height: 32,
          width: 32,
          child: ClipOval(
            child: Image.network(
              model.avatar,
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
                      model.commentStr,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 14, color: AppColor.textPrimary1, fontWeight: FontWeight.w400),
                    ),
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                    richTexts: [
                      BaseRichText(
                        "LIUWEN",
                        style: TextStyle(color: AppColor.textPrimary1, fontSize: 15, fontWeight: FontWeight.w500),
                        onTap: () {
                          print("点击用户LIUWEN");
                        },
                      ),
                      BaseRichText(
                        "@AaryCheueng",
                        style: TextStyle(color: AppColor.mainBlue, fontSize: 15, fontWeight: FontWeight.w500),
                        onTap: () {
                          print("点击AaryCheueng");
                        },
                      ),
                    ],
                  ),
                  Container(height: 6),
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "3小时前   回复",
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
              '666',
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
            ),
          ],
        )
      ],
      // ),
      // ),
    );
  }

  // 切换按钮
  toggleButton() {
    // 是否显示隐藏按钮
    if (isShowHiddenButtons) {
      return GestureDetector(
        child: Text("─── 隐藏回复", style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          hideData();
        },
      );
    } else {
      return GestureDetector(
        child: Text("─── 查看${count}条回复", style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          loadData();
        },
      );
    }
  }

  // 子评论列表
  subCommentsList(List<SubCommentsModel> model) {
    // 没有子评论就没必要显示
    return Offstage(
      offstage: count == 0,
      child: Container(
          margin: EdgeInsets.only(top: 12, left: 57),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 查看按钮和隐藏按钮的切换
              toggleButton(),
              // 间距
              Container(
                height: 12,
              ),
              // 子评论
              Offstage(
                offstage: !isShowAllComment,
                child: AnimationLimiter(
                  child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: model.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                    verticalOffset: 50.0, child: FadeInAnimation(child: subComments(model[index]))));
                          })),
                ),
              )
            ],
          )
        // ListView头部有一段空白区域，是因为当ListView没有和AppBar一起使用时，头部会有一个padding，为了去掉padding，可以使用MediaQuery.removePadding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return subCommentsList(subModel);
  }
}