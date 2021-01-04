import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchUser extends StatefulWidget {
  String text;
  double width;
  TextEditingController textController;
  PanelController pc;
  SearchUser({this.text, this.width, this.textController,this.pc});

  @override
  State<StatefulWidget> createState() {
    return searchUserState();
  }
}

class searchUserState extends State<SearchUser> {
  List<UserModel> modelList = [];
  bool isFollow = false;
  int _lastTime = 0;
  int hashNext;
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  int dataPage = 1;
  RefreshController _refreshController = new RefreshController();
  bool noData = false;
  bool refreshOver = false;
  String lastString;

  @override
  void initState() {
    super.initState();
    lastString = widget.text;
    _getSearchUser(lastString);
    widget.textController.addListener(() {
      if (refreshOver) {
        setState(() {
          dataPage = 1;
          _lastTime = null;
          lastString = widget.textController.text;
        });
        _getSearchUser(lastString);
      }
    });
  }

  _onRefresh() {
    setState(() {
      dataPage = 1;
      _lastTime = null;
    });
    _getSearchUser(lastString);
  }

  _onLoading() {
    setState(() {
      dataPage += 1;
    });
    _getSearchUser(lastString, lastTime: _lastTime);
  }

  _getSearchUser(String text, {int lastTime}) async {
    if (dataPage > 1 && lastTime == null) {
      print('=============================退出请求');
      _refreshController.loadNoData();
      return;
    }
    refreshOver = false;
    print('开始请求接口================================');
    SearchUserModel model = await ProfileSearchUser(text, 20, lastTime: lastTime);
    setState(() {
      if (dataPage == 1) {
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
            if (model.hasNext == 0) {
              _refreshController.loadNoData();
            }
            _refreshController.refreshToIdle();
          }
        } else {
          noData = true;
        }
      } else if (dataPage > 1 && lastTime != null) {
        _refreshController.isLoading;
        if (model.list != null) {
          model.list.forEach((element) {
            modelList.add(element);
          });
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      }
      lastTime = model.lastTime;
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
                    return _item(index);
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

  Widget _item(int index) {
    int relation = modelList[index].relation;
    if (relation == 0 || relation == 2) {
      isFollow = false;
    } else if (relation == 1 || relation == 3) {
      isFollow = true;
    }
    return Container(
      height:58,
      padding: EdgeInsets.only(top: 5,bottom: 5
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child:InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return ProfileDetailPage(userId: modelList[index].uid,pcController: widget.pc,);
                }));
              },
              child:ClipOval(
              child: CachedNetworkImage(
                height: widget.width * 0.1,
                width: widget.width * 0.1,
                imageUrl: modelList[index].avatarUri,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  "images/test.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),),),

          SizedBox(
            width: 11,
          ),
          Center(child: Container(
            width: widget.width * 0.59,
            height: 58,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return ProfileDetailPage(userId: modelList[index].uid,pcController: widget.pc,);
                        }));
                      },
                      child: Text(
                      modelList[index].nickName != null ? modelList[index].nickName : " ",
                      style: AppStyle.textMedium15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),)
                  ),
                ),
                Expanded(
                  flex:modelList[index].description==null?0:1,
                  child: Text(
                    modelList[index].description != null ? modelList[index].description : "",
                    style: AppStyle.textSecondaryRegular12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),),
          Expanded(child: Container()),
          InkWell(
            onTap: (){
              if(isFollow){
                _getAttention(modelList[index].uid);
              }
            },
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
          )),
        ],
      ),
    );
  }
  _getAttention(int id) async {
    int attntionResult = await ProfileAddFollow(id);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1||attntionResult==3) {
      ToastShow.show(msg: "关注成功!", context: context);
      _getSearchUser(lastString);
    }

  }
}
