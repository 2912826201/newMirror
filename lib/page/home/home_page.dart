import 'dart:convert';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/search/search_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.controller, this.ifPageController}) : super(key: key);
  TabController controller;
  TabController ifPageController;

  HomePageState createState() => HomePageState(controller: controller);
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  HomePageState({TabController controller});

  // taBar和TabBarView必要的
  TabController controller;

  @override
  bool get wantKeepAlive => true; //必须重写
  // 发布进度
  double _process = 0.0;

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                      publishTextStatus(context.watch<FeedMapNotifier>().plannedSpeed),
                      Spacer(),
                      Offstage(
                          offstage: context.watch<FeedMapNotifier>().plannedSpeed != -1,
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
            value: context.watch<FeedMapNotifier>().plannedSpeed,
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

  // 发布动态
  pulishFeed() async {
    List<File> fileList = [];
    UploadResults results;
    List<PicUrlsModel> picUrls = [];
    List<VideosModel> videos = [];
    // 设置不可发布
    context.watch<FeedMapNotifier>().isPublish = false;
    PostFeedModel postFeedModel = context.watch<FeedMapNotifier>().postFeedModel;
    if (postFeedModel != null) {
      PostFeedModel postModel = postFeedModel;
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
          videos.add(VideosModel(
              width: element.sizeInfo.width,
              height: element.sizeInfo.height,
              duration: element.sizeInfo.duration,
              videoCroppedRatio: element.sizeInfo.videoCroppedRatio,
              offsetRatioX: element.sizeInfo.offsetRatioX,
              offsetRatioY: element.sizeInfo.offsetRatioY));
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
          // _process = 1.0;
          // context.read<FeedMapNotifier>().getPostPlannedSpeed(_process);
          // 发布完成
          // 延迟器:
          new Future.delayed(Duration(seconds: 3), () {
            // 清空发布model
            context.read<FeedMapNotifier>().setPublishFeedModel(null);
            //还原进度条
            _process = 0.0;
            context.read<FeedMapNotifier>().getPostPlannedSpeed(_process);
            // 设置可发布
            context.read<FeedMapNotifier>().isPublish = true;
          });
          // new Future.delayed(Duration(seconds: 1), () {
          // 插入数据
          attentionKey.currentState.insertData(HomeFeedModel.fromJson(feedModel).id);
          context
              .read<FeedMapNotifier>()
              .PublishInsertData(HomeFeedModel.fromJson(feedModel).id, HomeFeedModel.fromJson(feedModel));
          // });
        } else {
          // 发布失败
          print('================================发布失败');
          // 清空发布model
          context.read<FeedMapNotifier>().setPublishFeedModel(null);
          // 设置不可发布
          context.read<FeedMapNotifier>().setPublish(false);
          _process = -1.0;
          context.read<FeedMapNotifier>().getPostPlannedSpeed(_process);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("HomePage_____________________________________________build");
    // 发布动态
    if (context.watch<FeedMapNotifier>().postFeedModel != null && context.watch<FeedMapNotifier>().isPublish) {
      // 定位到main_page页
      widget.ifPageController.index = 1;
      // 定位到关注页
      controller.index = 0;
      // 关注页回到顶部
      attentionKey.currentState.backToTheTop();
      // 发布动态
      pulishFeed();
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
                  if (context.read<FeedMapNotifier>().plannedSpeed != -1) {
                    ToastShow.show(msg: "你有动态正在发送中，请稍等", context: context, gravity: Toast.CENTER);
                  } else {
                    ToastShow.show(msg: "动态发送失败", context: context, gravity: Toast.CENTER);
                  }
                } else {
                  AppRouter.navigateToMediaPickerPage(
                      context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
                      publishMode: 1);
                }
              }),
          titleWidget: Container(
            width: 140,
            child: TabBar(
              controller: controller,
              tabs: [Text("关注"), Text("推荐")],
              labelStyle: TextStyle(fontSize: 18),
              labelColor: Colors.black,
              // indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
              // unselectedLabelColor: Color.fromRGBO(153, 153, 153, 1),
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
            Offstage(
              offstage: context.watch<FeedMapNotifier>().postFeedModel == null,
              child: createdPostPromptView(),
            ),
            Expanded(
              child: TabBarView(
                controller: this.controller,
                children: [
                  AttentionPage(
                    key: attentionKey,
                    postFeedModel: context.watch<FeedMapNotifier>().postFeedModel,
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
