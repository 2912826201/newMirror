
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'live_room_test_page_1.dart';

class LiveRoomTestPage extends StatefulWidget {
  @override
  _LiveRoomTestPageState createState() => _LiveRoomTestPageState();
}

class _LiveRoomTestPageState extends State<LiveRoomTestPage> {
  List<Widget> textArray=[];

  @override
  void initState() {
    super.initState();
    for(int i=0;i<100;i++){
      textArray.add(Text("$i"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.lightBlue,
        child: SingleChildScrollView(
          child: Column(
            children: textArray,
          ),
        ),
      ),
    );
  }
}
