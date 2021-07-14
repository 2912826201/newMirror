import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListviewItemPage extends StatefulWidget {
  @override
  _ListviewItemPageState createState() => _ListviewItemPageState();
}

class _ListviewItemPageState extends State<ListviewItemPage> {
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
            itemCount: 100,
          ),
          Positioned(
            child: RaisedButton(
              child: Text('在前面加一个'),
              onPressed: () {
                _controller.jumpTo(_controller.position.maxScrollExtent);
              },
            ),
          ),
          Positioned(
            right: 0,
            child: RaisedButton(
              child: Text('在后面加一个'),
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
