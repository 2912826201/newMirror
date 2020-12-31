import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/fans_list_model.dart';
import 'package:mirror/data/model/profile/follow_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class QueryFollowList extends StatefulWidget {
  PanelController pc;

  //传1为关注，传2为粉丝，3为话题
  int type;
  int userId;

  QueryFollowList({this.type, this.pc, this.userId});

  @override
  State<StatefulWidget> createState() {
    return _queryFollowState();
  }
}

class _queryFollowState extends State<QueryFollowList> {
  TextEditingController controller = TextEditingController();

  //输入框内容
  String editText = "";

  //关注的modelList
  List<FollowModel> followList = [];

  List<fansModel> totalfansModel = [];

  //粉丝的modelList
  List<fansModel> fansList = [];

  //话题的modelList
  List<topicModel> topicList = [];

  //用于分页加载的page
  int page = 1;
  int hasNext = 0;
  RefreshController _refreshController = RefreshController();

  //判断是否有备注
  bool haveRemarks = false;

  //判断是否有简介
  bool haveIntroduction = false;

  bool isMySelf = true;

  bool isCanOnclick = true;

  bool isFollow = false;
  bool isSearch = false;
  int _lastTime;
  int searchHashNext;
  int dataPage = 1;
  bool noData = false;
  bool refreshOver = false;
  String lastString = "";

  ///获取关注列表
  _getFollowList() async {
    print('====================关注页请求接口');
    FollowLsitModel model = await GetFollowList(uid: widget.userId.toString());
    followList.clear();
    if (model != null) {
      if (isSearch) {
        for (int i = 0; i < model.list.length; i++) {
          print('for 循环==================================${model.list[i].nickName} ${model.list[i].description}');
          if (model.list[i].nickName.indexOf(controller.text) != -1) {
            print('匹配==============================${model.list[i].nickName}');
            followList.add(model.list[i]);
          }
        }
      } else {
        model.list.forEach((element) {
          followList.add(element);
        });
      }
      _refreshController.refreshCompleted();
    } else {
      _refreshController.resetNoData();
    }
    followList.insert(0, FollowModel());
    setState(() {});
  }

