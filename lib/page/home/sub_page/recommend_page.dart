import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/bottom_popup.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/rach_text_widget.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

FocusNode commentFocus = FocusNode();

// 推荐
class RecommendPage extends StatefulWidget {
  RecommendPage({Key key, this.coverUrls, this.pc}) : super(key: key);
  PanelController pc = new PanelController();
  List<CourseModel> coverUrls = [];

  RecommendPageState createState() => RecommendPageState();
}

class RecommendPageState extends State<RecommendPage> {
  @override
  Widget build(BuildContext context) {
    double screen_top = ScreenUtil.instance.statusBarHeight;
    final double bottomPadding = ScreenUtil.instance.bottomBarHeight;
    double inputHeight = MediaQuery.of(context).viewInsets.bottom;
    print("更新整个视图$inputHeight");
    return GestureDetector(
      onTap: () => print("点击"),
      onDoubleTap: () => print("双击"),
      onLongPress: () => print("长按"),
      onTapCancel: () => print("取消"),
      onTapUp: (e) => print("松开"),
      onTapDown: (e) => print("按下"),
      onPanDown: (DragDownDetails e) {
        commentFocus.unfocus(); // 失去焦点
        //打印手指按下的位置
        print("手指按下：${e.globalPosition}");
      },
      //手指滑动
      onPanUpdate: (DragUpdateDetails e) {
        print(e.delta.dx);
        print(e.delta.dy);
      },
      onPanEnd: (DragEndDetails e) {
        //打印滑动结束时在x、y轴上的速度
        print(e.velocity);
      },
      child: Stack(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 51 + bottomPadding),
              child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    ScrollMetrics metrics = notification.metrics;
                    // 注册通知回调
                    if (notification is ScrollStartNotification) {
                      // 滚动开始
                      print('滚动开始');
                      print("{{{{}}}}}}{{{{{{}}}}}}{{{{{}}}}}}}{{{{{}}}{}{}{}{}{}}{{}}{}}{}}{}}");
                    } else if (notification is ScrollUpdateNotification) {
                      // 滚动位置更新
                      print('滚动位置更新');
                      // 当前位置
                      print("当前位置${metrics.pixels}");
                    } else if (notification is ScrollEndNotification) {
                      // 滚动结束
                      print('滚动结束');
                      print("{{{{}}}}}}{{{{{{}}}}}}{{{{{}}}}}}}{{{{{}}}{}{}{}{}{}}{{}}{}}{}}{}}");
                    }
                  },
                  child: CustomScrollView(
                    slivers: [
                      // 因为SliverList并不支持设置滑动方向由CustomScrollView统一管理，所有这里使用自定义滚动
                      // CustomScrollView要求内部元素为Sliver组件， SliverToBoxAdapter可包裹普通的组件。
                      // 横向滑动区域
                      SliverToBoxAdapter(
                        child: getCourse(),
                      ),
                      // 垂直列表
                      SliverList(
                        delegate: SliverChildBuilderDelegate((content, index) {
                          return recommendListLayout(
                            index: index,
                            pc: widget.pc,
                          );
                        }, childCount: 19),
                      )
                    ],
                  ))),
          Positioned(
              bottom: inputHeight,
              left: 0,
              child: Offstage(
                offstage: inputHeight == 0,
                child: Container(
                  width: ScreenUtil.instance.screenWidthDp,
                  color: AppColor.white,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: commentInputBar(),
                ),
              ))
        ],
      ),
    );
  }

  // 课程横向布局
  getCourse() {
    return Container(
      margin: EdgeInsets.only(top: 24, bottom: 18),
      height: 93,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: widget.coverUrls.map((e) {
          var index = e.index;
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: index > 0 ? 24 : 16,
                      right: index == widget.coverUrls.length - 1 ? 16 : 0,
                      top: 0,
                      bottom: 8.5),
                  height: 53,
                  width: 53,
                  decoration: BoxDecoration(
                    // color: Colors.redAccent,
                    image: DecorationImage(image: NetworkImage(e.avatar), fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(Radius.circular(26.5)),
                  ),
                ),
                Container(
                  width: 53,
                  margin: EdgeInsets.only(
                      left: index > 0 ? 24 : 16,
                      right: index == widget.coverUrls.length - 1 ? 16 : 0,
                      top: 0,
                      bottom: 8.5),
                  child: Center(
                    child: Text(
                      "小课${index}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

//垂直列表推荐列表布局
class recommendListLayout extends StatefulWidget {
  recommendListLayout({Key key, this.index, this.pc}) : super(key: key);
  final index;
  PanelController pc;

  recommendListLayoutState createState() => recommendListLayoutState(index: index);
}

class recommendListLayoutState extends State<recommendListLayout> {
  final index;

  recommendListLayoutState({this.index});

  String longText =
      "1、信息展示：- 发布人相关：（1）用户：头像、昵称/备注（2）话题：话题头像、话题名- 动态相关：发布时间、图片/视频、文字、话题名- 社交相关：点赞数、评论数、分享数- 更多…： 点击…按键出现选框：- 图片：1:1、4:5、1.9:1为常规尺寸，对于纵图或者横图，未达到比例阈值前正常展示，超过比例阈值后只展示阈值中的部分。纵图阈值4:5、横图阈值1.9:1，具体展示情况看UI图，最多展示9张照片2、点击用户区域，除【…】外跳转至个人主页3、点击【更多】，出现弹窗我的动态：删除他人动态：取消关注、举报、图片区域- 图片最多展示9张，左右滑动切换- 当只有一张图片时，没有翻页符和张数提示";
  List<String> tags = [
    "这是课程呜呜呜呜呜呜外",
    "成都~福年广场wWWWWW12121332",
  ];
  List<String> PhotoUrl = [
    "images/test/yxlm.jpg",
    "images/test/yxlm1.jpeg",
    "images/test/yxlm2.jpeg",
    "images/test/yxlm3.jpeg",
    "images/test/yxlm4.jpg",
    "images/test/yxlm5.jpg",
    "images/test/yxlm6.jpg",
    "images/test/yxlm7.jpeg",
  ];

  void childFun() {
    print("hahahhahahahah");
    const timeout = const Duration(seconds: 3);
    Timer(timeout, () {
      print("hahahhahahahah");
    });
  }

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // 头部头像时间
        getHead(screen_width),
        // 图片区域
        SlideBanner(height: 200, list: PhotoUrl),
        // 点赞，转发，评论三连区域
        getTripleArea(num: 3, pc: widget.pc),
        // 课程信息和地址
        Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          // color: Colors.orange,
          width: screen_width,
          child: getCourseInfo(tags),
        ),
        // 文本文案
        Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: ExpandableText(
            text: longText,
            maxLines: 2,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        getAttention(this.index),
        // 评论文本
        commentLayout(
          commenNum: 4,
        ),
        // 输入框
        commentInputBox(),
        // 分割块
        Container(
          height: 18,
          color: Colors.white,
        )
      ],
    );
  }

  // 头部
  Widget getHead(var width) {
    return Container(
        height: 62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, right: 11),
              child: CircleAvatar(
                backgroundImage: NetworkImage("https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg"),
                maxRadius: 19,
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Text(
                    "哈哈哈",
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: () {},
                ),
                Container(
                  padding: EdgeInsets.only(top: 2),
                  child: Text("3小时前",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
                        list.add("删除");
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

  // 图片路径
  String getPhotoUrl(var index) {
    var url = "images/test/yxlm2.jpeg";
    if (index == 0 || index % 10 == 0) {
      url = "images/test/yxlm.jpg";
    } else if (index == 1 || index % 10 == 1) {
      url = "images/test/yxlm1.jpeg";
    } else if (index == 2 || index % 10 == 2) {
      url = "images/test/yxlm2.jpeg";
    } else if (index == 3 || index % 10 == 3) {
      url = "images/test/yxlm3.jpeg";
    } else if (index == 4 || index % 10 == 4) {
      url = "images/test/yxlm4.jpg";
    } else if (index == 5 || index % 10 == 5) {
      url = "images/test/yxlm5.jpg";
    } else if (index == 6 || index % 10 == 6) {
      url = "images/test/yxlm6.jpg";
    } else if (index == 7 || index % 10 == 7) {
      url = "images/test/yxlm7.jpeg";
    } else if (index == 8 || index % 10 == 8) {
      url = "images/test/yxlm8.jpg";
    } else if (index == 9 || index % 10 == 9) {
      url = "images/test/yxlm9.jpeg";
    }
    return url;
  }

// 视频
  Widget getVideo() {}

  // 课程信息和地址
  Widget getCourseInfo(var tags) {
    return Row(
      children: [for (String item in tags) TagItem(item, tags)],
    );
  }

  // 列表3的推荐书籍
  Widget getAttention(var index) {
    if (index == 3) {
      return Container(height: 100, width: 600, color: Colors.redAccent);
    }
    if (index == 1) {
      return Container(
        height: 80,
        width: 600,
        color: Colors.lightBlueAccent,
      );
    }
    return Container(
      width: 0,
      height: 0,
    );
  }
}

// wrap子元素课程信息和地址
class TagItem extends StatelessWidget {
  final String text;
  List tas;

  TagItem(this.text, this.tas);

  // 最外层圆角背景的宽度
  double getBgWidth() {
    // 获取屏幕宽度
    double screenWidth = ScreenUtil.instance.screenWidthDp;
    // 课程边框最大宽度
    double maxWidth = (screenWidth - 32 - 12) * 0.75; //减去两遍间距 32，再减去和地址的间距12.按照需求最大占剩下的4分之3，地址最大占4分之一
    // 文本最大宽度
    double textMaxWidth = maxWidth - 16 - 16 - 3; // 文本最大宽度要减去二变间距16，图片 16，文本和图片间距3.
    // 获取文本宽度
    double textWidth = getTextSize(text, TextStyle(fontSize: 12)).width;
    // 获取背景边框宽度
    double BgWidth = textWidth + 16 + 16 + 3;
    // 为课程时
    if (tas.indexOf(text) == 0) {
      // 文字宽度超长
      if (textWidth >= textMaxWidth) {
        return maxWidth;
      } else {
        return BgWidth;
      }
    } else {
      // 地址位置
      if (getTextSize(tas[0], TextStyle(fontSize: 12)).width >= textMaxWidth) {
        return (screenWidth - 32 - 12) * 0.25;
      } else {
        if (getTextSize(tas[0], TextStyle(fontSize: 12)).width + textWidth >
            (screenWidth - 32 - 12 - 32 - 3 - 32 - 3)) {
          return (screenWidth - 32 - 12) - getTextSize(tas[0], TextStyle(fontSize: 12)).width - 35;
        } else {
          return BgWidth;
        }
      }
    }
  }

  // 内层文本的宽度
  double getTextWidth() {
    // print("内层最大文本宽度${getBgWidth() - 16 - 16 - 3}");
    return getBgWidth() - 16 - 16 - 3;
  }

  // 截取文本添加...
  // 虽然有属性可设置，但是有个问题是汉字和数字，或者汉字和英文混排时，flutter 设置属性超出显示...数字和英文会自动换行。
  String interceptText(String textStr) {
    // 获取文本宽度
    double textWidth = getTextSize(text, TextStyle(fontSize: 12)).width;
    if (textWidth > getTextWidth()) {
      String frontText = textStr.substring(0, getTextWidth() ~/ 12);
      if (interceptNum(frontText) > 0) {
        // print(textStr.substring(0, (getTextWidth() ~/ 12 + interceptNum(frontText))));
        return textStr.substring(0, (getTextWidth() ~/ 12 + (interceptNum(frontText) ~/ 1.8))) + "...";
      }
      ;
      return frontText + "...";
    }
    return textStr;
  }

  // 判断截取了几个数字加小写英文
  int interceptNum(String str) {
    RegExp regExpStr = new RegExp(r"^[a-z0-9_]+$");
    var noChinesecharacter = 0;
    for (var i = 0; i < str.length; i++) {
      if (regExpStr.hasMatch(str[i])) {
        noChinesecharacter += 1;
      }
    }
    // print("存在$noChinesecharacter个非汉字");
    return noChinesecharacter;
  }

  @override
  Widget build(BuildContext context) {
    // coverUrls.indexOf(i)
    return Container(
      margin: EdgeInsets.only(left: tas.indexOf(text) != 0 ? 12 : 0),
      padding: EdgeInsets.only(top: 3.5, bottom: 3.5),
      width: getBgWidth(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Color.fromRGBO(242, 242, 242, 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 8),
            child: CircleAvatar(
              backgroundImage: AssetImage("images/test/yxlm9.jpeg"),
              maxRadius: 8,
            ),
          ),
          Container(
            width: getTextWidth(),
            child: Text(
              interceptText(text),
              style: TextStyle(fontSize: 12),
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
            ),
            margin: EdgeInsets.only(left: 3),
          ),
        ],
        // )
      ),
    );
  }
}

//  点赞，转发，评论三连区域
class getTripleArea extends StatefulWidget {
  var model;
  int num;
  PanelController pc;

  getTripleArea({Key key, this.model, this.num, this.pc}) : super(key: key);

  getTripleAreaState createState() => getTripleAreaState();
}

class getTripleAreaState extends State<getTripleArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: avatarOverlap(widget.num)),
          ],
        ));
  }

  // 横排重叠头像
  avatarOverlap(var num) {
    if (num == 1) {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(left: 16, top: 13.5, child: roundedAvatar()),
          Positioned(child: roundedLikeNum(), top: 18, left: 42),
          Positioned(top: 12, right: 16, child: roundedTriple(pc: widget.pc))
        ],
      );
    } else if (num == 2) {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(left: 16, top: 13.5, child: roundedAvatar()),
          Positioned(
            child: roundedAvatar(),
            left: 27,
            top: 13.5,
          ),
          Positioned(child: roundedLikeNum(), top: 18, left: 53),
          Positioned(top: 12, right: 16, child: roundedTriple(pc: widget.pc))
        ],
      );
    } else {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(top: 13.5, left: 16, child: roundedAvatar()),
          Positioned(child: roundedAvatar(), top: 13.5, left: 27),
          Positioned(child: roundedAvatar(), top: 13.5, left: 38),
          Positioned(child: roundedLikeNum(), top: 18, left: 64),
          Positioned(
            top: 12,
            right: 16,
            child: roundedTriple(pc: widget.pc),
          )
        ],
      );
    }
  }

  // 横排头像默认值
  roundedAvatar() {
    return CircleAvatar(
      backgroundImage: AssetImage("images/test/yxlm9.jpeg"),
      maxRadius: 10.5,
    );
  }

  // 横排
  roundedLikeNum() {
    return Container(
      // margin: EdgeInsets.only(left: 6),
      child: Text(
        "3次赞",
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

// 横排三连布局
class roundedTriple extends StatefulWidget {
  roundedTriple({Key key, this.pc}) : super(key: key);
  PanelController pc;

  roundedTripleState createState() => roundedTripleState();
}

class roundedTripleState extends State<roundedTriple> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          child: Image.asset(
            "images/test/爱心.png",
            width: 24,
            height: 24,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          child: Image.asset(
            "images/test/分享.png",
            width: 24,
            height: 24,
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 16),
            child: GestureDetector(
                child: Image.asset(
                  "images/test/消息.png",
                  width: 24,
                  height: 24,
                ),
                onTap: () {
                  widget.pc.open();
                }))
      ],
    );
  }
}

