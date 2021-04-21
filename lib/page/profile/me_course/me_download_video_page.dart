import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/download_video_course_db_helper.dart';
import 'package:mirror/data/dto/download_video_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/left_scroll/left_scroll_list_view.dart';

///我的课程-下载课程界面
class MeDownloadVideoCoursePage extends StatefulWidget {
  @override
  _MeDownloadVideoCoursePageState createState() => _MeDownloadVideoCoursePageState();
}

class _MeDownloadVideoCoursePageState extends State<MeDownloadVideoCoursePage> {
  LoadingStatus loadingStatus;
  List<DownloadCourseVideoDto> courseVideoModelList = <DownloadCourseVideoDto>[];
  Map<String, int> filePathCountMap = Map();

  String topText = "选择";
  bool isAllSelect = false;
  List<int> selectDeleteIndexList = <int>[];

  @override
  void initState() {
    super.initState();
    loadingStatus = LoadingStatus.STATUS_LOADING;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "下载课程",
        actions: [
          Visibility(
            visible: courseVideoModelList.length>0,
            child: CustomAppBarTextButton(topText, AppColor.textPrimary3, () {
              if (courseVideoModelList != null && courseVideoModelList.length > 0) {
                if (topText == "选择") {
                  topText = "取消";
                } else {
                  topText = "选择";
                }
                selectDeleteIndexList.clear();
                isAllSelect = false;
                if (mounted) {
                  setState(() {});
                }
              } else {
                ToastShow.show(msg: "暂无课程", context: context);
              }
            }),
          ),
        ],
      ),
      body: getBodyUi(),
    );
  }

  // 监听返回
  Future<bool> _requestPop() {
    if (topText == "选择") {
      return new Future.value(true);
    } else {
      topText = "选择";
      setState(() {});
      return new Future.value(false);
    }
  }

  Widget getBodyUi() {
    return judgeUi();
  }

  Widget judgeUi() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return Container(
        color: AppColor.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 100),
        child: UnconstrainedBox(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (loadingStatus == LoadingStatus.STATUS_COMPLETED &&
        courseVideoModelList != null &&
        courseVideoModelList.length > 0) {
      return haveDataUi();
    } else {
      return noHaveDataUi();
    }
  }

  //有数据ui
  Widget haveDataUi() {
    return Container(
      color: AppColor.white,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: getListView(),
            ),
          ),
          Visibility(
            visible: topText == "取消",
            child: bottomPlan(),
          ),
        ],
      ),
    );
  }

  //底部操作面板
  Widget bottomPlan() {
    return Column(
      children: [
        Container(
          height: 48,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                width: MediaQuery.of(context).size.width,
                height: 48,
                color: AppColor.white,
                child: Row(
                  children: [
                    AppIcon.getAppIcon(isAllSelect ? AppIcon.selection_selected : AppIcon.selection_not_selected, 24),
                    SizedBox(width: 12),
                    Text("全选", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
                    Expanded(child: SizedBox()),
                    Text("删除${selectDeleteIndexList.length < 1 ? "" : "(${selectDeleteIndexList.length})"}",
                        style: TextStyle(
                            fontSize: 16,
                            color: selectDeleteIndexList.length < 1
                                ? AppColor.mainRed.withOpacity(0.35)
                                : AppColor.mainRed)),
                  ],
                ),
              ),
              Positioned(
                child: GestureDetector(
                  child: Container(
                    color: Colors.transparent,
                    height: 48,
                    width: 100,
                  ),
                  onTap: () {
                    if (isAllSelect) {
                      selectDeleteIndexList.clear();
                      isAllSelect = false;
                    } else {
                      isAllSelect = true;
                      selectDeleteIndexList.clear();
                      for (int i = 0; i < courseVideoModelList.length; i++) {
                        selectDeleteIndexList.add(i);
                      }
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                left: 0,
              ),
              Positioned(
                child: GestureDetector(
                  child: Container(
                    color: Colors.transparent,
                    height: 48,
                    width: 100,
                  ),
                  onTap: () {
                    if (selectDeleteIndexList.length < 1) {
                      return;
                    }
                    showAppDialog(context,
                        title: isAllSelect ? "清除下载" : "删除确认",
                        info: isAllSelect ? "清除全部下载视频后，训练课程时需要重新下载" : "清除下载视频后，训练课程时需要重新下载",
                        cancel: AppDialogButton("取消", () {
                          print("点了取消");
                          return true;
                        }),
                        confirm: AppDialogButton("确定", () {
                          print("点击了删除");
                          deleteVideo();
                          return true;
                        }));
                  },
                ),
                right: 0,
              ),
            ],
          ),
        ),
        Container(
          height: ScreenUtil.instance.bottomBarHeight,
          width: MediaQuery.of(context).size.width,
          color: AppColor.white,
        ),
      ],
    );
  }

  //滑动列表
  Widget getListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: courseVideoModelList.length + 1,
      itemBuilder: (context, index) {
        if (index == courseVideoModelList.length) {
          return Container(
            height: ScreenUtil.instance.bottomBarHeight,
            color: AppColor.white,
          );
        } else {
          return getLeftDeleteUi(courseVideoModelList[index], index);
        }
      },
    );
  }

  //获取每一个带左滑删除btn的item
  Widget getLeftDeleteUi(DownloadCourseVideoDto courseVideoDto, int index) {
    if (topText == "取消") {
      return GestureDetector(
        child: getItem(courseVideoDto, index),
        onTap: () {
          onItemCLick(index);
        },
      );
    } else if (Application.platform == 0) {
      return GestureDetector(
        child: getItem(courseVideoDto, index),
        onTap: () {
          onItemCLick(index);
        },
        onLongPress: () {
          showAppDialog(context,
              title: "删除确认",
              info: "清除下载视频后，训练课程时需要重新下载",
              barrierDismissible: false,
              cancel: AppDialogButton("取消", () {
                print("点了取消");
                return true;
              }),
              confirm: AppDialogButton("确定", () {
                print("点击了确定");
                //点击了删除按钮
                selectDeleteIndexList.clear();
                selectDeleteIndexList.add(index);
                deleteVideo();
                return true;
              }));
        },
      );
    } else {
      return LeftScrollListView(
        itemKey: courseVideoDto.courseId.toString(),
        itemTag: "tag",
        itemIndex: index,
        itemChild: getItem(courseVideoDto, index),
        isDoubleDelete: true,
        onTap: () {
          onItemCLick(index);
        },
        onClickRightBtn: () {
          //点击了删除按钮
          selectDeleteIndexList.clear();
          selectDeleteIndexList.add(index);
          deleteVideo();
        },
      );
    }
  }

  //每一个item的点击事件
  void onItemCLick(int index) async {
    if (topText == "取消") {
      if (selectDeleteIndexList.contains(index)) {
        selectDeleteIndexList.remove(index);
      } else {
        selectDeleteIndexList.add(index);
      }
      isAllSelect = selectDeleteIndexList.length == courseVideoModelList.length;
      if (mounted) {
        setState(() {});
      }
    } else {
      //获取视频详情数据
      //加载数据
      Map<String, dynamic> model = await getVideoCourseDetail(courseId: courseVideoModelList[index].courseId);
      if (model["code"] != null && model["code"] == CODE_SUCCESS && model["dataMap"] != null) {
        LiveVideoModel videoModel = LiveVideoModel.fromJson(model["dataMap"]);
        AppRouter.navigateToVideoDetail(context, courseVideoModelList[index].courseId, videoModel: videoModel);
      } else if (model["code"] != null && model["code"] == CODE_NO_DATA) {
        ToastShow.show(msg: "该课程已失效!", context: context);
      } else {
        ToastShow.show(msg: "请求课程失败!", context: context);
      }
    }
  }

  //每一个item
  Widget getItem(DownloadCourseVideoDto courseVideoDto, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColor.transparent,
      child: Column(
        children: [
          Row(
            children: [
              Visibility(
                visible: topText == "取消",
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  child: AppIcon.getAppIcon(
                      selectDeleteIndexList.contains(index)
                          ? AppIcon.selection_selected
                          : AppIcon.selection_not_selected,
                      24),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18),
                      Text(
                        courseVideoDto.courseName,
                        style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        "${getVideoSize(courseVideoDto)}M",
                        style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                      ),
                      SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 40),
              AppIcon.getAppIcon(AppIcon.arrow_right_18, 18, color: AppColor.textHint),
            ],
          ),
          Container(
            color: AppColor.bgWhite,
            height: 1,
          ),
        ],
      ),
    );
  }

  //获取视频的大小
  double getVideoSize(DownloadCourseVideoDto courseVideoDto) {
    double size = 0.0;
    if (courseVideoDto.courseFilePaths == null || courseVideoDto.courseFilePaths.length < 1) {
      return size;
    }
    for (String filePath in courseVideoDto.courseFilePaths) {
      if (File(filePath).existsSync()) {
        size += File(filePath).lengthSync();
      }
    }
    return formatData(size ~/ 1024 / 1024);
  }

  double formatData(double value) {
    return ((value * 100) ~/ 1) / 100;
  }

  //没有数据的ui
  Widget noHaveDataUi() {
    return Container(
      color: AppColor.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/png/default_no_data.png", width: 224, height: 224, fit: BoxFit.cover),
          SizedBox(height: 16),
          Text("您还没有下载过任何视频", style: TextStyle(fontSize: 14, color: AppColor.textSecondary)),
        ],
      ),
    );
  }

  //加载数据
  void loadData() async {
    courseVideoModelList = await DownloadVideoCourseDBHelper().queryAll();
    if (courseVideoModelList != null) {
      filePathCountMap.clear();
      for (DownloadCourseVideoDto dto in courseVideoModelList) {
        if (dto.courseUrls != null && dto.courseUrls.length > 0) {
          for (String url in dto.courseUrls) {
            if (filePathCountMap[StringUtil.generateMd5(url)] != null) {
              filePathCountMap[StringUtil.generateMd5(url)] = filePathCountMap[StringUtil.generateMd5(url)] + 1;
            } else {
              filePathCountMap[StringUtil.generateMd5(url)] = 1;
            }
          }
        }
      }
    }
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
    if (mounted) {
      setState(() {});
    }
  }

  void deleteVideo() async {
    if (selectDeleteIndexList.length < 1) {
      isAllSelect = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    for (int index in selectDeleteIndexList) {
      for (String url in courseVideoModelList[index].courseUrls) {
        if (filePathCountMap[StringUtil.generateMd5(url)] == null ||
            filePathCountMap[StringUtil.generateMd5(url)] == 1) {
          await FileUtil().removeDownloadTask(url);
        } else {
          filePathCountMap[StringUtil.generateMd5(url)] = filePathCountMap[StringUtil.generateMd5(url)] - 1;
        }
        await DownloadVideoCourseDBHelper().remove(courseVideoModelList[index]);
      }
    }

    loadData();
  }

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return false;
    } else {
      return true;
    }
  }
}
