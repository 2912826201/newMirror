import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/bottom_sheet.dart' as CustomBottomSheet;
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/rach_text_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// 关注
class AttentionPage extends StatefulWidget {
  AttentionPage({Key key, this.coverUrls}) : super(key: key);
  List<CourseModel> coverUrls = [];

  AttentionPageState createState() => AttentionPageState();
}

class AttentionPageState extends State<AttentionPage> {
  PanelController _pc = new PanelController();
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
        panel: Center(
          child: TikTokCommentBottomSheet(),
        ),
      backdropEnabled: true,
      controller: _pc,
      minHeight: 0,
      body:Container(
          margin: EdgeInsets.only(top: 68),
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
                        pc: _pc,
                      );
                    }, childCount: 19),
                  )
                ],
              ))) ,
    );

  }

  // 课程横向布局
  getCourse() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: widget.coverUrls.map((e) {
          var index = e.index;
          return Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: index > 0 ? 5 : 16, right: index == widget.coverUrls.length - 1 ? 16 : 0, top: 5, bottom: 5),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  // color: Colors.redAccent,
                  image: DecorationImage(image: NetworkImage(e.avatar), fit: BoxFit.cover),
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
              ),
              Text("小课$index")
            ],
          );
        }).toList(),
      ),
    );
  }
}


//垂直列表推荐列表布局
class recommendListLayout extends StatefulWidget{
  recommendListLayout({Key key, this.index,this.pc}) : super(key: key);
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
    "这是课程A222",
    "成都~福年广场",
    "陈建华教练",
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
        // 图片
        getPhoto(this.index, screen_width),
        // 点赞，转发，评论三连区域
        getTripleArea(num: 2,pc:widget.pc),
        // 课程信息和地址
        Container(
          margin: EdgeInsets.only(left: 13, right: 16),
          width: screen_width,
          child: getCourseInfo(tags),
        ),
        // 文本文案
        Container(
          margin: EdgeInsets.only(left: 16, right: 16,bottom: 8),
          child: ExpandableText(
            text: longText,
            maxLines: 2,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        getAttention(this.index),
        inputBox(),
        commentText(commenNum: 4,),
        // RaisedButton(onPressed: () {
        //
        // },
        //   color: Colors.limeAccent,
        // ),
        // 分割块
        Container(
          height: 10,
          color: Color.fromARGB(255, 234, 233, 234),
        )
      ],
    );
  }

  // 头部
  Widget getHead(var width) {
    return Container(
        height: 60,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, right: 8),
              child: CircleAvatar(
                backgroundImage: NetworkImage("https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg"),
                maxRadius: 25,
              ),
            ),
            Container(
                height: 38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: Text(
                        "哈哈哈",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      onTap: () {},
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text("3小时前",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          )),
                    )
                  ],
                )),
            Container(
              // color: Colors.deepOrangeAccent,
              margin: EdgeInsets.only(
                  left: width - 16 - 50 - 8 - 16 - 28 - getTextSize("哈哈哈", TextStyle(fontSize: 14)).width),
              child: GestureDetector(
                child: Image.asset("images/test/ic_big_dynamic_more.png", fit: BoxFit.cover, width: 28, height: 28),
              ),
            )
          ],
        ));
  }

  // 图片
  Widget getPhoto(var index, var screen_width) {
    var url = getPhotoUrl(index);
    return Container(
      width: screen_width,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(url), fit: BoxFit.cover),
      ),
      height: 200,
    );
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
    return Wrap(
      children: [for (String item in tags) TagItem(item)],
    );
  }

  // 列表3的推荐书籍
  Widget getAttention(var index) {
    if (index == 3) {
      return Container(
          height: 100,
          width: 600,
          color: Colors.redAccent
      );
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

  TagItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Color.fromRGBO(242, 242, 242, 1),
      ),
      child: Container(
          margin: EdgeInsets.all(4),
          child: Stack(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("images/test/yxlm9.jpeg"),
                maxRadius: 8,
              ),
              Container(
                child: Text(text),
                margin: EdgeInsets.only(left: 20),
              ),
            ],
          )),
    );
  }
}

//  点赞，转发，评论三连区域
class getTripleArea extends StatefulWidget {
  var model;
  int num;
  PanelController pc;
  getTripleArea({Key key, this.model, this.num,this.pc}) : super(key: key);

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
          Positioned(left: 16, top: 9, child: roundedAvatar()),
          Positioned(child: roundedLikeNum(), top: 16, left: 50),
          Positioned(
            top: 10,
            right: 16,
            child: roundedTriple(pc: widget.pc)
          )
        ],
      );
    } else if (num == 2) {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(left: 16, top: 9, child: roundedAvatar()),
          Positioned(
            child: roundedAvatar(),
            left: 41,
            top: 9,
          ),
          Positioned(child: roundedLikeNum(), top: 16, left: 75),
          Positioned(
            top: 10,
            right: 16,
            child: roundedTriple(pc:widget.pc)
          )
        ],
      );
    } else {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(top: 9, left: 16, child: roundedAvatar()),
          Positioned(child: roundedAvatar(), top: 9, left: 41),
          Positioned(child: roundedAvatar(), top: 9, left: 66),
          Positioned(child: roundedLikeNum(), top: 16, left: 100),
          Positioned(
            top: 10,
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
      maxRadius: 15,
    );
  }

  // 横排
  roundedLikeNum() {
    return Container(
      // margin: EdgeInsets.only(left: 6),
      child: Text("3次赞"),
    );
  }
}

