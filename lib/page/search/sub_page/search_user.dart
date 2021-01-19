import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
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

class _SearchUserState extends State<SearchUser> {
  List<UserModel> modelList = [];
  bool isFollow = false;
  int _lastTime;
  int hashNext;
  int dataPage = 1;
  bool noData = false;
  bool refreshOver = false;
  String lastString;
  RefreshController _refreshController = new RefreshController();
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
    setState(() {
      if (dataPage == 1) {
        _refreshController.loadComplete();
        _refreshController.isRefresh;
        if (model.list.isNotEmpty) {
          noData = false;
          if (modelList == model.list) {
            _refreshController.refreshToIdle();
            return;
          } else {
            modelList.clear();
            print('===================== =============model有值');
            hashNext = model.hasNext;
            model.list.forEach((element) {
              print('model================ ${element.nickName}');
              modelList.add(element);
            });
            _lastTime = model.lastTime;
            _refreshController.refreshToIdle();
          }
          _refreshController.refreshCompleted();
        } else {
          noData = true;
        }
      } else if (dataPage > 1 && hashNext == 1) {
        _refreshController.isLoading;
        if (model.list != null) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return !noData
      ? Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: SmartRefresher(
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
              body = Text("");
            }
            return Container(
              child: Center(
                child: body,
              ),
            );
          },
        ),
        controller: _refreshController,
        header: WaterDropHeader(
          complete: Text("刷新完成"),
          failed: Text(""),
        ),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemCount: modelList.length,
          itemBuilder: (context, index) {
            return SearchUserItem(model: modelList[index],  width: widget.width,);
          }),
      ))
      : Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 35),
        child: Center(
          child: Column(
            children: [
              Container(
                height: widget.width * 0.59,
                width: widget.width * 0.59,
                color: AppColor.color246,
              ),
              Center(
                child: Text("你的放大镜陨落星辰了", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
              ),
              Center(
                child: Text("换一个试一试", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
              ),
            ],
          )),
      ));
  }
}
//搜索的item
class SearchUserItem extends StatefulWidget {
  UserModel model;
  double width;

  SearchUserItem({this.model, this.width});

  @override
  State<StatefulWidget> createState() {
    return _SearchState();
  }
}

class _SearchState extends State<SearchUserItem> {
  bool isFollow = false;
  bool isMySelf = false;
    //获取当前item用户的信息
  _getUserInfo({int id}) async {
    UserModel userModel = await getUserInfo(uid: id);
    if (userModel != null) {
      setState(() {
        int relation = userModel.relation;
        if (relation == 0 || relation == 2) {
          setState(() {
            widget.model.relation = 0;
          });

        } else if (relation == 1 || relation == 3) {
           setState(() {
             widget.model.relation = 1;
           });
        }
      });
    }
  }
  @override
  void initState() {
    super.initState();
    if(widget.model.uid==context.read<ProfileNotifier>().profile.uid){
        isMySelf = true;
    }else{
      isMySelf = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    int relation = widget.model.relation;
      if (relation == 0 || relation == 2) {
        isFollow = false;
      } else if (relation == 1 || relation == 3) {
        isFollow = true;
      }
    return Container(
      height: 58,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ProfileDetailPage(
                  userId: widget.model.uid,
                );
              }));
            },
            child: Row(
              children: [
          Container(
            alignment: Alignment.centerLeft,
            child: ClipOval(
                child: CachedNetworkImage(
                  height: 38,
                  width: 38,
                  imageUrl: widget.model.avatarUri,
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
                      child:Text(
                          widget.model.nickName != null
                            ? widget.model.nickName
                            : " ",
                          style: AppStyle.textMedium15,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  widget.model.description != null?Spacer():Container(),
                  //签名
                  widget.model.description != null?Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.model.description,
                        style: AppStyle.textSecondaryRegular12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ):Container(height: 0,),
                  Spacer(),
                ],
              ),
            ),
          ),
          ],)),
          Spacer(),
          !isMySelf?InkWell(
            onTap: () {
                //只有在未关注时点击走方法
              if (!isFollow) {
                _getAttention(widget.model.uid);
              }
            },
            ///按钮
            child: Container(
              width: 56,
              height: 24,
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: !isFollow ? AppColor.textPrimary1 : AppColor.transparent,
                borderRadius: BorderRadius.all(Radius.circular(14)),
                border: Border.all(width: !isFollow ? 0.5 : 0.0, color: AppColor.black),
              ),
              child: Center(
                child: Text(!isFollow ? "关注" : "已关注",
                  style: !isFollow ? AppStyle.whiteRegular12 : AppStyle.textSecondaryRegular12),
              ),
            )):Container()
        ],
      ),
    );
  }

  _getAttention(int id) async {
    int attntionResult = await ProfileAddFollow(id);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      ToastShow.show(msg: "关注成功!", context: context);
      setState(() {
        widget.model.relation = 1;
      });
    }
  }
}
