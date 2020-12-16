import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/post_feed/post_feed.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:provider/provider.dart';

enum Status {
  notLoggedIn, //未登录
  loggedIn, // 登录
  noConcern, //无关注
  concern // 关注
}

enum PostStatus {
  publishing, //正在发布
  complete, // 发布完成
  fail, //发布失败
}

// 关注
class AttentionPage extends StatefulWidget {
  AttentionPage({Key key, this.coverUrls, this.pc}) : super(key: key);
  List<CourseModel> coverUrls = [];
  PanelController pc = new PanelController();

  AttentionPageState createState() => AttentionPageState();
}

class AttentionPageState extends State<AttentionPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  var status = Status.notLoggedIn;

  // 发布动态需要的数据
  PostFeedModel postFeedModel;

  // 发布进度
  double _process = 0.0;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;

  // 数据源
  List<HomeFeedModel> attentionModel = [];

  // 请求下一页
  int lastTime;

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 是否登录
  bool isLoggedIn = false;
  bool isPublishing = false;
  // 是否请求接口
  bool isRequestInterface = false;

  double _nowPercent = 0;
  @override
  void initState() {
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否登录$isLoggedIn");
    if (!isLoggedIn) {
      status = Status.notLoggedIn;
    } else {
      status = Status.loggedIn;
      postFeedModel = Application.postFeedModel;
      Application.postFeedModel = null;
    }
    // 上拉加载
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        dataPage += 1;
        getRecommendFeed();
      }
    });
    super.initState();
  }

  // 发布动态
  pulishFeed() async {
    List<File> fileList = [];
    UploadResults results;
    List<PicUrlsModel> picUrls = [];
    List<VideosModel> videos = [];
    context.watch<PublishMonitorNotifier>().getPublishing(true);
    print('===========================================这是发布页入口的Publishing${context.watch<PublishMonitorNotifier>().isPublishing}');
    if (postFeedModel != null) {
      // 正在发布
      context.watch<PublishMonitorNotifier>().getPostStatus(PostStatus.publishing);
      print("掉发布数据");
      // 上传图片
      if (postFeedModel.selectedMediaFiles.type == mediaTypeKeyImage) {
        // 获取当前时间
        String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
        int i = 0;
        //
        postFeedModel.selectedMediaFiles.list.forEach((element) async {
          if (element.croppedImageData == null) {
            fileList.add(element.file);
          } else {
            i++;
            print("%%%%%%%%%%i=$i%%%%%%%%%%%");
            File imageFile = await FileUtil().writeImageDataToFile(element.croppedImageData, timeStr + i.toString());
            fileList.add(imageFile);
          }
          picUrls.add(PicUrlsModel(width: element.sizeInfo.width, height: element.sizeInfo.height));
        });
        results = await FileUtil().uploadPics(fileList, (path, percent) {
                    double imgProgress = 0.8/fileList.length;
                    if(percent<0.95){
                      _nowPercent=0;
                    }
                    if(_process<0.8){
                      if(percent!=_nowPercent){
                        print('------------------------------这是文件上传监听$percent');
                      if(percent==0.95){
                            _process+=imgProgress;
                            _nowPercent = percent;
                            print('----------------------------这是进度条监听$_process');
                        }
                      }
                    }else{
                      return;
                    }
                    context.read<PublishMonitorNotifier>().getPostPlannedSpeed(_process);
        });
        print(results.isSuccess);
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          picUrls[i].url = model.url;
        }
      } else if (postFeedModel.selectedMediaFiles.type == mediaTypeKeyVideo) {
        postFeedModel.selectedMediaFiles.list.forEach((element) {
          fileList.add(element.file);
          videos.add(VideosModel(
              width: element.sizeInfo.width, height: element.sizeInfo.height, duration: element.sizeInfo.duration));
        });
        results = await FileUtil().uploadMedias(fileList, (path, percent) {

        });
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下视频索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          videos[i].url = model.url;
          videos[i].coverUrl = model.url + "?vframe/jpg/offset/1";
        }
      }
      print("数据请求发不打印${postFeedModel.content}");
      Map<String, dynamic> feedModel = await publishFeed(
          type: 0,
          content: postFeedModel.content,
          picUrls: jsonEncode(picUrls),
          videos: jsonEncode(videos),
          // atUsers: jsonEncode(postFeedModel.atUsersModel),
          address: postFeedModel.address,
          latitude: postFeedModel.latitude,
          longitude: postFeedModel.longitude,
          cityCode: postFeedModel.cityCode,
          topicId: postFeedModel.topicId);
      print("发不接受发布结束：feedModel$feedModel");
      if (feedModel != null) {
        _process = 1.0;
        context.read<PublishMonitorNotifier>().getPostPlannedSpeed(_process);
        print('===========++++++++++++++++++++++++++进度条监听$_process');
        // 插入数据
        context.read<PublishMonitorNotifier>().attentionModel.insert(0, HomeFeedModel.fromJson(feedModel));
        // 发布完成
        context.read<PublishMonitorNotifier>().getPostStatus(PostStatus.complete);
        print('================================发布完成');
        context.read<PublishMonitorNotifier>().getPublishing(false);
        context.read<PublishMonitorNotifier>().getRequestInterface(false);
      } else {
        // 发布失败
        print('================================发布失败');
        context.read<PublishMonitorNotifier>().getPublishing(false);
        context.read<PublishMonitorNotifier>().getRequestInterface(false);
        context.read<PublishMonitorNotifier>().getPostStatus(PostStatus.fail);
      }
    }
    postFeedModel = null;
  }

  // 创建发布进度视图
  createdPostPromptView() {
    // 展示文字
    return Container(
      height: 60,
      width: ScreenUtil
        .instance.screenWidthDp - 32,
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                color: AppColor.mainRed,
                margin: EdgeInsets.only(right: 16),
              ),
              Text("正在发布")
            ],
          )),
          LinearProgressIndicator(
            value: _process,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            backgroundColor: AppColor.white,
          ),
        ],
      ),
    );
  }

  // // 推荐页model