  ///获取粉丝列表
  _getFansList() async {
    if (page > 1 && hasNext == 0) {
      print('===========================接口退回');
      _refreshController.loadNoData();
      return;
    }
    print('====================粉丝页请求接口');
    FansListModel model = await GetFansList(page, 15, uid: widget.userId);
    setState(() {
      if (page == 1) {
        _refreshController.loadComplete();
        fansList.clear();
        if (model != null) {
          hasNext = model.hasNext;
          print('粉丝数=====================================${model.list.length}');
          model.list.forEach((element) {
            fansList.add(element);
          });
          print('model粉丝数=====================================${fansList.length}');
          _refreshController.refreshCompleted();
        } else {
          _refreshController.resetNoData();
        }
      } else if (page > 1 && hasNext != 0) {
        if (model != null) {
          hasNext = model.hasNext;
          model.list.forEach((element) {
            fansList.add(element);
          });
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
    });
  }

  ///获取关注话题列表
  _getTopicList() async {
    if (page > 1 && hasNext == 0) {
      _refreshController.loadNoData();
      return;
    }
    print('====================话题页请求接口');
    TopicListModel model = await GetTopicList(page, 20);
    setState(() {
      if (page == 1) {
        _refreshController.loadComplete();
        topicList.clear();
        if (model != null) {
          hasNext = model.hasNext;
          model.list.forEach((element) {
            topicList.add(element);
          });
          _refreshController.refreshCompleted();
        } else {
          _refreshController.resetNoData();
        }
      } else if (page > 1 && hasNext != 0) {
        if (model != null) {
          hasNext = model.hasNext;
          model.list.forEach((element) {
            topicList.add(element);
          });
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
    });
  }

  //刷新
  __onRefresh() {
    setState(() {
      page = 1;
      isSearch = false;
    });
    if (widget.type == 1) {
      _getFollowList();
    } else if (widget.type == 2) {
      _getFansList();
    } else {
      _getTopicList();
    }
  }

  //加载
  _onLoading() {
    setState(() {
      page += 1;
    });
    if (widget.type == 2) {
      if (isSearch) {
        dataPage += 1;
        /*_getSearchUser(controller.text);*/
      } else {
        _getFansList();
      }
    } else {
      _getTopicList();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userId == context.read<ProfileNotifier>().profile.uid) {
      isMySelf = true;
    } else {
      isMySelf = false;
    }
    __onRefresh();
    lastString = controller.text;
    controller.addListener(() {
      if (controller.text != null) {
        if (lastString != controller.text) {
          if (widget.type == 1) {
            isSearch = true;
            _getFollowList();
          }
          /*else if(widget.type==2){
        dataPage = 1;
        _lastTime = null;
        isSearch = true;
        _getSearchUser(controller.text);
      }*/
          lastString = controller.text;
        }
      } else {
        /*if(widget.type==2){
          _getFansList();
        }*/
      }
    });
  }

  //获取搜索列表的方法
  _getSearchUser(String text) async {
    if (dataPage > 1 && searchHashNext == 0) {
      print('=============================退出请求');
      _refreshController.loadNoData();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户接口============================');
    SearchUserModel model = await ProfileSearchUser(text, 20, lastTime: _lastTime);
    setState(() {
      if (dataPage == 1) {
        _refreshController.loadComplete();
        _refreshController.isRefresh;
        if (model.list.isNotEmpty) {
          print('===================== =============model有值');
          searchHashNext = model.hasNext;
          fansList.clear();
          totalfansModel.clear();
          totalfansModel.insert(0, fansModel());
          for (int i = 0; i < model.list.length; i++) {
            print('searchelement===========${model.list[i].nickName}');
            if (model.list[i].relation == 2 || model.list[i].relation == 3) {
              print('relation=========================${model.list[i].relation}');
              totalfansModel.first.nickName = model.list[i].nickName;
              totalfansModel.first.description = model.list[i].description;
              totalfansModel.first.avatarUri = model.list[i].avatarUri;
              totalfansModel.first.uid = model.list[i].uid;
              if (model.list[i].relation == 2) {
                totalfansModel.first.isFallow = 0;
              } else {
                totalfansModel.first.isFallow = 1;
              }
              fansList.add(totalfansModel.first);
            }
          }
          _lastTime = model.lastTime;
          _refreshController.refreshCompleted();
        }
      } else if (dataPage > 1 && searchHashNext == 1) {
        _refreshController.isLoading;
        if (model.list != null) {
          model.list.forEach((element) {});
          searchHashNext = model.hasNext;
          _lastTime = model.lastTime;
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
      refreshOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    print('这是从个人主页传过来的type================================${widget.type}');
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.white,
          leading: InkWell(
            child: Container(
              margin: EdgeInsets.only(left: 16),
              child: Image.asset("images/resource/2.0x/return2x.png"),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          leadingWidth: 44,
          title: isMySelf
              ? Text(
                  widget.type == 1
                      ? "我的关注"
                      : widget.type == 2
                          ? "我的粉丝"
                          : "我关注的话题",
                  style: AppStyle.textMedium18,
                )
              : Text(
                  widget.type == 1
                      ? "他的关注"
                      : widget.type == 2
                          ? "他的粉丝"
                          : "他关注的话题",
                  style: AppStyle.textMedium18,
                )),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            isMySelf?Container(
              height: 32,
              width: width,
              color: AppColor.bgWhite,
              padding: EdgeInsets.only(left: 12),
              child: Center(
                child: Row(
                  children: [
                    Container(
                      height: 21,
                      width: 21,
                      child: Image.asset("images/resource/Nav_search_icon.png"),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: TextField(
                        cursorColor: AppColor.black,
                        style: AppStyle.textRegular16,
                        controller: controller,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 12),
                          counterText: '',
                          hintText: widget.type == 1
                              ? "搜索用户"
                              : widget.type == 2
                                  ? "搜索用户"
                                  : "搜索",
                          hintStyle: TextStyle(fontSize: 16, color: AppColor.textHint),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ):Container(height: 0,),
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: SmartRefresher(
                  controller: _refreshController,
                  enablePullUp: widget.type == 1 ? false : true,
                  enablePullDown: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.loading) {
                        body = CircularProgressIndicator();
                      } else if (mode == LoadStatus.noMore) {
                        body = Text("没有更多了");
                      } else if (mode == LoadStatus.failed) {
                        body = Text("加载错误,请重试");
                      } else {
                        body = Text(" ");
                      }
                      return Container(
                        child: Center(
                          child: body,
                        ),
                      );
                    },
                  ),
                  header: WaterDropHeader(
                    complete: Text("刷新完成"),
                    failed: Text(" "),
                  ),
                  onRefresh: __onRefresh,
                  onLoading: _onLoading,
                  child: ListView.builder(
                      shrinkWrap: true, //解决无限高度问题
                      physics: AlwaysScrollableScrollPhysics(),
                      //这里是将插入的假数据展示成跳转话题页的item
                      itemCount: widget.type == 1
                          ? followList != null
                              ? followList.length
                              : 1
                          : widget.type == 2
                              ? fansList.length
                              : topicList.length,
                      itemBuilder: (context, index) {
                        ///type为1,关注
                        if (widget.type == 1) {
                          //index=0的时候展示跳转话题页的item,否则展示关注item
                          if (index == 0) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                  return QueryFollowList(
                                    type: 3,
                                    userId: widget.userId,
                                  );
                                }));
                              },
                              child: _followTopic(width),
                            );
                          } else {
                            return QueryFollowItem(
                              type: widget.type,
                              pc: widget.pc,
                              index: index,
                              followList: followList,
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf,
                            );
                          }
                          //type为2的时候展示粉丝
                        } else if (widget.type == 2) {
                          return QueryFollowItem(
                              type: widget.type,
                              pc: widget.pc,
                              index: index,
                              fansList: fansList,
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf);
                        } else {
                          //type为3的时候展示话题
                          return QueryFollowItem(
                              type: widget.type,
                              pc: widget.pc,
                              index: index,
                              topicList: topicList,
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf);
                        }
                      })),
            ),
          ],
        ),
      ),
    );
  }

