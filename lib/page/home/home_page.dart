import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:connectivity/connectivity.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide TabBar, TabBarView;
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/jump_app_page_model.dart';
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
import 'package:mirror/widget/banner_view/page_scroll_physics.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/customize_tab_bar/customize_tab_bar.dart' as Custom;
import 'package:mirror/widget/customize_tab_bar/customiize_tab_bar_view.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  HomePageState createState() => HomePageState();
}

GlobalKey<HomePageState> homePageKey = GlobalKey();

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //????????????
  // taBar???TabBarView?????????
  TabController controller;

  // ????????????model
  PostprogressModel postprogressModel = PostprogressModel();
  bool publishFeedOver = true;
  double animalHeight = 0;
  StreamSubscription<ConnectivityResult> connectivityListener;
  StreamController<double> streamController = StreamController<double>();

  // ????????????
  StreamController<PostprogressModel> streamProgress = StreamController<PostprogressModel>();

  //  tabBar?????????
  // StreamController<int> streamTabBar = StreamController<int>();

  @override
  void dispose() {
    controller.dispose();
    print("??????homePage");
    // EventBus.getDefault().unRegister(registerName: EVENTBUS_GET_FAILURE_MODEL, pageName: EVENTBUS_HOME_PAGE);
    // EventBus.getDefault().unRegister(registerName: EVENTBUS_POST_PORGRESS_VIEW, pageName: EVENTBUS_HOME_PAGE);
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    print("homePage?????????");
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
    // ???????????????????????????????????????model??????
    EventBus.init()
        .registerNoParameter(postModelAssignment, EVENTBUS_HOME_PAGE, registerName: EVENTBUS_GET_FAILURE_MODEL);
    // ???????????????????????????model??????
    EventBus.init().registerSingleParameter(pulishFeed, EVENTBUS_HOME_PAGE, registerName: EVENTBUS_POST_PORGRESS_VIEW);
    EventBus.init().registerSingleParameter(_jumpPage, EVENTBUS_HOME_PAGE, registerName: MAIN_PAGE_JUMP_PAGE);
    _initConnectivity();
    // controller.addListener(() {
    //   Application.feedBetterPlayerControllerList.clear();
    // });
  }

  // ?????????????????????model??????
  postModelAssignment() {
    if (AppPrefs.getPublishFeedLocalInsertData(
            "${Application.postFailurekey}_${context.read<TokenNotifier>().token.uid}") !=
        null) {
      print("HomePageState??????????????????");
      // ????????????????????????
      postprogressModel = PostprogressModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
          "${Application.postFailurekey}_${context.read<TokenNotifier>().token.uid}")));
      print("??????????????????postprogressModel???${postprogressModel.toString()}");
      if (postprogressModel != null && postprogressModel.postFeedModel != null) {
        print("1111111111111");
        postprogressModel.postFeedModel.selectedMediaFiles.list.forEach((v) {
          // ???????????????????????????????????????????????????????????????????????????????????????????????????
          try {
            v.file = File(v.filePath);
          } catch (error) {
            // ???????????????????????????
            // ??????????????????
            print("????????????_______________________");
            AppPrefs.removePublishFeed("${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}");
            //  ??????????????????
            if (postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path
                .contains(AppConfig.getAppPublishDir())) {
              _clearCache(AppConfig.getAppPublishDir());
            }
            // ????????????model
            postprogressModel.postFeedModel = null;
            //???????????????
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

  // ????????????????????????
  PostprogressModel getPublishFeedData() {
    postprogressModel = PostprogressModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
        "${Application.postFailurekey}_${context.read<TokenNotifier>().token.uid}")));
    if (postprogressModel != null && postprogressModel.postFeedModel != null) {
      postprogressModel.postFeedModel.selectedMediaFiles.list.forEach((v) {
        v.file = File(v.filePath);
      });
      postprogressModel.showPulishView = true;
      print("??????????????????postprogressModel???${postprogressModel.toString()}");
      streamProgress.sink.add(postprogressModel);
    }
    return postprogressModel;
  }

  //????????????????????????
  _initConnectivity() async {
    if (context.read<TokenNotifier>().token != null) {
      connectivityListener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (context.read<TokenNotifier>().isLoggedIn) {
          if (AppPrefs.getPublishFeedLocalInsertData(
                  "${Application.postFailurekey}_${context.read<TokenNotifier>().token.uid}") !=
              null) {
            if (result == ConnectivityResult.mobile) {
              print("?????????");
              pulishFeed(getPublishFeedData(), isPostPageJump: false);
            } else if (result == ConnectivityResult.wifi) {
              print("wifi");
              pulishFeed(getPublishFeedData(), isPostPageJump: false);
            } else {
              print("?????????");
            }
          }
        }
      });
    }
  }

  // ????????????
  pulishFeed(PostprogressModel postprogress, {isPostPageJump = true}) async {
    print("??????????????????????????????");
    if (!publishFeedOver) {
      print('-------------------??????????????????????????????');
      return;
    }
    publishFeedOver = false;
    if (mounted) {
      postprogressModel = postprogress;
      // ????????????????????????????????????
      print("???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????$isPostPageJump");
      if (isPostPageJump) {
        // ?????????main_page???
        Application.ifPageController.index = Application.ifPageController.length - 1;
        // ??????????????????
        if (controller != null && controller.index != 0) {
          controller.index = 0;
        }
        streamController.sink.add(60.0);
        // ?????????????????????
        if (attentionKey.currentState != null) {
          attentionKey.currentState.backToTheTop();
        }
        // ???????????????UI
        streamProgress.sink.add(postprogressModel);
      }
      // ????????????
      for (MediaFileModel model in postprogressModel.postFeedModel.selectedMediaFiles.list) {
        // ????????????
        var _percent = 0.0;
        if (model.croppedImage != null && model.croppedImageData == null) {
          ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
          Uint8List picBytes = byteData.buffer.asUint8List();
          model.croppedImageData = picBytes;
          _percent += 1 / postprogressModel.postFeedModel.selectedMediaFiles.list.length;
        } else {
          _percent = 1;
        }
        if (postprogressModel.postFeedModel.selectedMediaFiles.type == mediaTypeKeyImage) {
          postprogressModel.plannedSpeed = _percent / 3;
          streamProgress.sink.add(postprogressModel);
        }
      }
      // ?????????
      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
      int i = 0;
      // ??????
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

      // ????????????
      if (AppPrefs.getPublishFeedLocalInsertData(
              "${Application.postFailurekey}_${context.read<TokenNotifier>().token.uid}") ==
          null) {
        AppPrefs.setPublishFeedLocalInsertData(
            "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}",
            jsonEncode(postprogressModel.toJson()));
      }
      List<File> fileList = [];
      UploadResults results;
      List<PicUrlsModel> picUrls = [];
      List<VideosModel> videos = [];
      print("??????1111111111111111111");
      print("??????2222222222222222222");
      if (postprogressModel != null) {
        PostFeedModel postModel = postprogressModel.postFeedModel;
        print(postModel.atUsersModel);
        print("???????????????");
        print(postModel.selectedMediaFiles.type == mediaTypeKeyImage);
        // ????????????
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
            print('================================?????????????????????');
            // Note ??????????????????????????????????????????????????????
            ToastShow.show(msg: "???????????????????????????", context: context);
            // ??????????????????
            postprogressModel.plannedSpeed = -1.0;
            streamProgress.sink.add(postprogressModel);
            publishFeedOver = true;
            return;
          }
          for (int i = 0; i < results.resultMap.length; i++) {
            print("????????????????????????$i");
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
            print("percent???${percent}");
            if (postprogressModel.plannedSpeed < percent) {
              postprogressModel.plannedSpeed = percent;
              // postprogressModel.plannedSpeed = percent;
              streamProgress.sink.add(postprogressModel);
            }
            print("percent?????????:");
          });
          if (results.isSuccess == false) {
            print('================================?????????????????????');
            // Note ??????????????????????????????????????????????????????
            ToastShow.show(msg: "???????????????????????????", context: context);
            // ??????????????????
            postprogressModel.plannedSpeed = -1.0;
            streamProgress.sink.add(postprogressModel);
            publishFeedOver = true;
            return;
          }
          print("resultsErroe:${results.isSuccess}");
          for (int i = 0; i < results.resultMap.length; i++) {
            print("??????????????????????????????$i");
            UploadResultModel model = results.resultMap.values.elementAt(i);
            videos[i].url = model.url;
            videos[i].coverUrl = FileUtil.getVideoFirstPhoto(model.url);
          }
        }
        print("????????????????????????${postModel.toString()}");
        if (mounted) {
          Map<String, dynamic> feedModel = Map();
          print(
              '--------jsonEncode(postModel.topics)--------jsonEncode(postModel.topics)---------${jsonEncode(postModel.topics)}');
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
              topics: jsonEncode(postModel.topics),
              videoCourseId: postModel.videoCourseId,
              activityId: postModel.activityId);
          print("???????????????????????????feedModel$feedModel");

          if (feedModel != null) {
            // ????????????
            // ??????????????????
            attentionKey.currentState.insertData(HomeFeedModel.fromJson(feedModel));
            // ??????????????????
            AppPrefs.removePublishFeed("${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}");
            postprogressModel.plannedSpeed = 1.0;
            streamProgress.sink.add(postprogressModel);
            // ?????????:
            new Future.delayed(Duration(seconds: 3), () {
              //  ??????????????????
              if (postprogressModel != null &&
                  postprogressModel.postFeedModel != null &&
                  postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path
                      .contains(AppConfig.getAppPublishDir())) {
                _clearCache(AppConfig.getAppPublishDir());
              }
              // ????????????model
              postprogressModel.postFeedModel = null;
              streamProgress.sink.add(postprogressModel);
              streamController.sink.add(0.0);
            });
            new Future.delayed(Duration(milliseconds: 4500), () {
              postprogressModel.plannedSpeed = 0.0;
            });
          } else {
            // Note ??????????????????????????????????????????????????????
            ToastShow.show(msg: "??????????????????", context: context);
            // ????????????
            print('================================????????????');
            postprogressModel.plannedSpeed = -1.0;
            postprogressModel.showPulishView = true;
            streamProgress.sink.add(postprogressModel);
          }
          publishFeedOver = true;
        }
      }
    }
  }

  void _clearCache(String path) async {
    try {
      //??????????????????
      Directory file = Directory(path);
      await delDir(file);
    } catch (e) {
      print(e);
      Toast.show('??????????????????', context);
    } finally {}
  }

  ///????????????????????????
  Future<Null> delDir(FileSystemEntity file) async {
    try {
      await file.stat().then((value) => print('========????????????---------------$value'));
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
        //??????????????????
        print('=========================================else');
        await file.delete(recursive: false);
      }
    } catch (e) {
      print(e);
    }
  }

  // ?????????????????????
  subpageRefresh({bool isBottomNavigationBar = false}) {
    if (controller.index == 0 && attentionKey.currentState != null) {
      attentionKey.currentState.onDoubleTap(isBottomNavigationBar);
    } else if (controller.index == 1 && recommendKey.currentState != null) {
      recommendKey.currentState.againLoginReplaceLayout(isBottomNavigationBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("HomePage_____________________________________________build");
    return
        // Scaffold(
        // backgroundColor: AppColor.white,
        // appBar: CustomAppBar(
        //   leading: CustomAppBarIconButton(
        //       svgName: AppIcon.nav_camera,
        //       iconColor: AppColor.black,
        //       onTap: () {
        //         print("${FluroRouter.appRouter.hashCode}");
        //         if (postprogressModel != null && postprogressModel.postFeedModel != null) {
        //           if (postprogressModel.plannedSpeed != -1) {
        //             ToastShow.show(msg: "???????????????????????????????????????", context: context, gravity: Toast.CENTER);
        //           } else {
        //             ToastShow.show(msg: "??????????????????", context: context, gravity: Toast.CENTER);
        //           }
        //         } else {
        //           // ???????????????????????????????????????
        //           if (context.read<TokenNotifier>().isLoggedIn) {
        //             // ?????????????????????
        //             AppRouter.navigateToMediaPickerPage(
        //                 context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
        //                 publishMode: 1);
        //             // Application.ifPageController.animateTo(0);
        //           } else {
        //             AppRouter.navigateToLoginPage(context);
        //           }
        //         }
        //       }),
        //   titleWidget: Container(
        //       width: 140,
        //       color: AppColor.white,
        //       child: Custom.TabBar(
        //         controller: controller,
        //         tabs: [
        //           Text(
        //             "??????",
        //           ),
        //           Text(
        //             "??????",
        //           )
        //         ],
        //         indicatorSize: Custom.TabBarIndicatorSize.label,
        //         labelStyle: const TextStyle(
        //           fontSize: 17.5,
        //           fontWeight: FontWeight.w600,
        //         ),
        //         labelColor: Colors.black,
        //         unselectedLabelStyle: const TextStyle(fontSize: 15.5),
        //         indicator: const RoundUnderlineTabIndicator(
        //           borderSide: const BorderSide(
        //             width: 3,
        //             color: Color.fromRGBO(253, 137, 140, 1),
        //           ),
        //           insets: EdgeInsets.only(bottom: -6),
        //           wantWidth: 16,
        //         ),
        //         onDoubleTap: (index) {
        //           if (controller.index == index) {
        //             subpageRefresh();
        //           } else {
        //             controller.animateTo(index);
        //           }
        //         },
        //       )),
        //   actions: [
        //     CustomAppBarIconButton(
        //         svgName: AppIcon.nav_search,
        //         iconColor: AppColor.black,
        //         onTap: () {
        //           AppRouter.navigateSearchPage(context);
        //         }),
        //   ],
        // ),
        // body:
        Column(
      children: [
        Container(
          width: ScreenUtil.instance.width,
          height: CustomAppBar.appBarHeight,
          margin: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
          // color: AppColor.mainRed,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: CustomAppBar.appBarHorizontalPadding,
              ),
              CustomAppBarIconButton(
                  svgName: AppIcon.nav_camera,
                  iconColor: AppColor.white,
                  onTap: () {
                    print("${FluroRouter.appRouter.hashCode}");
                    if (postprogressModel != null && postprogressModel.postFeedModel != null) {
                      if (postprogressModel.plannedSpeed != -1) {
                        ToastShow.show(msg: "???????????????????????????????????????", context: context, gravity: Toast.CENTER);
                      } else {
                        ToastShow.show(msg: "??????????????????", context: context, gravity: Toast.CENTER);
                      }
                    } else {
                      // ???????????????????????????????????????
                      if (context.read<TokenNotifier>().isLoggedIn) {
                        // ?????????????????????
                        AppRouter.navigateToMediaPickerPage(
                            context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
                            publishMode: 1);
                        // Application.ifPageController.animateTo(0);
                      } else {
                        AppRouter.navigateToLoginPage(context);
                      }
                    }
                  }),
              Spacer(),
              Container(
                  width: 140,
                  color: AppColor.mainBlack,
                  child: Custom.TabBar(
                    controller: controller,
                    tabs: [
                      Text(
                        "??????",
                      ),
                      Text(
                        "??????",
                      )
                    ],
                    indicatorSize: Custom.TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                    ),
                    labelColor: AppColor.white,
                    unselectedLabelStyle: const TextStyle(fontSize: 15.5),
                    indicator: const RoundUnderlineTabIndicator(
                      borderSide: const BorderSide(
                        width: 3,
                        color: AppColor.mainYellow,
                        // Color.fromRGBO(253, 137, 140, 1),
                      ),
                      insets: EdgeInsets.only(bottom: -6),
                      wantWidth: 16,
                    ),
                    onDoubleTap: (index) {
                      if (controller.index == index) {
                        subpageRefresh();
                      } else {
                        controller.animateTo(index);
                      }
                    },
                  )),
              Spacer(),
              CustomAppBarIconButton(
                  svgName: AppIcon.nav_search,
                  iconColor: AppColor.white,
                  onTap: () {
                    AppRouter.navigateSearchPage(context);
                  }),
              SizedBox(
                width: CustomAppBar.appBarHorizontalPadding,
              ),
            ],
          ),
        ),
        Expanded(
            child: Stack(
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
                    physics: context.watch<FeedMapNotifier>().value.isDropDown
                        ? ClampingScrollPhysics()
                        : NeverScrollableScrollPhysics(),
                    children: [
                      AttentionPage(
                        key: attentionKey,
                      ),
                      RecommendPage(
                        key: recommendKey,
                      ),
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
                          // ??????????????????
                          AppPrefs.removePublishFeed(
                              "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}");
                          //  ??????????????????
                          if (postprogressModel != null &&
                              postprogressModel.postFeedModel != null &&
                              postprogressModel.postFeedModel.selectedMediaFiles.list.first.file.path
                                  .contains(AppConfig.getAppPublishDir())) {
                            _clearCache(AppConfig.getAppPublishDir());
                          }
                          // ????????????model
                          postprogressModel.postFeedModel = null;
                          streamController.sink.add(0.0);
                          streamProgress.sink.add(postprogressModel);
                          new Future.delayed(Duration(milliseconds: 1500), () {
                            //???????????????
                            postprogressModel.plannedSpeed = 0.0;
                          });
                        },
                        // ????????????
                        resendFeedChanged: () {
                          pulishFeed(getPublishFeedData(), isPostPageJump: false);
                        },
                      );
                    })),
            //     )
            // : Container(),
          ],
        ))
      ],
    );

    // );
    // });
  }

  _jumpPage(int jumpAppPageModel) {
    int pagePosition = -1;
    switch (jumpAppPageModel) {
      case JumpAppPageModel.AttentionPage: //?????????
        pagePosition = 0;
        break;
      case JumpAppPageModel.RecommendPage: //?????????
        pagePosition = 1;
        break;
      default:
        pagePosition = -1;
        break;
    }
    if (pagePosition >= 0) {
      if (controller != null) {
        controller.animateTo(pagePosition);
      }
    }
  }
}
