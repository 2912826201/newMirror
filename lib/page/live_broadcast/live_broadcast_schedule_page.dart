


import 'dart:math';

import 'package:device_calendar/device_calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/live_broadcast_model.dart';
import 'package:mirror/util/ToastShow.dart';
import 'package:mirror/util/date_util.dart';
import 'package:permission_handler/permission_handler.dart';

/// 直播日程页
class LiveBroadcastSchedulePage extends StatefulWidget {
  LiveBroadcastSchedulePageState createState() => LiveBroadcastSchedulePageState();
}

class LiveBroadcastSchedulePageState extends State<LiveBroadcastSchedulePage> {
  var liveBroadcastList=<LiveBroadcastModel>[];
  var liveBroadcastOldData=<LiveBroadcastModel>[];
  var liveBroadcastNewData=<LiveBroadcastModel>[];
  var selectPosition=0;
  var calendarEvents=<Event>[];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _retrieveCalendarEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions(){
    return Column(
      children: [
        SizedBox(height: 40,),
        _getTitleBar(),
        Expanded(child: SizedBox(
          child: _buildSuggestions1(),
        ))
      ],
    );
  }

  //头部bar
  Widget _getTitleBar(){
    return  Container(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: Stack(
        children: [
          Positioned(child:GestureDetector(
            child:  Container(
              height: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios_rounded,size: 18,)
                ],
              ),
            ),
            onTap: (){
              Navigator.of(context).pop("1");
            },
          ),
            left: 20,),
          Container(
              width: double.infinity,
              child: Container(
                height: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("直播课",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  //判断是否获取网络数据
  Widget _buildSuggestions1(){
    if(liveBroadcastList!=null&&liveBroadcastList.length>0){
      setDataCalendar();
      return _getUi();
    }
    return FutureBuilder<List<LiveBroadcastModel>>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState==ConnectionState.done){
          if(snapshot.hasError){
            return Text("请求错误");
          }else{
            liveBroadcastList=snapshot.data;
            setData();
            setDataCalendar();
            return _getUi();
          }
        }else{
          return UnconstrainedBox(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }


  Widget _getUi(){
    var widgetArray=<Widget>[];
    //头部日历
    widgetArray.add(_getTopCalendar());
    //不能回放的直播课程
    if(liveBroadcastNewData!=null&&liveBroadcastNewData.length>0){
      widgetArray.add(_getLiveBroadcastUI(liveBroadcastNewData));
    }
    //回放的直播课程
    if(liveBroadcastOldData!=null&&liveBroadcastOldData.length>0){
      widgetArray.add(_getOldDataTitle());
      widgetArray.add(_getLiveBroadcastUI(liveBroadcastOldData));
    }
    return SingleChildScrollView(
      child: Column(
        children: widgetArray,
      ),
    );
  }


  Widget _getOldDataTitle(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 20,right: 20,top: 30),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text("今日可回放课程",style: TextStyle(fontSize: 18),),
          ),
          SizedBox(height: 10,),
          Divider(),
        ],
      ),
    );
  }


  //头部日期
  Widget _getTopCalendar(){
    var now = new DateTime.now();
    var calendarWidgetArray=<Widget>[];
    if(selectPosition<0||selectPosition>=7){
      selectPosition=0;
    }
    for(int i=0;i<7;i++){
      var fiftyDaysFromNow = now.add(new Duration(days: i));
      var margin=const EdgeInsets.only(left: 10,right: 10);
      var marginFirst=const EdgeInsets.only(left: 20,right: 10);
      var marginEnd=const EdgeInsets.only(left: 10,right: 20);
      calendarWidgetArray.add(
        GestureDetector(
          child: Container(
            margin: i==0?marginFirst:(i==6?marginEnd:margin),
            width: 50,
            decoration: BoxDecoration(
              color: selectPosition==i?Colors.grey:null,
              border: Border.all(width: 0.5,color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(DateUtil.getDateDayStringJin(fiftyDaysFromNow)),
                Text(DateUtil.getStringWeekDayStartZero(fiftyDaysFromNow.weekday-1)),
              ],
            ),
          ),
          onTap: (){
            selectPosition=i;
            setState(() {
            });
          },
        )
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: calendarWidgetArray,
      ),
    );
  }