// 隐藏的输入框
class commentInputBox extends StatefulWidget {
  commentInputBox({Key key,this.isUnderline = false}) : super(key: key);
  bool isUnderline;
  commentInputBoxState createState() => commentInputBoxState();
}

class commentInputBoxState extends State<commentInputBox> {
  var offstage = true;

  inputHide() {
    setState(() {
      offstage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("底部键盘高度${MediaQuery.of(context).viewInsets.bottom}");
    return Offstage(
      offstage: false,
      child: Container(
        // color: Colors.limeAccent,
        height: 48,
        width: ScreenUtil.instance.screenWidthDp,
        decoration: BoxDecoration(
          // border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
          border:  Border(top: BorderSide(width: widget.isUnderline ? 0.5 : 0.000000001, color: Color(0xffe5e5e5))),
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage('https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg'),
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
                  child: Text("喜欢就评论吧~"),
                ),
                onTap: () {
                  // 唤醒键盘获取焦点
                  FocusScope.of(context).requestFocus(commentFocus);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 评论排版
class commentLayout extends StatefulWidget {
  commentLayout({Key key, this.commenNum}) : super(key: key);
  final commenNum;

  commentayoutState createState() => commentayoutState();
}

class commentayoutState extends State<commentLayout> {
  var userName = ["张珊", "李思", "王武", "赵柳"];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 6),
              child: Text(
                "共${widget.commenNum}条评论",
                style: TextStyle(fontSize: 12, color: Color.fromRGBO(153, 153, 153, 1)),
              )),
          MyRichTextWidget(
            Text(
              "${userName[0]}: 这是评论的内容，如果很长最多只显示一行。",
              style: TextStyle(fontSize: 13, color: Color.fromRGBO(151, 151, 151, 1)),
            ),
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            richTexts: [
              BaseRichText(
                "${userName[0]}:",
                style: TextStyle(color: Colors.black, fontSize: 14),
                onTap: () {
                  print("点击用户${userName[0]}");
                },
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 4, bottom: 4),
            child: MyRichTextWidget(
              Text(
                "${userName[1]}: 回复 ${userName[2]} 回复的其他人的评论内容超过这是评论的内容，如果很长最多只显示一行。",
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 12, color: Color.fromRGBO(151, 151, 151, 1)),
              ),
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              richTexts: [
                BaseRichText(
                  "${userName[1]}: 回复",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  onTap: () {
                    print("点击用户${userName[1]}");
                  },
                ),
                BaseRichText(
                  userName[2],
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  onTap: () {
                    print("点击用户${userName[2]}");
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// 底部评论框区域
class commentInputBar extends StatefulWidget {
  commentInputBar({Key key}) : super(key: key);

  commentInputBarState createState() => commentInputBarState();
}

class commentInputBarState extends State<commentInputBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: Platform.isIOS
              ? ScreenUtil.instance.screenWidthDp - 32
              : ScreenUtil.instance.screenWidthDp - 32 - 52 - 12,
          margin: EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: AppColor.bgWhite_65,
          ),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 80.0,
                    minHeight: 16.0,
                    maxWidth: Platform.isIOS
                        ? ScreenUtil.instance.screenWidthDp - 32 - 32 - 64
                        : ScreenUtil.instance.screenWidthDp - 32 - 32 - 64 - 52 - 12),
                child: TextField(
                  // 管理焦点
                  focusNode: commentFocus,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  //不限制行数
                  // 光标颜色
                  cursorColor: Color.fromRGBO(253, 137, 140, 1),
                  scrollPadding: EdgeInsets.all(0),
                  style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
                  // 装饰器修改外观
                  decoration: InputDecoration(
                    // 去除下滑线
                    border: InputBorder.none,
                    // 提示文本
                    hintText: "喜欢就评论吧~",
                    // 提示文本样式
                    hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
                    contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 16),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                color: Colors.redAccent,
                margin: EdgeInsets.only(left: 12),
              ),
              Container(
                width: 24,
                height: 24,
                color: Colors.redAccent,
                margin: EdgeInsets.only(left: 4),
              )
              // MyIconBtn()
            ],
          ),
        ),
        Offstage(
          offstage: Platform.isIOS,
          child: Container(
              // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
              height: 32,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: AppColor.textPrimary1,
              ),
              child: Center(
                child: Text(
                  "发送",
                  style: TextStyle(color: AppColor.white, fontSize: 14),
                ),
              )),
        )
      ],
    );
  }
}

// 底部评论抽屉
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
          commentInputBox(isUnderline: true,)
        ],
      ),
    );
  }
}

