import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widget/overscroll_behavior.dart';
import '../profile_detail_page.dart';

class QueryFollowList extends StatefulWidget {
  //传1为关注，传2为粉丝，3为话题
  int type;
  int userId;

  QueryFollowList({this.type, this.userId});


  @override
  State<StatefulWidget> createState() {
    return _QueryFollowState();
  }
}

class _QueryFollowState extends State<QueryFollowList> {
  TextEditingController controller = TextEditingController();

  //输入框内容
  String editText = "";

  //关注的modelList
  List<BuddyModel> buddyList = [];

  List<BuddyModel> searchModel = [];

  //话题的modelList
  List<TopicDtoModel> topicList = [];

  //用于分页加载的page
  int listPage = 1;
  int hasNext = 0;
  RefreshController _refreshController;
  bool fristRequestIsOver = false;

  //判断是否有备注
  bool haveRemarks = false;

  //判断是否有简介
  bool haveIntroduction = false;

  bool isMySelf = true;

  //判断到当前在搜索用户则直接本地用户搜索
  bool isSearch = false;
  int _lastTime;
  double _lastScore;
  int searchHashNext;
  bool refreshOver = true;
  String lastString = "";
  GlobalKey globalKey = GlobalKey();
  String hintText;
  bool showNoMore = true;
  bool idNeedClear = false;
  bool userIdNeedClear = false;
  String defaultImage = DefaultImage.nodata;

