
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FollowButton extends StatefulWidget {
  UserModel coachDto;
  Function(int attntionResult) onClickAttention;
  Function resetDataListener;

  FollowButton(this.coachDto, this.onClickAttention,this.resetDataListener);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {


  bool isHaveAnimation=false;
  StreamController<TextStyle> streamTextController = StreamController<TextStyle>();
  StreamController<double> streamBtnController = StreamController<double>();

  @override
  void dispose() {
    super.dispose();
    streamTextController.close();
    streamBtnController.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
        initialData: _isFollow()?0.0:1.0,
        stream: streamBtnController.stream,
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if(snapshot.data<=0||snapshot.data>1){
            return Container();
          }
          return AnimatedOpacity(
            opacity: snapshot.data,
            duration: Duration(milliseconds: 1000),
            child: getButton(),
          );
        });
  }


  Widget getButton(){
    return GestureDetector(
      onTap: _onClickAttention,
      child: Container(
        color: Colors.transparent,
        height: 48.0,
        padding: EdgeInsets.only(right: 16),
        child: UnconstrainedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              color: AppColor.black,
              child: InkWell(
                splashColor: AppColor.textHint,
                onTap: _onClickAttention,
                child: Container(
                  width: 56.0,
                  height: 24.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: getTextAnimation(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget getTextAnimation(){
    streamTextController = StreamController<TextStyle>();
    return StreamBuilder<TextStyle>(
        initialData: TextStyle(fontSize: 1, color: AppColor.white),
        stream: streamTextController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<TextStyle> snapshot) {
          if(_isFollow()){
            print("22222");
            return AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: snapshot.data,
              child: Text(
                "已关注",
                textAlign: TextAlign.center,
              ),
            );
          }else{
            print("1111111");
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("+", style: TextStyle(color: AppColor.white, fontSize: 15)),
                SizedBox(width: 5),
                Text("关注", style: TextStyle(color: AppColor.white, fontSize: 11)),
              ],
            );
          }
        });
  }



  _onClickAttention(){
    print("点击了关注按钮");
    onClickAttention();
  }


  ///这是关注的方法
  onClickAttention() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    if (!_isFollow()) {
      _checkBlackStatus();
    }
  }

  _checkBlackStatus() async {
    BlackModel blackModel = await ProfileCheckBlack(widget.coachDto.uid);
    if (blackModel != null) {
      print('inThisBlack===================${blackModel.inThisBlack}');
      print('inYouBlack===================${blackModel.inYouBlack}');
      if (blackModel.inYouBlack == 1) {
        ToastShow.show(msg: "关注失败，你已将对方加入黑名单!", context: context);
      } else if (blackModel.inThisBlack == 1) {
        ToastShow.show(msg: "关注失败，你已被对方加入黑名单!", context: context);
      } else {
        _getAttention();
      }
    } else {
      ToastShow.show(msg: "关注失败，请重试!", context: context);
    }
  }

  ///这是关注的方法
  _getAttention() async {
    int attntionResult = await ProfileAddFollow(widget.coachDto.uid);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {

      if(widget.onClickAttention!=null){
        widget.onClickAttention(attntionResult);
      }

      widget.coachDto.relation=attntionResult;
      // isHaveAnimation=true;
      streamTextController.sink.add(TextStyle(color: AppColor.white, fontSize: 1));
      Future.delayed(Duration(milliseconds: 200),(){
        streamTextController.sink.add(TextStyle(color: AppColor.white, fontSize: 11));
        streamBtnController.sink.add(0.01);
        Future.delayed(Duration(seconds: 1),(){
          streamBtnController.sink.add(0.0);
        });
      });
    }else{
      ToastShow.show(msg: "关注失败，请重试!", context: context);
    }
  }


  bool isOfflineBool = false;

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (isOfflineBool) {
        isOfflineBool = false;
        if(widget.resetDataListener!=null){
          widget.resetDataListener();
        }
      }
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (isOfflineBool) {
        isOfflineBool = false;
        if(widget.resetDataListener!=null){
          widget.resetDataListener();
        }
      }
      return false;
    } else {
      isOfflineBool = true;
      return true;
    }
  }

  bool _isFollow(){
    bool isFollow;
    if (widget.coachDto != null && widget.coachDto.relation != null) {
      isFollow = widget.coachDto.relation == 1 || widget.coachDto.relation == 3;
    } else {
      isFollow = false;
    }
    print("isFollow:$isFollow");
    return isFollow;
  }
}
