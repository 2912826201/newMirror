import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/feed_laud_list.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

class Like extends StatefulWidget {
  Like({Key key,this.model}) : super(key: key);
  HomeFeedModel model;
  LikeState createState() => LikeState();
}

class LikeState extends State<Like> {
  String text = "赞";
  List<FeedLaudListModel> laudListModel = [];
  double offset(String texts) {
    // 屏幕宽度减去文字宽度对半分
    double half = (ScreenUtil.instance.screenWidthDp - getTextSize(texts,TextStyle(fontSize: 16),1).width) / 2.0;

    double offsetWidth = half - 16 - 28;
    return offsetWidth;
  }
@override
  void initState() {
    requestFeedLuadList();
  }
  requestFeedLuadList() async {
    DataResponseModel model = await getFeedLaudList(targetId: widget.model.id);
    if (mounted) {
      setState(() {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            laudListModel.add(FeedLaudListModel.fromJson(v));
          });
          laudListModel.insert(0, FeedLaudListModel());
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Container(
            height: 44.0,
            width: ScreenUtil.instance.screenWidthDp,
            margin: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
            padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyIconBtn(
                  width: 28,
                  height: 28,
                  iconSting: "images/resource/2.0x/return2x.png",
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                Container(
                  margin: EdgeInsets.only(left: offset(text)),
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColor.textPrimary1,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: AnimationLimiter(
                  child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ScrollConfiguration(
                        behavior: NoBlueEffectBehavior(),
                        child: ListView.builder(
                          itemCount: laudListModel.length ,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                //滑动动画
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                    //渐隐渐现动画
                                    child: index == 0 ? Container(height: 14) : LikeListViewItem(model:laudListModel[index])),
                              ),
                            );
                          },
                        ),
                      )
                  )
              )
          )
        ],
      ),
    );
  }
}

class LikeListViewItem extends StatelessWidget {
  FeedLaudListModel model;
  LikeListViewItem({this.model});
  @override
  Widget build(BuildContext context) {
    // 头像
    var avatar = Container(
      child: Container(
        margin: EdgeInsets.only(right: 16),
        height: 38,
        width: 38,
        child: ClipOval(
          child: Image.network(
            model.avatarUrl,
            // "https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
    var info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "${model.uid}",
          // '用户昵称显示',
          style: TextStyle(
            color: AppColor.textPrimary1,
            fontSize: 15,
              decoration: TextDecoration.none
          ),
        ),
        Container(height: 2),
        Container(
          width: ScreenUtil.instance.screenWidthDp - 32 - 38 - 38 - 12,
          child:Text(
            "${DateUtil.generateFormatDate(model.laudTime)}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: AppColor.textSecondary,
                fontSize: 12,
                decoration: TextDecoration.none
            ),
          ),
        )

      ],
    );
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 10),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [avatar,info],

      ),
    );
  }
}
