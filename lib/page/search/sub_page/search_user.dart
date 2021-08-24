import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
class SearchUser extends StatefulWidget {
  final String text;
  final double width;
  final FocusNode focusNode;
  final TextEditingController textController;
  final TabController controller;

  SearchUser({this.text, this.width, this.textController, this.focusNode, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _SearchUserState();
  }
}

class _SearchUserState extends State<SearchUser> with AutomaticKeepAliveClientMixin {
  List<UserModel> modelList = [];
  bool isFollow = false;
  int _lastTime;
  int hashNext;
  int dataPage = 1;
  bool noData = false;
  bool refreshOver = false;
  String lastString;
  RefreshController _refreshController = new RefreshController();
  String defaultImage = DefaultImage.nodata;
  ScrollController scrollController = ScrollController();

  GlobalKey globalKey = GlobalKey();
  bool showNoMore = true;
  List<int> tabBarIndexList;

// Token can be shared with different requests.
  CancelToken token = CancelToken();

  @override
  void dispose() {
    // TODO: implement dispose
    // 取消网络请求
    cancelRequests(token: token);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    lastString = widget.text;
    _getSearchUser(lastString);
    int controllerIndex = 3;
    if (AppConfig.needShowTraining) {
      controllerIndex = 4;
    }
    widget.controller.addListener(() {
      print("widget.tabBarIndexList话题:::${Application.tabBarIndexList}");
      // 切换tab监听在当前tarBarView下
      if (widget.controller.index == controllerIndex) {
        print(Application.tabBarIndexList.contains(controllerIndex));
        // 初始化过的文本变化
        if (Application.tabBarIndexList.contains(controllerIndex)) {
          print("lastString::::$lastString");
          print("widget.keyWord::::${widget.textController.text}");
          if (lastString != widget.textController.text) {
            dataPage = 1;
            _lastTime = null;
            lastString = widget.textController.text;
            _getSearchUser(lastString);
          }
        } else {
          Application.tabBarIndexList.add(controllerIndex);
        }
      }
    });
    widget.textController.addListener(() {
      if (widget.controller.index == controllerIndex) {
        if (lastString != widget.textController.text) {
          if (refreshOver) {
            dataPage = 1;
            _lastTime = null;
            lastString = widget.textController.text;
            _getSearchUser(lastString);
          }
        }
      }
    });
    // Build完成第一帧绘制完成回调
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("关注页Build完成第一帧绘制完成回调");
      PrimaryScrollController.of(context).addListener(() {
        print('-------------------11111111111111111111111111111111111');
        if (widget.focusNode.hasFocus) {
          print('-------------------focusNode---focusNode----focusNode--focusNode');
          widget.focusNode.unfocus();
        }
      });
    });
  }

  //刷新
  _onRefresh() {
    setState(() {
      dataPage = 1;
      _lastTime = null;
    });
    _getSearchUser(lastString);
  }

  //加载
  _onLoading() {
    setState(() {
      dataPage += 1;
    });
    _getSearchUser(lastString);
  }

  //获取搜索列表的方法
  _getSearchUser(String text) async {
    if (dataPage > 1 && hashNext == 0) {
      print('=============================退出请求');
      _refreshController.loadComplete();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户接口============================');
    SearchUserModel model = await ProfileSearchUser(text, 15, lastTime: _lastTime, token: token);
    if (dataPage == 1) {
      _refreshController.loadComplete();
      _refreshController.isRefresh;
      if (model != null) {
        hashNext = model.hasNext;
        if (model.list.isNotEmpty) {
          noData = false;
          modelList.clear();
          _lastTime = model.lastTime;
            print('===================== =============model有值');
            model.list.forEach((element) {
              print('model================ ${element.relation}');
              modelList.add(element);
              try {
                if (context.read<UserInteractiveNotifier>().value.profileUiChangeModel.containsKey(element.uid)) {
                  context
                      .read<UserInteractiveNotifier>()
                      .changeIsFollow(mounted, element.relation == 0 || element.relation == 2, element.uid);
                } else {
                  context.read<UserInteractiveNotifier>().setFirstModel(element.uid,
                      isFollow: element.relation == 0 || element.relation == 2, needNotify: mounted);
                }
              } catch (e) {
                print('----UserInteractiveNotifier------------error:$e');
              }
            });
        } else {
          noData = true;
          defaultImage = DefaultImage.nodata;
        }
      } else {
        noData = true;
        defaultImage = DefaultImage.error;
      }
      _refreshController.refreshCompleted();
    } else if (dataPage > 1 && hashNext == 1) {
      _refreshController.isLoading;
      if (model != null && model.list != null) {
        model.list.forEach((element) {
          modelList.add(element);
        });
        hashNext = model.hasNext;
        _lastTime = model.lastTime;
        _refreshController.loadComplete();
      } else {
        _refreshController.loadComplete();
      }
    }
    refreshOver = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !noData
        ? Container(
          color:AppColor.mainBlack ,
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: ScrollConfiguration(
                behavior: OverScrollBehavior(),
                child: SmartRefresher(
                  enablePullUp: true,
                  enablePullDown: true,
                  footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: showNoMore),
                  controller: _refreshController,
                  header: SmartRefresherHeadFooter.init().getHeader(),
                  onRefresh: _onRefresh,
                  onLoading: () {
                    if (modelList != null && modelList.isNotEmpty && dataPage == 1) {
                      setState(() {
                        showNoMore = IntegerUtil.showNoMore(globalKey, lastItemToTop: true);
                      });
                    }
                    _onLoading();
                  },
                  child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      controller: PrimaryScrollController.of(context),
                      // scrollController,
                      itemCount: modelList.length,
                      itemExtent: 58,
                      itemBuilder: (context, index) {
                        return SearchUserItem(
                          globalKey: index == modelList.length - 1 ? globalKey : null,
                          model: modelList[index],
                          width: ScreenUtil.instance.screenWidthDp,
                          type: 1,
                        );
                      }),
                )))
        : Container(
            height: ScreenUtil.instance.height,
            width: ScreenUtil.instance.screenWidthDp,
            color: AppColor.mainBlack,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 224,
                  height: 224,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                const Text("你的放大镜陨落星辰了", style: AppStyle.text1Regular14),
                const Text("换一个试一试", style: AppStyle.text1Regular14),
                const Spacer(),
              ],
            ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//搜索的item
