
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';


class LiveRoomTestPage extends StatefulWidget {
  final int liveCourseId;
  final String coachId;

  const LiveRoomTestPage({
    Key key,
    @required this.liveCourseId,
    @required this.coachId,}) : super(key: key);


  @override
  _LiveRoomTestPageState createState() => _LiveRoomTestPageState(liveCourseId,coachId);
}

class _LiveRoomTestPageState extends XCState {


  _LiveRoomTestPageState(this.liveCourseId, this.coachId);

  final int liveCourseId;
  final String coachId;


  String url = "rtmp://58.200.131.2:1935/livetv/cctv13";
  final FijkPlayer player = FijkPlayer();
  LoadingStatus loadingStatus=LoadingStatus.STATUS_LOADING;

  @override
  void initState() {
    super.initState();
    //加入聊天室
    Application.rongCloud.joinChatRoom(coachId);
    // player.setDataSource(url, autoPlay: true);
    EventBus.getDefault().register(exit,"LiveRoomTestPage",registerName: "LiveRoomTestPage-exit");
    loadingStatus=LoadingStatus.STATUS_LOADING;
    getLiveVideoUrl();
  }

  //退出界面
  void exit(name){
    Future.delayed(Duration(milliseconds: 100),(){
      EventBus.getDefault().unRegister(pageName:"LiveRoomTestPage",registerName: "LiveRoomTestPage-exit");
      //退出聊天室
      Application.rongCloud.quitChatRoom(coachId);
      player.release();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        child: Stack(
          children: [
            judgeShowUi(),
            getOccludeUi(),
          ],
        ),
      ),
    );
  }


  Widget judgeShowUi(){
    if(loadingStatus==LoadingStatus.STATUS_LOADING){
      return getLoading();
    }else if(loadingStatus==LoadingStatus.STATUS_IDEL){
      return getErrorUi();
    }else{
      return getShowVideoUi();
    }
  }

  Widget getLoading(){
    return Container(
      color:AppColor.textPrimary1,
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Center(
        child: Container(
          height: 24.0,
          width: 24.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
  Widget getErrorUi(){
    return Container(
      color:AppColor.textPrimary1,
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Center(
        child: Text("直播加载失败！！！",style: TextStyle(color: AppColor.white,fontSize: 18)),
      ),
    );
  }

  //展示直播的ui
  Widget getShowVideoUi(){
    return Container(
      color:AppColor.textPrimary1,
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: ScreenUtil.instance.width,
                height: ScreenUtil.instance.height,
                child: FijkView(
                  player: player,
                  color: AppColor.bgBlack,
                  fit: FijkFit.cover,
                  fsFit: FijkFit.cover,
                  cover: AssetImage("images/test/bg.png"),
                ),
              )
            ],
          )
      ),
    );
  }



  //遮挡
  Widget getOccludeUi(){
    return Container(
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.35),
                  AppColor.textPrimary1.withOpacity(0.001),
                ],
              ),
            ),
          ),
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.001),
                  AppColor.textPrimary1.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  //获取聊天室的直播地址
  void getLiveVideoUrl()async{
    Map<String, dynamic> map = await getPullStreamUrl(liveCourseId);
    if(map["code"]==200){
        if(map["data"]!=null&&map["data"]["url"]!=null){
          print("直播地址：${map["data"].toString()}");
          url=map["data"]["url"];
          print("直播地址url：$url");
          player.setDataSource(url, autoPlay: true);
          loadingStatus=LoadingStatus.STATUS_COMPLETED;
        }else{
          ToastShow.show(msg: "暂无该场直播!", context: context);
          loadingStatus=LoadingStatus.STATUS_IDEL;
        }
    }else{
      ToastShow.show(msg: "直播地址获取失败!", context: context);
      loadingStatus=LoadingStatus.STATUS_IDEL;
    }
    if(mounted){
      reload(() {});
    }
  }
}
