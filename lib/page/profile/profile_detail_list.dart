import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

///个人主页动态List
class ProfileDetailsList extends StatefulWidget {
  int type;
  int id;
  bool isMySelf;

  ProfileDetailsList({this.type, this.id, this.isMySelf});

  @override
  State<StatefulWidget> createState() {
    return ProfileDetailsListState();
  }
}

class ProfileDetailsListState extends State<ProfileDetailsList> with AutomaticKeepAliveClientMixin {
  ///动态model
  List<HomeFeedModel> followModel = [];


  int followDataPage = 1;
  int followlastTime;
  RefreshController _refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  StateResult fllowState = StateResult.RESULTNULL;

  _getDynamicData() async {
    if (followDataPage > 1 && followlastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    List<int> idList = [];
    DataResponseModel model =
        await getPullList(type: widget.type, size: 20, targetId: widget.id, lastTime: followlastTime);
    setState(() {
      if (followDataPage == 1) {
        followModel.clear();
        context.read<ProfilePageNotifier>().idListClear(widget.id, type:widget.type);
        if (model!=null&&model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            idList.add(HomeFeedModel.fromJson(result).id);
          });
          context.read<ProfilePageNotifier>().setFeedIdList(widget.id, idList, widget.type);
          fllowState = StateResult.HAVERESULT;
          _refreshController.refreshCompleted();
        } else {
          print('======================没有数据');
          fllowState = StateResult.RESULTNULL;
          _refreshController.refreshCompleted();
          setState(() {
          });
        }
      } else if (followDataPage > 1 && followlastTime != null) {
        if (model!=null&&model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            idList.add(HomeFeedModel.fromJson(result).id);
          });
          context.read<ProfilePageNotifier>().setFeedIdList(widget.id, idList, widget.type);
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }
    });
    followlastTime = model.lastTime;
    List<HomeFeedModel> feedList = [];
    context.read<FeedMapNotifier>().feedMap.forEach((key, value) {
      feedList.add(value);
    });
    // 只同步没有的数据
    context.read<FeedMapNotifier>().updateFeedMap(StringUtil.followModelFilterDeta(followModel, feedList));
  }

  ///上拉加载
  _onLoadding() {
    followDataPage += 1;
    _getDynamicData();
  }

  _onRefresh() {
    followDataPage = 1;
    followlastTime = null;
    _getDynamicData();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,(){
      _getDynamicData();
    });
  }

  @override
  Widget build(BuildContext context) {
   return Container(
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,

      ///刷新控件
      child: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.loading) {
              body = Text("正在加载");
            } else if (mode == LoadStatus.idle) {
              body = Text("上拉加载更多");
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败,请重试");
            } else {
              body = Text("没有更多了");
            }
            return Container(
              child: Center(
                child: body,
              ),
            );
          },
        ),
        header: WaterDropHeader(
          complete: Text("刷新完成"),
          failed: Text(""),
        ),
        controller: _refreshController,
        onLoading: _onLoadding,
        onRefresh: _onRefresh,
        child: _showDataUi(),
      ),
    );



  }
  Widget _showDataUi(){
    var list = ListView.builder(
        shrinkWrap: true, //解决无限高度问题
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: widget.type==2
            ?context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.id].profileFeedListId.length
            :context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.id].profileLikeListId.length,
        itemBuilder: (context, index) {
          HomeFeedModel model;
          if(index>0){
            try{
              int id = widget.type==2
                  ?context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.id]
                  .profileFeedListId[index]
                  :context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.id]
                  .profileLikeListId[index];
              model = context.read<FeedMapNotifier>().feedMap[id];
            }catch(e){
              print(e);
            }
          }
          if (index == 0) {
            return Container(
              height: 10,
            );
          } else {
            return DynamicListLayout(
              index: index,
              pageName: "profileDetails",
              isShowRecommendUser: false,
              isShowConcern: false,
              model: model,
              isMySelf: widget.isMySelf,
              mineDetailId: widget.id,
              key: GlobalObjectKey("attention$index"),
              removeFollowChanged: (model) {},
              deleteFeedChanged: (feedId) {
                context.read<ProfilePageNotifier>().synchronizeIdList(widget.id,feedId);
                if(widget.type==2&&context.read<ProfilePageNotifier>().profileUiChangeModel[widget.id]
                    .profileFeedListId.length<2){
                  print('=====================动态列表删完了');
                  fllowState = StateResult.RESULTNULL;
                }else if(widget.type==6&&context.read<ProfilePageNotifier>().profileUiChangeModel[widget.id]
                    .profileLikeListId.length<2){
                  print('=====================喜欢列表删完了');
                  fllowState = StateResult.RESULTNULL;
                }
                setState(() {
                });
                if(context.read<FeedMapNotifier>().feedMap.containsKey(feedId)){
                  context.read<FeedMapNotifier>().deleteFeed(feedId);
                }
              },
            );
          }
        });
    var noDataUi = Container(
        padding: EdgeInsets.only(top: 12),
        color: AppColor.white,
        child: Column(
          children: [
            Center(
              child: Container(
                width: 224,
                height: 224,
                color: AppColor.bgWhite.withOpacity(0.65),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                widget.type == 3 ? "ta还没有发布动态" :widget.type==2?"发布你的第一条动态吧~": "你还没有喜欢的内容~去逛逛吧",
                style: AppStyle.textPrimary3Regular14,
              ),
            )
          ],
        ));
    switch (fllowState) {
      case StateResult.RESULTNULL:
        return noDataUi;
        break;
      case StateResult.HAVERESULT:
        return list;
        break;
    }
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