// 评论抽屉内的评论列表
class CommentBottomListView extends StatefulWidget {
  CommentBottomListView({Key key}) : super(key: key);

  CommentBottomListViewState createState() => CommentBottomListViewState();
}

class CommentBottomListViewState extends State<CommentBottomListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Row(
        // 横轴距定对齐
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          avatar,
          Expanded(child: info),
          right,
        ],
      ),
    );
  }

  Widget avatar = Container(
    child: Container(
      height: 42,
      width: 42,
      child: ClipOval(
        child: Image.network(
          "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif",
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
  Widget info = Container(
    margin: EdgeInsets.only(left:15,right: 12),
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      // Text(
      //   'LIUWEN 很喜欢这节课已经练习过55次了加油加油加油加油加油加油加油，',
      //   // style: StandardTextStyle.smallWithOpacity,
      // ),
      MyRichTextWidget(
        Text(
          "LIUWEN 很喜欢这节课已经练习过55次了加油加油加油加油加油加油加油啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦了。",
          overflow: TextOverflow.visible,
          style: TextStyle(
              fontSize: 14,
              color: AppColor.textPrimary1,
            fontWeight: FontWeight.w400
          ),
        ),
        maxLines: 2,
        textOverflow: TextOverflow.ellipsis,
        richTexts: [
          BaseRichText(
            "LIUWEN",
            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
            onTap: () {
              print("点击用户LIUWEN");
            },
          ),
        ],
      ),
      Container(height: 6),
      Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Text("3小时前   回复"),
      ),
      Text("-------  查看2条回复")
    ],
  ));
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
        // style: StandardTextStyle.small,
      ),
    ],
  );
}


