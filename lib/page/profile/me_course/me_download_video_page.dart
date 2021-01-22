import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/download_video_course_db_helper.dart';
import 'package:mirror/data/dto/download_video_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/dialog.dart';

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
      appBar: AppBar(
        title: Text("下载课程"),
        centerTitle: true,
        actions: [
          GestureDetector(
            child: Container(
              height: double.infinity,
              color: AppColor.transparent,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                child: Text(
                  topText,
                  style: TextStyle(fontSize: 16, color: AppColor.textPrimary3),
                ),
              ),
            ),
            onTap: () {
              if (topText == "选择") {
                topText = "取消";
              } else {
                topText = "选择";
              }
              selectDeleteIndexList.clear();
              isAllSelect = false;
              setState(() {});
            },
          )
        ],
      ),
      body: getBodyUi(),
    );
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
    return Container(
      height: 48,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: isAllSelect ? AppColor.mainRed : AppColor.white,
                    border: Border.all(width: isAllSelect ? 0 : 1, color: AppColor.textHint),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                SizedBox(width: 12),
                Text("全选", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                Expanded(child: SizedBox()),
                Text("删除${selectDeleteIndexList.length < 1 ? "" : "(${selectDeleteIndexList.length})"}",
                    style: TextStyle(
                        fontSize: 16,
                        color:
                            selectDeleteIndexList.length < 1 ? AppColor.mainRed.withOpacity(0.35) : AppColor.mainRed)),
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
                setState(() {});
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
                    title: "确认删除",
                    info: "你确定删除这些课程吗？",
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
    );
  }

  //滑动列表
  Widget getListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: courseVideoModelList.length,
      itemBuilder: (context, index) {
        return Material(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            color: AppColor.white,
            child: new InkWell(
              child: getItem(courseVideoModelList[index], index),
              splashColor: AppColor.textHint,
              onTap: () {
                if (topText == "取消") {
                  if (selectDeleteIndexList.contains(index)) {
                    selectDeleteIndexList.remove(index);
                  } else {
                    selectDeleteIndexList.add(index);
                  }
                  isAllSelect = selectDeleteIndexList.length == courseVideoModelList.length;
                  setState(() {});
                } else {
                  AppRouter.navigateToVideoDetail(context, courseVideoModelList[index].courseId);
                }
              },
            ));
      },
    );
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
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1, right: 12),
                  decoration: BoxDecoration(
                    color: selectDeleteIndexList.contains(index) ? AppColor.mainRed : AppColor.white,
                    border: Border.all(width: selectDeleteIndexList.contains(index) ? 0 : 1, color: AppColor.textHint),
                    borderRadius: BorderRadius.circular(9),
                  ),
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
                        style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold),
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
              Icon(Icons.chevron_right, size: 18, color: AppColor.textHint),
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
          Image.asset("images/test/bg.png", width: 224, height: 224, fit: BoxFit.cover),
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
    setState(() {});
  }

  void deleteVideo() async {
    if (selectDeleteIndexList.length < 1) {
      isAllSelect = false;
      setState(() {});
      return;
    }

    for (int index in selectDeleteIndexList) {
      for (String url in courseVideoModelList[index].courseUrls) {
        if (filePathCountMap[StringUtil.generateMd5(url)] == null ||
            filePathCountMap[StringUtil.generateMd5(url)] == 1) {
          await FileUtil().removeDownloadTask(url);
        }
        await DownloadVideoCourseDBHelper().remove(courseVideoModelList[index]);
      }
    }

    loadData();
  }
}
