import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListviewItemPage extends StatefulWidget {
  @override
  _ListviewItemPageState createState() => _ListviewItemPageState();
}

class _ListviewItemPageState extends State<ListviewItemPage> {
  ScrollController _controller;

  List<int> dataList = [];

  int topValue = -1;
  int bottomValue = 20;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    for (int i = 0; i < 20; i++) {
      dataList.add(i);
    }

    initController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          ListView.builder(
            controller: _controller,
            itemBuilder: (context, index) {
              return Container(
                height: 80,
                alignment: Alignment.center,
                color: Colors.primaries[dataList[index].abs() % Colors.primaries.length],
                child: Text(
                  '${dataList[index]}',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              );
            },
            //itemExtent提高性能
            itemExtent: 80,
            itemCount: dataList.length,
          ),
          Positioned(
            child: RaisedButton(
              child: Text('在前面加一个'),
              onPressed: () {
                double scrollHeight = _controller.position.pixels;
                scrollHeight += 80;
                dataList.insert(0, topValue--);
                setState(() {});
                _controller.jumpTo(scrollHeight);
              },
            ),
          ),
          Positioned(
            right: 0,
            child: RaisedButton(
              child: Text('在后面加一个'),
              onPressed: () {
                dataList.add(bottomValue++);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  initController() {
    _controller.addListener(() {
      // print("_controller.position.pixels:${_controller.position.pixels}");
      // print("_controller.position.maxScrollExtent:${_controller.position.maxScrollExtent}");
    });
  }
}