  ///获取关注列表
  _getFollowList() async {
    if (listPage > 1 && hasNext == 0) {
      print('=============================退出请求');
      _refreshController.loadComplete();
      return;
    }
    print('====================关注页请求接口');
    BuddyListModel model = await GetFollowList(20, uid: widget.userId.toString(), lastTime: _lastTime);
    if (listPage == 1 && _lastTime == null) {
      _refreshController.loadComplete();
      if (model != null) {
        hasNext = model.hasNext;
        buddyList.clear();
        _lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            buddyList.add(element);
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
          buddyList.add(BuddyModel(uid: -1));
        }
        _refreshController.refreshCompleted();
      } else {
        hintText = "内容君在来的路上出了点状况...";
        defaultImage = DefaultImage.error;
        _refreshController.refreshFailed();
        buddyList.add(BuddyModel(uid: -1));
      }
      //这是插入的作为话题入口的假数据
      buddyList.insert(0, BuddyModel());
      fristRequestIsOver = true;
    } else if (listPage > 1 && _lastTime != null) {
      if (model != null) {
        hasNext = model.hasNext;
        _lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            buddyList.add(element);
          });
          _refreshController.loadComplete();
        } else {
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadFailed();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  ///搜索关注用户
  _getSearchUser(String text) async {
    if (listPage > 1 && hasNext == 0) {
      print('=============================退出请求');
      _refreshController.loadComplete();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户接口============================');
    SearchUserModel model = await searchFollowUser(text, 20, uids: widget.userId.toString(), lastTime: _lastTime);
    if (listPage == 1) {
      _refreshController.loadComplete();
      if (model != null) {
        print('===================== =============model有值');
        buddyList.clear();
        hasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            //因为搜索的model和关注列表的model不一样，用这个model插入一条数据去接得到的数据
            searchModel.clear();
            searchModel.insert(0, BuddyModel());
            searchModel.first.uid = element.uid;
            searchModel.first.avatarUri = element.avatarUri;
            searchModel.first.description = element.description;
            searchModel.first.nickName = element.nickName;
            if (element.relation == 0 || element.relation == 2) {
              searchModel.first.relation = 0;
            } else {
              searchModel.first.relation = 1;
            }
            buddyList.add(searchModel.first);
          });
          _lastTime = model.lastTime;
          _refreshController.refreshCompleted();
        } else {
          buddyList.add(BuddyModel(uid: -1));
        }
      } else {
        buddyList.add(BuddyModel(uid: -1));
      }
      //这是插入的作为话题入口的假数据
      buddyList.insert(0, BuddyModel());
      _refreshController.refreshCompleted();
    } else if (listPage > 1 && _lastTime != null) {
      if (model != null) {
        hasNext = model.hasNext;
        if (model.list != null) {
          model.list.forEach((element) {
            searchModel.clear();
            searchModel.insert(0, BuddyModel());
            searchModel.first.uid = element.uid;
            searchModel.first.avatarUri = element.avatarUri;
            searchModel.first.description = element.description;
            searchModel.first.nickName = element.nickName;
            if (element.relation == 0 || element.relation == 2) {
              searchModel.first.relation = 0;
            } else {
              searchModel.first.relation = 1;
            }
            buddyList.add(searchModel.first);
          });
          _lastTime = model.lastTime;
          _refreshController.loadComplete();
        } else {
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadFailed();
      }
    }
    refreshOver = true;
    setState(() {});
  }

  ///获取粉丝列表
  _getFansList() async {
    if (listPage > 1 && hasNext == 0) {
      print('===========================接口退回');
      _refreshController.loadComplete();
      return;
    }
    print('====================粉丝页请求接口');
    BuddyListModel model = await GetFansList(_lastTime, 15, uid: widget.userId);

    if (listPage == 1 && _lastTime == null) {
      _refreshController.loadComplete();
      if (model != null) {
        if (context.read<UserInteractiveNotifier>().value.fansUnreadCount != 0) {
          context.read<UserInteractiveNotifier>().changeUnreadFansCount(0);
        }
        buddyList.clear();
        hasNext = model.hasNext;
        _lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            buddyList.add(element);
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
        }
        _refreshController.refreshCompleted();
      } else {
        hintText = "内容君在来的路上出了点状况...";
        defaultImage = DefaultImage.error;
        _refreshController.refreshFailed();
      }
      fristRequestIsOver = true;
    } else if (listPage > 1 && _lastTime != null) {
      print('lastTime================================$_lastTime');
      if (model != null) {
        hasNext = model.hasNext;
        _lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            buddyList.add(element);
          });
        } else {
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadFailed();
      }
    } else {
      _refreshController.loadComplete();
    }
    if (mounted) {
      setState(() {});
    }
  }

  ///获取关注话题列表
  _getTopicList() async {
    if (listPage > 1 && hasNext == 0) {
      _refreshController.loadComplete();
      return;
    }
    print('====================话题页请求接口');
    TopicListModel model = await GetTopicList(_lastTime, 20, uid: widget.userId);

    if (listPage == 1) {
      _refreshController.loadComplete();
      if (model != null) {
        hasNext = model.hasNext;
        topicList.clear();
        _lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            print('话题名称============================${element.name}');
            topicList.add(element);
          });
        }
        _refreshController.refreshCompleted();
        fristRequestIsOver = true;
      } else {
        hintText = "内容君在来的路上出了点状况...";
        defaultImage = DefaultImage.error;
        _refreshController.refreshFailed();
      }
    } else if (listPage > 1 && _lastTime != null) {
      if (model != null) {
        hasNext = model.hasNext;
        _lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((element) {
            topicList.add(element);
          });
        }
        _refreshController.loadComplete();
      } else {
        _refreshController.loadFailed();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  //搜索关注话题
  _getSearchTopic(String text) async {
    if (listPage > 1 && hasNext == 0) {
      print('=============================退出请求');
      _refreshController.loadNoData();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户关注话题接口============================');
    TopicListModel model = await searchTopicUser(text, 15, lastScore: _lastScore);
    if (listPage == 1) {
      _refreshController.loadComplete();
      _refreshController.isRefresh;
      if (model != null) {
        hasNext = model.hasNext;
        _lastScore = model.lastScore;
        topicList.clear();
        if (model.list.isNotEmpty) {
          print('===================== =============model有值');
          model.list.forEach((element) {
            print('model================ ${element.id}');
            topicList.add(element);
          });
        }
        _refreshController.refreshCompleted();
      } else {
        hintText = "内容君在来的路上出了点状况...";
        defaultImage = DefaultImage.error;
        _refreshController.refreshFailed();
      }
    } else if (listPage > 1 && _lastScore != null) {
      _refreshController.isLoading;
      if (model != null) {
        hasNext = model.hasNext;
        _lastScore = model.lastScore;
        if (model.list != null) {
          model.list.forEach((element) {
            topicList.add(element);
          });
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadFailed();
      }
    }
    refreshOver = true;
    setState(() {});
  }

  //刷新
  __onRefresh() {
    listPage = 1;
    _lastTime = null;
    if (widget.type == 1) {
      if (controller.text.isNotEmpty) {
        _getSearchUser(controller.text);
      } else {
        _getFollowList();
      }
    } else if (widget.type == 2) {
      _getFansList();
    } else {
      if (controller.text.isNotEmpty) {
        _getSearchTopic(controller.text);
      } else {
        _getTopicList();
      }
    }
  }

  //加载
  _onLoading() {
    listPage += 1;
    if (widget.type == 1) {
      if (controller.text.isNotEmpty) {
        _getSearchUser(controller.text);
      } else {
        _getFollowList();
      }
    } else if (widget.type == 2) {
      _getFansList();
    } else {
      if (controller.text.isNotEmpty) {
        _getSearchTopic(controller.text);
      } else {
        _getTopicList();
      }
    }
  }

  void loginBeforRefreash() {
    print('--------loginBeforRefreash------------loginBeforRefreash----------loginBeforRefreash--');
    if (widget.userId == context.read<ProfileNotifier>().profile.uid) {
      isMySelf = true;
    } else {
      isMySelf = false;
    }
    __onRefresh();
  }

  @override
  void initState() {
    super.initState();
    hintText = "静悄悄的,什么都没有";
    if (context.read<UserInteractiveNotifier>().value.userFollowChangeIdList == null) {
      userIdNeedClear = true;
      context.read<UserInteractiveNotifier>().value.userFollowChangeIdList = [];
    }
    if (context.read<UserInteractiveNotifier>().value.removeId == null) {
      idNeedClear = true;
      context.read<UserInteractiveNotifier>().value.removeId = [];
    }
    EventBus.getDefault().registerNoParameter(loginBeforRefreash, EVENTBUS_FOLLOW_FANS_PAGE,
        registerName: AGAIN_LOGIN_REFREASH_USERPAGE);
    if (widget.userId == context.read<ProfileNotifier>().profile.uid) {
      isMySelf = true;
    } else {
      isMySelf = false;
    }
    _refreshController = RefreshController(initialRefresh: true);
    controller.addListener(() {
      _lastTime = null;
      _lastScore = null;
      listPage = 1;
      if (controller.text.isNotEmpty) {
        print('text===============不为空');
        if (lastString != controller.text) {
          print('text===============改变值');
          if (refreshOver) {
            print('text===============刷新完成');
            if (widget.type == 1) {
              _getSearchUser(controller.text);
            } else {
              _getSearchTopic(controller.text);
            }
          }
        }
      } else {
        if (widget.type == 1) {
          _getFollowList();
        } else {
          _getTopicList();
        }
      }
      lastString = controller.text;
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    if (idNeedClear) {
      context.read<UserInteractiveNotifier>().value.removeId = null;
    }
    if (userIdNeedClear) {
      context.read<UserInteractiveNotifier>().value.userFollowChangeIdList = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    print('这是从个人主页传过来的type================================${widget.type}');
    return Scaffold(
        backgroundColor: AppColor.mainBlack,
        appBar: CustomAppBar(
          titleString: isMySelf
              ? widget.type == 1
                  ? "我的关注"
                  : widget.type == 2
                      ? "我的粉丝"
                      : "我关注的话题"
              : widget.type == 1
                  ? "TA的关注"
                  : widget.type == 2
                      ? "TA的粉丝"
                      : "TA关注的话题",
        ),
        body: Container(
          height: height,
          width: width,
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              //需要显隐的搜索框
              isMySelf && widget.type != 2
                  ? Column(
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          height: 32,
                          width: width,
                          color: AppColor.textFieldwhite10,
                          padding: EdgeInsets.only(left: 12),
                          child: Center(
                            child: Row(
                              children: [
                                AppIcon.getAppIcon(AppIcon.input_search, 21,color: AppColor.white),
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: TextField(
                                    cursorColor: AppColor.black,
                                    style: AppStyle.whiteRegular16,
                                    controller: controller,
                                    maxLines: 1,
                                    inputFormatters: [ExpressionTeamDeleteFormatter()],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(bottom: 12),
                                      counterText: '',
                                      hintText: widget.type == 1
                                          ? "搜索用户"
                                          : widget.type == 2
                                              ? "搜索用户"
                                              : "搜索",
                                      hintStyle: AppStyle.text1Regular16,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    )
                  : Container(
                      height: 0,
                    ),
              Expanded(
                child: ScrollConfiguration(
                    behavior: OverScrollBehavior(),
                    child: SmartRefresher(
                      controller: _refreshController,
                      enablePullUp: true,
                      enablePullDown: true,
                      footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: showNoMore),
                      header: SmartRefresherHeadFooter.init().getHeader(),
                      onRefresh: __onRefresh,
                      onLoading: () {
                        if ((widget.type == 1 && buddyList.length > 2) ||
                            (widget.type == 2 && buddyList.length != 0) ||
                            (widget.type == 3 && topicList.length != 0)) {
                          setState(() {
                            showNoMore = IntegerUtil.showNoMore(globalKey, lastItemToTop: true);
                          });
                        }
                        _onLoading();
                      },
                      child: buddyList.isNotEmpty || topicList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true, //解决无限高度问题
                              physics: AlwaysScrollableScrollPhysics(),
                              addRepaintBoundaries: false,
                              controller: PrimaryScrollController.of(context),
                              addAutomaticKeepAlives: false,
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              //这里是将插入的假数据展示成跳转话题页的item
                              itemCount: widget.type == 1 || widget.type == 2 ? buddyList.length : topicList.length,
                              itemBuilder: (context, index) {
                                ///type为1,关注
                                if (widget.type == 1) {
                                  //index=0的时候展示跳转话题页的item,否则展示关注item
                                  if (index == 0) {
                                    print('-000000000000000000000000000000003');
                                    return InkWell(
                                      onTap: () {
                                        AppRouter.navigateToQueryFollowList(context, 3, widget.userId);
                                      },
                                      child: _followTopic(width),
                                    );
                                  } else {
                                    //这是缺省图，插入了一条id为-1的数据
                                    if (buddyList[index].uid == -1) {
                                      print('-11111111111111111111111111111111');
                                      return Container(
                                        height: ScreenUtil.instance.height,
                                        width: ScreenUtil.instance.screenWidthDp,
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 150,
                                              ),
                                              Container(
                                                width: 285,
                                                height: 285,
                                                child: Image.asset(defaultImage),
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Text(
                                                hintText,
                                                style: AppStyle.textPrimary3Regular14,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    print('22222222222222222222222222222222222222');
                                    return QueryFollowItem(
                                      type: widget.type,
                                      buddyModel: buddyList[index],
                                      width: width,
                                      userId: widget.userId,
                                      isMySelf: isMySelf,
                                      globalKey: index ==
                                              (widget.type == 1 || widget.type == 2
                                                  ? buddyList.length - 1
                                                  : topicList.length - 1)
                                          ? globalKey
                                          : null,
                                      userFollowChangeCallBack: () {
                                        if (context
                                                .read<UserInteractiveNotifier>()
                                                .value
                                                .userFollowChangeIdList
                                                .isNotEmpty &&
                                            widget.userId == context.read<ProfileNotifier>().profile.uid) {
                                          buddyList.removeWhere((element) {
                                            return element.uid != null &&
                                                context
                                                    .read<UserInteractiveNotifier>()
                                                    .value
                                                    .userFollowChangeIdList
                                                    .contains(element.uid);
                                          });
                                          context.read<UserInteractiveNotifier>().value.userFollowChangeIdList = [];
                                          if (buddyList.length == 1) {
                                            if (hasNext == 0) {
                                              buddyList.add(BuddyModel(uid: -1));
                                            } else {
                                              _refreshController.requestLoading();
                                            }
                                          }
                                          setState(() {});
                                        }
                                      },
                                    );
                                  }
                                  //type为2的时候展示粉丝
                                } else if (widget.type == 2) {
                                  return QueryFollowItem(
                                      type: widget.type,
                                      buddyModel: buddyList[index],
                                      width: width,
                                      userId: widget.userId,
                                      isMySelf: isMySelf,
                                      globalKey: index ==
                                              (widget.type == 1 || widget.type == 2
                                                  ? buddyList.length - 1
                                                  : topicList.length - 1)
                                          ? globalKey
                                          : null);
                                } else {
                                  return QueryFollowItem(
                                    type: widget.type,
                                    tpcModel: topicList[index],
                                    width: width,
                                    userId: widget.userId,
                                    isMySelf: isMySelf,
                                    globalKey: index ==
                                            (widget.type == 1 || widget.type == 2
                                                ? buddyList.length - 1
                                                : topicList.length - 1)
                                        ? globalKey
                                        : null,
                                    topicDeleteCallBack: () {
                                      print('=========================话题详情返回');
                                      if (context.read<UserInteractiveNotifier>().value.removeId != null &&
                                          context.read<UserInteractiveNotifier>().value.removeId.isNotEmpty &&
                                          widget.userId == context.read<ProfileNotifier>().profile.uid) {
                                        topicList.removeWhere((element) {
                                          return context
                                              .read<UserInteractiveNotifier>()
                                              .value
                                              .removeId
                                              .contains(element.id);
                                        });
                                        setState(() {});
                                        context.read<UserInteractiveNotifier>().value.removeId = [];
                                      }
                                    },
                                  );
                                }
                              })
                          : fristRequestIsOver
                              ? Container(
                                  height: height,
                                  child: ListView(
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 150,
                                      ),
                                      Center(
                                        child: Container(
                                          width: 285,
                                          height: 285,
                                          child: Image.asset(defaultImage),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Center(
                                        child: Text(
                                          hintText,
                                          style: AppStyle.textHintRegular14,
                                        ),
                                      ),
                                    ],
                                  ))
                              : Container(),
                    )),
              ),
            ],
          ),
        ));
  }

  //跳转关注话题的item
  Widget _followTopic(double width) {
    return Container(
      height: 48,
      width: width,
      child: Row(
        children: [
          ClipOval(child: Container(
            height: 38,
            width: 38,
           color: AppColor.imageBgGrey,
            child: AppIcon.getAppIcon(AppIcon.topic, 24, containerHeight: 38, containerWidth: 38,color: AppColor.white) ,),),
          SizedBox(
            width: 12,
          ),
          Text(
            isMySelf ? "这里是我关注的所有话题" : "这里是TA关注的所有话题",
            style: AppStyle.whiteRegular15,
          ),
          Spacer(),
          AppIcon.getAppIcon(AppIcon.arrow_right_18, 18, color: AppColor.textWhite60),
        ],
      ),
    );
  }
}

typedef DeleteChangedCallback = void Function();

class QueryFollowItem extends StatefulWidget {
  int type;

  //粉丝的modelList
  BuddyModel buddyModel;

  //话题的modelList
  TopicDtoModel tpcModel;
  double width;

  int userId;
  bool isMySelf;
  DeleteChangedCallback topicDeleteCallBack;
  DeleteChangedCallback userFollowChangeCallBack;
  GlobalKey globalKey;

  QueryFollowItem(
      {this.width,
      this.buddyModel,
      this.tpcModel,
      this.type,
      this.userId,
      this.isMySelf,
      this.topicDeleteCallBack,
      this.globalKey,
      this.userFollowChangeCallBack});

  @override
  State<StatefulWidget> createState() {
    return _FollowItemState();
  }
}

///粉丝。关注。话题列表的item
class _FollowItemState extends State<QueryFollowItem> {
  //判断是否有简介
  bool haveIntroduction = false;

  //是否关注
  bool isFollow = false;

  //是否有按钮
  bool isCanOnclick = false;

  String avatarUrl;

  int uid;

  String userName;

  String description;

  @override
  Widget build(BuildContext context) {
    print('=====================================item build');
    //关注和粉丝
    if (widget.type == 1 || widget.type == 2) {
      avatarUrl = widget.buddyModel.avatarUri;
      uid = widget.buddyModel.uid;
      userName = widget.buddyModel.nickName;
      description = widget.buddyModel.description;
      print('user======================================$userName==relation===${widget.buddyModel.relation}');
      if (widget.buddyModel.relation == 0 || widget.buddyModel.relation == 2) {
        isFollow = false;
      } else {
        isFollow = true;
      }

      ///判断是否有签名，好改变布局
      if (widget.buddyModel.description != null) {
        haveIntroduction = true;
      } else {
        haveIntroduction = false;
      }
      //话题列表
    } else {
      userName = "#${widget.tpcModel.name}";
      if (widget.tpcModel.description != null) {
        description = widget.tpcModel.description;
      } else {
        haveIntroduction = false;
      }
    }
    return Container(
      key: widget.globalKey,
      height: 58,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: AppColor.transparent,
              splashColor: AppColor.transparent,
              onTap: () async {
                if (widget.type == 1 || widget.type == 2) {
                  jumpToUserProfilePage(context, uid, avatarUrl: avatarUrl, userName: userName, callback: (result) {
                    if (widget.userFollowChangeCallBack != null) {
                      widget.userFollowChangeCallBack();
                    }
                  });
                } else {
                  AppRouter.navigateToTopicDetailPage(context, widget.tpcModel.id, isTopicList: true,
                      callback: (result) {
                    if (widget.topicDeleteCallBack != null) {
                      widget.topicDeleteCallBack();
                    }
                  });

                  ///这里处理话题跳转
                }
              },
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: widget.type == 3
                        ? ClipOval(child: Container(
                      height: 38,
                      width: 38,
                      color: AppColor.imageBgGrey,
                      child: AppIcon.getAppIcon(AppIcon.topic, 24, containerHeight: 38, containerWidth: 38,color: AppColor.white) ,),)
                        : ClipOval(
                            child: CachedNetworkImage(
                              height: 38,
                              width: 38,
                              memCacheWidth: 150,
                              memCacheHeight: 150,
                              imageUrl: avatarUrl != null ? FileUtil.getSmallImage(avatarUrl) : " ",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColor.bgWhite,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Container(
                    width: ScreenUtil.instance.screenWidthDp - (FollowButton.FOLLOW_BUTTON_WIDTH + 66 + 32),
                    height: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            userName,
                            style: AppStyle.whiteRegular15,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        haveIntroduction ? Spacer() : Container(),
                        haveIntroduction
                            ? Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  description,
                                  style: AppStyle.text1Regular12,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Container(
                                height: 0,
                              ),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              )),
          SizedBox(
            width: 16,
          ),
          widget.type != 3
              ? FollowButton(
                  id: uid,
                  relation: widget.type == 3 ? 0 : widget.buddyModel.relation,
                  isMyList: widget.isMySelf,
                  buttonType: widget.type == 1 ? FollowButtonType.FOLLOW : FollowButtonType.FANS,
                )
              : Container()
        ],
      ),
    );
  }
}
