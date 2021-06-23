

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mirror/constant/color.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SmartRefresherHeadFooter{
  static SmartRefresherHeadFooter _headFooter;

  static SmartRefresherHeadFooter init(){
    if(_headFooter==null){
      _headFooter=SmartRefresherHeadFooter();
    }
    return _headFooter;
  }


  getHeader(){
    return WaterDropHeader(
        refresh: Container(
          child: Column(
            children: [
              SizedBox(height: 20),
              // CupertinoActivityIndicator(),
              Lottie.asset('assets/lottie/loading_refresh_black.json',
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
        complete: Text(""),
        failed: Text(""),
        idleIcon: Container(
          child: Column(
            children: [
              // CupertinoActivityIndicator(),
              Lottie.asset('assets/lottie/loading_refresh_black.json',
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 6),
              Text("释放刷新"),
            ],
          ),
        ),
        waterDropColor:AppColor.transparent
    );
  }


  getFooter({bool isShowNoMore=true,bool isShowAddMore=true}){
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = isShowAddMore?Text("上拉加载更多"):Text("");
        } else if (mode == LoadStatus.loading) {
          body = Lottie.asset('assets/lottie/loading_refresh_black.json',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          );
          // Container(
          //   width: 20,
          //   height: 20,
          //   child: CircularProgressIndicator(),
          // );
        } else if (mode == LoadStatus.failed) {
          body = isShowAddMore?Text("上拉加载更多"):Text("");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("上拉加载更多");
        }  else if (mode == LoadStatus.noMore) {
          body = isShowNoMore?Text("没有更多数据了"):Text("");
        } else {
          body = Text("");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  getFooterContainer(){
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        return Container();
      },
    );
  }

}