// 推荐页model
  getRecommendFeed() async {
    context.watch<PublishMonitorNotifier>().getRequestInterface(true);
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    print("postFeedModel%%%%%%%$postFeedModel");
    if (postFeedModel != null&&!context.watch<PublishMonitorNotifier>().isPublishing) {
      print("postFeedModel优质");
      pulishFeed();
    }
    // else {
    print("开始请求动态数据");
    if (dataPage > 1 && lastTime == null) {
      loadText = "已加载全部动态";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
      print("返回不请求数据");
      return;
    }
    Map<String, dynamic> model = await getPullList(type: 0, size: 20, lastTime: lastTime);
    setState(() {
      print("dataPage:  ￥￥$dataPage");
      // print(model["list"].runtimeType);
      if (dataPage == 1) {
        if (model["list"] is List && (model["list"] as List).isNotEmpty) {
          model["list"].forEach((v) {
            attentionModel.add(HomeFeedModel.fromJson(v));
          });
          attentionModel.insert(0, HomeFeedModel());
          status = Status.concern;
        } else {
          status = Status.noConcern;
        }
      } else if (dataPage > 1 && lastTime != null) {
        print("lastTime&￥$lastTime");
        print("5data");
        if (model["list"] != null) {
          model["list"].forEach((v) {
            attentionModel.add(HomeFeedModel.fromJson(v));
          });
          print("数据长度${attentionModel.length}");
        }
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      } else {
        // 加载完毕
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    });
    lastTime = model["lastTime"];
    print("lastTime:    $lastTime");
    print(status);
  }

  Widget pageDisplay() {
    switch (status) {
      case Status.notLoggedIn:
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                color: AppColor.color246,
                margin: EdgeInsets.only(bottom: 16, top: 150),
              ),
              Text(
                "登录账号后查看你关注的精彩内容",
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              ),
              GestureDetector(
                onTap: () {
                  AppRouter.navigateToLoginPage(context);
                },
                child: Container(
                  width: 293,
                  height: 44,
                  color: Colors.black,
                  margin: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case Status.noConcern:
        return Container(
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
        break;
      case Status.loggedIn:
        return Container();
        break;
      case Status.concern:
        return ChangeNotifierProvider(
          create: (_) => PublishMonitorNotifier(plannedSpeed: 0.0),
          builder: (context, _) {
            return Container(
                child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                ScrollMetrics metrics = notification.metrics;
                // 注册通知回调
                if (notification is ScrollStartNotification) {
                  // 滚动开始
                  // print('滚动开始');
                } else if (notification is ScrollUpdateNotification) {
                  // 滚动位置更新
                  // print('滚动位置更新');
                  // 当前位置
                  // print("当前位置${metrics.pixels}");
                } else if (notification is ScrollEndNotification) {
                  // 滚动结束
                  // print('滚动结束');
                }
              },
              child: RefreshIndicator(
                  onRefresh: () async {
                    dataPage = 1;
                    attentionModel.clear();
                    loadStatus = LoadingStatus.STATUS_LOADING;
                    lastTime = null;
                    loadText = "加载中...";
                    Map<String, dynamic> model = await getPullList(type: 0, size: 20, lastTime: lastTime);
                    setState(() {
                      if (model["list"] != null) {
                        model["list"].forEach((v) {
                          print(v["comments"]);
                          if (v["comments"].length != 0) {
                            print("评论名${v["comments"][0]["name"]}");
                          }
                          attentionModel.add(HomeFeedModel.fromJson(v));
                        });
                        attentionModel.insert(0, HomeFeedModel());
                        print("数据长度${attentionModel.length}");
                        // print(attentionModel.)
                      }
                      lastTime = model["lastTime"];
                    });
                  },
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView.builder(
                        itemCount: attentionModel.length + 1,
                        controller: _controller,
                        itemBuilder: (context, index) {
                          print("关注");
                          print(index);
                          print(attentionModel.length);
                          if (index == attentionModel.length ) {
                            return LoadingView(
                              loadText: loadText,
                              loadStatus: loadStatus,
                            );
                          } else {
                            return backToView(index, postFeedModel);
                          }
                        }),
                  )),
            ));
          },
        );
        break;
    }
  }

  //返回视图
  backToView(int index, PostFeedModel postFeedModel) {
    if (index == 0) {
      if (postFeedModel != null) {
        return createdPostPromptView();
      } else {
        return Container(
          height: 14,
        );
      }
    } else {
      return DynamicListLayout(
          index: index,
          pc: widget.pc,
          isShowRecommendUser: true,
          model: attentionModel[index],
          // 可选参数 子Item的个数
          key: GlobalObjectKey("attention$index"));
    }
  }

  @override
  Widget build(BuildContext context) {
    var isLogged = context.watch<TokenNotifier>().isLoggedIn;
    if (!isLogged) {
      context.read<PublishMonitorNotifier>().getRequestInterface(false);
      status = Status.notLoggedIn;
      this.dataPage = 1;
      this.attentionModel = [];
      this.lastTime = null;
    }
    print("isLogged:$isLogged");
    print("isRequestInterface:${context.watch<PublishMonitorNotifier>().isRequestInterface}");
    print('==================================${context.watch<PublishMonitorNotifier>().isPublishing}');
    if (isLogged&&!context.watch<PublishMonitorNotifier>().isRequestInterface) {
      print('------------------------------------进推荐页');
      getRecommendFeed();

    } else {
      // postFeedModel = Application.postFeedModel;
      // print("Application.postFeedModel+++++_____________${Application.postFeedModel}");
      // Application.postFeedModel = null;
      print("postFeedModel*******$postFeedModel");
      // print("centent${postFeedModel.content}");
      if(!context.watch<PublishMonitorNotifier>().isPublishing&&postFeedModel!=null) {
        print('------------------进发布页');
        pulishFeed();
      }
    }
    return pageDisplay();
  }
}

// 发布监听通知
class PublishMonitorNotifier extends ChangeNotifier {
  PublishMonitorNotifier({this.postStatus = PostStatus.publishing,this.attentionModel ,this.plannedSpeed,this.isRequestInterface = false,this.isPublishing = false});
  // 发布状态
  PostStatus postStatus;

  // 发布进度
  double plannedSpeed = 0.0;
  bool isRequestInterface;
  bool isPublishing;
  // 数据源调用model
  List<HomeFeedModel> attentionModel;

  getPostStatus(PostStatus post) {
    this.postStatus = post;
    notifyListeners();
  }
  getPublishing(bool publishing){
    this.isPublishing = publishing;
    notifyListeners();
  }
  getRequestInterface(bool requestInterface){
    this.isRequestInterface = requestInterface;
    notifyListeners();
  }
  getPostPlannedSpeed(double plannedSpeed) {
    this.plannedSpeed = plannedSpeed;
    notifyListeners();
  }

  getAttentionModel(List<HomeFeedModel> model) {
    this.attentionModel = model;
    notifyListeners();
  }
}