  //获取列表ui
  Widget _getLiveBroadcastUI(List<LiveBroadcastModel> liveBroadcastList){
    var imageWidth=120;
    var imageHeight=90;
    var columnArray=<Widget>[];
    for (var value in liveBroadcastList) {
      columnArray.add(
          Container(
            height: imageHeight.toDouble(),
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
            child: Row(
              children: [
                _getItemLeftImageUi(value,imageWidth,imageHeight),
                _getRightDataUi(value,imageWidth,imageHeight),
              ],
            ),
          )
      );
    }

    return Container(
      child: Column(
        children: columnArray,
      ),
    );
  }


  //获取left的图片
  Widget _getItemLeftImageUi(LiveBroadcastModel value,int imageWidth,int imageHeight){
    return Container(
      width: imageWidth.toDouble(),
      child: Stack(
        children: [
          Positioned(
            child: Image.network(value.imageUrl,fit: BoxFit.cover,),
            left: 0,
            top: 0,
          ),
          Positioned(
            child: Container(
              width:  imageWidth.toDouble(),
              padding: const EdgeInsets.only(top: 3,bottom: 3),
              color: Color(0x70999999),
              child: Text(value.startAndEndTime,textAlign: TextAlign.center,),
            ),
            left: 0,
            bottom: 0,
          ),
        ],
      ),
    );
  }

