import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:mirror/widget/pull_to_refresh/pull_to_refresh.dart';

class SearchUser extends StatefulWidget {
  String text;
  double width;

  TextEditingController textController;

  SearchUser({this.text, this.width, this.textController});

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

  @override
  void initState() {
    super.initState();
    lastString = widget.text;
    _getSearchUser(lastString);
    widget.textController.addListener(() {
      if (lastString != widget.textController.text) {
        if (refreshOver) {
          dataPage = 1;
          _lastTime = null;
          lastString = widget.textController.text;
          _getSearchUser(lastString);
        }
      }
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
      _refreshController.loadNoData();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户接口============================');
    SearchUserModel model = await ProfileSearchUser(text, 15, lastTime: _lastTime);
    if (dataPage == 1) {
      _refreshController.loadComplete();
      _refreshController.isRefresh;
      if (model != null) {
        hashNext = model.hasNext;
        if (model.list.isNotEmpty) {
          noData = false;
          modelList.clear();
          _lastTime = model.lastTime;
          if (modelList == model.list) {
            _refreshController.refreshToIdle();
            return;
          } else {
            print('===================== =============model有值');
            model.list.forEach((element) {
              print('model================ ${element.relation}');
              modelList.add(element);
            });
          }
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
        _refreshController.loadNoData();
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
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: ScrollConfiguration(
                behavior: OverScrollBehavior(),
                child: SmartRefresher(
                  enablePullUp: true,
                  enablePullDown: true,
                  footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: false),
                  controller: _refreshController,
                  header: SmartRefresherHeadFooter.init().getHeader(),
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView.builder(
                      itemCount: modelList.length,
                      itemExtent: 58,
                      itemBuilder: (context, index) {
                        return SearchUserItem(
                          model: modelList[index],
                          width: ScreenUtil.instance.screenWidthDp,
                          type: 1,
                        );
                      }),
                )))
        : Container(
            height: ScreenUtil.instance.height,
            width: ScreenUtil.instance.screenWidthDp,
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
                const Text("你的放大镜陨落星辰了", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
                const Text("换一个试一试", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
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

  SearchUserItem({this.model, this.width, this.type});

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
      height: 58,
      padding: const EdgeInsets.only(top: 5, bottom: 5),
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
                          color: AppColor.bgWhite,
                        ),
                        errorWidget: (context, url, e) {
                          return Container(
                            color: AppColor.bgWhite,
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
                              style: AppStyle.textMedium15,
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
                                    style: AppStyle.textSecondaryRegular12,
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
            isFollow: isFollow,
            buttonType: FollowButtonType.SERCH,
            type: widget.type,
          )
        ],
      ),
    );
  }
}
