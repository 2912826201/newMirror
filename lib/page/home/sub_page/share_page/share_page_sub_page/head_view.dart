
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class HeadView extends StatefulWidget{
  HomeFeedModel model;
  bool isDetail;
  // 删除动态
  ValueChanged<int> deleteFeedChanged;

  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;
  HeadView({this.model,this.isDetail,this.deleteFeedChanged,this.removeFollowChanged});
  @override
  State<StatefulWidget> createState() {
   return HeadViewState(deleteFeedChanged: deleteFeedChanged,removeFollowChanged: removeFollowChanged,isDetail:
   isDetail,model: model);
  }

}
class HeadViewState extends State<HeadView> {
  HeadViewState({Key key ,this.model, this.deleteFeedChanged,
    this.removeFollowChanged,this.isDetail = true});
  HomeFeedModel model;
  bool isDetail;
  // 删除动态
  ValueChanged<int> deleteFeedChanged;

  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;
  List<String> list = [];
  // 删除动态
  deleteFeed() async {
    Map<String, dynamic> map = await deletefeed(id: model.id);
    if (map["state"]) {
      deleteFeedChanged(model.id);
    } else {
      print("删除失败");
    }
  }
  // 关注or取消关注
  removeFollowAndFollow(int isFollow, int id, BuildContext context) async {
    print("isFollow:::::::::$isFollow");
    // 取消关注
    if (isFollow == 1||isFollow==3) {
      int relation = await ProfileCancelFollow(id);
      if (relation == 0 || relation == 2) {
        // context.read<FeedMapNotifier>().setIsFollow(id, isFollow);
        removeFollowChanged(model);
        model.isFollow = 0;
        list.remove("取消关注");
        setState(() {
        });
        ToastShow.show(msg: "已取消关注", context: context);
      } else {
        ToastShow.show(msg: "取消关注失败", context: context);
      }
    }else if(isFollow == 0||isFollow==2){
      int relation = await ProfileAddFollow(id);
      if(relation!=null){
        if(relation==1||relation==3){
          model.isFollow = 1;
          list.insert(0, "取消关注");
          setState(() {
          });
          ToastShow.show(msg: "关注成功!", context: context);
        }
      }
    }
  }
  // 是否显示关注按钮
  isShowFollowButton(BuildContext context) {
    if (isDetail && model.isFollow == 0) {
      return  GestureDetector(
        onTap: () {
          removeFollowAndFollow(2, model.pushId, context);
        },
        child: Container(
          margin: EdgeInsets.only(right: 6),
          height: 28,
          padding: EdgeInsets.only(left: 12,top: 6,right: 12,bottom: 6),
          alignment: Alignment(0,0),
          decoration:  BoxDecoration(
            border: new Border.all(color: AppColor.textPrimary1, width: 1),
            borderRadius:BorderRadius.circular((14.0)),
          ),
          child: Row(
            children: [
              Icon(Icons.add,color: AppColor.textPrimary1,size: 16,),
              // Container(
              //   width: 16,
              //   height: 16,
              //   child: Image.asset(name),
              // ),
              SizedBox(
                width: 4,
              ),
              Container(
                child: Text(
                  "关注",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.textPrimary1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (model.pushId == context.read<ProfileNotifier>().profile.uid) {
      list.add("删除");
    } else {
      if (model.isFollow == 1||model.isFollow==3) {
        list.add("取消关注");
      }
      list.add("举报");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                print('动态item的Id========================${model.pushId}');
                AppRouter.navigateToMineDetail(context, model.pushId);
              },
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 11),
                child: CircleAvatar(
                  // backgroundImage: AssetImage("images/test/yxlm1.jpeg"),
                  backgroundImage:
                  model.avatarUrl != null ? NetworkImage(model.avatarUrl) : NetworkImage("images/test.png"),
                  maxRadius: 19,
                ),
              ),
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: Text(
                        model.name ?? "空名字",
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () {},
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 2),
                      child: Text("${DateUtil.generateFormatDate(model.createTime,false)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          )),
                    )
                  ],
                )),
            isShowFollowButton(context),
            Container(
              margin: EdgeInsets.only(right: 16),
              child: GestureDetector(
                child: Image.asset("images/test/ic_big_dynamic_more.png", fit: BoxFit.cover, width: 24, height: 24),
                onTap: () {
                  openMoreBottomSheet(
                      context: context,
                      lists: list,
                      onItemClickListener: (index) {
                        if (list[index] == "删除") {
                          deleteFeed();
                        }
                        if (list[index] == "取消关注") {
                          removeFollowAndFollow(model.isFollow, model.pushId, context);
                        }
                      });
                },
              ),
            )
          ],
        ));
  }

}