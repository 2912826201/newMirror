import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EchartsView extends StatefulWidget {
  @override
  EchartsViewState createState() => EchartsViewState();
}

class EchartsViewState extends State<EchartsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Map<String, Object>> _data1 = [];
  List<String> _dataName = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋"];
  List<int> _dataValue = [5, 20, 36, 10, 10];
  int count = 0;

  getData1() async {
    await Future.delayed(Duration(milliseconds: 300));
    count+=1;
    if(count > 5) {
      return;
    }
    List<String> a = ["袜子$count", "WW$count", "EE$count", "RR$count", "哈哈$count"];
    var rng = new Random();//随机数生成类
    List<int> b = [rng.nextInt(100)*count, rng.nextInt(100)*count, rng.nextInt(100)*count, rng.nextInt(100)*count, rng.nextInt(100)*count];
    this.setState(() {
      this._dataName.addAll(a);
      this._dataValue.addAll(b);
    });
  }

  @override
  void initState() {
    super.initState();
    // this.getData1();
  }

  nameToString(List<String> s) {
    String b = "[";
    s.forEach((v) {
      b += "\"";
      b += v;
      b += "\"";
      b += ",";
    });
    String b1 = b.substring(0, b.length - 1);
    b1 += "]";
    return b1;
  }

  valueToString(List<int> f) {
    String b = "[";
    f.forEach((v) {
      b += v.toString();
      b += ",";
    });
    String b1 = b.substring(0, b.length - 1);
    b1 += "]";
    return b1;
  }
  dataZoomToString(List<int> f) {
    String a = "";
    print(f.length);
    a = (100 * (1 - 5 / f.length)).toString();
    print("百分比：：：$a");
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        titleString: "个人体重",
      ),
      backgroundColor: Colors.white,
      body: Container(
          child: Column(
            children: <Widget>[
              Container(
                width:ScreenUtil.instance.width,
                height:CheckPhoneSystemUtil.init().isIos() ? ScreenUtil.instance.height * 0.3 : ScreenUtil.instance.height * 0.4,
                child: Echarts(
                    captureAllGestures: true,
                    option: '''
                  {
                  animation:true,
                  
                    tooltip : { //提示框组件
                      trigger: 'axis',//触发类型,'item'数据项图形触发，主要在散点图，饼图等无类目轴的图表中使用。 'axis'坐标轴触发，主要在柱状图，折线图等会使用类目轴的图表中使用。
                      triggerOn:'click',//提示框触发的条件,'mousemove'鼠标移动时触发。'click'鼠标点击时触发。'mousemove|click'同时鼠标移动和点击时触发。'none'不在 'mousemove' 或 'click' 时触发
                      showContent:true,                           //是否显示提示框浮层
                      alwaysShowContent:false,                     //是否永远显示提示框内容
                      showDelay:0,                                  //浮层显示的延迟，单位为 ms
                      hideDelay:100,                                //浮层隐藏的延迟，单位为 ms
                      // enterable:false,                             //鼠标是否可进入提示框浮层中
                      confine:false,                               //是否将 tooltip 框限制在图表的区域内
                      // transitionDuration:0.4,                      //提示框浮层的移动动画过渡时间，单位是 s,设置为 0 的时候会紧跟着鼠标移动
                      // position:['50%', '50%'],                    //提示框浮层的位置，默认不设置时位置会跟随鼠标的位置,[10, 10],回掉函数，inside鼠标所在图形的内部中心位置，top、left、bottom、right鼠标所在图形上侧，左侧，下侧，右侧，
                      formatter:"{c0}件",     //提示框浮层内容格式器，支持字符串模板和回调函数两种形式,模板变量有 {a}, {b}，{c}，{d}，{e}，分别表示系列名，数据名，数据值等
                      backgroundColor:"#fff",            //标题背景色
                      borderColor:'#FF4059',
                      // "rgba(255, 64, 89, 0.65)",                        //边框颜色
                      borderWidth:1,                              //边框线宽
                      padding:2,                                  //图例内边距，单位px  5  [5, 10]  [5,10,5,10]
                      // textStyle:mytextStyle,     
                      axisPointer: {
                        lineStyle:{
                          color: '#FF4059'
                        }
                      }
                    },
                    xAxis: {
                      inverse:true ,
                      data:${nameToString(_dataName)},
                      axisLine:{ // 去掉坐标x轴
                        show:false
                      },
                      axisTick:{// 去掉坐标轴刻度线
                       show:false
                      },
                    },
                    yAxis: {
                      type: 'value',
                       splitLine: {//坐标轴刻度设置为虚线
                         show: true,
                         lineStyle: {
                          color: '#ccc',
                          type: 'dashed',
                         }
                       },
                    },
                    dataZoom: [{
                          type: 'inside',
                          start: ${dataZoomToString(_dataValue)},
                          show:false,
                          end: 99,
                      },{
                          start: ${dataZoomToString(_dataValue)},
                          end: 99,
                          show:false, // 隐藏外部控制
                      }
                    ],
                    series: [{
                      animation:true,
                      // animationType: 'scale',
                      // animationEasing: 'elasticOut',
                      data: ${valueToString(_dataValue)},
                      type: 'line', // 折线图
                      smooth: true, // 曲线
                      itemStyle : { 
                        normal : {  
                           color:'#FF4059',
                           borderColor:'#FF4059',//拐点边框颜色
                           lineStyle:{  // 线条自定义颜色
                            color:'#FF4059'
                          }  
                        }  
                      },
                      lineStyle:{
                        normal:{
                          width:1,
                        }
                      },
                      areaStyle: { // 区域填充样式
                       color: new echarts.graphic.LinearGradient(0, 0, 0, 1,[{ 
                               offset: 0, color: 'rgba(255,64,89, 0.25)'// 0% 处的颜色 
                              }, {
                               offset: 1, color: 'rgba(255,64,89, 0)' // 100% 处的颜色
                              }, 
                             ]
                       ),
                      },
                      symbolSize:4,// 折线点的大小
                    }]
                  }''',
                    extraScript: '''
                    chart.on( 'datazoom', function (params) {
                    Messager.postMessage(
                    JSON.stringify({
                          // myChart:chart,
                          payload: params,
                        })
                        );
                    });
                  ''',
                    onMessage: (String message) {
                      print("滑动监听");
                      if (message != null && message.length > 0) {
                        Map<String, dynamic> json = jsonDecode(message);
                        // print("控制器：：：：${json['myChart']}");
                        Map<String, dynamic> item = json['payload'];
                        print("${item["batch"].first['end']}");
                        if (item["batch"] != null) {
                          if (item["batch"].first['end'] == 100) {
                            getData1();
                          }
                        }
                      }
                    }),
              ),
            ],
          ),
      ),
    );
  }
}

class EchartsModel {
  PayloadModel payload;

  EchartsModel({
    this.payload,
  });

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["payload"] = payload.toJson();
    return map;
  }

  EchartsModel.fromJson(Map<String, dynamic> json) {
    if (json["payload"] != null) {
      if (json["payload"] is PayloadModel) {
        payload = json["payload"];
      } else {
        payload = PayloadModel.fromJson(json["payload"]);
      }
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class PayloadModel {
  String type;
  List<BatchModel> batch = [];

  PayloadModel({
    this.type,
    this.batch,
  });

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["batch"] = batch;
    return map;
  }

  PayloadModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    if (json["batch"] != null) {
      json["batch"].forEach((v) {
        if (v is BatchModel) {
          batch.add(v);
        } else {
          batch.add(BatchModel.fromJson(v));
        }
      });
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class BatchModel {
  String dataZoomId;
  double start;
  double end;
  String type;

  BatchModel({this.type, this.dataZoomId, this.start, this.end});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["dataZoomId"] = dataZoomId;
    map["start"] = start;
    map["end"] = end;
    return map;
  }

  BatchModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    dataZoomId = json["dataZoomId"];
    start = json["start"];
    end = json["end"];
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
