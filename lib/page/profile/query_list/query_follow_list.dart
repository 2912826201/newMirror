import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

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
    BuddyListModel model = await GetFollowList(15, uid: widget.userId.toString(), lastTime: _lastTime);
    if (listPage == 1 && _lastTime == null) {
      _refreshController.loadComplete();
      buddyList.clear();
      if (model != null) {
        _lastTime = model.lastTime;
        model.list.forEach((element) {
          buddyList.add(element);
        });
        _refreshController.refreshCompleted();
      } else {
        _refreshController.resetNoData();
      }
      //这是插入的作为话题入口的假数据
      buddyList.insert(0, BuddyModel());
    } else if (listPage > 1 && _lastTime != null) {
      if (model != null) {
        _lastTime = model.lastTime;
        model.list.forEach((element) {
          buddyList.add(element);
        });
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }
    if (mounted) {
      setState(() {});
    }
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

      if (listPage == 1) {
        _refreshController.loadComplete();
        if (model.list.isNotEmpty) {
          print('===================== =============model有值');
          buddyList.clear();
          //这是插入的作为话题入口的假数据
          buddyList.insert(0, BuddyModel());
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
          buddyList.clear();
          buddyList.insert(0, BuddyModel());
          _refreshController.refreshCompleted();
        }
      } else if (listPage > 1 && _lastTime != null) {
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
          _refreshController.loadNoData();
        }
      }
      refreshOver = true;
    setState(() {
    });
    if(buddyList.length>1){
      for(int i = 0;i<buddyList.length;i++){
        context.watch<ProfilePageNotifier>().changeIsFollow(true,
            buddyList[i].relation==0||buddyList[i].relation==2
                ?true:false, buddyList[i].uid);
      }
    }
  }

  ///获取粉丝列表
  _getFansList() async {
    if (listPage > 1 && _lastTime == null) {
      print('===========================接口退回');
      _refreshController.loadNoData();
      return;
    }
    print('====================粉丝页请求接口');
    BuddyListModel model = await GetFansList(_lastTime, 15, uid: widget.userId);

    if (listPage == 1 && _lastTime == null) {
      _refreshController.loadComplete();
      buddyList.clear();
      if (model.list != null) {
        hasNext = model.hasNext;
        _lastTime = model.lastTime;
        print('粉丝数=====================================${model.list.length}');
        model.list.forEach((element) {
          buddyList.add(element);
        });
        print('model粉丝数=====================================${buddyList.length}');
        _refreshController.refreshCompleted();
      } else {
        _refreshController.resetNoData();
      }
    } else if (listPage > 1 && _lastTime != null) {
      print('lastTime================================$_lastTime');
      if (model.list != null) {
        _lastTime = model.lastTime;
        model.list.forEach((element) {
          buddyList.add(element);
        });
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  ///获取关注话题列表
  _getTopicList() async {
    if (listPage > 1 && _lastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    print('====================话题页请求接口');
    TopicListModel model = await GetTopicList(_lastTime, 20, uid: widget.userId);

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
    if (mounted) {
      setState(() {});
    }
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
          _refreshController.resetNoData();
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
    setState(() {
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
    context.read<ProfilePageNotifier>().removeId = null;
    if (widget.userId == context
        .read<ProfileNotifier>()
        .profile
        .uid) {
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
      body:Container(
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

            buddyList.isNotEmpty || topicList.isNotEmpty ? Expanded(
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
                      itemCount: widget.type == 1 || widget.type == 2 ? buddyList.length : topicList.length,
                      itemBuilder: (context, index) {
                        ///type为1,关注
                        if (widget.type == 1) {
                          //index=0的时候展示跳转话题页的item,否则展示关注item
                          if (index == 0) {
                            return InkWell(
                              onTap: () {
                                AppRouter.navigateToQueryFollowList(context, 3, widget.userId);
                              },
                              child: _followTopic(width),
                            );
                          } else {
                            if(!context.watch<ProfilePageNotifier>().profileUiChangeModel.containsKey
                              (buddyList[index].uid)){
                              context.watch<ProfilePageNotifier>().setFirstModel(buddyList[index].uid,
                                  isFollow:buddyList[index].relation==0||buddyList[index].relation==2?true:false);
                            }
                            return !context.watch<ProfilePageNotifier>().profileUiChangeModel[buddyList[index].uid]
                                .isFollow?QueryFollowItem(
                              type: widget.type,
                              buddyModel: buddyList[index],
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf,
                            ):Container();
                          }
                          //type为2的时候展示粉丝
                        } else if (widget.type == 2) {
                          return QueryFollowItem(
                              type: widget.type,
                              buddyModel: buddyList[index],
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf);
                        } else {
                          return QueryFollowItem(
                              type: widget.type,
                              tpcModel: topicList[index],
                              width: width,
                              userId: widget.userId,
                              isMySelf: isMySelf,
                              topicDeleteCallBack: (){
                                print('=========================话题详情返回');
                                if(context.read<ProfilePageNotifier>().removeId!=null){
                                  List<TopicDtoModel> list = [];
                                  topicList.forEach((element) {
                                    if(element.id!=context.read<ProfilePageNotifier>().removeId){
                                      list.add(element);
                                    }
                                  });
                                  topicList.clear();
                                  topicList.addAll(list);
                                  setState(() {
                                  });
                                }
                              },);
                        }
                      })),
            ): Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                    width: 285,
                    height: 285,
                    color: AppColor.bgWhite,
                  ),
                  SizedBox(height: 12,),
                  Text("没有你要的东西,一会儿再来看看吧", style: AppStyle.textHintRegular14,),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      )
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
          Spacer(),
          Image.asset("images/resource/news_icon_arrow-red.png")
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
  QueryFollowItem({this.width, this.buddyModel, this.tpcModel, this.type, this.userId, this.isMySelf,this.topicDeleteCallBack});

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
      height: 58,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
              onTap: () async{
                if (widget.type == 1 || widget.type == 2) {
                  AppRouter.navigateToMineDetail(context, uid);
                } else {
                  TopicDtoModel topicModel = await getTopicInfo(topicId: widget.tpcModel.id);
                  AppRouter.navigateToTopicDetailPage(context, topicModel,isTopicList:true,callback: (result){
                    widget.topicDeleteCallBack();
                  });
                  ///这里处理话题跳转
                }
              },
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: widget.type == 3
                        ? Image.asset("images/resource/searchGroup.png")
                        : ClipOval(
                      child: CachedNetworkImage(
                        height: widget.width * 0.1,
                        width: widget.width * 0.1,
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Image.asset(
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
                      height: 48,
                      child: Column(
                        children: [
                          Spacer(),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userName,
                              style: AppStyle.textMedium15,
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
          FollowButton(
            id:uid,
            isFollow: isFollow,
            isMysList:widget.isMySelf,
            buttonType:widget.type==1
                ?FollowButtonType.FOLLOW
                :widget.type==2
                ?FollowButtonType.FANS
                :FollowButtonType.TOPIC,)
        ],
      ),
    );
  }
}
