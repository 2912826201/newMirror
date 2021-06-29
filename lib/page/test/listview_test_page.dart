import 'package:flutter/material.dart';

/// listview_test_page
/// Created by yangjiayi on 2021/6/28.

class ListViewTestPage extends StatefulWidget {
  @override
  _ListViewTestPageState createState() => _ListViewTestPageState();
}

class _ListViewTestPageState extends State<ListViewTestPage> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
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
                color: Colors.primaries[index % Colors.primaries.length],
                child: Text(
                  '$index',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              );
            },
            //itemExtent提高性能
            itemExtent: 80,
            itemCount: 2000,
          ),
          Positioned(
            child: RaisedButton(
              child: Text('滚动到最后'),
              onPressed: () {
                _controller.jumpTo(_controller.position.maxScrollExtent);
              },
            ),
          ),
          Positioned(
            right: 0,
            child: RaisedButton(
              child: Text('滚动到最前'),
              onPressed: () {
                _controller.jumpTo(0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
