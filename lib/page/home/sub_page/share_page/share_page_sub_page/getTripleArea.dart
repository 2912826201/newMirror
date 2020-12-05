//  点赞，转发，评论三连区域
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GetTripleArea extends StatefulWidget {
  HomeFeedModel model;
  int num;
  PanelController pc;

  GetTripleArea({Key key, this.model, this.num, this.pc}) : super(key: key);

  GetTripleAreaState createState() => GetTripleAreaState();
}

class GetTripleAreaState extends State<GetTripleArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: avatarOverlap(num, context)),
          ],
        ));
  }

  // 横排重叠头像
  avatarOverlap(var num, BuildContext context) {
    if (num == 1) {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(left: 16, top: 13.5, child: roundedAvatar(context)),
          Positioned(child: roundedLikeNum(context), top: 18, left: 42),
          Positioned(top: 12, right: 16, child: roundedTriple())
        ],
      );
    } else if (num == 2) {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(left: 16, top: 13.5, child: roundedAvatar(context)),
          Positioned(
            child: roundedAvatar(context),
            left: 27,
            top: 13.5,
          ),
          Positioned(child: roundedLikeNum(context), top: 18, left: 53),
          Positioned(top: 12, right: 16, child: roundedTriple())
        ],
      );
    } else {
      return Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(top: 13.5, left: 16, child: roundedAvatar(context)),
          Positioned(child: roundedAvatar(context), top: 13.5, left: 27),
          Positioned(child: roundedAvatar(context), top: 13.5, left: 38),
          Positioned(child: roundedLikeNum(context), top: 18, left: 64),
          Positioned(
            top: 12,
            right: 16,
            child: roundedTriple(),
          )
        ],
      );
    }
  }

  // 跳转点赞页
  jumpLike(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Like();
    }));
    // AppRouter.navigateToLikePage(context);
  }

  // 横排头像默认值
  roundedAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        jumpLike(context);
      },
      child: CircleAvatar(
        backgroundImage: AssetImage("images/test/yxlm9.jpeg"),
        maxRadius: 10.5,
      ),
    );
  }

  // 横排
  roundedLikeNum(BuildContext context) {
    return GestureDetector(
      onTap: () {
        jumpLike(context);
      },
      child: Container(
        // margin: EdgeInsets.only(left: 6),
          child: Offstage(
            offstage: widget.model.laudCount == null,
            child:  Text(
              "${widget.model.laudCount ?? 0}次赞",
              style: TextStyle(fontSize: 12),
            ),
          )

      ),
    );
  }
  // 横排三连布局
  roundedTriple () {
    return Row(
      children: [
        Container(
          child: GestureDetector(
              onTap: () {

              },
              child: Image.asset(
                "images/test/爱心.png",
                width: 24,
                height: 24,
              )),
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