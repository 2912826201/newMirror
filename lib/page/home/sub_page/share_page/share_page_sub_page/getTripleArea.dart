//  点赞，转发，评论三连区域
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/route/router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
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
            Selector<DynamicModelNotifier, List<String>>(builder: (context,laudUserInfo , child) {
              return laudUserInfo.length == 0 ? Container() : avatarOverlap(laudUserInfo.length, context,laudUserInfo);
            }, selector: (context, notifier) {
              return notifier.dynamicModel.laudUserInfo;
            }),
            // context

            SizedBox(width: 5),
            Selector<DynamicModelNotifier, List<String>>(builder: (context,laudUserInfo , child) {
              return laudUserInfo.length == 0 ? Container() : roundedLikeNum(context);
            }, selector: (context, notifier) {
              return notifier.dynamicModel.laudUserInfo;
            }),
            // widget.model.laudUserInfo.length == 0 ? Container(width: 20,) : roundedLikeNum(context),
            Spacer(),
            Container(
              width: 104,
              margin: EdgeInsets.only(right: 16),
              child: roundedTriple(),
            )

          ],
        ));
  }

  // 横排重叠头像
  avatarOverlap(int num, BuildContext context,List<String> laudUserInfo) {
    print("num:$num");
    if (num == 1) {
        return  Container(
          width: 37,
          child:  Stack(
            overflow: Overflow.clip,
            children: [
              Positioned(left: 16, top: 13.5, child: roundedAvatar(context,laudUserInfo[0])),
              // Positioned(child: roundedLikeNum(context), top: 18, left: 42),
            ],
          ),
        );


    } else if (num == 2) {
      return Container(
        width: 48,
          child:Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(left: 16, top: 13.5, child: roundedAvatar(context,laudUserInfo[0])),
          Positioned(
            child: roundedAvatar(context,laudUserInfo[1]),
            left: 27,
            top: 13.5,
          ),
          // Positioned(child: roundedLikeNum(context), top: 18, left: 53),
        ],
          ));
    } else {
       return Container(
          width: 59,
          child: Stack(
        overflow: Overflow.clip,
        children: [
          Positioned(top: 13.5, left: 16, child: roundedAvatar(context,laudUserInfo[0])),
          Positioned(child: roundedAvatar(context,laudUserInfo[1]), top: 13.5, left: 27),
          Positioned(child: roundedAvatar(context,laudUserInfo[2]), top: 13.5, left: 38),
          // Positioned(child: roundedLikeNum(context), top: 18, left: 64),
        ],)
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
  // 点赞
  setUpLuad() async {
    bool  isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      Map<String, dynamic> model = await laud(id: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<DynamicModelNotifier>().setLaud(widget.model.isLaud,context.read<ProfileNotifier>().profile.avatarUri);
      } else { // 失败
        print("shib ");
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  // 横排头像默认值
  roundedAvatar(BuildContext context,String url) {
    return GestureDetector(
      onTap: () {
        jumpLike(context);
      },
      child: CircleAvatar(
        backgroundImage: NetworkImage(url) ?? AssetImage("images/test/yxlm9.jpeg"),
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
            child: //用Selector的方式监听数据
            Selector<DynamicModelNotifier, int>(builder: (context,laudCount , child) {
              return Text("$laudCount次赞",style: TextStyle(fontSize: 12),);
            }, selector: (context, notifier) {
              return notifier.dynamicModel.laudCount;
            }),
            // child:  Text(
            //   "${context.select((value) => null)}次赞",
            //   style: TextStyle(fontSize: 12),
            // ),
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
                setUpLuad();
              },
             child:  Icon(
               Icons.favorite,
                color: context.watch<DynamicModelNotifier>().dynamicModel.isLaud == 0 ? Colors.grey : Colors.redAccent,
               size: 24,
             ),
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
                  context.read<FeedIdcommentlNotifier>().getCommentIdCallback(widget.model.id);
                  Application.feedModel = widget.model;
                }))
      ],
    );
  }
}