// 横排三连布局
class roundedTriple extends StatefulWidget {
  roundedTriple({Key key,this.pc}) : super(key: key);
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
            width: 28,
            height: 28,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 12),
          child: Image.asset(
            "images/test/分享.png",
            width: 28,
            height: 28,
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 12),
            child:GestureDetector(
                child: Image.asset(
                  "images/test/消息.png",
                  width: 28,
                  height: 28,
                ),
                onTap: () {
                  widget.pc.open();
                }
            )

        )
      ],
    );
  }
}

// 隐藏的输入框
class inputBox extends StatefulWidget {
  inputBox({Key key}) : super(key: key);
  inputBoxState createState() => inputBoxState();
}
class inputBoxState extends State<inputBox> {
  var offstage = true;
  inputHide() {
    setState(() {
      offstage = false;
    });
  }
  @override
  Widget build(BuildContext context) {
   return Offstage(
     offstage: offstage,
     child: Container(
       color: Colors.limeAccent,
       height: 40,
       width: 300,
     ),
   );
  }
}
// 评论排版
class commentText extends StatefulWidget {
  commentText({Key key,this.commenNum}) : super(key: key);
  final commenNum;
  commentTextState createState() => commentTextState();
}
class commentTextState extends State<commentText> {
  var userName = ["张珊","李思","王武","赵柳"];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: EdgeInsets.only(left: 16,right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             margin: EdgeInsets.only(bottom: 8),
             child:
             Text(
               "共${widget.commenNum}条评论",
               style: TextStyle(
                 fontSize: 14,
                 color: Color.fromRGBO(153, 153, 153, 1)
               ),
             )
           ),

          MyRichTextWidget(
            Text(
              "${userName[0]} 这是评论的内容，如果很长最多只显示一行。",
              style: TextStyle(
                fontSize: 12,
                color: Color.fromRGBO(151, 151, 151, 1)
              ),
            ),
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            richTexts: [
              BaseRichText(
                  userName[0],
                style: TextStyle(color: Colors.black,fontSize: 14),
                onTap: () {
                    print("点击用户${userName[0]}");
                },
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 4,bottom: 4),
            child:  MyRichTextWidget(
              Text(
                "${userName[1]} 回复 ${userName[2]} 回复的其他人的评论内容超过这是评论的内容，如果很长最多只显示一行。",
                overflow: TextOverflow.visible,
                style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(151, 151, 151, 1)
                ),
              ),
              maxLines:1,
              textOverflow: TextOverflow.ellipsis,
              richTexts: [
                BaseRichText(
                  userName[1],
                  style: TextStyle(color: Colors.black,fontSize: 14),
                  onTap: () {
                    print("点击用户${userName[1]}");
                  },
                ),
                BaseRichText(
                  userName[2],
                  style: TextStyle(color: Colors.black,fontSize: 14),
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



class TikTokCommentBottomSheet extends StatelessWidget {
  const TikTokCommentBottomSheet({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(4),
            height: 4,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            height: 24,
            alignment: Alignment.center,
            // color: Colors.white.withOpacity(0.2),
            child: Text(
              '128条评论',
            ),
          ),
          Expanded(
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: <Widget>[
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
                _CommentRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _CommentRow extends StatelessWidget {
  const _CommentRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '是假用户哟',
          // style: StandardTextStyle.smallWithOpacity,
        ),
        Container(height: 2),
        Text(
          '这是一条模拟评论，主播666啊。',
          // style: StandardTextStyle.normal,
        ),
      ],
    );
    Widget right = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.favorite,
          color: Colors.white,
        ),
        Text(
          '54',
          // style: StandardTextStyle.small,
        ),
      ],
    );
    right = Opacity(
      opacity: 0.3,
      child: right,
    );
    var avatar = Container(
      margin: EdgeInsets.fromLTRB(0, 8, 10, 8),
      child: Container(
        height: 36,
        width: 36,
        child: ClipOval(
          child: Image.network(
            "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif",fit: BoxFit.cover,
          ),
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: <Widget>[
          avatar,
          Expanded(child: info),
          right,
        ],
      ),
    );
  }
}