  //跳转关注话题的item
  Widget _followTopic(double width) {
    return Container(
      height: 48,
      width: width,
      child: Row(
        children: [
          Center(
            child: Image.asset("images/resource/searchGroup.png"),
          ),
          SizedBox(
            width: 21,
          ),
          Text(
            isMySelf ? "这里是我关注的所有话题" : "这里是他关注的所有话题",
            style: AppStyle.textMedium15,
          ),
          Expanded(child: SizedBox()),
          Image.asset("images/resource/news_icon_arrow-red.png")
        ],
      ),
    );
  }
}

class QueryFollowItem extends StatefulWidget {
  int type;

  //关注的modelList
  List<FollowModel> followList = [];

  //粉丝的modelList
  List<fansModel> fansList = [];
  int index;

  //话题的modelList
  List<topicModel> topicList = [];
  double width;
  PanelController pc;

  int userId;
  bool isMySelf;

  QueryFollowItem(
      {this.width,
      this.fansList,
      this.followList,
      this.topicList,
      this.type,
      this.index,
      this.pc,
      this.userId,
      this.isMySelf});

  @override
  State<StatefulWidget> createState() {
    return _followItemState();
  }
}

///粉丝。关注。话题列表的item
class _followItemState extends State<QueryFollowItem> {
  //判断是否有备注
  bool haveRemarks = false;

  //判断是否有简介
  bool haveIntroduction = false;

  bool isFollow = false;

  bool isCanOnclick;

