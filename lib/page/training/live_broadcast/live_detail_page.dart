import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/live_broadcast/live_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/comment_input_bottom_bar.dart';
import 'live_broadcast_page.dart';
import 'sliver_custom_header_delegate.dart';
import 'package:provider/provider.dart';

/// 直播详情页
class LiveDetailPage extends StatefulWidget {
  const LiveDetailPage(
      {Key key, this.heroTag, this.liveCourseId, this.courseId})
      : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final int courseId;

  @override
  createState() {
    return LiveDetailPageState(
        heroTag: heroTag, liveCourseId: liveCourseId, courseId: courseId);
  }
}

class LiveDetailPageState extends State<LiveDetailPage> {
  LiveDetailPageState(
      {Key key, this.heroTag, this.liveCourseId, this.courseId});

  //头部hero的标签
  String heroTag;

  //直播课程的id
  int liveCourseId;

  //直播课程的大课程的id
  int courseId;

  //当前直播的model
  LiveModel liveModel;

  //加载状态
  LoadingStatus loadingStatus;

  //加载状态--子评论
  var commentLoadingStatusList=<LoadingStatus>[];

  //title文字的样式
  var titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColor.textPrimary1);

  //用户的评论热度
  CommentModel courseCommentHot;

  //评论
  CommentModel courseCommentTime;

  //回复第二级别人的评论时-别人的id
  int replyId = -1;

  //回复第二级别人时 别人评论的id
  int replyCommentId = -1;

  //发布评论时的targetId
  int targetId;
  //发布评论时的targetType
  int targetType;

  //判断是热度还是评论
  bool isHotOrTime = true;

  //用户评论的的一些动画参数
  var commentListSubSettingList = <CommentListSubSetting>[];

  //折叠动画的时间
  var animationTime = 500; //毫秒

  //是否可以回弹
  bool isBouncingScrollPhysics=false;
  //每次请求的评论个数
  int courseCommentPageSize=3;
  //热门当前是第几页
  int courseCommentPageHot=1;
  //时间排序当前是第几页
  int courseCommentPageTime=1;
  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    //todo 先这样实现---以后再改为路由
    liveModel = LiveBroadcastPage.liveModel;
    LiveBroadcastPage.liveModel = null;
    courseCommentHot = null;
    courseCommentTime = null;
    if (liveModel == null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
      getDataAction();
      return;
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      getDataAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
    );
  }

  //判断加载什么布局
  Widget _buildSuggestions() {
    var widgetArray = <Widget>[];
    //有数据
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(
        height: 40,
      ));
      widgetArray.add(_getNoCompleteTitle());
      //在加载中
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        widgetArray.add(Expanded(
            child: SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )));
      } else {
        //加载失败
        widgetArray.add(Expanded(
            child: SizedBox(
              child: Center(
                child: GestureDetector(
                  child: Text("加载失败"),
                  onTap: () {
                    loadingStatus = LoadingStatus.STATUS_LOADING;
                    setState(() {});
                    getDataAction();
                  },
                ),
              ),
            )));
      }
      return Container(
        child: Column(children: widgetArray),
      );
    }
  }

  //当没有加载完成或者没有加载成功时的title
  Widget _getNoCompleteTitle() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "直播课程详情页",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColor.textPrimary1,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  //加载数据成功时的布局
  Widget _buildSuggestionsComplete() {
    return Container(
      color: AppColor.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height-50,
            child: ScrollConfiguration(
              behavior: NoBlueEffectBehavior(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  ScrollMetrics metrics = notification.metrics;
                  if (metrics.pixels < 10) {
                    if(isBouncingScrollPhysics) {
                      isBouncingScrollPhysics = false;
                      setState(() {

                      });
                    }
                  } else {
                    if(!isBouncingScrollPhysics) {
                      isBouncingScrollPhysics = true;
                      setState(() {

                      });
                    }
                  }
                  return false;
                },
                child:SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("");
                      } else if (mode == LoadStatus.loading) {
                        body = CircularProgressIndicator();
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
                  onLoading: _onLoading,
                  child: CustomScrollView(
                    physics: isBouncingScrollPhysics?BouncingScrollPhysics():ClampingScrollPhysics(),
                    slivers: <Widget>[
                      // header,

                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverCustomHeaderDelegate(
                          title: liveModel.name,
                          collapsedHeight: 40,
                          expandedHeight: 300,
                          paddingTop: MediaQuery
                              .of(context)
                              .padding
                              .top,
                          coverImgUrl: 'images/test/bg.png',
                          heroTag: heroTag,
                          startTime: liveModel.startTime,
                          endTime: liveModel.endTime,
                        ),
                      ),
                      _getTitleWidget(),
                      _getCoachItem(),
                      _getLineView(),
                      _getActionUi(),
                      _getLineView(),
                      _getCourseCommentUi(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: AppColor.white,
            child:_getBottomBar(),
          ),
        ],
      ),
    );
  }


  //获取训练数据ui
  Widget _getTitleWidget() {
    var widgetArray = <Widget>[];
    var titleArray=[liveModel.totalTrainingTime.toString(),liveModel.totalCalories.toString(),liveModel.coursewareDto?.levelDto?.ename];
    var subTitleArray=["分钟","千卡",liveModel.coursewareDto?.levelDto?.name];
    var tagArray=["时间","消耗","难度"];

    for(int i=0;i<titleArray.length;i++){
      widgetArray.add(
          Container(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Text(titleArray[i],
                        style: TextStyle(fontSize: 23,color: AppColor.black,fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 2,),
                      Container(
                        child: Text(subTitleArray[i], style:  TextStyle(fontSize: 12,color: AppColor.textPrimary3),),
                        margin: const EdgeInsets.only(top: 4),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 6,),
                Text(tagArray[i], style:  TextStyle(fontSize: 12,color: AppColor.textHint),),
              ],
            ),
            width: (MediaQuery.of(context).size.width-1)/3,
          )
      );
      if(i<titleArray.length-1){
        widgetArray.add(
            Container(
              width: 0.5,
              height: 18,
              color: AppColor.textHint,
            )
        );
      }
    }
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        color: AppColor.white,
        padding: const EdgeInsets.only(top: 14,bottom: 14),
        child: Row(
          children: widgetArray,
        ),
      ),
    );
  }

  //获取教练的名字
  Widget _getCoachItem() {
    return SliverToBoxAdapter(
      child: Container(
        padding:
        const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
        color: Colors.white,
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                // border: Border.all(width: 0.0, color: Colors.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "images/test/yxlm1.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Container(
              child: Column(
                children: [
                  Text(
                    // ignore: null_aware_before_operator
                    liveModel.coachDto?.nickName,
                    style:const TextStyle(fontSize: 14,color: AppColor.textPrimary2,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            Container(
              padding:
              const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color:AppColor.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text("关注",style: TextStyle(color: AppColor.white,fontSize: 11),),
            )
          ],
        ),
      ),
    );
  }

  //获取横线
  Widget _getLineView() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 12,
        color: AppColor.bgWhite_65,
      ),
    );
  }

  //获取动作的ui
  Widget _getActionUi() {
    if(liveModel.movementDtos==null||liveModel.movementDtos.length<1){
      return SliverToBoxAdapter();
    }
    var widgetArray = <Widget>[];
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 11.5),
      width: double.infinity,
      child: Text(
        "动作${liveModel.movementDtos.length}个",
        style: titleTextStyle,
      ),
    ));

    for(int i=0;i<liveModel.movementDtos.length;i++){

      widgetArray.add(Container(
        width: double.infinity,
        height: 0.5,
        margin: const EdgeInsets.only(left: 16, right: 16),
        color: AppColor.bgWhite,
      ));

      widgetArray.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 16, right: 16),
          padding: const EdgeInsets.only(top: 13.5, bottom: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                liveModel.movementDtos[i].name,
                style: TextStyle(fontSize: 16,color: AppColor.textPrimary2),
              ),
              Text(
                liveModel.movementDtos[i].amount.toString()+liveModel.movementDtos[i].unit.toString(),
                style: TextStyle(fontSize: 14,color: AppColor.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgetArray,
        ),
      ),
    );
  }

  //课程评论的框架--头部的数据
  Widget _getCourseCommentUi() {
    List<Widget> widgetArray = <Widget>[];
    //评论头部title
    widgetArray.add(Container(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 10),
      width: double.infinity,
      child: Text(
        "课程评论",
        style: titleTextStyle,
      ),
    ));
    //评论数量等等
    widgetArray.add(Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16.5, right: 16, top: 8),
      child: Row(
        children: [
          Text(
            "${isHotOrTime ? (courseCommentHot?.totalCount) : (courseCommentTime
                ?.totalCount)}评论",
            style: TextStyle(fontSize: 16,color: AppColor.textPrimary1),
          ),
          Expanded(child: SizedBox()),
          InkWell(
            child: Text(
              "按热度",
              style: TextStyle(
                fontSize: 14,
                color: isHotOrTime?AppColor.textPrimary1:AppColor.textSecondary,
                fontWeight: isHotOrTime?FontWeight.bold:FontWeight.normal,
              ),
            ),
            splashColor: AppColor.textHint1,
            onTap: () {
              if(!isHotOrTime) {
                _refreshController.loadComplete();
                isHotOrTime = !isHotOrTime;
                getDataAction();
              }
            },
          ),
          SizedBox(width: 7,),
          Container(
            width: 0.5,
            height: 15.5,
            color: AppColor.textHint1,
          ),
          SizedBox(width: 7,),
          InkWell(
            child: Text(
              "按时间",
              style: TextStyle(
                fontSize: 14,
                color: !isHotOrTime?AppColor.textPrimary1:AppColor.textSecondary,
                fontWeight: !isHotOrTime?FontWeight.bold:FontWeight.normal,
              ),
            ),
            splashColor: AppColor.textHint1,
            onTap: () {
              if(isHotOrTime) {
                _refreshController.loadComplete();
                isHotOrTime = !isHotOrTime;
                getDataAction();
              }
            },
          ),

        ],
      ),
    ),);
    widgetArray.add(SizedBox(height: 12,));
    //点击写评论
    widgetArray.add(Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 20),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage("images/test/yxlm1.jpeg"),
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
              child: Text("说点什么吧~",
                  style: TextStyle(
                      fontSize: 14, color: AppColor.textHint)),
            ),
            onTap: () {
              targetId=liveModel.courseId;
              targetType=1;
              replyId = -1;
              replyCommentId = -1;

              openInputBottomSheet(
                context: this.context,
                voidCallback: (String context) {
                  _publishComment(context,-1);
                  print("发表评论----" + context);
                },
              );
            },
          ),
        ],
      ),
    ));
    //评论主体
    widgetArray.add(_getCommentItemUi());

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        child: Column(
          children: widgetArray,
        ),
      ),
    );
  }

  //评论列表的外层的评论
  Widget _getCommentItemUi() {
    var widgetArray = <Widget>[];

    widgetArray.add(SizedBox(height: 23,));
    if ((isHotOrTime ? (courseCommentHot) : (courseCommentTime)) == null) {
      widgetArray.add(Container(
        child: Column(
          children: [
            Image.asset("images/test/bg.png",fit: BoxFit.cover,width: 224,height: 224,),
            SizedBox(height: 16,),
            Text("偷偷逆袭中，还没有人来冒泡呢",style: TextStyle(fontSize: 14,color: AppColor.textSecondary),)
          ],
        ),
      ));
    } else {
      for (int i = 0; i <
          (isHotOrTime ? (courseCommentHot) : (courseCommentTime))?.list
              ?.length; i++) {
        CommentDtoModel value = (isHotOrTime
            ? (courseCommentHot)
            : (courseCommentTime)).list[i];

        var subCommentComplete=
            // ignore: null_aware_before_operator
            (value.replys?.length<value.replyCount ? "查看" : (commentListSubSettingList[i].isFold?"查看":"隐藏")) +
            // ignore: null_aware_before_operator
            "${value.replys?.length>=value.replyCount?value.replys?.length:(value.replyCount-value.replys?.length)}条回复";

        var subCommentLoading="正在加载。。。";


        widgetArray.add(Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              _getCommentUi(value, false,value.id),
              SizedBox(height: 13,),
              Offstage(
                offstage: value.replyCount < 1,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: GestureDetector(
                          child: Row(
                            children: [
                              SizedBox(width: 57,),
                              Container(
                                width: 40,
                                height: 0.5,
                                color: AppColor.textSecondary,
                              ),
                              SizedBox(width: 4,),
                              Container(
                                child: Text(commentLoadingStatusList[i]==LoadingStatus.STATUS_COMPLETED?subCommentComplete:subCommentLoading,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // ignore: null_aware_before_operator
                            if(value.replys?.length>=value.replyCount){
                              if(commentListSubSettingList[i].subCommentAllHeight==null){
                                commentListSubSettingList[i].subCommentAllHeight= commentListSubSettingList[i].globalKey.currentContext.size.height;
                                setState(() {

                                });
                                Future.delayed(Duration(milliseconds: 100), () {
                                  commentListSubSettingList[i].isFold = !commentListSubSettingList[i].isFold;
                                  setState(() {});
                                });
                              }else{
                                commentListSubSettingList[i].isFold = !commentListSubSettingList[i].isFold;
                                setState(() {});
                              }
                            }else{
                              commentLoadingStatusList[i]=LoadingStatus.STATUS_LOADING;
                              setState(() {

                              });
                              _getSubComment(value.id, value.replys?.length, value.replyCount,i);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 13,),
                      _getSubCommentItemUi(value, i),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    }


    return Container(
      width: double.infinity,
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //sub 子品评论
  Widget _getSubCommentItemUi(CommentDtoModel value, int index) {
    var widgetArray = <Widget>[];
    if (value.replys != null && value.replys.length > 0) {
      for (int i = 0; i < value.replys.length; i++) {
        widgetArray.add(_getCommentUi(value.replys[i], true,value.id));
        widgetArray.add(SizedBox(height: 13,));
      }
    }

    Widget widget=Container(
      key: commentListSubSettingList[index].globalKey,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 55),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: widgetArray,
        ),
      ),
    );
    if(commentListSubSettingList[index].subCommentAllHeight==null||commentListSubSettingList[index].subCommentAllHeight<0) {
      return Offstage(
        offstage: commentListSubSettingList[index].isFold,
        child: widget,
      );
    }else{
      return AnimatedContainer(
        height: commentListSubSettingList[index].isFold?0.0:commentListSubSettingList[index].subCommentAllHeight,
        duration: Duration(milliseconds: animationTime),
        child: widget,
      );
    }
  }

  //获取评论的item--每一个item
  Widget _getCommentUi(CommentDtoModel value, bool isSubComment,int _targetId) {
    var textSpanList=<TextSpan>[];
    textSpanList.add(TextSpan(
      text: value.name+" ",
      style: TextStyle(
        fontSize: 15,
        color: AppColor.textPrimary1,
        fontWeight: FontWeight.bold,
      ),
    ));
    if(isSubComment){
      if(value.replyId!=null&&value.replyId>0){
        textSpanList.add(TextSpan(
          text: "回复 ",
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textPrimary1,
          ),
        ));

        textSpanList.add(TextSpan(
          text: value.replyName+" ",
          style: TextStyle(
            fontSize: 15,
            color: AppColor.textPrimary1,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }
    textSpanList.add(TextSpan(
      text: value.content,
      style: TextStyle(
        fontSize: 14,
        color: AppColor.textPrimary1,
      ),
    ));

    return GestureDetector(
      child: IntrinsicHeight(
        child: Row(
          verticalDirection: VerticalDirection.up,
          children: [
            //头像
            Container(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "images/test/bg.png",
                      fit: BoxFit.cover,
                      width: 42,
                      height: 42,
                    ),
                  )
                ],
              ),
            ),
            //间隔
            SizedBox(
              width: 15,
            ),
            // //中间信息
            Expanded(
                child: SizedBox(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: RichText(
                          text: TextSpan(
                            children: textSpanList,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Container(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                DateUtil.formatDateNoYearString(DateUtil.getDateTimeByMs(value.createTime)),
                                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                              ),
                            ),
                            SizedBox(width: 12,),
                            InkWell(
                              child: Container(
                                child: Text("回复",
                                  style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                                ),
                              ),
                              onTap: (){
                                targetId=_targetId;
                                targetType=2;
                                if(isSubComment){
                                  replyId = value.uid;
                                  replyCommentId = value.id;
                                }else{
                                  replyId = -1;
                                  replyCommentId = -1;
                                }
                                openInputBottomSheet(
                                  context: this.context,
                                  voidCallback: (String context) {
                                    _publishComment(context,_targetId);
                                    print("回复评论----" + context);
                                  },
                                );
                              },
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                )),
            SizedBox(width: 16,),
            //点赞
            Container(
              child: GestureDetector(
                child: Column(
                  children: [
                    Icon(
                      value.isLaud==1?Icons.favorite:Icons.favorite_border,
                      color: value.isLaud == 1 ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                    SizedBox(height: 7,),
                    Text(
                      value.laudCount.toString(),
                      style: TextStyle(fontSize: 12,color: AppColor.textSecondary),
                    ),
                  ],
                ),
                onTap: () {
                  if (value.isLaud == 1) {
                    return;
                  }
                  value.isLaud = 1;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
      onLongPress: (){
        ToastShow.show(msg: "长按", context: context);

        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('删除评论'),
                content: Text('是否删除评论'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('不删除'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text('删除'),
                    onPressed: () {
                      _deleteComment(value.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  //获取底部按钮
  Widget _getBottomBar() {
    Widget containerWidget;
    bool isLoggedIn;
    context.select((TokenNotifier notifier) => notifier.isLoggedIn ? isLoggedIn=true : isLoggedIn=false);

    //todo 判断是否绑定了终端
    bool bindingTerminal=false;
    //todo 判断用户是不是vip
    bool isVip=false;
    //todo 判断这个课程是不是vip直播
    bool courseVip=false;

    TextStyle textStyle= const TextStyle(color: AppColor.white,fontSize: 16);
    TextStyle textStyleVip= const TextStyle(color: AppColor.textVipPrimary1,fontSize: 16);
    EdgeInsetsGeometry margin_32=const EdgeInsets.only(left: 32,right: 32);
    EdgeInsetsGeometry margin_left_32_right_16=const EdgeInsets.only(left: 32,right: 16);
    EdgeInsetsGeometry margin_left_26_right_20=const EdgeInsets.only(left: 26,right: 20);
    EdgeInsetsGeometry margin_right_32=const EdgeInsets.only(right: 32);
    EdgeInsetsGeometry margin_right_16=const EdgeInsets.only(right: 16);


    Widget widget3=Container(
      width: 60,
      height: double.infinity,
      margin: margin_left_26_right_20,
      child: Column(
        children: [
          Icon(Icons.headset),
          Text((liveModel.playType==3?liveModel.getGetPlayType():"试听")),
        ],
      ),
    );
    Widget widget4=getBtnUi(false,"回放",textStyle,94,40,margin_left_32_right_16);
    Widget widget5=getBtnUi(true,"开通vip使用终端播放",textStyleVip,double.infinity,40,(liveModel.getGetPlayType()=="回放"?margin_right_32:margin_right_16));
    Widget widget2=getBtnUi(false,"登陆终端使用终端播放",textStyle,double.infinity,40,(liveModel.getGetPlayType()=="回放"?margin_right_32:margin_right_16));
    Widget widget1=getBtnUi(false,"使用终端训练",textStyle,double.infinity,40,(liveModel.getGetPlayType()=="回放"?margin_right_32:margin_right_16));
    Widget widget6=getBtnUi(false,liveModel.getGetPlayType(),textStyle,double.infinity,40,margin_32);

    var childrenArray=<Widget>[];

    if(!isLoggedIn){
      print("没有登陆");
      childrenArray.add(widget6);
      containerWidget=GestureDetector(
        child: Container(
          width: double.infinity,
          child: Row(
            children: childrenArray,
          ),
        ),
        onTap: (){
          ToastShow.show(msg: "去登陆", context: context);
          // 去登录
          AppRouter.navigateToLoginPage(context);
        },
      );
    }else{
      print("登陆了");
      //todo 取绑定了终端没有

      if (liveModel.playType == 3) {
        childrenArray.add(
          GestureDetector(
            child: widget4,
            onTap: (){
              print("回放");
              ToastShow.show(msg: liveModel.getGetPlayType(), context: context);
            },
          ),
        );
      } else {
        childrenArray.add(
            GestureDetector(
              child: widget3,
              onTap: (){
                print("试听");
                ToastShow.show(msg: liveModel.getGetPlayType(), context: context);
              },
            )
        );
      }

      if(!courseVip||isVip) {
        if (bindingTerminal) {
          childrenArray.add(
            Expanded(child: SizedBox(
              child: GestureDetector(
                child: widget1,
                onTap: (){
                  print("绑定了终端");
                  ToastShow.show(msg: "使用终端训练", context: context);
                },
              ),
            ))
          );
        } else {
          childrenArray.add(
            Expanded(child: SizedBox(
                child: GestureDetector(
                child: widget2,
                onTap: (){
                  print("没有绑定终端");
                  ToastShow.show(msg: "登陆终端使用终端播放", context: context);
                },
              )
            ))
          );
        }
      }else{
        childrenArray.add(
          Expanded(child: SizedBox(
              child: GestureDetector(
              child: widget5,
              onTap: (){
                print("vip课程");
                ToastShow.show(msg: "开通vip使用终端播放", context: context);
              },
            )
          ))
        );
      }

      containerWidget = Container(
        width: double.infinity,
        child: Row(
          children: childrenArray,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: containerWidget,
    );
  }


  Widget getBtnUi(bool isVip,String text,TextStyle textStyle,double width1,double height1,EdgeInsetsGeometry marginData){
    var colors=<Color>[];
    if(isVip){
      colors.add(AppColor.bgVip1);
      colors.add(AppColor.bgVip2);
    }else{
      colors.add(AppColor.textPrimary1);
      colors.add(AppColor.textPrimary1);
    }
    return Container(
      width: width1,
      height: height1,
      margin: marginData,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height1 / 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(text, style: textStyle,),
      ),
    );
  }


  //加载网络数据
  void getDataAction() async {
    //获取评论
    if (isHotOrTime) {
      //todo 加载评论-*--没有分页加载只有第一页的
      if (courseCommentHot == null) {
        Map<String, dynamic> commentModel = await queryListByHot(
            targetId: courseId, targetType: 1, page: courseCommentPageHot, size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentHot = CommentModel.fromJson(commentModel);
          courseCommentPageHot++;
        }
      }
      setCommentListSubSetting(courseCommentHot);
    } else {
      if (courseCommentTime == null) {
        Map<String, dynamic> commentModel = await queryListByTime(
            targetId: courseId, targetType: 1, page: courseCommentPageTime, size: courseCommentPageSize);
        if (commentModel != null) {
          courseCommentTime = CommentModel.fromJson(commentModel);
          courseCommentPageTime++;
        }
      }
      setCommentListSubSetting(courseCommentTime);
    }

    //获取直播详情数据
    if (liveModel == null||liveModel.movementDtos==null) {
      //加载数据
      Map<String, dynamic> model = await liveCourseDetail(
          courseId: liveCourseId);
      if (model == null) {
        loadingStatus = LoadingStatus.STATUS_IDEL;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
      } else {
        liveModel = LiveModel.fromJson(model);
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
        setState(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    }
  }

  //设置评论的动画类
  void setCommentListSubSetting(CommentModel commentModel) {
    commentListSubSettingList.clear();
    commentLoadingStatusList.clear();
    if (commentModel == null) {
      return;
    }
    for (int i = 0; i < commentModel?.list?.length; i++) {
      CommentListSubSetting commentListSubSetting = new CommentListSubSetting();
      commentListSubSetting.commentId = commentModel.list[i].id;
      commentListSubSetting.isFold = false;
      commentListSubSettingList.add(commentListSubSetting);
      GlobalKey _globalKey = GlobalKey();
      commentListSubSetting.globalKey=_globalKey;


      //每一个加载评论的加载子评论的状态
      LoadingStatus commentLoadingStatus=LoadingStatus.STATUS_COMPLETED;
      commentLoadingStatusList.add(commentLoadingStatus);
    }
  }

  //发布评论
  _publishComment(String content,int _targetId) async {
    Map<String, dynamic> model = await publish(targetId: targetId,
        targetType: targetType=2,
        content: content,
        replyId: replyId > 0 ? replyId : null,
        replyCommentId: replyCommentId > 0 ? replyCommentId : null);
    if (model != null) {
      courseCommentHot = null;
      courseCommentTime = null;

      getDataAction();
      ToastShow.show(msg: "发布成功", context: context);
    } else {
      ToastShow.show(msg: "发布失败", context: context);
    }
  }

  //删除评论
  _deleteComment(int commentId) async {
    //todo 回复子评论有问题
    Map<String, dynamic> model = await deleteComment(commentId:commentId);
    print(model);
    if (model != null&&model["state"]==true) {
      courseCommentHot = null;
      courseCommentTime = null;
      getDataAction();
      ToastShow.show(msg: "删除成功", context: context);
    } else {
      ToastShow.show(msg: "删除失败，只能删除自己的评论", context: context);
    }
  }

  //获取子评论
  _getSubComment(int targetId,int replyLength,int replyCount,int positionComment)async{
      int subCommentPageSize=3;
      // int subCommentAllPage=replyCount%subCommentPageSize>0?(replyCount~/subCommentPageSize)+1:(replyCount~/subCommentPageSize);
      int nowSubCommentPage=replyLength%subCommentPageSize>0?(replyLength~/subCommentPageSize)+1:(replyLength~/subCommentPageSize);
      int page=nowSubCommentPage+1;

      try{

        Map<String, dynamic> commentModel = await (isHotOrTime?queryListByHot:queryListByTime)(targetId: targetId, targetType: 2, page: page, size: subCommentPageSize);

        if (commentModel != null) {
          List<CommentDtoModel> commentDtoModelList=<CommentDtoModel>[];
          commentDtoModelList.addAll(CommentModel.fromJson(commentModel).list);

          if((isHotOrTime?courseCommentHot:courseCommentTime).list[positionComment].replys!=null){
            commentDtoModelList.addAll((isHotOrTime?courseCommentHot:courseCommentTime).list[positionComment].replys);
          }
          (isHotOrTime?courseCommentHot:courseCommentTime).list[positionComment].replys=commentDtoModelList;
        }
      }catch(e){

      }

      commentLoadingStatusList[positionComment]=LoadingStatus.STATUS_COMPLETED;
      setState(() {

      });
  }

  //加载更多的评论
  void _onLoading() async {
    Future.delayed(Duration(milliseconds: 500), () async{
      Map<String, dynamic> mapModel = await (isHotOrTime?queryListByHot:queryListByTime)(targetId: courseId, targetType: 1, page: (isHotOrTime?courseCommentPageHot:courseCommentPageTime), size: courseCommentPageSize);
      if (mapModel != null) {
        CommentModel commentModel=CommentModel.fromJson(mapModel);
        if(commentModel==null||commentModel.list==null||commentModel.list.length<1){
          _refreshController.loadNoData();
        }else {
          (isHotOrTime ? courseCommentHot : courseCommentTime).list.addAll(
              commentModel.list);
          setCommentListSubSetting(
              (isHotOrTime ? courseCommentHot : courseCommentTime));
          isHotOrTime ? courseCommentPageHot++ : courseCommentPageTime++;
          _refreshController.loadComplete();
        }
      }else{
        _refreshController.loadNoData();
      }
      setState(() {});
    });
  }

}

class CommentListSubSetting {
  int commentId;
  bool isFold;
  double subCommentAllHeight;
  GlobalKey globalKey;
}
