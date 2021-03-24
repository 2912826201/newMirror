import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/release_progress_view.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:union_tabs/union_tabs.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // taBar和TabBarView必要的
  TabController controller;

  // 发布动态model
  PostprogressModel postprogressModel = PostprogressModel();

  double animalHeight = 0;
  StreamSubscription<ConnectivityResult> connectivityListener;
  StreamController<double> streamController = StreamController<double>();

  // 进度监听
  StreamController<PostprogressModel> streamProgress = StreamController<PostprogressModel>();

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
    EventBus.getDefault().registerSingleParameter(
        (postprogress) => pulishFeed(postprogress, isBackToTheTop: true), EVENTBUS_HOME_PAGE,
        registerName: EVENTBUS_POST_PORGRESS_VIEW);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (AppPrefs.getPublishFeedLocalInsertData(
              "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}") !=
          null) {
        print("HomePageState发布失败数据");
        // 取出发布动态数据
        postprogressModel = PostprogressModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
            "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
        if (postprogressModel != null && postprogressModel.postFeedModel != null) {
          postprogressModel.postFeedModel.selectedMediaFiles.list.forEach((v) {
            v.file = File(v.filePath);
          });
          postprogressModel.plannedSpeed = -1.0;
          postprogressModel.showPulishView = true;
          postprogressModel.isPublish = false;
          streamController.sink.add(60.0);
          streamProgress.sink.add(postprogressModel);
        }
      }
    });
    _initConnectivity();
  }

  // 取出发布动态数据
  PostprogressModel getPublishFeedData() {
    postprogressModel = PostprogressModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
        "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
    if (postprogressModel != null && postprogressModel.postFeedModel != null) {
      postprogressModel.postFeedModel.selectedMediaFiles.list.forEach((v) {
        v.file = File(v.filePath);
      });
    }
    postprogressModel.showPulishView = true;
    streamProgress.sink.add(postprogressModel);
    return postprogressModel;
  }

  //获取网络连接状态
  _initConnectivity() async {
    // ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile) {
    //   pulishFeed(getPublishFeedData());
    // } else if (connectivityResult == ConnectivityResult.wifi) {
    //   pulishFeed(getPublishFeedData());
    // } else {
    //
    // }
    connectivityListener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (context.read<TokenNotifier>().isLoggedIn) {
        if (AppPrefs.getPublishFeedLocalInsertData(
                "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}") !=
            null) {
          if (result == ConnectivityResult.mobile) {
            print("移动网");
            pulishFeed(getPublishFeedData());
          } else if (result == ConnectivityResult.wifi) {
            print("wifi");
            pulishFeed(getPublishFeedData());
          } else {
            print("无网了");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 发布动态
  pulishFeed(PostprogressModel postprogress, {isBackToTheTop = false}) async {
    postprogressModel = postprogress;
    // 不可发布时
    if (!postprogress.isPublish) {
      return;
    }

    // 才从发布动态页跳转回来时
    if (isBackToTheTop) {
      // 定位到main_page页
      Application.ifPageController.index = Application.ifPageController.length - 1;
      // 定位到关注页
      controller.index = 0;
      streamController.sink.add(60.0);
      postprogressModel.showPulishView = true;
      // 关注页回到顶部
      if (attentionKey.currentState != null) {
        attentionKey.currentState.backToTheTop();
      }
      // 设置不可发布
      postprogressModel.isPublish = false;
    }

    List<File> fileList = [];
    UploadResults results;
    List<PicUrlsModel> picUrls = [];
    List<VideosModel> videos = [];
    print("发布1111111111111111111");
    print("发布2222222222222222222");
    if (postprogressModel != null) {
      PostFeedModel postModel = postprogressModel.postFeedModel;
      print(postModel.atUsersModel);
      print("掉发布数据");
      print(postModel.selectedMediaFiles.type == mediaTypeKeyImage);
      // 上传图片
      if (postModel.selectedMediaFiles.type == mediaTypeKeyImage) {
        postModel.selectedMediaFiles.list.forEach((element) {
          print(element.file);
          fileList.add(element.file);
          picUrls.add(PicUrlsModel(width: element.sizeInfo.width, height: element.sizeInfo.height));
        });

        results = await FileUtil().uploadPics(fileList, (percent) {
          postprogressModel.plannedSpeed = percent;
          streamProgress.sink.add(postprogressModel);
        });
        if (results.isSuccess == false) {
          print('================================上传七牛云失败');
          // 设置不可发布
          postprogressModel.isPublish = false;
          postprogressModel.plannedSpeed = -1.0;
          streamProgress.sink.add(postprogressModel);
          return;
        }
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          picUrls[i].url = model.url;
        }
      } else if (postModel.selectedMediaFiles.type == mediaTypeKeyVideo) {
        postModel.selectedMediaFiles.list.forEach((element) {
          fileList.add(element.file);
          videos.add(VideosModel(
              width: element.sizeInfo.width,
              height: element.sizeInfo.height,
              duration: element.sizeInfo.duration,
              videoCroppedRatio: element.sizeInfo.videoCroppedRatio,
              offsetRatioX: element.sizeInfo.offsetRatioX,
              offsetRatioY: element.sizeInfo.offsetRatioY));
        });
        results = await FileUtil().uploadMedias(fileList, (percent) {
          print("percent：${percent}");
          postprogressModel.plannedSpeed = percent;
          streamProgress.sink.add(postprogressModel);
          print("percent结束了:");
        });
        print("resultsErroe:${results.isSuccess}");
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下视频索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          videos[i].url = model.url;
          videos[i].coverUrl = FileUtil.getVideoFirstPhoto(model.url);
        }
      }
      print("数据请求发不打印${postModel.toString()}");
      if (mounted) {
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

        if (feedModel != null) {
          // 发布完成
          // 插入接口更新
          attentionKey.currentState.insertData(HomeFeedModel.fromJson(feedModel));
          // 延迟器:
          new Future.delayed(Duration(seconds: 3), () {
            // 重新赋值存入
            AppPrefs.setPublishFeedLocalInsertData(
                "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}", null);
            // todo 清除图片路径

            // 清空发布model
            postprogressModel.postFeedModel = null;
            //还原进度条
            postprogressModel.plannedSpeed = 0.0;
            streamController.sink.add(0.0);
            postprogressModel.isPublish = true;
            streamProgress.sink.add(postprogressModel);
          });
        } else {
          // 发布失败
          print('================================发布失败');
          postprogressModel.isPublish = false;
          postprogressModel.plannedSpeed = -1.0;
          postprogressModel.showPulishView = true;
          streamProgress.sink.add(postprogressModel);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("HomePage_____________________________________________build");
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        leading:
            // StreamBuilder<PostprogressModel>(
            //     initialData: postprogressModel,
            //     stream: streamCustomAppBar.stream,
            //     builder: (BuildContext stramContext, AsyncSnapshot<PostprogressModel> snapshot) {
            CustomAppBarIconButton(
                svgName: AppIcon.nav_camera,
                iconColor: AppColor.black,
                onTap: () {
                  print("${FluroRouter.appRouter.hashCode}");
                  print(postprogressModel.toString());
                  if (postprogressModel != null && postprogressModel.postFeedModel != null) {
                    if (postprogressModel.plannedSpeed != -1) {
                      ToastShow.show(msg: "你有动态正在发送中，请稍等", context: context, gravity: Toast.CENTER);
                    } else {
                      ToastShow.show(msg: "动态发送失败", context: context, gravity: Toast.CENTER);
                    }
                  } else {
                    // 从打开新页面改成滑到负一屏
                    if (context.read<TokenNotifier>().isLoggedIn) {
                      // 暂时屏蔽负一屏
                      AppRouter.navigateToMediaPickerPage(
                          context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
                          publishMode: 1);
                      // Application.ifPageController.animateTo(0);
                    } else {
                      AppRouter.navigateToLoginPage(context);
                    }
                  }
                }),
        // }),
        titleWidget: Container(
          width: 140,
          child: TabBar(
            controller: controller,
            tabs: [
              Text("关注"),
              Text(
                "推荐",
              )
            ],
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            labelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontSize: 16),
            indicator: RoundUnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: Color.fromRGBO(253, 137, 140, 1),
              ),
              insets: EdgeInsets.only(bottom: -6),
              wantWidth: 16,
            ),
          ),
        ),
        actions: [
          CustomAppBarIconButton(
              svgName: AppIcon.nav_search,
              iconColor: AppColor.black,
              onTap: () {
                AppRouter.navigateSearchPage(context);
              }),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              StreamBuilder<double>(
                  initialData: animalHeight,
                  stream: streamController.stream,
                  builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear,
                      height: snapshot.data,
                      child: Container(
                        height: snapshot.data,
                      ),
                    );
                  }),
              Expanded(
                child: UnionInnerTabBarView(
                  controller: controller,
                  children: [
                    AttentionPage(
                      key: attentionKey,
                    ),
                    RecommendPage()
                    // RecommendPage()
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              top: 0,
              child: StreamBuilder<PostprogressModel>(
                  initialData: postprogressModel,
                  stream: streamProgress.stream,
                  builder: (BuildContext stramContext, AsyncSnapshot<PostprogressModel> snapshot) {
                    return ReleaseProgressView(
                      postprogressModel: snapshot.data,
                      deleteReleaseFeedChanged: () {
                        // 重新赋值存入
                        AppPrefs.setPublishFeedLocalInsertData(
                            "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}", null);
                        // todo 清除图片路径

                        // 清空发布model
                        postprogressModel.postFeedModel = null;
                        // context.read<ReleaseProgressNotifier>().setPublishFeedModel(null);
                        // 删除本地插入数据
                        // if (attentionKey.currentState != null) {
                        //   attentionKey.currentState.deleteData();
                        // } else {
                        //   new Future.delayed(Duration(milliseconds: 500), () {
                        //     attentionKey.currentState.deleteData();
                        //   });
                        // }
                        //还原进度条
                        postprogressModel.plannedSpeed = 0.0;
                        // 设置可发布
                        postprogressModel.isPublish = true;
                        streamController.sink.add(0.0);
                        streamProgress.sink.add(postprogressModel);
                      },
                      // 重新发送
                      resendFeedChanged: () {
                        pulishFeed(getPublishFeedData());
                      },
                    );
                  })),
          //     )
          // : Container(),
        ],
      ),
    );
    // });
  }
}