  ///这是关注按钮
  _getAttention(int id) async {
    int attntionResult = await ProfileAddFollow(id);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      ToastShow.show(msg: "关注成功!", context: context);
      if (widget.type == 1) {
        setState(() {
          widget.followList[widget.index].isFallow = 1;
        });
      } else {
        setState(() {
          widget.fansList[widget.index].isFallow = 1;
        });
      }
    }
  }

  ///这是用于用户跳转界面过后返回时去效验用户关系刷新按钮
  _getUserInfo({int id}) async {
    UserModel userModel = await getUserInfo(uid: id);
    if (userModel != null) {
      setState(() {
        int relation = userModel.relation;
        if (relation == 0 || relation == 2) {
          if (widget.type == 1) {
            setState(() {
              widget.followList[widget.index].isFallow = 0;
            });
          } else {
            setState(() {
              widget.fansList[widget.index].isFallow = 0;
            });
          }
        } else if (relation == 1 || relation == 3) {
          if (widget.type == 1) {
            setState(() {
              widget.followList[widget.index].isFallow = 1;
            });
          } else {
            setState(() {
              widget.fansList[widget.index].isFallow = 1;
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState========================initState');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('==================================disPose');
  }

  @override
  Widget build(BuildContext context) {
    print('=====================================item build');
    //关注列表
    if (widget.type == 1) {
      if (widget.followList[widget.index].isFallow == 0 || widget.followList[widget.index].isFallow == 2) {
        isFollow = false;
      } else {
        isFollow = true;
      }
      if (widget.isMySelf) {
        ///自己的关注列表是没有按钮的
        isCanOnclick = false;
      } else {
        ///别人的关注列表如果有自己也不显示按钮  粉丝列表同理
        if (widget.followList[widget.index].uid == context.watch<ProfileNotifier>().profile.uid) {
          isCanOnclick = false;
        } else {
          isCanOnclick = true;
        }
      }

      ///判断是否有签名，好改变布局
      if (widget.followList[widget.index].description != null) {
        haveIntroduction = true;
      } else {
        haveIntroduction = false;
      }
    }//粉丝列表
    else {
      if (widget.fansList[widget.index].description != null) {
        haveIntroduction = true;
      } else {
        haveIntroduction = false;
      }

      if (widget.fansList[widget.index].uid == context.watch<ProfileNotifier>().profile.uid) {
        isCanOnclick = false;
      } else {
        isCanOnclick = true;
      }
      if (widget.fansList[widget.index].remarkName != null) {
        haveRemarks = true;
      } else {
        haveRemarks = false;
      }
      if (widget.fansList[widget.index].isFallow == 0 || widget.fansList[widget.index].isFallow == 2) {
        isFollow = false;
      } else {
        isFollow = true;
      }
    }
    return Container(
      height: haveRemarks ? 78 : 58,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                if (widget.type == 1 || widget.type == 2) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return ProfileDetailPage(
                      userId:
                          widget.type == 1 ? widget.followList[widget.index].uid : widget.fansList[widget.index].uid,
                      pcController: widget.pc,
                    );
                  })).then((value) {
                    ///这里每次回来都去请求一遍用户关系,改变按钮状态
                    if (widget.type == 1) {
                      _getUserInfo(id: widget.followList[widget.index].uid);
                    } else {
                      _getUserInfo(id: widget.fansList[widget.index].uid);
                    }
                  });
                }
              },
              child: widget.type == 3
                  ? Image.asset("images/resource/searchGroup.png")
                  : ClipOval(
                      child: CachedNetworkImage(
                        height: widget.width * 0.1,
                        width: widget.width * 0.1,
                        imageUrl: widget.type == 1
                            ? widget.followList[widget.index].avatarUri
                            : widget.fansList[widget.index].avatarUri,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 11,
          ),
          Center(
            child: Container(
              width: widget.width * 0.59,
              height: haveRemarks ? 68 : 48,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return ProfileDetailPage(
                                userId: widget.type == 1
                                    ? widget.followList[widget.index].uid
                                    : widget.fansList[widget.index].uid,
                                pcController: widget.pc,
                              );
                            })).then((value) {
                              ///这里每次回来都去请求一遍用户关系,改变按钮状态
                              if (widget.type == 1) {
                                _getUserInfo(id: widget.followList[widget.index].uid);
                              } else {
                                _getUserInfo(id: widget.fansList[widget.index].uid);
                              }
                            });
                          },
                          child: Text(
                            haveRemarks
                                ? widget.fansList[widget.index].remarkName
                                : widget.type == 1
                                    ? widget.followList[widget.index].nickName
                                    : widget.fansList[widget.index].nickName,
                            style: AppStyle.textMedium15,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ),
                  haveRemarks
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "昵称:${widget.fansList[widget.index].nickName}",
                              style: AppStyle.textSecondaryRegular12,
                            ),
                          ))
                      : Container(),
                  haveIntroduction
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.type == 1
                                  ? widget.followList[widget.index].description
                                  : widget.type == 2
                                      ? widget.fansList[widget.index].description
                                      : " ",
                              style: AppStyle.textSecondaryRegular12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      : Container(
                          height: 0,
                        )
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
          isCanOnclick
              ? InkWell(
                  onTap: () {
                    if (widget.type == 1) {
                      if (widget.followList[widget.index].isFallow == 0) {
                        _getAttention(widget.followList[widget.index].uid);
                      }
                    } else {
                      if (widget.fansList[widget.index].isFallow == 0) {
                        _getAttention(widget.fansList[widget.index].uid);
                      }
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 24,
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: widget.type == 2
                          ? widget.fansList[widget.index].isFallow == 0
                              ? AppColor.buttonBackground
                              : AppColor.transparent
                          : widget.followList[widget.index].isFallow == 0
                              ? AppColor.buttonBackground
                              : AppColor.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      border: Border.all(
                          width: widget.type == 2
                              ? widget.fansList[widget.index].isFallow == 0
                                  ? 0.5
                                  : 0.0
                              : widget.followList[widget.index].isFallow == 0
                                  ? 0.5
                                  : 0.0),
                    ),
                    child: Center(
                      child: Text(

                          ///是我自己的页面时粉丝页按钮显示回粉已关注关注页不显示按钮，否则则分别判断两个model的状态
                          widget.isMySelf
                              ? widget.fansList[widget.index].isFallow == 0
                                  ? "回粉"
                                  : "已关注"
                              : widget.type == 2
                                  ? widget.fansList[widget.index].isFallow == 0
                                      ? "关注"
                                      : "已关注"
                                  : widget.followList[widget.index].isFallow == 0
                                      ? "关注"
                                      : "已关注",
                          style: widget.type == 2
                              ? widget.fansList[widget.index].isFallow == 0
                                  ? AppStyle.textButtonwhite
                                  : AppStyle.textSecondaryRegular12
                              : widget.followList[widget.index].isFallow == 0
                                  ? AppStyle.textButtonwhite
                                  : AppStyle.textSecondaryRegular12),
                    ),
                  ))
              : Container(),
        ],
      ),
    );
  }
}
