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
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/release_progress_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/release_progress_view.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:union_tabs/union_tabs.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // taBar和TabBarView必要的
  TabController controller;

  @override
  bool get wantKeepAlive => true; //必须重写
  // 发布进度
  double _process = 0.0;

  StreamSubscription<ConnectivityResult> connectivityListener;

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
    if(AppPrefs.getPublishFeedLocalInsertData(
        "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")!=null){
      new Future.delayed(Duration.zero, () {
        print("发布失败数据");
        // 取出发布动态数据
        PostFeedModel feedModel = PostFeedModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
            "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
        if (feedModel != null) {
          feedModel.selectedMediaFiles.list.forEach((v) {
            v.file = File(v.filePath);
          });
          context.read<FeedMapNotifier>().setPublishFeedModel(feedModel);
          // // 插入数据
          // if (attentionKey.currentState != null) {
          //   attentionKey.currentState.insertData(HomeFeedModel().conversionModel(feedModel, context, isRefresh: true));
          // } else {
          //   new Future.delayed(Duration(milliseconds: 500), () {
          //     attentionKey.currentState.insertData(HomeFeedModel().conversionModel(feedModel, context, isRefresh: true));
          //   });
          // }
          context.read<FeedMapNotifier>().setPublish(false);
          _process = -1.0;
          context.read<ReleaseProgressNotifier>().getPostPlannedSpeed(_process);
        }
      });
    }

    _initConnectivity();
  }

  // 取出发布动态数据
  PostFeedModel getPublishFeedData() {
    PostFeedModel feedModel = PostFeedModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
        "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
    if (feedModel != null) {
      if(feedModel.selectedMediaFiles.type==mediaTypeKeyImage){
        feedModel.selectedMediaFiles.list.forEach((v) {
          v.file = File(v.filePath);
        });
      }else if(feedModel.selectedMediaFiles.type==mediaTypeKeyVideo){
        feedModel.selectedMediaFiles.list.forEach((v) {
          v.file = File(v.thumbPath);
        });
      }
    }
    return feedModel;
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
      if (result == ConnectivityResult.mobile&&AppPrefs.getPublishFeedLocalInsertData(
          "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")!=null) {
        pulishFeed(getPublishFeedData());
      } else if (result == ConnectivityResult.wifi&&AppPrefs.getPublishFeedLocalInsertData(
          "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")!=null) {
        pulishFeed(getPublishFeedData());
      } else {}
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 发布动态
  pulishFeed(PostFeedModel postFeedModel) async {
    List<File> fileList = [];
    UploadResults results;
    List<PicUrlsModel> picUrls = [];
    List<VideosModel> videos = [];
    print("发布1111111111111111111");
    // // 设置不可发布
    // context.watch<FeedMapNotifier>().setPublish(false);
    print("发布2222222222222222222");
    if (postFeedModel != null) {
      PostFeedModel postModel = postFeedModel;
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
          Future.delayed(Duration.zero, () {
            context.read<ReleaseProgressNotifier>().getPostPlannedSpeed(percent);
          });
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
          context.read<ReleaseProgressNotifier>().getPostPlannedSpeed(percent);
          print("percent结束了:");
        });
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
          // 延迟器:
          new Future.delayed(Duration(seconds: 3), () {
            // 重新赋值存入
            AppPrefs.setPublishFeedLocalInsertData(
                "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}", null);
            // todo 清除图片路径

            // 清空发布model
            context.read<FeedMapNotifier>().setPublishFeedModel(null);
            //还原进度条
            _process = 0.0;
            context.read<ReleaseProgressNotifier>().getPostPlannedSpeed(_process);
            // 设置可发布
            context.read<FeedMapNotifier>().isPublish = true;
          });
          // 数据更新
          attentionKey.currentState.replaceData(HomeFeedModel.fromJson(feedModel));
        } else {
          // 发布失败
          print('================================发布失败');
          // 设置不可发布
          context.read<FeedMapNotifier>().setPublish(false);
          _process = -1.0;
          context.read<ReleaseProgressNotifier>().getPostPlannedSpeed(_process);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("HomePage_____________________________________________build");
    // 发布动态
    if (context.watch<FeedMapNotifier>().postFeedModel != null && context.watch<FeedMapNotifier>().isPublish) {
      print("疯狂)))))))))))))))))))))");

      PostFeedModel postFeedModel = context.watch<FeedMapNotifier>().postFeedModel;
      HomeFeedModel homeFeedModel = HomeFeedModel().conversionModel(postFeedModel, context);
      // 定位到main_page页
      Application.ifPageController.index = Application.ifPageController.length - 1;
      // 定位到关注页
      controller.index = 0;
      // 关注页回到顶部
      if (attentionKey.currentState != null) {
        attentionKey.currentState.backToTheTop();
      }
      // 插入数据
      if (attentionKey.currentState != null) {
        attentionKey.currentState.insertData(homeFeedModel);
      } else {
        new Future.delayed(Duration(milliseconds: 500), () {
          attentionKey.currentState.insertData(homeFeedModel);
        });
      }
      // 设置不可发布
      context.watch<FeedMapNotifier>().setPublish(false);
      // 发布动态
      pulishFeed(postFeedModel);
    }
    return Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBar(
          leading: CustomAppBarIconButton(
              icon: Icons.camera_alt_outlined,
              iconColor: AppColor.black,
              // isLeading: true,
              onTap: () {
                print("${FluroRouter.appRouter.hashCode}");
                if (context.read<FeedMapNotifier>().postFeedModel != null) {
                  if (context.read<ReleaseProgressNotifier>().plannedSpeed != -1) {
                    ToastShow.show(msg: "你有动态正在发送中，请稍等", context: context, gravity: Toast.CENTER);
                  } else {
                    ToastShow.show(msg: "动态发送失败", context: context, gravity: Toast.CENTER);
                  }
                } else {
                  // 从打开新页面改成滑到负一屏
                  if (context.read<TokenNotifier>().isLoggedIn) {
                    Application.ifPageController.animateTo(0);
                  } else {
                    AppRouter.navigateToLoginPage(context);
                  }
                }
              }),
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
                icon: Icons.search,
                iconColor: AppColor.black,
                // isLeading: false,
                onTap: () {
                  AppRouter.navigateSearchPage(context);
                }),
          ],
        ),
        body: Column(
          children: [
            // context.watch<FeedMapNotifier>().postFeedModel != null
            //     ? Offstage(
            //         offstage: context.watch<FeedMapNotifier>().postFeedModel == null, child:
            // createdPostPromptView()
            ReleaseProgressView(
              deleteReleaseFeedChanged: () {
                // 重新赋值存入
                AppPrefs.setPublishFeedLocalInsertData(
                    "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}", null);
                // todo 清除图片路径

                // 清空发布model
                context.read<FeedMapNotifier>().setPublishFeedModel(null);
                // 删除本地插入数据
                if (attentionKey.currentState != null) {
                  attentionKey.currentState.deleteData();
                } else {
                  new Future.delayed(Duration(milliseconds: 500), () {
                    attentionKey.currentState.deleteData();
                  });
                }
                //还原进度条
                _process = 0.0;
                context.read<ReleaseProgressNotifier>().getPostPlannedSpeed(_process);
                // 设置可发布
                context.read<FeedMapNotifier>().isPublish = true;
              },
              resendFeedChanged: () {
                pulishFeed(context.read<FeedMapNotifier>().postFeedModel);
              },
            ),
            //     )
            // : Container(),
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
            )
          ],
        ));
  }
}
