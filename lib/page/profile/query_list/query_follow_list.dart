import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
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

  List<FollowModel> searchModel = [];

  //粉丝的modelList
  List<FansModel> fansList = [];

  //话题的modelList
  List<TopicDtoModel> topicList = [];

  //用于分页加载的page
  int listPage = 1;
  int hasNext = 0;
  RefreshController _refreshController = RefreshController();

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

  ///获取关注列表
  _getFollowList() async {
    if (listPage > 1 && _lastTime == null) {
      print('=============================退出请求');
      _refreshController.loadNoData();
      return;
    }
    print('====================关注页请求接口');
    FollowListModel model = await GetFollowList(15, uid: widget.userId.toString(), lastTime: _lastTime);
    if (listPage == 1 && _lastTime == null) {
      _refreshController.loadComplete();
      followList.clear();
      if (model != null) {
        _lastTime = model.lastTime;
        model.list.forEach((element) {
          followList.add(element);
        });
        _refreshController.refreshCompleted();
      } else {
        _refreshController.resetNoData();
      }
      //这是插入的作为话题入口的假数据
      followList.insert(0, FollowModel());
    } else if (listPage > 1 && _lastTime != null) {
      if (model != null) {
        _lastTime = model.lastTime;
        model.list.forEach((element) {
          followList.add(element);
        });
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }
    setState(() {});
  }

  ///搜索关注用户
  _getSearchUser(String text) async {
    if (listPage > 1 && _lastTime == null) {
      print('=============================退出请求');
      _refreshController.loadNoData();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户接口============================');
    SearchUserModel model = await searchFollowUser(text, 6, uids: widget.userId.toString(), lastTime: _lastTime);
    setState(() {
      if (listPage == 1) {
        _refreshController.loadComplete();
        if (model.list.isNotEmpty) {
          print('===================== =============model有值');
          followList.clear();
          //这是插入的作为话题入口的假数据
          followList.insert(0, FollowModel());
          model.list.forEach((element) {
            //因为搜索的model和关注列表的model不一样，用这个model插入一条数据去接得到的数据
            searchModel.clear();
            searchModel.insert(0, FollowModel());
            searchModel.first.uid = element.uid;
            searchModel.first.avatarUri = element.avatarUri;
            searchModel.first.description = element.description;
            searchModel.first.nickName = element.nickName;
            if (element.relation == 0 || element.relation == 2) {
              searchModel.first.isFallow = 0;
            } else {
              searchModel.first.isFallow = 1;
            }
            followList.add(searchModel.first);
          });
          _lastTime = model.lastTime;
          _refreshController.refreshCompleted();
        } else {
          followList.clear();
          followList.insert(0, FollowModel());
        }
      } else if (listPage > 1 && _lastTime != null) {
        if (model.list != null) {
          model.list.forEach((element) {
            searchModel.clear();
            searchModel.insert(0, FollowModel());
            searchModel.first.uid = element.uid;
            searchModel.first.avatarUri = element.avatarUri;
            searchModel.first.description = element.description;
            searchModel.first.nickName = element.nickName;
            if (element.relation == 0 || element.relation == 2) {
              searchModel.first.isFallow = 0;
            } else {
              searchModel.first.isFallow = 1;
            }
            followList.add(searchModel.first);
          });
          _lastTime = model.lastTime;
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
      refreshOver = true;
    });
  }

  ///获取粉丝列表
  _getFansList() async {
    if (listPage > 1 && _lastTime == null) {
      print('===========================接口退回');
      _refreshController.loadNoData();
      return;
    }
    print('====================粉丝页请求接口');
    FansListModel model = await GetFansList(_lastTime, 15, uid: widget.userId);
    setState(() {
      if (listPage == 1 && _lastTime == null) {
        _refreshController.loadComplete();
        fansList.clear();
        if (model.list != null) {
          hasNext = model.hasNext;
          _lastTime = model.lastTime;
          print('粉丝数=====================================${model.list.length}');
          model.list.forEach((element) {
            fansList.add(element);
          });
          print('model粉丝数=====================================${fansList.length}');
          _refreshController.refreshCompleted();
        } else {
          _refreshController.resetNoData();
        }
      } else if (listPage > 1 && _lastTime != null) {
        print('lastTime================================$_lastTime');
        if (model.list != null) {
          _lastTime = model.lastTime;
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
    if (listPage > 1 && _lastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    print('====================话题页请求接口');
    TopicListModel model = await GetTopicList(_lastTime, 20, uid: widget.userId);
    setState(() {
      if (listPage == 1) {
        _refreshController.loadComplete();
        topicList.clear();
        if (model != null) {
          _lastTime = model.lastTime;
          model.list.forEach((element) {
            print('话题名称============================${element.name}');
            topicList.add(element);
          });
          _refreshController.refreshCompleted();
        } else {
          _refreshController.resetNoData();
        }
      } else if (listPage > 1 && _lastTime != null) {
        if (model != null) {
          _lastTime = model.lastTime;
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

  //搜索关注话题
  _getSearchTopic(String text) async {
    if (listPage > 1 && _lastScore == null) {
      print('=============================退出请求');
      _refreshController.loadNoData();
      return;
    }
    refreshOver = false;
    print('====开始请求搜索用户关注话题接口============================');
    TopicListModel model = await searchTopicUser(text, 15, lastScore: _lastScore);
    setState(() {
      if (listPage == 1) {
        _refreshController.loadComplete();
        _refreshController.isRefresh;
        if (model.list.isNotEmpty) {
          topicList.clear();
          print('===================== =============model有值');
          model.list.forEach((element) {
            print('model================ ${element.id}');
            topicList.add(element);
          });
          _lastScore = model.lastScore;
          _refreshController.refreshCompleted();
        } else {
          topicList.clear();
        }
      } else if (listPage > 1 && _lastScore != null) {
        _refreshController.isLoading;
        if (model.list != null) {
          model.list.forEach((element) {
            topicList.add(element);
          });
          _lastScore = model.lastScore;
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
      refreshOver = true;
    });
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

  @override
  void initState() {
    super.initState();
    if (widget.userId == context.read<ProfileNotifier>().profile.uid) {
      isMySelf = true;
    } else {
      isMySelf = false;
    }
    __onRefresh();

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
              child: SmartRefresher(
                  controller: _refreshController,
                  enablePullUp: true,
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
                          ? followList.length
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
                              followModel: followList[index],
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
                              fansModel: fansList[index],
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf);
                        } else {
                          return QueryFollowItem(
                              type: widget.type,
                              pc: widget.pc,
                              tpcModel: topicList[index],
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
  FollowModel followModel;

  //粉丝的modelList
  FansModel fansModel;

  //话题的modelList
  TopicDtoModel tpcModel;
  double width;
  PanelController pc;

  int userId;
  bool isMySelf;

  QueryFollowItem(
      {this.width, this.fansModel, this.followModel, this.tpcModel, this.type, this.pc, this.userId, this.isMySelf});

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
  bool haveIntroduction = true;

  bool isFollow = false;

  bool isCanOnclick;

  String avatarUrl;

  int uid;

  String userName;

  String description;

  ///这是关注按钮
  _getAttention(int id) async {
    int attntionResult = await ProfileAddFollow(id);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      ToastShow.show(msg: "关注成功!", context: context);
      if (widget.type == 1) {
        setState(() {
          widget.followModel.isFallow = 1;
        });
      } else {
        setState(() {
          widget.fansModel.isFallow = 1;
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
              widget.followModel.isFallow = 0;
            });
          } else {
            setState(() {
              widget.fansModel.isFallow = 0;
            });
          }
        } else if (relation == 1 || relation == 3) {
          if (widget.type == 1) {
            setState(() {
              widget.followModel.isFallow = 1;
            });
          } else {
            setState(() {
              widget.fansModel.isFallow = 1;
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
      avatarUrl = widget.followModel.avatarUri;
      uid = widget.followModel.uid;
      userName = widget.followModel.nickName;
      description = widget.followModel.description;
      if (widget.followModel.isFallow == 0 || widget.followModel.isFallow == 2) {
        isFollow = false;
      } else {
        isFollow = true;
      }
      if (widget.isMySelf) {
        ///自己的关注列表是没有按钮的
        isCanOnclick = false;
      } else {
        ///别人的关注列表如果有自己也不显示按钮  粉丝列表同理
        if (widget.followModel.uid == context.watch<ProfileNotifier>().profile.uid) {
          isCanOnclick = false;
        } else {
          isCanOnclick = true;
        }
      }

      ///判断是否有签名，好改变布局
      if (widget.followModel.description != null) {
        haveIntroduction = true;
      } else {
        haveIntroduction = false;
      }
    } //粉丝列表
    else if (widget.type == 2) {
      avatarUrl = widget.fansModel.avatarUri;
      uid = widget.fansModel.uid;
      userName = widget.fansModel.nickName;
      description = widget.fansModel.description;
      if (widget.fansModel.description != null) {
        haveIntroduction = true;
      } else {
        haveIntroduction = false;
      }

      if (widget.fansModel.uid == context.watch<ProfileNotifier>().profile.uid) {
        isCanOnclick = false;
      } else {
        isCanOnclick = true;
      }
      if (widget.fansModel.remarkName != null) {
        haveRemarks = true;
      } else {
        haveRemarks = false;
      }
      if (widget.fansModel.isFallow == 0 || widget.fansModel.isFallow == 2) {
        isFollow = false;
      } else {
        isFollow = true;
      }
    } else {
      userName = "#${widget.tpcModel.name}";
      description = widget.tpcModel.description;
      isCanOnclick = false;
      haveRemarks = false;
    }
    return Container(
      height: haveRemarks ? 78 : 58,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              if (widget.type == 1 || widget.type == 2) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return ProfileDetailPage(
                    userId: uid,
                  );
                })).then((value) {
                  ///这里每次回来都去请求一遍用户关系,改变按钮状态
                  if (widget.type == 1) {
                    if (isCanOnclick) {
                      _getUserInfo(id: widget.followModel.uid);
                    }
                  } else {
                    _getUserInfo(id: widget.fansModel.uid);
                  }
                });
              } else {
                ///这里处理话题跳转
              }
            },
            child:  Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child:  widget.type == 3
                      ? Image.asset("images/resource/searchGroup.png")
                      : ClipOval(
                          child: CachedNetworkImage(
                            height: widget.width * 0.1,
                            width: widget.width * 0.1,
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                              "images/test.png",
                              fit: BoxFit.cover,
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
                      Spacer(),
                       Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            haveRemarks ? widget.fansModel.remarkName : userName,
                            style: AppStyle.textMedium15,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Spacer(),
                      haveRemarks
                          ?  Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "昵称:${widget.fansModel.nickName}",
                                  style: AppStyle.textSecondaryRegular12,
                                ),
                              )
                          : Container(),
                      Spacer(),
                      haveIntroduction
                          ? Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  description != null ? description : " ",
                                  style: AppStyle.textSecondaryRegular12,
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
              ),
            ],
          )),
          Spacer(),
          isCanOnclick
              ? InkWell(
                  onTap: () {
                    if (widget.type == 1) {
                      if (!isFollow) {
                        _getAttention(widget.followModel.uid);
                      }
                    } else {
                      if (!isFollow) {
                        _getAttention(widget.fansModel.uid);
                      }
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 24,
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: !isFollow ? AppColor.textPrimary1 : AppColor.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      border: Border.all(width: !isFollow ? 0.5 : 0.0),
                    ),
                    child: Center(
                      child: Text(!isFollow ? "关注" : "已关注",
                          style: !isFollow ? AppStyle.whiteRegular12 : AppStyle.textSecondaryRegular12),
                    ),
                  ))
              : Container(),
        ],
      ),
    );
  }
}