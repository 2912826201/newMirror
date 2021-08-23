import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
import 'package:provider/provider.dart';

import '../release_page.dart';

// @联系人列表
class AtList extends StatefulWidget {
  AtList({this.controller});

  TextEditingController controller;

  @override
  AtListState createState() => AtListState();
}

class AtListState extends State<AtList> {
  List<BuddyModel> followList = [];

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  /*
  关注列表字段
   */
  // 请求下一页
  int lastTime;

  // 是否存在下页
  int hasNext;

  // 数据加载页数
  int dataPage = 1;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

// /*
// 搜索全局的字段
//  */

  // 数据加载页数
  int searchDataPage = 1;

  // Token can be shared with different requests.
  CancelToken token = CancelToken();

  @override
  void dispose() {
    _scrollController.dispose();
    // 取消网络请求
    cancelRequests(token: token);
    super.dispose();
  }

  @override
  void initState() {
    requestBothFollowList();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ReleaseFeedInputNotifier>().setAtScrollController(_scrollController);
      }
    });
    _scrollController.addListener(() {
      // 搜索全局用户关键字
      String searchUserStr = context.read<ReleaseFeedInputNotifier>().atSearchStr;
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (searchUserStr.isNotEmpty) {
          searchDataPage += 1;
          requestSearchFollowList(searchUserStr);
        } else {
          dataPage += 1;
          requestBothFollowList();
        }
      }
    });
    super.initState();
  }

  // 请求搜索关注用户
  // 此处调用都为第二页及以上数据第一页在输入框回调内调用
  requestSearchFollowList(String keyWork) async {
    List<BuddyModel> searchFollowList = [];
    if (context.read<ReleaseFeedInputNotifier>().searchLoadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (context.read<ReleaseFeedInputNotifier>().searchHasNext == 0) {
      context.read<ReleaseFeedInputNotifier>().searchLoadText = "已加载全部好友";
      context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
      print("返回不请求搜索数据");
      return;
    }
    SearchUserModel model = await ProfileSearchUser(keyWork, 20,
        lastTime: context.read<ReleaseFeedInputNotifier>().searchLastTime, token: token);
    if (model != null) {
      if (searchDataPage > 1 && context.read<ReleaseFeedInputNotifier>().searchLastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            BuddyModel followModel = BuddyModel();
            followModel.nickName = v.nickName + " ";
            followModel.uid = v.uid;
            followModel.avatarUri = v.avatarUri;
            searchFollowList.add(followModel);
          });
          context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_IDEL;
          context.read<ReleaseFeedInputNotifier>().searchLoadText = "加载中...";
        }
      }
      // 记录搜索状态
      context.read<ReleaseFeedInputNotifier>().searchLastTime = model.lastTime;
      context.read<ReleaseFeedInputNotifier>().searchHasNext = model.hasNext;
    }
    if (mounted) {
      setState(() {});
      // 把在输入框回调内的第一页数据插入
      searchFollowList.insertAll(0, context.read<ReleaseFeedInputNotifier>().followList);
      // 获取关注@数据
      List<BuddyModel> followList = [];
      context.read<ReleaseFeedInputNotifier>().backupFollowList.forEach((v) {
        if (v.nickName.contains(keyWork)) {
          followList.add(v);
        }
      });
      // 筛选全局的@用户数据
      List<BuddyModel> filterFollowList = followModelarrayDate(searchFollowList, followList);
      filterFollowList.insertAll(0, followList);
      context.read<ReleaseFeedInputNotifier>().setFollowList(filterFollowList);
    }
  }

  // 请求好友列表
  requestBothFollowList() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (hasNext == 0) {
      setState(() {
        loadText = "已加载全部好友";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
        print("返回不请求数据");
      });
      return;
    }
    BuddyListModel model = await GetFollowList(20, lastTime: lastTime, token: token);
    if (model != null) {
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          print(model.list.length);
          followList = model.list;
          followList.forEach((element) {
            element.nickName = element.nickName + " ";
          });
          if (model.hasNext == 0) {
            loadText = "";
            loadStatus = LoadingStatus.STATUS_COMPLETED;
          }
        }
      } else if (dataPage > 1 && lastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            v.nickName = v.nickName + " ";
          });
          followList.addAll(model.list);
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        }
      }
      lastTime = model.lastTime;
      hasNext = model.hasNext;
    }
    if (mounted) {
      // 存入@显示数据
      context.read<ReleaseFeedInputNotifier>().setFollowList(followList);
      // 搜索时会替换@显示数据，备份一份数据
      context.read<ReleaseFeedInputNotifier>().setBackupFollowList(followList);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BuddyModel> list = context.watch<ReleaseFeedInputNotifier>().followList;
    // 搜索全局用户关键字
    String searchUserStr = context.watch<ReleaseFeedInputNotifier>().atSearchStr;
    return list.isNotEmpty
        ? MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return LoadingView(
                    loadText:
                        searchUserStr.isNotEmpty ? context.read<ReleaseFeedInputNotifier>().searchLoadText : loadText,
                    loadStatus: searchUserStr.isNotEmpty
                        ? context.read<ReleaseFeedInputNotifier>().searchLoadStatus
                        : loadStatus,
                  );
                } else if (index == list.length + 1) {
                  return Container();
                } else {
                  return GestureDetector(
                    // 点击空白区域响应事件
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.read<ReleaseFeedInputNotifier>().setClickAtUser(true);
                      // At的文字长度
                      int AtLength = list[index].nickName.length;
                      // 获取输入框内的规则
                      var rules = context.read<ReleaseFeedInputNotifier>().rules;
                      // 检测是否添加过
                      if (rules.isNotEmpty) {
                        for (Rule rule in rules) {
                          if (rule.id == list[index].uid && rule.isAt == true) {
                            ToastShow.show(msg: "你已经@过Ta啦！", context: context, gravity: Toast.CENTER);
                            return;
                          }
                        }
                      }
                      // 获取@的光标
                      int atIndex = context.read<ReleaseFeedInputNotifier>().atCursorIndex;
                      // 获取实时搜索文本
                      String searchStr = context.read<ReleaseFeedInputNotifier>().atSearchStr;
                      // @前的文字
                      String atBeforeStr = widget.controller.text.substring(0, atIndex);
                      // @后的文字
                      String atRearStr = "";
                      print(searchStr);
                      print("controller.text:${widget.controller.text}");
                      print("atBeforeStr$atBeforeStr");
                      if (searchStr != "" || searchStr.isNotEmpty) {
                        print("atIndex:$atIndex");
                        print("searchStr:$searchStr");
                        print("controller.text:${widget.controller.text}");
                        atRearStr =
                            widget.controller.text.substring(atIndex + searchStr.length, widget.controller.text.length);
                        print("atRearStr:$atRearStr");
                      } else {
                        atRearStr = widget.controller.text.substring(atIndex, widget.controller.text.length);
                      }

                      // 拼接修改输入框的值
                      widget.controller.text = atBeforeStr + list[index].nickName + atRearStr;
                      // 设置光标
                      if (!Platform.isIOS) {
                        var setCursor = TextSelection(
                          baseOffset: widget.controller.text.length,
                          extentOffset: widget.controller.text.length,
                        );
                        print("设置光标${setCursor}");
                        widget.controller.selection = setCursor;
                      }

                      print("controller.text:${widget.controller.text}");
                      context.read<ReleaseFeedInputNotifier>().getInputText(widget.controller.text);
                      // 这是替换输入的文本修改后面输入的@的规则
                      if (searchStr != "" || searchStr.isNotEmpty) {
                        int oldLength = searchStr.length;
                        int newLength = list[index].nickName.length;
                        int oldStartIndex = atIndex;
                        int diffLength = newLength - oldLength;
                        for (int i = 0; i < rules.length; i++) {
                          if (rules[i].startIndex >= oldStartIndex) {
                            int newStartIndex = rules[i].startIndex + diffLength;
                            int newEndIndex = rules[i].endIndex + diffLength;
                            rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
                          }
                        }
                      }
                      // 此时为了解决后输入的@切换光标到之前输入的@或者#前方，更新之前输入@和#的索引。
                      for (int i = 0; i < rules.length; i++) {
                        // 当最新输入框内的文本对应不上之前的值时。
                        if (rules[i].params !=
                            widget.controller.text.substring(rules[i].startIndex, rules[i].endIndex)) {
                          print("进入");
                          print(rules[i]);
                          rules[i] = Rule(rules[i].startIndex + AtLength, rules[i].endIndex + AtLength, rules[i].params,
                              rules[i].clickIndex, rules[i].isAt, rules[i].id);
                          print(rules[i]);
                        }
                      }
                      // 存储规则
                      context.read<ReleaseFeedInputNotifier>().addRules(Rule(
                          atIndex - 1, atIndex + AtLength, "@" + list[index].nickName, index, true, list[index].uid));
                      print('----------------------关闭视图开始');
                      context.read<ReleaseFeedInputNotifier>().setAtSearchStr("");
                      // 关闭视图
                      context.read<ReleaseFeedInputNotifier>().changeCallback("");
                      print('----------------------关闭视图结束');
                    },
                    child: Container(
                      height: 48,
                      width: ScreenUtil.instance.width,
                      margin: const EdgeInsets.only(bottom: 10, left: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                              child: CachedNetworkImage(
                            width: 38,
                            height: 38,
                            /// imageUrl的淡入动画的持续时间。
                            // fadeInDuration: Duration(milliseconds: 0),
                            imageUrl: FileUtil.getSmallImage(list[index].avatarUri) ?? "",
                            fit: BoxFit.cover,
                            // 调整磁盘缓存中图像大小
                            // maxHeightDiskCache: 150,
                            // maxWidthDiskCache: 150,
                            // 指定缓存宽高
                            memCacheWidth: 150,
                            memCacheHeight: 150,
                            placeholder: (context, url) => Container(
                              color: AppColor.bgWhite,
                            ),
                            errorWidget: (context, url, e) {
                              return Container(
                                color: AppColor.bgWhite,
                              );
                            },
                          )),
                          const SizedBox(width: 12),
                          Text(
                            list[index].nickName,
                            // followList[index].nickName,
                            style: AppStyle.whiteRegular16,
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
              itemCount: list.length + 1,
            ))
        : Container();
  }
}
