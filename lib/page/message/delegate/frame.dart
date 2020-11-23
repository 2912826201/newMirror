

import 'package:flutter/material.dart';

import 'content_generate.dart';
//消息页面的基础架构
abstract class MPBasements{
  MPDataSourceProxy  dataSource;
  MPUiProxy uiProvider;
  //用于反馈的作用，例如执行某种操作之后，需要产生手机振动等效果时调取此函数，称为向消息版块"feedBack"
  void  feedBackForSys();
}