import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class OtherCompleteCoursePage extends StatefulWidget {
  final int targetId;

  OtherCompleteCoursePage({this.targetId});

  @override
  _OtherCompleteCoursePageState createState() => _OtherCompleteCoursePageState();
}

class _OtherCompleteCoursePageState extends State<OtherCompleteCoursePage> {
  //数据
  List<HomeFeedModel> recommendTopicList = [];
  int lastTime;
  int pageSize=0;

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  // 数据加载页数
  int dataPage = 1;

// 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_LOADING;
  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadStatus = LoadingStatus.STATUS_LOADING;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "TA们刚刚完成训练",
      ),
      body: Container(
        color: AppColor.bgWhite,
        child: _buildSuggestions(),
      ),
    );
  }

  Widget _buildSuggestions() {
    if(recommendTopicList!=null&&recommendTopicList.length>0) {
      print("recommendTopicList.length:${recommendTopicList.length}");
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: getRefreshIndicator(),
      );
    }else{
      return getNoDateUi();
    }
  }


  Widget getNoDateUi(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 224,
            height: 224,
            color: AppColor.color246,
            margin: EdgeInsets.only(bottom: 16, top: 188),
          ),
          Text(
            "这里空空如也，去推荐看看吧",
            style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }

  //有数据的ui
  Widget getRefreshIndicator(){
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(
        complete: Text("刷新完成"),
        failed: Text(" "),
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("");
          } else if (mode == LoadStatus.loading) {
            body = Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            );
          } else if (mode == LoadStatus.failed) {
            body = Text("");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("");
          } else {
            body = Text("");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onLoading: _loadData,
      onRefresh: _onRefresh,
      child: listView(),
    );
  }

  //获取listview
  Widget listView(){
    return StaggeredGridView.countBuilder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: recommendTopicList.length,
      primary: false,
      crossAxisCount: 4,
      // 上下间隔
      mainAxisSpacing: 8.0,
      // 左右间隔
      crossAxisSpacing: 8.0,
      controller: _scrollController,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Hero(
            tag: "complex${recommendTopicList[index].id}",
            child:item(recommendTopicList[index],index,recommendTopicList.length),
          ),
          onTap: (){
            HomeFeedModel feedModel = recommendTopicList[index];
            List<HomeFeedModel> list = [];
            list.add(feedModel);
            context.read<FeedMapNotifier>().updateFeedMap(list);
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => FeedDetailPage(model: feedModel,type: 1,)),
            );
          },
        );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    );
  }

  Widget item(HomeFeedModel homeFeedModel,int index,int length){
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Visibility(
            visible: index==0||index==1,
            child: SizedBox(height: 16),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(3),topRight: Radius.circular(3)),
            child: Container(
              width: double.infinity,
              child: getImage(homeFeedModel,index),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColor.white,
            padding: const EdgeInsets.only(left: 8,right: 8,top: 6),
            child: Text(
              homeFeedModel.content,
              style: TextStyle(fontSize: 13,color: AppColor.textPrimary1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3),bottomRight: Radius.circular(3)),
            child: getHorUserItem(homeFeedModel,index),
          ),

          Visibility(
            visible: index==length-1||index==length-2,
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  //横向的用户资料
  Widget getHorUserItem(HomeFeedModel homeFeedModel,int index){
    return Container(
      width: double.infinity,
      color: AppColor.white,
      padding: const EdgeInsets.only(left: 8,right: 8,top: 6,bottom: 8),
      child: Stack(
        children: [
          Row(
            children: [
              getUserImage(homeFeedModel.avatarUrl,16,16),
              SizedBox(width: 4),
              Expanded(child: SizedBox(child: Text(homeFeedModel.name,maxLines: 1,overflow: TextOverflow.ellipsis,),)),
              Icon(
                  homeFeedModel.isLaud==1?Icons.favorite_rounded:Icons.favorite_outline_sharp,
                  size: 12,
                  color: homeFeedModel.isLaud==1?AppColor.mainRed:AppColor.textSecondary
              ),
              SizedBox(width: 5),
              Text(IntegerUtil.formatIntegerEn(homeFeedModel.laudCount),
                style: TextStyle(color: AppColor.textSecondary,fontSize: 12),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: SizedBox(
                child: GestureDetector(
                  child: Container(
                    height: 20,
                    color: Colors.transparent,
                  ),
                  onTap: (){
                    print("点击了用户名字");
                  },
                ),
              )),
              GestureDetector(
                child: Container(
                  height: 20,
                  width: 50,
                  color: Colors.transparent,
                ),
                onTap: (){
                  print("点赞");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //获取图片
  Widget getImage(HomeFeedModel homeFeedModel,int index){
    String url="";
    int width=1024;
    int height=1024;
    bool isImageOrVideo=true;
    if(homeFeedModel.picUrls!=null&&homeFeedModel.picUrls.length>0){
      url=homeFeedModel.picUrls[0].url;
      width=homeFeedModel.picUrls[0].width;
      height=homeFeedModel.picUrls[0].height;
      isImageOrVideo=true;
    }else if(homeFeedModel.videos!=null&&homeFeedModel.videos.length>0){
      url=FileUtil.getVideoFirstPhoto(homeFeedModel.videos[0].url);
      width=homeFeedModel.videos[0].width;
      height=homeFeedModel.videos[0].height;
      isImageOrVideo=false;
    }

    return Container(
      color: Colors.amber,
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            //圆角图片
            borderRadius: BorderRadius.circular(2),
            child: CachedNetworkImage(
              height: setAspectRatio(height.toDouble(),width.toDouble(),index),
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => new Container(
                  child: new Center(
                    child: new CircularProgressIndicator(),
                  )),
              imageUrl: url,
              errorWidget: (context, url, error) => new Image.asset("images/test.png"),
            ),
          ),
          Positioned(
            child: Visibility(
              visible: !isImageOrVideo,
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 18,
                color: AppColor.white,
              ),
            ),
            right: 10,
            top: 8,
          ),
        ],
      ),
    );
  }

  //刷新
  void _onRefresh(){
    lastTime=null;
    pageSize=0;
    recommendTopicList.clear();
    _loadData();
  }

  //加载数据
  void _loadData() async{
    if(pageSize>0&&lastTime==null){
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      return;
    }
    DataResponseModel model=await getPullList(type: 7,size: 20,targetId: widget.targetId,lastTime: lastTime);
    if (model!=null&&model.list!=null&&model.list.length>0) {
      model.list.forEach((v) {
        recommendTopicList.add(HomeFeedModel.fromJson(v));
      });
      lastTime=model.lastTime;
      pageSize++;
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    if(mounted){
      setState(() {});
    }
  }

  // 宽高比例高度
  double setAspectRatio(double height, double width,int index) {
    if (index == 0) {
      return (((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) / width) * height - 20;
    }
    return (((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) / width) * height;
  }
}
