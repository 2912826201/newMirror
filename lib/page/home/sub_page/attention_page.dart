import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
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
  AttentionPage({Key key, this.postFeedModel}) : super(key: key);

  // 发布动态需要的数据
  PostFeedModel postFeedModel;

  AttentionPageState createState() => AttentionPageState();
}

class AttentionPageState extends State<AttentionPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  var status = Status.loggedIn;

  // 发布进度
  double _process = 0.0;

  // 加载中默认文字
  String loadText = "";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;

  // 数据源
  List<int> attentionIdList = [];
  List<HomeFeedModel> attentionModelList = [];

  // 请求下一页
  int lastTime;

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 是否登录
  bool isLoggedIn = false;

  // 是否请求接口
  bool isRequestInterface = false;

  @override
  void initState() {
    print("初始化一下啊");
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否登录$isLoggedIn");
    if (!isLoggedIn) {
      status = Status.notLoggedIn;
    } else {
      getRecommendFeed();
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

  // 请求关注接口
  getRecommendFeed() async {
    isRequestInterface = true;
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    print("postFeedModel%%%%%%%$widget.postFeedModel");
    print("开始请求动态数据");
    if (dataPage > 1 && lastTime == null) {
      loadText = "已加载全部动态";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
      print("返回不请求数据");
      return;
    }
    DataResponseModel model = await getPullList(type: 0, size: 20, lastTime: lastTime);
    setState(() {
      print("dataPage:  ￥￥$dataPage");
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            attentionIdList.add(HomeFeedModel.fromJson(v).id);
            attentionModelList.add(HomeFeedModel.fromJson(v));
            print("接口赶回");
            print(HomeFeedModel.fromJson(v).comments);
          });
          if (model.hasNext == 0) {
            loadText = "";
            loadStatus = LoadingStatus.STATUS_IDEL;
          }
          attentionIdList.insert(0, -1);
          status = Status.concern;
        } else {
          status = Status.noConcern;
        }
      } else if (dataPage > 1 && lastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            attentionIdList.add(HomeFeedModel.fromJson(v).id);
            attentionModelList.add(HomeFeedModel.fromJson(v));
          });
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        } else {
          // 加载完毕
          loadText = "已加载全部动态";
          loadStatus = LoadingStatus.STATUS_COMPLETED;
        }
      }
    });
    lastTime = model.lastTime;
    isRequestInterface = false;
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
  }

  // 发布动态
  pulishFeed() async {
    List<File> fileList = [];
    UploadResults results;
    List<PicUrlsModel> picUrls = [];
    List<VideosModel> videos = [];

    if (widget.postFeedModel != null && context.watch<FeedMapNotifier>().isPublish) {
      PostFeedModel postModel = widget.postFeedModel;
      // 设置不可发布
      context.watch<FeedMapNotifier>().isPublish = false;
      print("掉发布数据");
      // 上传图片
      if (postModel.selectedMediaFiles.type == mediaTypeKeyImage) {
        // 获取当前时间
        String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
        int i = 0;
        //
        postModel.selectedMediaFiles.list.forEach((element) async {
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
        results = await FileUtil().uploadPics(fileList, (percent) {
          context.read<FeedMapNotifier>().getPostPlannedSpeed(percent);
        });

        print(results.isSuccess);
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          picUrls[i].url = model.url;
        }
      } else if (postModel.selectedMediaFiles.type == mediaTypeKeyVideo) {
        postModel.selectedMediaFiles.list.forEach((element) {
          fileList.add(element.file);
          videos.add(VideosModel(width: element.sizeInfo.width, height: element.sizeInfo.height,
              duration: element.sizeInfo.duration, videoCroppedRatio: element.sizeInfo.videoCroppedRatio,
              offsetRatioX: element.sizeInfo.offsetRatioX, offsetRatioY: element.sizeInfo.offsetRatioY));
        });
        results = await FileUtil().uploadMedias(fileList, (percent) {
          context.read<FeedMapNotifier>().getPostPlannedSpeed(percent);
        });
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下视频索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          videos[i].url = model.url;
          videos[i].coverUrl = FileUtil.getVideoFirstPhoto(model.url);
        }
      }
      print("数据请求发不打印${postModel.content}");
      Map<String, dynamic> feedModel = await publishFeed(
          type: 0,
          content: postModel.content,
          picUrls: jsonEncode(picUrls),
          videos: jsonEncode(videos),
          atUsers: jsonEncode(postModel.atUsersModel),
          address: postModel.address,
          latitude: postModel.latitude,
          longitude: postModel.longitude,
          cityCode: postModel.cityCode,
          topics: jsonEncode(postModel.topics));
      print("发不接受发布结束：feedModel$feedModel");
      // 清空发布model
      context.read<FeedMapNotifier>().setPublishFeedModel(null);
      if (feedModel != null) {
        _process = 1.0;
        context.read<FeedMapNotifier>().getPostPlannedSpeed(_process);
        // 设置可发布
        context.read<FeedMapNotifier>().setPublish(true);
        status = Status.concern;
        // 发布完成
        // 延迟器:
        new Future.delayed(Duration(seconds: 1), () {
          widget.postFeedModel = null;
          postModel = null;
          //还原进度条
          _process = 0.0;
          context.read<FeedMapNotifier>().getPostPlannedSpeed(_process);
          // 插入数据
          attentionIdList.insert(1, HomeFeedModel.fromJson(feedModel).id);
          context
              .read<FeedMapNotifier>()
              .PublishInsertData(HomeFeedModel.fromJson(feedModel).id, HomeFeedModel.fromJson(feedModel));
        });
      } else {
        // 发布失败
        print('================================发布失败');
        // 设置不可发布
        context.read<FeedMapNotifier>().setPublish(false);
        context.read<FeedMapNotifier>().setPublishFeedModel(postModel);
        _process = -1.0;
        context.read<FeedMapNotifier>().getPostPlannedSpeed(_process);
        context.read<FeedMapNotifier>().setPublish(true);
      }
    }
  }

  // 返回关注视图
  backToView(int index, HomeFeedModel feedmodel) {
    if (index == 0) {
      // return
      //   FlatButton(
      //     child: Text(context.read<TokenNotifier>().token.anonymous == 0 ? "登出" : "登录"),
      //     onPressed: () async {
      //        Application.token.anonymous = 1;
      //       //先取个匿名token
      //        context.read<TokenNotifier>().setToken(Application.token);
      //       }
      //   );
      return Container(
        height: 14,
      );
    } else {
      return DynamicListLayout(
        index: index,
        isShowRecommendUser: true,
        model: feedmodel,
        // 可选参数 子Item的个数
        key: GlobalObjectKey("attention$index"),
        deleteFeedChanged: (id) {
          setState(() {
            attentionIdList.remove(id);
            context.read<FeedMapNotifier>().deleteFeed(id);
          });
        },
        removeFollowChanged: (model) {
          int pushId = model.pushId;
          Map<int, HomeFeedModel> feedMap = context.read<FeedMapNotifier>().feedMap;

          ///临时的空数组
          List<int> themList = [];
          feedMap.forEach((key, value) {
            if (value.pushId == pushId) {
              themList.add(key);
            }
          });
          setState(() {
            attentionIdList = arrayDate(attentionIdList, themList);
            loadStatus = LoadingStatus.STATUS_IDEL;
            loadText = "";
          });
        },
      );
    }
  }

  /**比较两数组 取出不同的，
   * array1 数组一
   * array2 数组二
   * **/
  arrayDate(List<int> array1, List<int> array2) {
    var arr1 = array1;
    var arr2 = array2;
    List<int> result = [];
    for (var i = 0; i < array1.length; i++) {
      var obj = array1[i];
      var isExist = false;
      for (var j = 0; j < array2.length; j++) {
        var aj = array2[j];
        if (obj == aj) {
          isExist = true;
          continue;
        }
      }
      if (!isExist) {
        result.add(obj);
      }
    }
    print("result${result.toString()}");
    return result;
  }

  // 缺省图未登录关注视图的长度。
  int itemcount() {
    int count = 0;
    // if (status == Status.noConcern || status == Status.notLoggedIn || status == Status.loggedIn) {
    //   count = 1;
    // } else if (status == Status.concern) {
    count = attentionIdList.length + 1;
    // }
    return count;
  }

  // 创建发布进度视图
  createdPostPromptView() {
    // 展示文字
    return Container(
      height: 60,
      width: ScreenUtil.instance.screenWidthDp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        color: AppColor.mainRed,
                        margin: EdgeInsets.only(right: 16),
                      ),
                      publishTextStatus(context.read<FeedMapNotifier>().plannedSpeed),
                      Spacer(),
                      Offstage(
                          offstage: context.read<FeedMapNotifier>().plannedSpeed != -1,
                          child: Container(
                            width: 76,
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.lime,
                                ),
                                Spacer(),
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.lime,
                                ),
                              ],
                            ),
                          ))
                    ],
                  ))),
          LinearProgressIndicator(
            value: context.read<FeedMapNotifier>().plannedSpeed,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            backgroundColor: AppColor.white,
          ),
        ],
      ),
    );
  }

  // 发布动态进度条视图
  publishTextStatus(double plannedSpeed) {
    print("空值的来历￥￥$plannedSpeed");
    if (plannedSpeed >= 0 && plannedSpeed < 1) {
      return Text(
        "正在发布",
        style: AppStyle.textRegular16,
      );
    } else if (plannedSpeed == 1) {
      return Text(
        "完成",
        style: AppStyle.textRegular16,
      );
    } else if (plannedSpeed == -1) {
      return Text(
        "我们会在网络信号改善时重试",
        style: AppStyle.textHintRegular16,
      );
    }
  }

  // 缺省图未登录关注视图切换
  Widget pageDisplay(int index, HomeFeedModel feedModel) {
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
                onTap: () async {
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
        if (index == attentionIdList.length) {
          return LoadingView(
            loadText: loadText,
            loadStatus: loadStatus,
          );
        } else {
          return backToView(index, feedModel);
        }
    }
  }

  @override
  void dispose() {
    print("关注页面销毁了");

    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivate：：：：：：关注页");
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies：：：：：：关注页");
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AttentionPage oldWidget) {
    print("didUpdateWidget：：：：：：关注页");
    // context.read<FeedMapNotifier>().clearBuildCount();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    print("关注页");
    print("当前时间${DateTime.now().millisecondsSinceEpoch.toString()}");
    var isLogged = context.watch<TokenNotifier>().isLoggedIn;
    print(isLogged);
    if (!isLogged) {
      status = Status.notLoggedIn;
      this.dataPage = 1;
      this.attentionIdList.clear();
      this.attentionModelList.clear();
      this.lastTime = null;
      loadStatus = LoadingStatus.STATUS_LOADING;
      isRequestInterface = false;
    }

    if (isLogged && attentionIdList.isEmpty && !isRequestInterface && status != Status.noConcern) {
      getRecommendFeed();
    }

    if (context.watch<FeedMapNotifier>().postFeedModel != null && context.watch<FeedMapNotifier>().isPublish) {
      if (status == Status.noConcern) {
        print("attentionIdList${attentionIdList.toString()}");
        if (attentionIdList.isEmpty) {
          attentionIdList.insert(0, -1);
        }
      }
      // 回到顶部，加这个判断是没加载过关注页时_controller并未绑定直接调用会崩溃。
      if(_controller.hasClients) {
        _controller.jumpTo(0);
      }
      pulishFeed();
    }
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
            attentionIdList.clear();
            attentionModelList.clear();
            loadStatus = LoadingStatus.STATUS_IDEL;
            lastTime = null;
            loadText = "";
            getRecommendFeed();
          },
          child: CustomScrollView(controller: _controller, physics: AlwaysScrollableScrollPhysics(), slivers: [
            SliverList(
              // controller: _controller,
              delegate: SliverChildBuilderDelegate((content, index) {
                if (index == 0 && widget.postFeedModel != null) {
                  return createdPostPromptView();
                }
                if (status == Status.noConcern || status == Status.notLoggedIn || status == Status.noConcern) {
                  return pageDisplay(0, HomeFeedModel());
                }
                // 获取动态id
                int id;
                // 获取动态id指定model
                HomeFeedModel feedModel;
                if (index < attentionIdList.length) {
                  id = attentionIdList[index];
                  feedModel = context.read<FeedMapNotifier>().feedMap[id];
                }
                return pageDisplay(index, feedModel);
              }, childCount: itemcount()),
            )
            // )
          ])),
    ));
  }
}
