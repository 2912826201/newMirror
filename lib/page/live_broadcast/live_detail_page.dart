import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/action_model.dart';
import 'package:mirror/data/model/user_comment_model.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/ToastShow.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

import 'SliverCustomHeaderDelegate.dart';

/// 直播详情页
class LiveDetailPage extends StatefulWidget {
  @override
  createState() => new LiveDetailPageState();
}

class LiveDetailPageState extends State<LiveDetailPage>
    with TickerProviderStateMixin {
  var actionModelList = <ActionModel>[];
  var titleTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  bool isExpandedTrue = false;
  var courseCommentArray = <UserCommentModel>[];
  var commentListSubSettingList = <CommentListSubSetting>[];
  var commentItemHeight = 65;

  var controllerArrayOpen = <AnimationController>[];
  var controllerArrayClose = <AnimationController>[];
  var animationArrayOpen = <Animation>[];
  var animationArrayClose = <Animation>[];

  var animationTime = 300; //毫秒

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    setDataAction();
    setDataComment();
    setAnimationData();

    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: NoBlueEffectBehavior(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverCustomHeaderDelegate(
                    title: '哪吒之魔童降世',
                    collapsedHeight: 40,
                    expandedHeight: 300,
                    paddingTop: MediaQuery.of(context).padding.top,
                    valueArray: ["45", "108", "初级"],
                    titleArray: ["分钟", "千卡", "难度"],
                    coverImgUrl: 'images/test/bg.png'),
              ),
              _getCoachItem(),
              _getLineView(),
              _getActionUi(),
              _getLineView(),
              _getCourseCommentUi(),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: Container(
            color: Colors.lightBlueAccent,
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: _getBottomBar(),
          ),
          bottom: 0,
        ),
      ],
    );
  }

  //获取教练的名字
  Widget _getCoachItem() {
    return SliverToBoxAdapter(
      child: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        color: Colors.white,
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0.5, color: Colors.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "images/test/bg.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Container(
              child: Column(
                children: [
                  Text(
                    "教练名字",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            Container(
              padding:
                  const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text("关注"),
            )
          ],
        ),
      ),
    );
  }

  //获取横线
  Widget _getLineView() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 10,
        color: Colors.grey,
      ),
    );
  }

  //获取动作的ui
  Widget _getActionUi() {
    var widgetArray = <Widget>[];
    var titleStyle = TextStyle(fontSize: 20);
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      width: double.infinity,
      child: Text(
        "动作  ${actionModelList.length}个",
        style: titleTextStyle,
      ),
    ));
    for (var value in actionModelList) {
      widgetArray.add(Container(
        width: double.infinity,
        height: 0.3,
        margin: const EdgeInsets.only(left: 20, right: 20),
        color: Colors.grey,
      ));
      widgetArray.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 30, right: 20),
          padding: const EdgeInsets.only(top: 13, bottom: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.title,
                style: titleStyle,
              ),
              Text(
                value.longTime,
                style: titleStyle,
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgetArray,
        ),
      ),
    );
  }

  //课程评论的框架--头部的数据
  Widget _getCourseCommentUi() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            //title
            Container(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              width: double.infinity,
              child: Text(
                "课程评论",
                style: titleTextStyle,
              ),
            ),
            //数量和排序
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "110评论",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    "按热度/按时间",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("images/test/yxlm1.jpeg"),
                            // image: NetworkImage('https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg'),
                            fit: BoxFit.cover)),
                  ),
                  GestureDetector(
                    child: Container(
                      width: ScreenUtil.instance.screenWidthDp - 32 - 40,
                      height: 28,
                      margin: EdgeInsets.only(left: 12),
                      padding: EdgeInsets.only(left: 16),
                      alignment: Alignment(-1, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: AppColor.bgWhite_65,
                      ),
                      child: Text("说点什么吧~",
                          style: TextStyle(
                              fontSize: 14, color: AppColor.textHint)),
                    ),
                    onTap: () {
                      ToastShow.show("点击了添加评论", context);
                    },
                  ),
                ],
              ),
            ),
            _getCommentItemUi(),
          ],
        ),
      ),
    );
  }

  //评论列表的外层的评论
  Widget _getCommentItemUi() {
    var widgetArray = <Widget>[];

    widgetArray.add(SizedBox(
      height: 10,
    ));
    for (int i = 0; i < courseCommentArray.length; i++) {
      UserCommentModel value = courseCommentArray[i];

      widgetArray.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            _getCommentUi(value, false),
            Offstage(
              offstage: value.subCommentCount < 1,
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    GestureDetector(
                      child: Container(
                        child: Text(
                          "—— " +
                              (commentListSubSettingList[i].isFold
                                  ? "查看"
                                  : "隐藏") +
                              "${value.subCommentCount}条回复",
                          style: TextStyle(color: Colors.grey),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 55),
                      ),
                      onTap: () {
                        print("点击-${commentListSubSettingList[i].isFold}");
                        if (commentListSubSettingList[i].isFold) {
                          controllerArrayOpen[i].forward();
                        } else {
                          controllerArrayClose[i].forward();
                        }
                        delaySetting(i);
                        // commentListSubSettingList[i].isFold=!commentListSubSettingList[i].isFold;
                      },
                    ),
                    _getSubCommentItemUi(value, i),
                    // Offstage(
                    //   offstage: commentListSubSettingList[i].isFold,
                    //   child: _getSubCommentItemUi(value,i),
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return Container(
      width: double.infinity,
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //sub 子品评论
  Widget _getSubCommentItemUi(UserCommentModel value, int index) {
    var widgetArray = <Widget>[];
    if (value.subCommentList != null && value.subCommentList.length > 0) {
      for (int i = 0; i < value.subCommentList.length; i++) {
        widgetArray.add(_getCommentUi(value.subCommentList[i], true));
      }
    }
    return Container(
      width: double.infinity,
      height: double.parse((commentListSubSettingList[index].isFold
              ? animationArrayOpen[index].value
              : animationArrayClose[index].value)
          .toString()),
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 55),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: widgetArray,
        ),
      ),
    );
  }

  //获取评论的item--每一个item
  Widget _getCommentUi(UserCommentModel value, bool isSubComment) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      height: commentItemHeight.toDouble(),
      width: double.infinity,
      child: Row(
        children: [
          //头像
          Container(
            width: 45,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(width: 0.5, color: Colors.black),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                value.userUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          //间隔
          SizedBox(
            width: 10,
          ),
          //中间信息
          Expanded(
              child: SizedBox(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    value.userName + "   " + value.content,
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    value.createTime +
                        "  " +
                        (value.praiseCount.toString()) +
                        "次赞   回复",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          )),
          //点赞
          Container(
            height: double.infinity,
            child: Center(
              child: GestureDetector(
                child: Icon(
                  Icons.favorite_border,
                  color: value.userIsPraise ? Colors.red : Colors.grey,
                ),
                onTap: () {
                  value.userIsPraise = true;
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //获取底部按钮
  Widget _getBottomBar() {
    var textStyle = TextStyle(fontSize: 20, color: Colors.white);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text(
          "预览视频",
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  //设置数据
  void setDataAction() {
    if (actionModelList != null && actionModelList.length > 0) {
      return;
    }
    for (int i = 0; i < 6; i++) {
      ActionModel actionModel = new ActionModel();
      actionModel.id = i * 6;
      actionModel.title = "动作" + i.toString() * 6;
      actionModel.count = i;
      actionModel.longTime = "05 '00'";
      actionModelList.add(actionModel);
    }
  }

  //设置数据
  void setDataComment() {
    if (courseCommentArray != null && courseCommentArray.length > 0) {
      return;
    }

    for (int i = 0; i < 6; i++) {
      UserCommentModel userCommentModel = new UserCommentModel();
      userCommentModel.id = i * 7;
      userCommentModel.content = "评论内容" + i.toString() * 7;
      userCommentModel.createTime = "2020-12-09 08:00";
      userCommentModel.praiseCount = Random().nextInt(1000);
      userCommentModel.subCommentCount = Random().nextInt(6);
      userCommentModel.userId = (i * 8).toString();
      userCommentModel.userIsPraise = Random().nextInt(1000) > 800;
      userCommentModel.userName = "用户名字" + i.toString() * 5;
      userCommentModel.userUrl = "images/test/bg.png";
      var userCommentModelSub = <UserCommentModel>[];
      for (int j = 0; j < userCommentModel.subCommentCount; j++) {
        UserCommentModel subComment = new UserCommentModel();
        subComment.id = i * 7;
        subComment.content = "子评论内容" + i.toString() * 7;
        subComment.createTime = "2020-12-09 010:00";
        subComment.praiseCount = Random().nextInt(1000);
        subComment.userId = (i * 8).toString();
        subComment.userIsPraise = Random().nextInt(1000) > 800;
        subComment.userName = "用户名字" + j.toString() * 6;
        subComment.userUrl = "images/test/bg.png";
        subComment.replyName = userCommentModel.userName;
        userCommentModelSub.add(subComment);
      }
      userCommentModel.subCommentList = userCommentModelSub;
      courseCommentArray.add(userCommentModel);
      CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
      commentListSubSetting.commentId = userCommentModel.id;
      commentListSubSetting.isFold = true;
      commentListSubSetting.subCommentAllHeight =
          userCommentModel.subCommentCount * commentItemHeight;
      commentListSubSettingList.add(commentListSubSetting);
    }
  }

  //这是动画的值
  void setAnimationData() {
    if (controllerArrayOpen != null && controllerArrayOpen.length > 0) {
      return;
    }
    for (var value in commentListSubSettingList) {
      AnimationController _controllerOpen;
      AnimationController _controllerClose;
      Animation _animationOpen;
      Animation _animationClose;
      _controllerOpen = AnimationController(
          vsync: this, duration: Duration(milliseconds: animationTime))
        ..addListener(() {
          setState(() {});
        });
      _controllerClose = AnimationController(
          vsync: this, duration: Duration(milliseconds: animationTime))
        ..addListener(() {
          setState(() {});
        });
      _animationOpen =
          Tween(begin: 0, end: value.subCommentAllHeight.toDouble())
              .animate(_controllerOpen)
                ..addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    _controllerOpen.reverse();
                  }
                });
      _animationClose =
          Tween(begin: value.subCommentAllHeight.toDouble(), end: 0)
              .animate(_controllerClose)
                ..addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    _controllerClose.reverse();
                  }
                });
      controllerArrayOpen.add(_controllerOpen);
      controllerArrayClose.add(_controllerClose);
      animationArrayOpen.add(_animationOpen);
      animationArrayClose.add(_animationClose);
    }
  }

  //设置改变的值
  void delaySetting(int i) async {
    Future.delayed(Duration(milliseconds: animationTime), () {
      commentListSubSettingList[i].isFold =
          !commentListSubSettingList[i].isFold;
    });
  }
}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  int subCommentAllHeight;
}
