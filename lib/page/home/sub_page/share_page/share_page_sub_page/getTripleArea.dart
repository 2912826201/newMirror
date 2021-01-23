//  点赞，转发，评论三连区域
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/feed/feed_comment_popups.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
typedef backCallBack = void Function();
class GetTripleArea extends StatefulWidget {
  HomeFeedModel model;
  int index;
  GlobalKey offsetKey;
  backCallBack back;
  CommentDtoModel comment;
  List<CommentDtoModel> commentDtoModel;
  GetTripleArea({Key key, this.model,this.index,this.offsetKey,this.comment,this.commentDtoModel,this.back}) : super(key: key);

  GetTripleAreaState createState() => GetTripleAreaState();
}

class GetTripleAreaState extends State<GetTripleArea> {
  @override
  Widget build(BuildContext context) {
    print("打印model的值￥${widget.model}");
    return Container(
        key: widget.offsetKey,
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Selector<FeedMapNotifier, List<String>>(builder: (context,laudUserInfo , child) {
              return laudUserInfo.length == 0 ? Container() : avatarOverlap(laudUserInfo.length, context,laudUserInfo);
            }, selector: (context, notifier) {
              return notifier.feedMap[widget.model.id].laudUserInfo;
            }),
            // context
            // widget.model.laudUserInfo.length > 0 ? avatarOverlap(widget.model.laudUserInfo.length, context,widget.model.laudUserInfo) : Container(),
            SizedBox(width: 5),
            Selector<FeedMapNotifier, List<String>>(builder: (context,laudUserInfo , child) {
                          return laudUserInfo.length == 0 ? Container() : roundedLikeNum(context);
                        }, selector: (context, notifier) {
                          return notifier.feedMap[widget.model.id].laudUserInfo;
                        }),
            // widget.model.laudUserInfo.length > 0 ? roundedLikeNum(context) : Container(),
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
        ],)
      );
    }
  }

  // 跳转点赞页
  jumpLike(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Like(model: widget.model,);
    }));
    // AppRouter.navigateToLikePage(context);
  }
  // 点赞
  setUpLuad() async {
    bool  isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否点赞了￥${context.read<FeedMapNotifier>().feedMap[widget.model.id].isLaud}");
    if (isLoggedIn) {
      Map<String, dynamic> model = await laud(id: widget.model.id, laud:context.read<FeedMapNotifier>().feedMap[widget.model.id].isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<FeedMapNotifier>().setLaud(widget.model.isLaud,context.read<ProfileNotifier>().profile.avatarUri,widget.model.id);
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
            offstage: context.select((FeedMapNotifier value) => value.feedMap[widget.model.id].laudCount) == null,

            child: //用Selector的方式监听数据
            Selector<FeedMapNotifier, int>(builder: (context,laudCount , child) {
              return Text("${StringUtil.getNumber(laudCount)}次赞",style: TextStyle(fontSize: 12),);
            }, selector: (context, notifier) {
              return notifier.feedMap[widget.model.id].laudCount;
            }),
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
                color:
                // widget.model.isLaud == 0
                context.select((FeedMapNotifier value) => value.feedMap[widget.model.id].isLaud) == 0
                    ? Colors.grey : Colors.redAccent,
               size: 24,
             ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          child:GestureDetector(
              onTap: () {
                openShareBottomSheet(
                    context: context,
                    map: widget.model.toJson(),
                    chatTypeModel: ChatTypeModel.MESSAGE_TYPE_FEED);
              },
              child: Image.asset(
                "images/test/分享.png",
                width: 24,
                height: 24,
              )),

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
                  openFeedCommentBottomSheet(context: context, feedId: widget.model.id,callback: (){
                    widget.back();
                  });
                  // SingletonForWholePages.singleton().panelController().open();
                  // context.read<FeedMapNotifier>().changeFeeId(widget.model.id);
                }))
      ],
    );
  }
}