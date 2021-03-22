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
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

class Like extends StatefulWidget {
  Like({Key key, this.model}) : super(key: key);
  HomeFeedModel model;

  LikeState createState() => LikeState();
}

class LikeState extends State<Like> {
  List<FeedLaudListModel> laudListModel = [];

  @override
  void initState() {
    requestFeedLuadList();
  }
  // 请求点赞列表
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
    return Scaffold(
        appBar: CustomAppBar(
          titleString: "赞",
        ),
        body: Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Expanded(
              child: AnimationLimiter(
                  child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ScrollConfiguration(
                        behavior: NoBlueEffectBehavior(),
                        child: ListView.builder(
                          itemCount: laudListModel.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                //滑动动画
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                    //渐隐渐现动画
                                    child: index == 0
                                        ? Container(height: 14)
                                        : LikeListViewItem(model: laudListModel[index])),
                              ),
                            );
                          },
                        ),
                      ))))
        ],
      ),
    ));
  }
}

class LikeListViewItem extends StatelessWidget {
  FeedLaudListModel model;

  LikeListViewItem({this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 10),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "${model.nickName}",
                // '用户昵称显示',
                style: TextStyle(
                  color: AppColor.textPrimary1,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(height: 2),
              Offstage(
                offstage: model.description == null,
                child: Container(
                  width: ScreenUtil.instance.screenWidthDp - 32 - 38 - 38 - 12,
                  child: Text(
                    "${model.description}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
