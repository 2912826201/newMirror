import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:connectivity/connectivity.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
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

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
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
  void dispose() {
    controller.dispose();
    EventBus.getDefault().unRegister(registerName: EVENTBUS_GET_FAILURE_MODEL, pageName: EVENTBUS_HOME_PAGE);
    EventBus.getDefault().unRegister(registerName: EVENTBUS_POST_PORGRESS_VIEW, pageName: EVENTBUS_HOME_PAGE);
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);

    // 登录页重新登录获取发布失败model通知
    EventBus.getDefault()
        .registerNoParameter(postModelAssignment, EVENTBUS_HOME_PAGE, registerName: EVENTBUS_GET_FAILURE_MODEL);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 发布动态页发送发布model通知
      EventBus.getDefault()
          .registerSingleParameter(pulishFeed, EVENTBUS_HOME_PAGE, registerName: EVENTBUS_POST_PORGRESS_VIEW);
    });
    _initConnectivity();
  }

  // 发布失败后发布model赋值
  postModelAssignment() {
    if (AppPrefs.getPublishFeedLocalInsertData(
            "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}") !=
        null) {
      print("HomePageState发布失败数据");
      // 取出发布动态数据
      postprogressModel = PostprogressModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
          "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
      print("取出失败数据postprogressModel：${postprogressModel.toString()}");
      if (postprogressModel != null && postprogressModel.postFeedModel != null) {
        print("1111111111111");
        postprogressModel.postFeedModel.selectedMediaFiles.list.forEach((v) {
          // 这里是之前未处理发布页图片和视频数据未解析成功直接发布过来时的情况
          try {
            v.file = File(v.filePath);
          } catch (error) {
            // 当成功处理清空数据
            // 重新赋值存入
            print("清空数据_______________________");
            AppPrefs.setPublishFeedLocalInsertData(
                "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}", null);
            //  清除图片路径
            if (postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path
                .contains(AppConfig.getAppPublishDir())) {
              _clearCache(AppConfig.getAppPublishDir());
            }
            // 清空发布model
            postprogressModel.postFeedModel = null;
            //还原进度条
            postprogressModel.plannedSpeed = 0.0;
            streamController.sink.add(0.0);
            streamProgress.sink.add(postprogressModel);
            return;
          }
        });
        postprogressModel.plannedSpeed = -1.0;
        postprogressModel.showPulishView = true;
        streamController.sink.add(60.0);
        streamProgress.sink.add(postprogressModel);
      }
    }
  }

  // 取出发布动态数据
  PostprogressModel getPublishFeedData() {
    postprogressModel = PostprogressModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
        "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
    if (postprogressModel != null && postprogressModel.postFeedModel != null) {
      postprogressModel.postFeedModel.selectedMediaFiles.list.forEach((v) {
        v.file = File(v.filePath);
      });
      postprogressModel.showPulishView = true;
      print("断网重发数据postprogressModel：${postprogressModel.toString()}");
      streamProgress.sink.add(postprogressModel);
    }
    return postprogressModel;
  }

  //获取网络连接状态
  _initConnectivity() async {
    connectivityListener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (context.read<TokenNotifier>().isLoggedIn) {
        if (AppPrefs.getPublishFeedLocalInsertData(
                "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}") !=
            null) {
          if (result == ConnectivityResult.mobile) {
            print("移动网");
            pulishFeed(getPublishFeedData(), isPostPageJump: false);
          } else if (result == ConnectivityResult.wifi) {
            print("wifi");
            pulishFeed(getPublishFeedData(), isPostPageJump: false);
          } else {
            print("无网了");
          }
        }
      }
    });
  }

  // 发布动态
  pulishFeed(PostprogressModel postprogress, {isPostPageJump = true}) async {
    if (mounted) {
      postprogressModel = postprogress;
      // 才从发布动态页跳转回来时
      print("是否是发布页跳转回来：——————————————————————————————————————$isPostPageJump");
      if (isPostPageJump) {
        // 定位到main_page页
        Application.ifPageController.index = Application.ifPageController.length - 1;
        // 定位到关注页
        if (controller != null && controller.index != 0) {
          controller.index = 0;
        }
        streamController.sink.add(60.0);
        // 关注页回到顶部
        if (attentionKey.currentState != null) {
          attentionKey.currentState.backToTheTop();
        }
        // 展示进度条UI
        streamProgress.sink.add(postprogressModel);
      }
      // 解析数据
      for (MediaFileModel model in postprogressModel.postFeedModel.selectedMediaFiles.list) {
        // 解析进度
        var _percent = 0.0;
        if (model.croppedImage != null && model.croppedImageData == null) {
          ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
          Uint8List picBytes = byteData.buffer.asUint8List();
          model.croppedImageData = picBytes;
          _percent += 1 / postprogressModel.postFeedModel.selectedMediaFiles.list.length;
        } else {
          _percent = 1;
        }
        postprogressModel.plannedSpeed = _percent / 3;
        streamProgress.sink.add(postprogressModel);
      }
      // 转文件
      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
      int i = 0;
      // 图片
      if (postprogressModel.postFeedModel.selectedMediaFiles.type == mediaTypeKeyImage) {
        for (MediaFileModel v in postprogressModel.postFeedModel.selectedMediaFiles.list) {
          if (v.croppedImageData != null) {
            i++;
            File imageFile =
                await FileUtil().writeImageDataToFile(v.croppedImageData, timeStr + i.toString(), isPublish: true);
            v.file = imageFile;
          }
        }
      } else if (postprogressModel.postFeedModel.selectedMediaFiles.type == mediaTypeKeyVideo) {
        for (MediaFileModel v in postprogressModel.postFeedModel.selectedMediaFiles.list) {
          if (v.thumb != null) {
            i++;
            File thumbFile = await FileUtil().writeImageDataToFile(v.thumb, timeStr + i.toString(), isPublish: true);
            v.thumbPath = thumbFile.path;
          }
        }
      }

      // 存入数据
      AppPrefs.setPublishFeedLocalInsertData(
          "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}",
          jsonEncode(postprogressModel.toJson()));

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
            if (postprogressModel.plannedSpeed < 1) {
              postprogressModel.plannedSpeed += percent / 7;
            } else {
              postprogressModel.plannedSpeed = 1;
            }
            streamProgress.sink.add(postprogressModel);
          });
          if (results.isSuccess == false) {
            print('================================上传七牛云失败');
            // 设置不可发布
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
            if (postprogressModel.plannedSpeed < 1) {
              postprogressModel.plannedSpeed += percent / 7;
            } else {
              postprogressModel.plannedSpeed = 1;
            }
            // postprogressModel.plannedSpeed = percent;
            streamProgress.sink.add(postprogressModel);
            print("percent结束了:");
          });
          if (results.isSuccess == false) {
            print('================================上传七牛云失败');
            // 设置不可发布
            postprogressModel.plannedSpeed = -1.0;
            streamProgress.sink.add(postprogressModel);
            return;
          }
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
          Map<String, dynamic> feedModel = Map();
          feedModel = await publishFeed(
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
            postprogressModel.plannedSpeed = 1.0;
            streamProgress.sink.add(postprogressModel);
            // 延迟器:
            new Future.delayed(Duration(seconds: 3), () {
              // 重新赋值存入
              AppPrefs.setPublishFeedLocalInsertData(
                  "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}", null);
              //  清除图片路径
              print("文件路径：：：：${postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path}");
              print(
                  "文件路径：：：：${postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path.contains(AppConfig.getAppPublishDir())}");
              if (postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path
                  .contains(AppConfig.getAppPublishDir())) {
                _clearCache(AppConfig.getAppPublishDir());
              }
              // 清空发布model
              postprogressModel.postFeedModel = null;
              streamProgress.sink.add(postprogressModel);
              streamController.sink.add(0.0);
            });
            new Future.delayed(Duration(milliseconds: 4500), () {
              postprogressModel.plannedSpeed = 0.0;
            });
          } else {
            // 发布失败
            print('================================发布失败');
            postprogressModel.plannedSpeed = -1.0;
            postprogressModel.showPulishView = true;
            streamProgress.sink.add(postprogressModel);
          }
        }
      }
    }
  }

  void _clearCache(String path) async {
    try {
      //删除缓存目录
      Directory file = Directory(path);
      await delDir(file);
    } catch (e) {
      print(e);
      Toast.show('图片缓存失败', context);
    } finally {}
  }

  ///递归方式删除目录
  Future<Null> delDir(FileSystemEntity file) async {
    try {
      await file.stat().then((value) => print('========文件信息---------------$value'));
      print('=============path=============${file.path}');
      if (file is Directory) {
        print('=========================================if');
        final List<FileSystemEntity> children = file.listSync();
        if (children.isNotEmpty) {
          print('=====================${children.first.path}');
          for (final FileSystemEntity child in children) {
            await delDir(child);
          }
        }
      } else {
        //只清理子文件
        print('=========================================else');
        await file.delete(recursive: false);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("HomePage_____________________________________________build");
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        leading: CustomAppBarIconButton(
            svgName: AppIcon.nav_camera,
            iconColor: AppColor.black,
            onTap: () {
              print("${FluroRouter.appRouter.hashCode}");
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
        titleWidget: Container(
          width: 140,
          child: TabBar(
            controller: controller,
            tabs: [
              const Text("关注"),
              const Text(
                "推荐",
              )
            ],
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            labelColor: Colors.black,
            unselectedLabelStyle: const TextStyle(fontSize: 16),
            indicator: const RoundUnderlineTabIndicator(
              borderSide: const BorderSide(
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
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.linear,
                      height: snapshot.data,
                      child: Container(
                        height: snapshot.data,
                      ),
                    );
                  }),
              Expanded(
                child: TabBarView(
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
                        //  清除图片路径
                        if (postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path
                            .contains(AppConfig.getAppPublishDir())) {
                          _clearCache(AppConfig.getAppPublishDir());
                        }
                        // 清空发布model
                        postprogressModel.postFeedModel = null;
                        //还原进度条
                        postprogressModel.plannedSpeed = 0.0;
                        streamController.sink.add(0.0);
                        streamProgress.sink.add(postprogressModel);
                      },
                      // 重新发送
                      resendFeedChanged: () {
                        pulishFeed(getPublishFeedData(), isPostPageJump: false);
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
