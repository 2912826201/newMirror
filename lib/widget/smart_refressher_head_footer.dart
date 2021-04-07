

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
              CupertinoActivityIndicator(),
            ],
          ),
        ),
        complete: Text(""),
        failed: Text(""),
        idleIcon: Container(
          child: Column(
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 6),
              Text("释放刷新"),
            ],
          ),
        ),
        waterDropColor:AppColor.transparent
    );
  }


  getFooter(){
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("上拉加载更多");
        } else if (mode == LoadStatus.loading) {
          body = Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          );
        } else if (mode == LoadStatus.failed) {
          body = Text("上拉加载更多failed");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("上拉加载更多");
        }  else if (mode == LoadStatus.noMore) {
          body = Text("上拉加载更多noMore");
        } else {
          body = Text("上拉加载更多noMore--");
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