class SearchUserItem extends StatefulWidget {
  UserModel model;
  double width;
  int type;
  GlobalKey globalKey;

  SearchUserItem({this.model, this.width, this.type, this.globalKey});

  @override
  State<StatefulWidget> createState() {
    return _SearchState();
  }
}

class _SearchState extends State<SearchUserItem> {
  bool isFollow = false;

  @override
  void initState() {
    super.initState();
    print('=========================搜索iteminitState${widget.model.uid}');
    if (widget.model.relation == 0 || widget.model.relation == 2) {
      isFollow = false;
    } else if (widget.model.relation == 1 || widget.model.relation == 3) {
      isFollow = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('=========================搜索itembuid${widget.model.uid}');
    return Container(
      key: widget.globalKey != null ? widget.globalKey : null,
      height: 58,
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      color: AppColor.mainBlack,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                jumpToUserProfilePage(context, widget.model.uid,
                    avatarUrl: widget.model.avatarUri, userName: widget.model.nickName);
              },
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        height: 38,
                        width: 38,
                        // maxWidthDiskCache: 150,
                        // maxHeightDiskCache: 150,
                        // 指定缓存宽高
                        memCacheWidth: 150,
                        memCacheHeight: 150,
                        imageUrl: widget.model.avatarUri != null ? FileUtil.getSmallImage(widget.model.avatarUri) : " ",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColor.imageBgGrey,
                        ),
                        errorWidget: (context, url, e) {
                          return Container(
                            color: AppColor.imageBgGrey,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  Center(
                    child: Container(
                      width: widget.width * 0.59,
                      height: 48,
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.model.nickName != null ? widget.model.nickName : " ",
                              style: AppStyle.whiteRegular15,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          widget.model.description != null ? const Spacer() : Container(),
                          //签名
                          widget.model.description != null
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.model.description,
                                    style: AppStyle.text1Regular12,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : Container(
                                  height: 0,
                                ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          const Spacer(),
          FollowButton(
            id: widget.model.uid,
            relation: widget.model.relation,
            buttonType: FollowButtonType.SERCH,
          )
        ],
      ),
    );
  }
}