  //获取右边数据的ui
  Widget _getRightDataUi(LiveBroadcastModel value,int imageWidth,int imageHeight){
    return Expanded(
        child: SizedBox(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            height: imageHeight.toDouble(),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(value.title,style: TextStyle(fontSize: 18),),
                ),
                Expanded(child: SizedBox(
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        //数据
                        Expanded(child: SizedBox(
                          child: Container(
                            padding: const EdgeInsets.only(top: 6),
                            width: double.infinity,
                            height: double.infinity,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(value.type),
                                        padding: const EdgeInsets.only(top: 2,bottom: 2,left: 6,right: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(width: 0.5,color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Container(
                                        child: Text("${value.fat}卡"),
                                        padding: const EdgeInsets.only(top: 2,bottom: 2,left: 6,right: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(width: 0.5,color: Colors.black),
                                        ),
                                      ),

                                    ],
                                  ),
                                  top: 0,
                                  left: 0,
                                ),
                                Positioned(
                                  child: Text(value.coachName,style: TextStyle(fontSize: 18),),
                                  bottom: 0,
                                  left: 0,
                                )
                              ],
                            ),
                          ),
                        )),
                        //按钮
                        Container(
                          height: double.infinity,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomStart,
                            children: [
                              GestureDetector(
                                child: Container(
                                  child: Text(value.getGetType(),style:TextStyle(color: Colors.white),),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.only(left: 16,right: 16,top: 4,bottom: 4),
                                ),
                                onTap: (){
                                  onClickItem(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        )
    );
  }

  ///以上ui-------------------------------------------------------
  ///下面是获取数据-------------------------------------------------------
  Future<List<LiveBroadcastModel>> getData() async{
    var liveBroadcastList=<LiveBroadcastModel>[];
    for(int i=0;i<10;i++){
      var liveBroadcast=new LiveBroadcastModel();
      liveBroadcast.title="名字"+(i.toString())*5;
      liveBroadcast.coachName="教练"+(i.toString())*5;
      liveBroadcast.fat=i*5;
      liveBroadcast.id=i*6;
      liveBroadcast.startAndEndTime="18:00-19:00";
      liveBroadcast.type="减脂";
      if(i>4) {
        liveBroadcast.playType = 2;
      }else{
        liveBroadcast.playType = Random().nextInt(3);
      }
      liveBroadcast.imageUrl="https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2623955494.webp";
      liveBroadcastList.add(liveBroadcast);
    }
    return Future.delayed(Duration(seconds: 2),()=>liveBroadcastList);
  }

//设置数据
  void setData(){
    liveBroadcastOldData.clear();
    liveBroadcastNewData.clear();
    for (var value in liveBroadcastList) {
      if(value.playType==2){
        liveBroadcastOldData.add(value);
      }else{
        liveBroadcastNewData.add(value);
      }
    }
  }

//设置数据
  //应该要判断一下时间，以免 id相同 时间不同导致错误的预约
  void setDataCalendar(){
    if(calendarEvents==null||calendarEvents.length<1){
      return;
    }else{
      for(int i=0;i<calendarEvents.length;i++){
        int judge=0;
        for(int j=0;j<liveBroadcastOldData.length;j++){
          judge=0;
          if(liveBroadcastOldData[j].title==calendarEvents[i].title&&
            liveBroadcastOldData[j].coachName==calendarEvents[i].description){
            judge=1;
            liveBroadcastOldData[j].playType=3;
            break;
          }
        }
        if(judge==0) {
          for (int j = 0; j < liveBroadcastNewData.length; j++) {
            judge = 0;
            if (liveBroadcastNewData[j].title==calendarEvents[i].title&&
                liveBroadcastNewData[j].coachName==calendarEvents[i].description) {
              judge = 1;
              liveBroadcastNewData[j].playType = 3;
              break;
            }
          }
        }
      }
    }

    liveBroadcastOldData.clear();
    liveBroadcastNewData.clear();
    for (var value in liveBroadcastList) {
      if(value.playType==2){
        liveBroadcastOldData.add(value);
      }else{
        liveBroadcastNewData.add(value);
      }
    }
  }

  //点击item按钮判断怎么响应
  void onClickItem(LiveBroadcastModel value){
    if(value.playType==1){
      onClickMakeAnAppointment(value);
    }else{
      ToastShow.show("应该跳转界面", context);
    }
  }
  //点击预览
  void onClickMakeAnAppointment(LiveBroadcastModel value) async{
    await [Permission.calendar].request();

    DeviceCalendarPlugin _deviceCalendarPlugin=DeviceCalendarPlugin();

    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if(_calendars==null||_calendars.length<1){
      var result = await _deviceCalendarPlugin.createCalendar("mirror", localAccountName: "mirror——1",);
      if (result.isSuccess) {
        createEvent(result.data,_deviceCalendarPlugin,value);
      } else {
        ToastShow.show("保存错误",context);
      }
    }else{
      createEvent(_calendars[0].id,_deviceCalendarPlugin,value);
    }
  }

  void createEvent(String id,DeviceCalendarPlugin _deviceCalendarPlugin,LiveBroadcastModel value)async{
    Event _event = new Event(id);
    DateTime timedata = new DateTime.now();
    var startTime = timedata.add(new Duration(minutes: 30));
    _event.start = startTime;
    var endTime = startTime.add(new Duration(minutes: 90));
    List<Reminder> _reminders = <Reminder>[];
    _reminders.add(new Reminder(minutes: 15));
    _event.end = endTime;
    _event.title = value.title;
    _event.description = value.coachName;
    _event.reminders=_reminders;
    var createEventResult = await _deviceCalendarPlugin
        .createOrUpdateEvent(_event);
    if (createEventResult.isSuccess) {
      ToastShow.show("成功", context);
      _retrieveCalendarEvents();
    } else {
      ToastShow.show("失败", context);
    }
  }

  //获取所有的记录
  Future _retrieveCalendarEvents() async {
    DeviceCalendarPlugin _deviceCalendarPlugin=DeviceCalendarPlugin();
    final startDate = DateTime.now().add(Duration(days: -30));
    final endDate = DateTime.now().add(Duration(days: 30));
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if(_calendars!=null&&_calendars.length>0){
      var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
          _calendars[0].id,
          RetrieveEventsParams(startDate: startDate, endDate: endDate));
      calendarEvents = calendarEventsResult?.data;
      setState(() {
      });
    }
  }
}
